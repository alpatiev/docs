#!/bin/bash

SSH_LOG_PATH="/var/log/auth.log"
STAMP="[  *  ]"

show_selection() {
  echo "$STAMP Found:"
  i=1
  for ip in "${ips[@]}"; do
    echo "$i) $ip"
    ((i++))
  done
}

entries=$(grep 'Accepted' $SSH_LOG_PATH | awk '{print $1, $2, $3, $11, $9}')
ips=($(echo "$entries" | awk '{print $5}' | sort | uniq))

show_selection

while true; do
  read -p "$STAMP Select [1-${#ips[@]}] or [q]: " selection

  if [[ $selection == "q" ]]; then
    exit 0
  elif [[ $selection -ge 1 && $selection -le ${#ips[@]} ]]; then
    selected_ip=${ips[$((selection-1))]}
    echo "$STAMP Details for entries with $selected_ip:"
    echo "$entries" | grep "$selected_ip"
    read -p "$STAMP Check again [y/n]: " check_again
    if [[ $check_again == "n" ]]; then
      break
    else
      show_selection
    fi
  else
    echo "$STAMP Select from 1 to ${#ips[@]} or 'q' to quit."
  fi
done
