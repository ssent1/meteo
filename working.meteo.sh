#!/bin/bash

# NAME: now
# PATH: $HOME/bin
# DESC: Display current weather, calendar and time
# CALL: In terminal, run bash filename or ~/.bashrc
# [command line - Terminal splash screen with Weather, Calendar, Time & Sysinfo](https://askubuntu.com/questions/1020692/terminal-splash-screen-with-weather-calendar-time-sysinfo/)

# Setup for 92 character wide terminal
DateColumn=34 # Default is 27 for 80 character line, 34 for 92 character line
TimeColumn=61 # Default is 49 for   "   "   "   "    61 "   "   "   "

# Replace Edmonton with your city name, GPS, etc. See: curl wttr.in/:help
curl http://wttr.in/YKF?F --silent --max-time 3 > /tmp/now-weather
# Timeout #. Increase for slow connection---^
# For detailed information on parameters, flags, etc., please go `curl wttr.in/:help`.
# Canadian cities
#   [Ottawa](http://wttr.in/ottawa)
#   [Toronto](http://wttr.in/toronto) {sks: verified that Toronto is the best match}
#   [Montreal](http://wttr.in/montreal)
#   [Vancouver](http://wttr.in/vancouver)
#   [London, Ontario](http://wttr.in/london%20ontario)
#   [Montreal](http://wttr.in/montreal)
#   [YYZ](http://wttr.in/yyz)
# FLAGS `?n`
# ?0 : current conditions
# ?1 : current conditions + today's forecast
# ?2 : current conditions + 2-day forecast
# ?3 : current conditions + 3-day forecast
#    : no flag is the same as `?3`
# --max-time <time> (in seconds)

readarray aWeather < /tmp/now-weather
rm -f /tmp/now-weather

# Was valid weather report found or an error message?

if [[ "${aWeather[0]}" == "Weather report:"* ]] ; then
    WeatherSuccess=true
    echo "${aWeather[@]}"
else
    WeatherSuccess=false
    echo "+============================+"
    echo "| Weather unavailable now!!! |"
    echo "| Check reason with command: |"
    echo "|                            |"
    echo "| curl wttr.in/toronto?0     |"
    echo "|   --silent --max-time 3    |"
    echo "+============================+"
    echo " "
fi
    echo " " # Pad blank lines for calendar & time to fit


# calendar current month with today highlighted.
# UNIX Colour    (0: regular, 1:bold, 4:underline)
#   00 : off     ="\[\033[0m\]"   reset/colour_off
#   30 : Black   ="\[\033[0;30m\]"        
#   31 : Red     ="\[\033[0;31m\]"          
#   32 : Green   ="\[\033[0;32m\]"        
#   33 : Yellow  ="\[\033[0;33m\]"       
#   34 : Blue    ="\[\033[0;34m\]"         
#   35 : Purple  ="\[\033[0;35m\]"       
#   36 : Cyan    ="\[\033[0;36m\]"         
#   37 : White   ="\[\033[0;37m\]"        

tput sc # Save cursor position.
# Move up 9 lines
i=0
while [ $((++i)) -lt 10 ]; do tput cuu1; done

if [[ "$WeatherSuccess" == true ]] ; then
    # Depending on length of your city name and country name you will:
    #   1. Comment out next three lines of code. Uncomment fourth code line.
    #   2. Change subtraction value and set number of print spaces to match
    #      subtraction value. Then place comment on fourth code line.
    Column=$((DateColumn - 10))
    tput cuf $Column        # Move x column number
    # Blank out ", country" with x spaces
    printf "          "
else
    tput cuf $DateColumn    # Position to column 27 for date display
fi

# -h needed to turn off formating: https://askubuntu.com/questions/1013954/bash-substring-stringoffsetlength-error/1013960#1013960
cal > /tmp/terminal1
# cal, ncal -- displays a calendar and the date of Easter
# -h not supported in Ubuntu 18.04. Use second answer: https://askubuntu.com/a/1028566/307523
tr -cd '\11\12\15\40\60-\136\140-\176' < /tmp/terminal1  > /tmp/terminal
# tr -- translate characters
#   -C      Complement the set of characters in string1, that is ``-C ab'' includes every character except for `a' and `b'.
#   -c      Same as -C but complement the set of values in string1.
#   -d      Delete characters in string1 from the input.

CalLineCnt=1
Today=$(date +"%e") # today's `day of month, space padded`. See [Linux date command help and examples](https://www.computerhope.com/unix/udate.htm)

printf "\033[34m"   # [34m = blue -- see list above.

while IFS= read -r Cal; do
    printf "%s" "$Cal"                   # printf -- formatted output
    if [[ $CalLineCnt -gt 2 ]] ; then
        # See if today is on current line & invert background
        tput cub 22 # tput, reset - initialize a terminal or query terminfo database
        for (( j=0 ; j <= 18 ; j += 3 )) ; do
            Test=${Cal:$j:2}            # Current day on calendar line
            if [[ "$Test" == "$Today" ]] ; then
                printf "\033[33m\033[7m"        # [00 = yellow, [7m = knock-out/reverse
                printf "%s" "$Today"
                printf "\033[0m"        # Normal: [0m
                printf "\033[34m"       # row 5; [34m = blue -- see list above.
                tput cuf 1
            else
                tput cuf 3
            fi
        done
    fi

    tput cud1               # Down one line
    tput cuf $DateColumn    # Move 27 columns right
    CalLineCnt=$((++CalLineCnt))
done < /tmp/terminal

printf "\033[00m"           # color -- bright white (default)
echo ""

tput rc                     # Restore saved cursor position.
#-------- TIME --------------------------------------------------------------

tput sc                 # Save cursor position.
# Move up 8 lines
i=0
while [ $((++i)) -lt 9 ]; do tput cuu1; done
tput cuf $TimeColumn    # Move 49 columns right


# # Do we have the toilet package?
# if hash toilet 2>/dev/null; then
#     echo " $(date +"%I:%M %P") " | \
#         toilet -f future --filter border > /tmp/terminal
# # Do we have the figlet package?
# elif hash figlet 2>/dev/null; then
# #    echo $(date +"%I:%M %P") | figlet > /tmp/terminal
#     date +"%I:%M %P" | figlet > /tmp/terminal
# # else use standard font
# else
# #    echo $(date +"%I:%M %P") > /tmp/terminal
#     date +"%H:%M" > /tmp/terminal
# fi


# Do we have the toilet package?
if hash toilet 2>/dev/null; then
    echo " $(date +"%I:%M %P") " | \
        toilet -f future --filter border > /tmp/terminal
# Do we have the figlet package?
elif hash figlet 2>/dev/null; then
#    echo $(date +"%I:%M %P") | figlet > /tmp/terminal
    date +"%I:%M %P" | figlet > /tmp/terminal
# else use standard font
else
#    echo $(date +"%I:%M %P") > /tmp/terminal
    date +"%I:%M %P" > /tmp/terminal
fi

while IFS= read -r Time; do
    printf "\033[01;36m"    # color cyan
    printf "%s" "$Time"
    tput cud1               # Up one line
    tput cuf $TimeColumn    # Move 49 columns right
done < /tmp/terminal

tput rc                     # Restore saved cursor position.

exit 0
