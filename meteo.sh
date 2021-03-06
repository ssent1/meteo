#!/bin/bash
DateColumn=28
TimeColumn=17
curl https://wttr.in/YKF?0F --silent --max-time 3 > /tmp/now-weather
readarray aWeather < /tmp/now-weather
rm -f /tmp/now-weather
if [[ ${aWeather[0]} == "Weather report:"* ]]; then
    WeatherSuccess=true
    echo " ${aWeather[@]}"
else
    WeatherSuccess=false
    echo "+=====================+"
    echo "|                     |"
    echo "|                     |"
    echo "| Weather Unavailable |"
    echo "|                     |"
    echo "|                     |"
    echo "+=====================+"
    echo " "
fi
echo " "
#--------- CALENDAR -------------------------------------------------------------
tput sc
i=0
while [ $((++i)) -lt 10 ]; do tput cuu1; done
if [[ $WeatherSuccess == true ]]; then
    Column=$((DateColumn - 8))
    tput cuf $Column
    printf "          "
else
    tput cuf $DateColumn
fi
cal > /tmp/terminal1
tr -cd '\11\12\15\40\60-\136\140-\176' < /tmp/terminal1 > /tmp/terminal
CalLineCnt=1
Today=$(date +"%e")
printf "\033[34m"
while IFS= read -r Cal; do
    printf "%s" "$Cal"
    if [[ $CalLineCnt -gt 2 ]]; then
        tput cub 22
        for ((j = 0; j <= 18; j += 3)); do
            Test=${Cal:j:2}
            if [[ $Test == "$Today" ]]; then
                printf "\033[0;32m\033[7m"
                printf "%s" "$Today"
                printf "\033[0m"
                printf "\033[34m"
                tput cuf 1
            else
                tput cuf 3
            fi
        done
    fi
    tput cud1
    tput cuf $DateColumn
    CalLineCnt=$((++CalLineCnt))
done < /tmp/terminal
printf "\033[00m"
echo ""
tput rc
#--- TIME ---
tput sc
i=0
while [ $((++i)) -lt 9 ]; do tput cuu1; done
tput cuf $TimeColumn
date +"%H:%M" > /tmp/terminal
while IFS= read -r Time; do
    printf "\033[0;32m\033[7m"
    printf "%s" "$Time"
    tput cud1
    tput cuf $TimeColumn
done < /tmp/terminal
tput rc
exit 0
