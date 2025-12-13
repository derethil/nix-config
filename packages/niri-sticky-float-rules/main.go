package main

import (
	"bufio"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"net"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"sync"
)

type Workspace struct {
	Id               int     `json:"id"`
	Idx              int     `json:"idx"`
	Name             *string `json:"name"`
	Output           string  `json:"output"`
	Is_urgent        bool    `json:"is_urgent"`
	Is_active        bool    `json:"is_active"`
	Is_focused       bool    `json:"is_focused"`
	Active_window_id *int    `json:"active_window_id"`
}

type WorkspacesChanged struct {
	Workspaces []Workspace `json:"workspaces"`
}

type WorkspaceActivated struct {
	Id      int  `json:"id"`
	Focused bool `json:"focused"`
}

type WindowClosed struct {
	Id int `json:"id"`
}

type Layout struct {
	PosInScrollingLayout   *[2]float64 `json:"pos_in_scrolling_layout"`
	TileSize               [2]float64  `json:"tile_size"`
	WindowSize             [2]float64  `json:"window_size"`
	TilePosInWorkspaceView [2]float64  `json:"tile_pos_in_workspace_view"`
	WindowOffsetInTile     [2]float64  `json:"window_offset_in_tile"`
}

type FocusTimestamp struct {
	Secs  int `json:"secs"`
	Nanos int `json:"nanos"`
}

type Window struct {
	Id              int            `json:"id"`
	Title           string         `json:"title"`
	AppId           string         `json:"app_id"`
	Pid             int            `json:"pid"`
	WorkspaceId     int            `json:"workspace_id"`
	IsFocused       bool           `json:"is_focused"`
	IsFloating      bool           `json:"is_floating"`
	IsUrgent        bool           `json:"is_urgent"`
	Layout          Layout         `json:"layout"`
	Focus_timestamp FocusTimestamp `json:"focus_timestamp"`
}

type WindowOpenedOrChanged struct {
	Window `json:"window"`
}

type WindowsChanged struct {
	Windows []Window `json:"windows"`
}

type NiriEvent struct {
	*WorkspacesChanged     `json:"WorkspacesChanged"`
	*WorkspaceActivated    `json:"WorkspaceActivated"`
	*WindowClosed          `json:"WindowClosed"`
	*WindowOpenedOrChanged `json:"WindowOpenedOrChanged"`
	*WindowsChanged        `json:"WindowsChanged"`
}

type Reference struct {
	Index int `json:"Index"`
}

type MoveWindowToWorkspace struct {
	WindowId  int       `json:"window_id"`
	Reference Reference `json:"reference"`
	Focus     bool      `json:"focus"`
}
type Action struct {
	MoveWindowToWorkspace MoveWindowToWorkspace
}
type ActionPayload struct {
	Action Action
}

func main() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Fprintf(os.Stderr, "panic:  %v\n", r)
			os.Exit(1)
		}
	}()

	path := os.Getenv("NIRI_SOCKET")
	if path == "" {
		panic(errors.New("Socket not found"))
	}

	configFilePath := flag.String("rules", "rules.json", "Window rules to look for")

	flag.Parse()

	rulesContet, err := os.ReadFile(*configFilePath)
	if err != nil {
		panic(err)
	}

	var rulesToMatch []Rule

	err = json.Unmarshal(rulesContet, &rulesToMatch)
	if err != nil {
		panic(err)
	}

	niriEvents := make(chan string, 1000)
	niriCommands := make(chan string, 1000)

	eventStreamConn, err := net.Dial("unix", path)
	if err != nil {
		panic(err)
	}
	defer eventStreamConn.Close()

	actionsConn, err := net.Dial("unix", path)
	if err != nil {
		panic(err)
	}
	defer actionsConn.Close()

	eventStreamWriter := bufio.NewWriter(eventStreamConn)
	eventStreamReader := bufio.NewReader(eventStreamConn)
	actionsWriter := bufio.NewWriter(actionsConn)
	actionsReader := bufio.NewReader(actionsConn)

	_, err = eventStreamWriter.WriteString("\"EventStream\"\r\n")
	if err != nil {
		panic(err)
	}

	err = eventStreamWriter.Flush()
	if err != nil {
		panic(err)
	}

	// var niriState = NewNiriState(rulesToMatch, niriCommands, cmdTrackChildProcess) //using child process
	var niriState = NewNiriState(rulesToMatch, niriCommands, cmdTrackChannel) //using socket

	var wg sync.WaitGroup
	defer wg.Wait()

	wg.Go(func() {
		for event := range niriEvents {
			err := niriState.processEvent(event)
			if err != nil {
				panic(err)
			}
		}
		close(niriEvents)
	})

	wg.Go(func() {
		for {
			line, err := eventStreamReader.ReadString('\n')
			if err != nil {
				panic(err)
			}
			if line != "" {
				fmt.Println(line)
				niriEvents <- line
			}
		}
	})

	wg.Go(func() {
		for {
			line, err := actionsReader.ReadString('\n')
			if err != nil {
				panic(err)
			}
			if line != "" {
				fmt.Println(line)
				niriEvents <- line
			}
		}
	})

	wg.Go(func() {
		for cmd := range niriCommands {
			fmt.Println(cmd)
			_, err = actionsWriter.WriteString(cmd)
			if err != nil {
				panic(err)
			}
			err = actionsWriter.Flush()
			if err != nil {
				panic(err)
			}
		}
	})
}

type MoveTrackedWindowsCb func(self *NiriState, windowId int, workspaceIdx int) error

type MatchCondition map[string]any

type Rule struct {
	Match   []MatchCondition `json:"match"`
	Exclude []MatchCondition `json:"exclude"`
}

