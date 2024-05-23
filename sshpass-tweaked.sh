#!/bin/bash

TARGET=""

# If you noticed, the default implementation of sshpass
# does not allow you to use it from an alias.
#
# So, here is a fix:
# 1. Stores credentials in the "TARGET" variable (hardcoded, basically).
# 2. Uses the MacOS pbcopy buffer to execute keystrokes as the next command.
# 3. Now you can log in to your server with a single command.
#
# To download and install, use the following:
# curl -s https://raw.githubusercontent.com/alpatiev/docs/master/sshpass-tweaked.sh | sh -s -- -i
#
# Credits: https://alpatiev.com

exec_target() {
  echo "$TARGET" | pbcopy > /dev/null 2>&1
  osascript -e 'tell application "System Events" to keystroke "v" using command down' > /dev/null 2>&1
}

install_itself() {
  if ! command -v sshpass &> /dev/null; then
    if command -v brew &> /dev/null; then
      brew install sshpass
    else
      exit 1
    fi
  fi
  
  read -p "> Set password: " password
  read -p "> Set user: " user
  read -p "> Set IP: " ip
  read -p "> Set port [default 22]: " port
  read -p "> Set command name: " command_name

  if [[ -z "$password" ]]; then password="YOUR_PASSWORD"; fi
  if [[ -z "$user" ]]; then user="USERNAME"; fi
  if [[ -z "$ip" ]]; then ip="IP"; fi
  if [[ -z "$port" ]]; then port=22; fi
  if [[ -z "$command_name" ]]; then command_name=$(basename "$0" | sed 's/\.sh$//'); fi

  TARGET="sshpass -p \"$password\" ssh -p $port $user@$ip"

  script_path="/usr/local/bin/$command_name"
  sudo mkdir -p /usr/local/bin
  sudo mv "$0" "$script_path"
  sudo chmod +x "$script_path"
  
  sudo sed -i '' "3s|^TARGET=.*|TARGET=\"$TARGET\"|" "$script_path"
  
  local shell_config
  if [ "$SHELL" == "/bin/zsh" ]; then
    shell_config="$HOME/.zshrc"
  else
    shell_config="$HOME/.bashrc"
  fi
  
  echo "" >> "$shell_config"
  echo "# One-liner for sshpass" >> "$shell_config"
  echo "# Source https://github.com/alpatiev/docs" >> "$shell_config"
  echo "alias $command_name='$script_path'" >> "$shell_config"
  source "$shell_config"
}

echo_summary() {
  echo "All set up."
  echo "Script located at '/usr/local/bin/$(basename "$0")'"
  echo "Use '$command_name' to run."
}

main() {
  if [[ "$1" == "--install" || "$1" == "-i" ]]; then
    install_itself
    echo_summary
  else
    exec_target
  fi
}

main "$@"
