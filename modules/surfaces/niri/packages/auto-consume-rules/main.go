// niri-auto-consume-rules watches the niri event stream and consumes newly
// opened windows into an adjacent column (left or right) when they match a
// configured rule. Optionally toggles the column into tabbed display after
// consuming.
//
// Each window is only acted on once — subsequent title/state changes after the
// initial match are ignored.
package main

import (
	"bufio"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"net"
	"os"
	"regexp"
)

type Match struct {
	Title *string `json:"title,omitempty"`
	AppId *string `json:"app_id,omitempty"`

	titleRe *regexp.Regexp
	appIdRe *regexp.Regexp
}

func (m *Match) compile() error {
	if m.Title != nil {
		re, err := regexp.Compile(*m.Title)
		if err != nil {
			return fmt.Errorf("title regex %q: %w", *m.Title, err)
		}
		m.titleRe = re
	}
	if m.AppId != nil {
		re, err := regexp.Compile(*m.AppId)
		if err != nil {
			return fmt.Errorf("app_id regex %q: %w", *m.AppId, err)
		}
		m.appIdRe = re
	}
	return nil
}

func (m *Match) matches(w *Window) bool {
	if m.Title == nil && m.AppId == nil {
		return false
	}
	if m.titleRe != nil && !m.titleRe.MatchString(w.Title) {
		return false
	}
	if m.appIdRe != nil && !m.appIdRe.MatchString(w.AppId) {
		return false
	}
	return true
}

type Rule struct {
	Match     []Match `json:"match"`
	Exclude   []Match `json:"exclude"`
	Direction string  `json:"direction"` // "left" or "right"
}

func (r *Rule) compile() error {
	for i := range r.Match {
		if err := r.Match[i].compile(); err != nil {
			return err
		}
	}
	for i := range r.Exclude {
		if err := r.Exclude[i].compile(); err != nil {
			return err
		}
	}
	return nil
}

func (r *Rule) matches(w *Window) bool {
	if len(r.Match) > 0 {
		anyMatch := false
		for i := range r.Match {
			if r.Match[i].matches(w) {
				anyMatch = true
				break
			}
		}
		if !anyMatch {
			return false
		}
	}
	for i := range r.Exclude {
		if r.Exclude[i].matches(w) {
			return false
		}
	}
	return true
}

type Window struct {
	Id    int    `json:"id"`
	Title string `json:"title"`
	AppId string `json:"app_id"`
}

type WindowOpenedOrChanged struct {
	Window Window `json:"window"`
}

type WindowsChanged struct {
	Windows []Window `json:"windows"`
}

type WindowClosed struct {
	Id int `json:"id"`
}

type NiriEvent struct {
	WindowOpenedOrChanged *WindowOpenedOrChanged `json:"WindowOpenedOrChanged,omitempty"`
	WindowsChanged        *WindowsChanged        `json:"WindowsChanged,omitempty"`
	WindowClosed          *WindowClosed          `json:"WindowClosed,omitempty"`
}

type matchedState struct {
	matched bool
	rule    *Rule
}

func sendAction(socketPath string, payload any) error {
	conn, err := net.Dial("unix", socketPath)
	if err != nil {
		return err
	}
	defer conn.Close()
	b, err := json.Marshal(payload)
	if err != nil {
		return err
	}
	_, err = conn.Write(append(b, '\n'))
	return err
}

func actionConsumeLeft(id int) any {
	return map[string]any{"Action": map[string]any{"ConsumeOrExpelWindowLeft": map[string]any{"id": id}}}
}

func actionConsumeRight(id int) any {
	return map[string]any{"Action": map[string]any{"ConsumeOrExpelWindowRight": map[string]any{"id": id}}}
}

func loadRules(path string) ([]Rule, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var rules []Rule
	if err := json.Unmarshal(raw, &rules); err != nil {
		return nil, err
	}
	for i := range rules {
		if err := rules[i].compile(); err != nil {
			return nil, err
		}
	}
	return rules, nil
}

func processWindow(socketPath string, rules []Rule, w *Window, prev matchedState) matchedState {
	cur := prev
	if !cur.matched {
		for i := range rules {
			if rules[i].matches(w) {
				cur.matched = true
				cur.rule = &rules[i]
				break
			}
		}
	}

	if cur.matched && !prev.matched {
		fmt.Printf("consuming id=%d title=%q app_id=%q direction=%s",
			w.Id, w.Title, w.AppId, cur.rule.Direction)

		var consume any
		if cur.rule.Direction == "right" {
			consume = actionConsumeRight(w.Id)
		} else {
			consume = actionConsumeLeft(w.Id)
		}
		if err := sendAction(socketPath, consume); err != nil {
			fmt.Fprintln(os.Stderr, "consume:", err)
		}

	}

	return cur
}

func main() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Fprintf(os.Stderr, "panic: %v\n", r)
			os.Exit(1)
		}
	}()

	socketPath := os.Getenv("NIRI_SOCKET")
	if socketPath == "" {
		panic(errors.New("NIRI_SOCKET not set"))
	}

	rulesPath := flag.String("rules", "rules.json", "Path to rules JSON")
	flag.Parse()

	rules, err := loadRules(*rulesPath)
	if err != nil {
		panic(err)
	}
	if len(rules) == 0 {
		fmt.Fprintln(os.Stderr, "no rules in config; nothing to do")
		return
	}

	conn, err := net.Dial("unix", socketPath)
	if err != nil {
		panic(err)
	}
	defer conn.Close()

	if _, err := conn.Write([]byte("\"EventStream\"\n")); err != nil {
		panic(err)
	}

	states := map[int]matchedState{}
	scanner := bufio.NewScanner(conn)
	scanner.Buffer(make([]byte, 64*1024), 16*1024*1024)

	for scanner.Scan() {
		var ev NiriEvent
		if err := json.Unmarshal(scanner.Bytes(), &ev); err != nil {
			continue
		}

		switch {
		case ev.WindowsChanged != nil:
			next := map[int]matchedState{}
			for _, w := range ev.WindowsChanged.Windows {
				w := w
				next[w.Id] = processWindow(socketPath, rules, &w, states[w.Id])
			}
			states = next
		case ev.WindowOpenedOrChanged != nil:
			w := ev.WindowOpenedOrChanged.Window
			states[w.Id] = processWindow(socketPath, rules, &w, states[w.Id])
		case ev.WindowClosed != nil:
			delete(states, ev.WindowClosed.Id)
		}
	}

	if err := scanner.Err(); err != nil {
		panic(err)
	}
}