type NiriState struct {
	mu                   sync.Mutex
	Workspaces           []Workspace
	CurrentWorkspaceId   int
	TrackedWindowIds     map[int]bool
	LookupWindowRules    []Rule
	OutChan              chan<- string
	MoveTrackedWindowsCb MoveTrackedWindowsCb
}

func NewNiriState(
	lookupWindowRules []Rule,
	outChan chan<- string,
	moveTrackedWindowsCb MoveTrackedWindowsCb,
) NiriState {
	return NiriState{
		CurrentWorkspaceId:   -1,
		TrackedWindowIds:     map[int]bool{},
		LookupWindowRules:    lookupWindowRules,
		OutChan:              outChan,
		MoveTrackedWindowsCb: moveTrackedWindowsCb,
	}
}

func (s *NiriState) processEvent(evt string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	var data NiriEvent
	err := json.Unmarshal([]byte(evt), &data)
	if err != nil {
		return err
	}

	//Check for wokspaceActivatedEvent
	if data.WorkspacesChanged != nil {
		s.Workspaces = data.WorkspacesChanged.Workspaces
		for _, w := range data.WorkspacesChanged.Workspaces {
			if w.Is_active {
				s.CurrentWorkspaceId = w.Id
			}
		}
	}

	//Check for workspaceChangedEvent
	if data.WorkspaceActivated != nil {
		s.CurrentWorkspaceId = data.WorkspaceActivated.Id

		err := s.moveTrackedToWorkspace(s.CurrentWorkspaceId)
		if err != nil {
			return err
		}
	}

	if data.WindowClosed != nil {
		_, ok := s.TrackedWindowIds[data.WindowClosed.Id]
		if ok {
			delete(s.TrackedWindowIds, data.WindowClosed.Id)
		}
	}

	if data.WindowsChanged != nil {
		for _, w := range data.WindowsChanged.Windows {
			s.processWindow(w)
		}
	}

	if data.WindowOpenedOrChanged != nil {
		txt, err := json.Marshal(data.WindowOpenedOrChanged)
		if err != nil {
			println("error")
			return err
		}
		fmt.Fprintln(os.Stdout, string(txt))
		s.processWindow(data.WindowOpenedOrChanged.Window)
	}

	return nil
}

func (s *NiriState) processWindow(window Window) {
	b, _ := json.Marshal(window)
	m := make(map[string]any)
	json.Unmarshal(b, &m)

	if windowMatchesRules(s.LookupWindowRules, m) {
		s.TrackedWindowIds[window.Id] = true
	} else {
		// Window no longer matches, untrack it
		delete(s.TrackedWindowIds, window.Id)
	}
}

func (s *NiriState) moveTrackedToWorkspace(workspaceId int) error {
	var workspace *Workspace
	for _, w := range s.Workspaces {
		if w.Id == workspaceId {
			workspace = &w
		}
	}
	if workspace == nil {
		return fmt.Errorf("Not tracking workspace with id %d", workspaceId)
	}

	for k := range s.TrackedWindowIds {
		s.MoveTrackedWindowsCb(s, k, workspace.Idx)
	}
	return nil
}

func cmdTrackChildProcess(_ *NiriState, windowId int, workspaceIdx int) error {
	cmd := exec.Command(
		"niri",
		"msg",
		"action",
		"move-window-to-workspace",
		"--window-id", strconv.Itoa(windowId),
		strconv.Itoa(workspaceIdx),
	)

	err := cmd.Run()
	if err != nil {
		return err
	}
	return nil
}

func cmdTrackChannel(s *NiriState, windowId int, workspaceIdx int) error {
	action := ActionPayload{
		Action: Action{
			MoveWindowToWorkspace: MoveWindowToWorkspace{
				WindowId: windowId,
				Reference: Reference{
					Index: workspaceIdx,
				},
				Focus: true,
			},
		},
	}

	payload, err := json.Marshal(action)
	payload = append(payload, '\n')
	if err != nil {
		return err
	}

	s.OutChan <- string(payload)
	return nil
}

func windowMatchesRules(rules []Rule, window map[string]any) bool {
	// Only match floating windows
	isFloating, ok := window["is_floating"].(bool)
	if !ok || !isFloating {
		return false
	}

	for _, rule := range rules {
		// Check if any match condition matches (OR logic)
		matchFound := false
		if len(rule.Match) == 0 {
			// No match conditions means match everything
			matchFound = true
		} else {
			for _, matchCond := range rule.Match {
				if conditionMatches(matchCond, window) {
					matchFound = true
					break
				}
			}
		}

		if !matchFound {
			continue
		}

		// Check if any exclude condition matches (OR logic)
		excluded := false
		for _, excludeCond := range rule.Exclude {
			if conditionMatches(excludeCond, window) {
				excluded = true
				break
			}
		}

		if !excluded {
			return true
		}
	}

	return false
}

func conditionMatches(condition map[string]any, window map[string]any) bool {
	for key, expectedVal := range condition {
		// Skip null values in the condition
		if expectedVal == nil {
			continue
		}

		actualVal, ok := window[key]
		if !ok {
			return false
		}

		// Try regex matching for string values
		if expectedStr, isString := expectedVal.(string); isString {
			actualStr, actualIsString := actualVal.(string)
			if !actualIsString {
				return false
			}

			// Try to compile as regex, fall back to exact match if invalid
			if re, err := regexp.Compile(expectedStr); err == nil {
				if !re.MatchString(actualStr) {
					return false
				}
			} else {
				// Not a valid regex, do exact match
				if expectedVal != actualVal {
					return false
				}
			}
		} else {
			// Non-string values: exact match
			if expectedVal != actualVal {
				return false
			}
		}
	}
	return true
}
