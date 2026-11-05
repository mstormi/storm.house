#!/usr/bin/env bats

load storm.house.bash
load helpers.bash

# Claude Code für die Fehleranalyse durch den Support (install_claude_code in storm.house.bash)

@test "unit-claude_code_skip_32bit" {
  # auf 32-Bit-Systemen gibt es Claude Code nicht: überspringen, ohne Fehler
  hwarch=armv7l run install_claude_code install
  if [ "$status" -ne 0 ]; then echo "$output" >&3; fi
  [ "$status" -eq 0 ]
  [[ "$output" == *"SKIPPED"* ]]
}

@test "unit-claude_code_disabled" {
  # claudecode=disable in openhabian.conf: in der unbeaufsichtigten Installation nichts installieren
  local home
  home="$(mktemp -d)"
  UNATTENDED=1 claudecode=disable HOME="$home" run install_claude_code install
  if [ "$status" -ne 0 ]; then echo "$output" >&3; fi
  [ "$status" -eq 0 ]
  [[ "$output" == *"SKIPPED"* ]]
  [ ! -e "$home/.local/bin/claude" ]
  rm -rf "$home"
}

@test "destructive-claude_code_install" {
  local user="${username:-openhabian}"
  local home

  echo -e "# ${COL_CYAN}$(timestamp) [openHABian] Claude Code installation starting...${COL_DEF}" >&3
  UNATTENDED=1 run install_claude_code install 3>&-
  if [ "$status" -ne 0 ]; then echo "$output" >&3; fi
  [ "$status" -eq 0 ]
  home="$(getent passwd "$user" | cut -d: -f6)"
  run sudo -u "$user" -H "$home/.local/bin/claude" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"(Claude Code)"* ]]
  echo -e "# ${COL_GREEN}$(timestamp) [openHABian] Claude Code installation successful.${COL_DEF}" >&3

  UNATTENDED=1 run install_claude_code remove 3>&-
  [ "$status" -eq 0 ]
  [ ! -e "$home/.local/bin/claude" ]
}
