#!/usr/bin/python3
"""
Like open-float, but dynamically. Floats a window when it matches the rules.

Some windows don't have the right title and app-id when they open, and only set
them afterward. This script is like open-float for those windows.

Usage: fill in the RULES array below, then run the script.
"""

from dataclasses import dataclass, field
import json
import os
import re
import time
from socket import AF_UNIX, SHUT_WR, socket


@dataclass(kw_only=True)
class Match:
    title: str | None = None
    app_id: str | None = None

    def matches(self, window):
        if self.title is None and self.app_id is None:
            return False

        matched = True

        if self.title is not None:
            matched &= re.search(self.title, window["title"]) is not None
        if self.app_id is not None:
            matched &= re.search(self.app_id, window["app_id"]) is not None

        return matched


@dataclass
class Rule:
    match: list[Match] = field(default_factory=list)
    exclude: list[Match] = field(default_factory=list)
    width: int | None = None
    height: int | None = None

    def matches(self, window):
        if len(self.match) > 0 and not any(m.matches(window) for m in self.match):
            return False
        if any(m.matches(window) for m in self.exclude):
            return False

        return True


def load_rules_from_config():
    """Load rules from the config file."""
    config_path = os.path.expanduser("~/.config/niri/dynamic-float-rules.json")
    
    if not os.path.exists(config_path):
        print(f"Config file not found: {config_path}")
        return []
    
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        rules = []
        for rule_data in config.get("rules", []):
            match_list = []
            for match_data in rule_data.get("match", []):
                match_list.append(Match(
                    title=match_data.get("title"),
                    app_id=match_data.get("app_id")
                ))
            
            exclude_list = []
            for exclude_data in rule_data.get("exclude", []):
                exclude_list.append(Match(
                    title=exclude_data.get("title"),
                    app_id=exclude_data.get("app_id")
                ))
            
            rule = Rule(
                match=match_list,
                exclude=exclude_list,
                width=rule_data.get("width"),
                height=rule_data.get("height")
            )
            rules.append(rule)
        
        return rules
    except Exception as e:
        print(f"Error loading config: {e}")
        return []


RULES = load_rules_from_config()

if len(RULES) == 0:
    print("No rules found in config file. Please configure ~/.config/niri/dynamic-float-rules.json")
    exit()


niri_socket = socket(AF_UNIX)
niri_socket.connect(os.environ["NIRI_SOCKET"])
file = niri_socket.makefile("rw")

_ = file.write('"EventStream"')
file.flush()
niri_socket.shutdown(SHUT_WR)

windows = {}


def send(request):
    with socket(AF_UNIX) as niri_socket:
        niri_socket.connect(os.environ["NIRI_SOCKET"])
        file = niri_socket.makefile("rw")
        _ = file.write(json.dumps(request))
        file.flush()


def float(id: int):
    send({"Action": {"MoveWindowToFloating": {"id": id}}})


def center_window(id: int):
    send({"Action": {"CenterWindow": {"id": id}}})


def set_window_width(id: int, width: int):
    send({"Action": {"SetWindowWidth": {"id": id, "change": {"SetFixed": width}}}})


def set_window_height(id: int, height: int):
    send({"Action": {"SetWindowHeight": {"id": id, "change": {"SetFixed": height}}}})


def update_matched(win):
    win["matched"] = False
    win["matched_rule"] = None
    if existing := windows.get(win["id"]):
        win["matched"] = existing["matched"]
        win["matched_rule"] = existing.get("matched_rule")

    matched_before = win["matched"]
    matched_rule = None
    for r in RULES:
        if r.matches(win):
            win["matched"] = True
            matched_rule = r
            break

    if win["matched"] and not matched_before:
        print(f"floating title={win['title']}, app_id={win['app_id']}")
        float(win["id"])
        if matched_rule:
            if matched_rule.width:
                set_window_width(win["id"], matched_rule.width)
            if matched_rule.height:
                set_window_height(win["id"], matched_rule.height)
        time.sleep(0.05)
        center_window(win["id"])
        win["matched_rule"] = matched_rule


for line in file:
    event = json.loads(line)

    if changed := event.get("WindowsChanged"):
        for win in changed["windows"]:
            update_matched(win)
        windows = {win["id"]: win for win in changed["windows"]}
    elif changed := event.get("WindowOpenedOrChanged"):
        win = changed["window"]
        update_matched(win)
        windows[win["id"]] = win
    elif changed := event.get("WindowClosed"):
        del windows[changed["id"]]
