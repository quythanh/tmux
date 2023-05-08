#!/usr/bin/env bash

get_tmux_option() {
  local option value default
  option=$1
  default=$2
  value=$(tmux show-option -gqv "$option")

  if [ -n "$value" ]; then
    echo $value
  else
    echo $default
  fi
}

set() {
  local option=$1
  local value=$2
  tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
  local option=$1
  local value=$2
  tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

# normalize the percentage string to always have a length of 5
normalize_percent_len() {
  # the max length that the percent can reach, which happens for a two digit number with a decimal house: "99.9%"
  max_len=5
  percent_len=${#1}
  let diff_len=$max_len-$percent_len
  # if the diff_len is even, left will have 1 more space than right
  let left_spaces=($diff_len+1)/2
  let right_spaces=($diff_len)/2
  printf "%${left_spaces}s%s%${right_spaces}s\n" "" $1 ""
}
