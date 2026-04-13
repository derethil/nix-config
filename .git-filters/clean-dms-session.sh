#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq

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
  .vpnLastConnected,
  .lastPlayerIdentity
)'
