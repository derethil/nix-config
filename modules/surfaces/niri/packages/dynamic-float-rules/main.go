// niri-dynamic-float-rules subscribes to niri's event stream and floats
// windows that match a configured rule set the first time they're seen.
//
// Some windows don't have a usable title/app_id at open time and only set
// them after launch (Bitwarden popup inside Firefox is the canonical case),
// which makes niri's built-in `open-floating = true` rule useless. This
// daemon watches for window changes and reacts as soon as the identifiers
// settle.
//
// Match semantics mirror the previous Python implementation:
//   - Match{title, app_id} → both nil = no match; otherwise both populated
//     fields must regex-match (AND within a Match).
//   - Rule.match  → OR across the list. Empty match list means the rule
//     applies to everything (modulo excludes).
//   - Rule.exclude → OR; any hit disqualifies the window.
//   - Once a window has matched once, it's sticky — subsequent events for
//     the same window id don't re-fire the float action even if the window
//     state changes.
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
	"time"
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
	Match   []Match `json:"match"`
	Exclude []Match `json:"exclude"`
	Width   *int    `json:"width,omitempty"`
	Height  *int    `json:"height,omitempty"`
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

// sendAction opens a fresh connection per command (matching the upstream
// Python script) and writes a single JSON action. Niri accepts the command
// without requiring us to read a reply back.
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
	b = append(b, '\n')
	_, err = conn.Write(b)
	return err
}

func actionMoveToFloating(id int) any {
	return map[string]any{"Action": map[string]any{"MoveWindowToFloating": map[string]any{"id": id}}}
}

func actionSetWidth(id, width int) any {
	return map[string]any{"Action": map[string]any{"SetWindowWidth": map[string]any{
		"id":     id,
		"change": map[string]any{"SetFixed": width},
	}}}
}

func actionSetHeight(id, height int) any {
	return map[string]any{"Action": map[string]any{"SetWindowHeight": map[string]any{
		"id":     id,
		"change": map[string]any{"SetFixed": height},
	}}}
}

func actionCenter(id int) any {
	return map[string]any{"Action": map[string]any{"CenterWindow": map[string]any{"id": id}}}
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

// processWindow runs the match-and-act pipeline for a single window event.
// `prev` is the state we knew about the window before this event; the
// returned state is what we should remember next time we see the same id.
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
		fmt.Printf("floating id=%d title=%q app_id=%q\n", w.Id, w.Title, w.AppId)
		if err := sendAction(socketPath, actionMoveToFloating(w.Id)); err != nil {
			fmt.Fprintln(os.Stderr, "MoveWindowToFloating:", err)
		}
		if cur.rule != nil {
			if cur.rule.Width != nil {
				if err := sendAction(socketPath, actionSetWidth(w.Id, *cur.rule.Width)); err != nil {
					fmt.Fprintln(os.Stderr, "SetWindowWidth:", err)
				}
			}
			if cur.rule.Height != nil {
				if err := sendAction(socketPath, actionSetHeight(w.Id, *cur.rule.Height)); err != nil {
					fmt.Fprintln(os.Stderr, "SetWindowHeight:", err)
				}
			}
		}
		// Niri needs a beat to apply the floating + size changes before it
		// can center against the new geometry.
		time.Sleep(50 * time.Millisecond)
		if err := sendAction(socketPath, actionCenter(w.Id)); err != nil {
			fmt.Fprintln(os.Stderr, "CenterWindow:", err)
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
	// WindowsChanged can carry a lot of windows at once; bump the line buffer.
	scanner.Buffer(make([]byte, 64*1024), 16*1024*1024)

	for scanner.Scan() {
		var ev NiriEvent
		if err := json.Unmarshal(scanner.Bytes(), &ev); err != nil {
			continue
		}

		switch {
		case ev.WindowsChanged != nil:
			// Carry forward prior states for windows that still exist; drop
			// the rest. Mirrors the Python behaviour of replacing the
			// tracked map wholesale on WindowsChanged.
			next := map[int]matchedState{}
			for _, w := range ev.WindowsChanged.Windows {
				w := w
				prev := states[w.Id]
				next[w.Id] = processWindow(socketPath, rules, &w, prev)
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
