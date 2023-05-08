#!/usr/bin/env bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

main() {
  # Aggregate all commands in one array
  local tmux_commands=()

  # NOTE: Pulling in the selected theme by the theme that's being set as local
  # variables.
  # shellcheck source=catppuccin-frappe.tmuxtheme
  source /dev/stdin <<<"$(sed -e "/^[^#].*=/s/^/local /" "${current_dir}/../themes/frappe.tmuxtheme")"

  # status
  set status "on"
  set status-bg "${thm_bg}"
  set status-justify "left"
  set status-left-length "100"
  set status-right-length "100"

  # messages
  set message-style "fg=${thm_cyan},bg=${thm_gray},align=centre"
  set message-command-style "fg=${thm_cyan},bg=${thm_gray},align=centre"

  # panes
  set pane-border-style "fg=${thm_gray}"
  set pane-active-border-style "fg=${thm_blue}"

  # windows
  setw window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
  setw window-status-separator ""
  setw window-status-style "fg=${thm_fg},bg=${thm_bg},none"

  # --------=== Statusline

  # NOTE: Checking for the value of @catppuccin_window_tabs_enabled
  local wt_enabled="$(get_tmux_option "@catppuccin_window_tabs_enabled" "off")"
  local right_separator="$(get_tmux_option "@catppuccin_right_separator" "")"
  local left_separator="$(get_tmux_option "@catppuccin_left_separator" "")"
  local user="$(get_tmux_option "@catppuccin_user" "off")"
  local host="$(get_tmux_option "@catppuccin_host" "off")"
  local date_time="$(get_tmux_option "@catppuccin_date_time" "off")"
  local cpu="$(get_tmux_option "@catppuccin_cpu" "on")"

  # These variables are the defaults so that the setw and set calls are easier to parse.
  local show_directory="#[fg=$thm_pink,bg=$thm_bg,nobold,nounderscore,noitalics]$right_separator#[fg=$thm_bg,bg=$thm_pink,nobold,nounderscore,noitalics]  #[fg=$thm_fg,bg=$thm_gray] #{b:pane_current_path} #{?client_prefix,#[fg=$thm_red]"
  local show_window="#[fg=$thm_pink,bg=$thm_bg,nobold,nounderscore,noitalics]$right_separator#[fg=$thm_bg,bg=$thm_pink,nobold,nounderscore,noitalics] #[fg=$thm_fg,bg=$thm_gray] #W #{?client_prefix,#[fg=$thm_red]"
  local show_session="#[fg=$thm_green]}#[bg=$thm_gray]$right_separator#{?client_prefix,#[bg=$thm_red],#[bg=$thm_green]}#[fg=$thm_bg] #[fg=$thm_fg,bg=$thm_gray] #S "
  local show_directory_in_window_status="#[fg=$thm_bg,bg=$thm_blue] #I #[fg=$thm_fg,bg=$thm_gray] #{b:pane_current_path} "
  local show_directory_in_window_status_current="#[fg=$thm_bg,bg=$thm_orange] #I #[fg=$thm_fg,bg=$thm_bg] #{b:pane_current_path} "
  local show_window_in_window_status="#[fg=$thm_fg,bg=$thm_bg] #W #[fg=$thm_bg,bg=$thm_blue] #I#[fg=$thm_blue,bg=$thm_bg]$left_separator#[fg=$thm_fg,bg=$thm_bg,nobold,nounderscore,noitalics] "
  local show_window_in_window_status_current="#[fg=$thm_fg,bg=$thm_gray] #W #[fg=$thm_bg,bg=$thm_orange] #I#[fg=$thm_orange,bg=$thm_bg]$left_separator#[fg=$thm_fg,bg=$thm_bg,nobold,nounderscore,noitalics] "
  local show_user="#[fg=$thm_blue,bg=$thm_gray]$right_separator#[fg=$thm_bg,bg=$thm_blue] #[fg=$thm_fg,bg=$thm_gray] #(whoami) "
  local show_host="#[fg=$thm_blue,bg=$thm_gray]$right_separator#[fg=$thm_bg,bg=$thm_blue]󰒋 #[fg=$thm_fg,bg=$thm_gray] #H "
  local show_date_time="#[fg=$thm_blue,bg=$thm_gray]$right_separator#[fg=$thm_bg,bg=$thm_blue] #[fg=$thm_fg,bg=$thm_gray] $date_time "
  local show_cpu="#[fg=$thm_yellow,bg=$thm_bg,nobold,nounderscore,noitalics]$right_separator#[fg=$thm_bg,bg=$thm_yellow,nobold,nounderscore,noitalics]CPU #[fg=$thm_fg,bg=$thm_gray] #($current_dir/cpu.sh) "

  # Right column 1 by default shows the Window name.
  local right_column1=$show_window

  # Right column 2 by default shows the current Session name.
  local right_column2=$show_session

  # Window status by default shows the current directory basename.
  local window_status_format=$show_directory_in_window_status
  local window_status_current_format=$show_directory_in_window_status_current

  # NOTE: With the @catppuccin_window_tabs_enabled set to on, we're going to
  # update the right_column1 and the window_status_* variables.
  if [[ "${wt_enabled}" == "on" ]]; then
    right_column1=$show_directory
    window_status_format=$show_window_in_window_status
    window_status_current_format=$show_window_in_window_status_current
  fi

  if [[ "${cpu}" == "on" ]]; then
    right_column2=$right_column2$show_cpu
  fi

  if [[ "${user}" == "on" ]]; then
    right_column2=$right_column2$show_user
  fi

  if [[ "${host}" == "on" ]]; then
    right_column2=$right_column2$show_host
  fi

  if [[ "${date_time}" != "off" ]]; then
    right_column2=$right_column2$show_date_time
  fi

  set status-left ""

  set status-right "${right_column1},${right_column2}"

  setw window-status-format "${window_status_format}"
  setw window-status-current-format "${window_status_current_format}"

  # --------=== Modes
  #
  setw clock-mode-colour "${thm_blue}"
  setw mode-style "fg=${thm_pink} bg=${thm_black4} bold"

  tmux "${tmux_commands[@]}"
}

main "$@"
