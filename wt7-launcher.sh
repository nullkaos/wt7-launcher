#!/bin/bash
#
# WT7 Launcher - Douglas Berdeaux
#  2016 - WeakNet Labs, Weakerthan Linux, WeakNet Academy
#

# CONSTANTS (Change me for your specific distro):
WINDOWTITLE="Weakerthan Linux Launcher"
mediaApp="vlc" # for music/video
textApp="leafpad" # for text files
webApp="firefox" # for web files
fileManager="pcmanfm" # for opening directories
icon="/root/.wt7/images/icons/shield-small-icon.png"
image="/root/.wt7/images/icons/shield-small-icon.png"
IFS=$'\n' # to handle spaces

# WORKFLOW:
WHAT=$(yad --center --form --field="" --display=$DISPLAY --window-icon=$icon --center --image=$image --title="$WINDOWTITLE" --width=500)
WHAT=$(echo $WHAT|sed -e 's/|$//g'); # remove the pipe
if [ "$WHAT" != "" ];then # if something was entered:
 #Progress window:
 #TODO check if it is alphanum
 files=($(find / * | grep -Ei "$WHAT"|grep -v '^\.'|sed -re 's/\s/\ /g'|tee >(yad --progress --text="Searching File System" --title="$WINDOWTITLE" --center --window-icon=$icon --image=$image --pulsate --no-buttons --auto-close))); # The "*" is because we want ALL things
 #TODO check if list is empty
 file=$(yad --button="Open File:1" --button="Open Directory:2" --width=500 --height=300 --list --separator= --title="$WINDOWTITLE" --center --always-print-result --column=Filename "${files[@]}");
fi;
action=$?

# Handle selection
if [ "$file" != "" ];then # They have made a selection
 if [ "$action" -lt 2 ];then # 0-1
  if [ "$(echo $file|grep -Ei '\.(mp[3-4]|avi|flv)$')" ];then # MEDIA
   $mediaApp $file # open with VLC
  #elif [ "$(echo $file|grep -iE '\.()$')" ];then
  elif [ "$(echo $file|grep -iE '\.(txt|csv|conf)$')" ];then # TEXT
   $textApp $file
  elif [ "$(echo $file|grep -iE '\.(c|php|pl|md|rb|py|java|run|bin|sh)$')" ];then # CODE
   $(echo $file|xargs -I {} gnome-terminal -e "bash -c \"vim {};exec bash\"";) #$codeApp)
  elif [ "$(echo $file|grep -iE '\.(html|js|xml)$')" ];then # WEB FILE
   $webApp $file
  elif [ "$(echo $file|grep -v '\.')" ];then # run the command
   $($file); # commands monstly dont have periods in them, if so, it will be handled above
  else # I don't know this file type yet
   directory=$(echo $file|sed -re 's/([^/]+)$//g')
   $fileManager $directory
  fi
 elif [ "$action" -eq 2 ];then # 2 for directory
  directory=$(echo $file|sed -re 's/([^/]+)$//g')
  $fileManager $directory
 else # X button pressed?
  exit 1;
 fi
fi
