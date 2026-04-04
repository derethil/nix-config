#!/usr/bin/env bash
# Clean filter for session.json - removes dynamic runtime state before staging

jq 'del(
  .launcherLastMode,
  .launcherLastQuery,
  .launcherQueryHistory,
  .appDrawerLastMode,
  .niriOverviewLastMode,
  .settingsSidebarCollapsedIds,
  .settingsSidebarExpandedIds,
  .recentColors,
  .trayItemOrder,
  .brightnessUserSetValues,
  .deviceMaxVolumes,
  .vpnLastConnected
)'