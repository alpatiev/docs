#!/bin/bash

SSH_LOG_DIR="/var/log"
SSH_LOG_FILES=("auth.log" "auth.log.*" "auth.log.*.gz")
TEMP_FILE=".ssh-temp-batch"
STAMP="[  *  ]"

show_selection() {
  echo "$STAMP Found:"
  i=1
  for ip in "${ips[@]}"; do
    echo "$i) $ip"
    ((i++))
  done
}

extract_entries() {
  > $TEMP_FILE
  for file in "${SSH_LOG_FILES[@]}"; do
    for log in $SSH_LOG_DIR/$file; do
      if [[ -f $log ]]; then
        if [[ $log == *.gz ]]; then
          zgrep 'Accepted' "$log" >> $TEMP_FILE
        else
          grep 'Accepted' "$log" >> $TEMP_FILE
        fi
      fi
    done
  done
}

extract_entries

entries=$(grep 'Accepted' $TEMP_FILE | awk '{print $1, $2, $3, $11, $9}')
ips=($(echo "$entries" | awk '{print $5}' | sort | uniq))

show_selection

while true; do
  read -p "$STAMP Select [1-${#ips[@]}] or [q]: " selection

  if [[ $selection == "q" ]]; then
    rm $TEMP_FILE
    exit 0
  elif [[ $selection -ge 1 && $selection -le ${#ips[@]} ]]; then
    selected_ip=${ips[$((selection-1))]}
    echo "$STAMP Details for entries with $selected_ip:"
    grep "$selected_ip" $TEMP_FILE
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

rm $TEMP_FILE
