#!/usr/bin/env bash

COMPOSER_VERSION="2.0.8"

# Check color support
if [ $(tput colors) -ge 8 ]; then
  COLOR_SUPPORT=true
  RESET="\033[00;37m"
  ORANGE="\033[01;33m"
  GREEN="\033[00;32m"
else
  COLOR_SUPPORT=false
fi

docker ps &>/dev/null
if [ "$?" -ne 0 ]; then
  # It appears that this user isn't enabled to talk to the Docker daemon
  echo -e "You don't have access to the Docker daemon\nTry executing as \`root\` please."
  exit 1
else
  # List all directories (Composer modules), excluding "." alone;
  # sorted alphabetically, just for output beauty
  DIRS=$(find . -maxdepth 1 -type d | tail -n +2 | cut -d/ -f2 | sort)
  for DIR in $DIRS; do
    echo "Installing '$DIR'..."
    # Enter the directory and install the Composer module from Composer's network itself
    cd $DIR
    # Ensure that a "composer.json" exists, or do you want to include the cosmic nothing?
    if [ ! -f "composer.json" ]; then
      if [ $COLOR_SUPPORT ]; then printf "[ ${ORANGE}Warn${RESET} ] "; fi
      echo "Composer's files not found on module '$DIR', skipping."; echo
      # Go back one level, since then we'll `continue` and not going back before the end of
      # the loop step
      cd ..
      # No Composer related files in this directory, skip it!
      continue
    fi
    # List Composer permissions, extract uid and gid from respective files in /etc
    user=$(cat /etc/passwd | grep -e "^$(ls -l composer.json | awk '{print $3}')" | cut -d: -f3)
    group=$(cat /etc/group | grep -e "^$(ls -l composer.json | awk '{print $4}')" | cut -d: -f3)
    # Retrieve composer modules using docker and the user's uid and gid
    # (the container gets deleted as soon as finished)
    docker run --rm -it --user "$user":"$group" -v `pwd`:/app composer:$COMPOSER_VERSION install &>/dev/null
    # Just some user presentation
    if [ $COLOR_SUPPORT ]; then printf "[ ${GREEN}Ok${RESET} ] "; fi
    echo "Module '$DIR' installed successfully."; echo
    # Go back one level, unless on the next step you want to enter a non existent directory
    cd ..
  done
  # Just some final user presentation
  if [ $COLOR_SUPPORT ]; then printf "[ ${GREEN}All Done${RESET} ] "; fi
  echo "All Composer modules downloaded and ready."
fi
