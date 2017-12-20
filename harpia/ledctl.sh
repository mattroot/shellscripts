#!/system/xbin/bash
########################################
#                       Notifications reader forn ATC LED                     
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

# Test whether everything is set up or not.
if [ -e /sdcard/ledsettings.sh ]
then
 # If it is, try. to use it
 source /sdcard/ledsettings.sh
 if [ $enabled -eq 1 ]
 then
  # Convert hours to milliseconds
  thold=$(($thold * 3600000))
  # Hello
  if [ $interval -gt 1 ]
  then
   mist='minutes'
  else
   mist='minute'
  fi
  echo "Hey there! Turn off your screen and wait $interval $mist, then, the LED will start blinking."
  #Convert minutes to seconds
  interval=$(($interval * 60))
  # Blink the LED every defined minutes
  PREV='None'
  while true
  do
   sleep $interval
   # Check if screen is on
   service call power 12 | grep 1 > /dev/null
   if [ $? -ne 0 ]
   then
    # Get DB entries
    QUERY="SELECT * FROM log WHERE posttime_ms < $thold ORDER BY posttime_ms DESC LIMIT 1"
    CMD="sqlite3 /data/system/notification_log.db '$QUERY'"
    LNOF=$(su -c "$CMD")
   if [ "$LNOF" != "$PREV" ]
   then
      # On
      su -c 'echo heartbeat > /sys/class/leds/charging/trigger'
      sleep  3
      # Off
      su -c 'echo none > /sys/class/leds/charging/trigger'
      PREV=$LNOF
    fi
   fi
  done
 fi
else
 # If it isn't, just generate the file and exit with a generic error code.
 printf '#!/system/bin/bash\n# Set to 0 to disable, 1 to enable\nenabled=1\n# Set this variable to the desired threshold: (hours)\nthold=1\n# Set the reading interval: (minutes)\ninterval=10' > /sdcard/ledsettings.sh
 echo 'Unable to startup, please edit /sdcard/ledsettings.sh before continuing or run again for defaults.'
 exit 1
fi
exit 0