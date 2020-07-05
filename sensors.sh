#!/bin/bash
# Required for floating point arithmetic.  (Use bc to accommodate bash)
# sensors.sh
# A script to display Raspberry Pi on-board sensor data
#
# ==============================================================================================================================
# sensors.sh
# ==========
#
# A script to display Raspberry Pi on-board sensor data
#
# Larry Dighera: Mon Dec 23 04:07:23 PST 2013
# Larry Dighera: Mon Aug 10 14:02:46 PDT 2015: Added degree symbols, over-temperature based on degrees C so it will work without bc
# Richard Elkins: 2016-08-28:
#   * Checked for installation of `bc`.  Proceed with installation if not present (which fails if no Internet connection).
#   * Miscellaneous readability
#   * Deleted f2c() and addcomma() because they are never used
#   * Deleted c2f() because it produces bash syntax errors and Farenheit is not useful in this context
#   * Deleted first line "#!/usr/bin/ksh".  Diagnosing the Bourne shell instead.
#   * Deleted the � characters which seem to be spurious (?)
#=======================================================================================================================================
# Ben Moyes / Derek Moyes: Sun Jul 05 02:43 CDT:
#   * Cleaned up erroneous HTML characters from the site " https://www.cyberciti.biz/faq/linux-find-out-raspberry-pi-gpu-and-arm-cpu-temperature-command/
 
    echo -e "\n"
    echo -e "===== T E M P    C H E C K ====================================="
    date
    echo -e "================================================================\n"
    if [ `ps | tail -n 4 | sed -E '2,$d;s/.* (.*)/1/'` = "sh" ]; then
       echo
       echo "*** Oops, the Bourne shell is not supported"
       echo
       exit 86
    fi
    
    flagbc=`which bc`
    
    if [ -z $flagbc ]; then
       echo Installing bc
       sudo apt-get -y install bc
    fi
    
    TEMPC=$(/opt/vc/bin/vcgencmd measure_temp|awk -F "=" '{print $2}')
    TEMPf=$(echo -e "$TEMPC" | awk -F "'" '{print $1}' 2> /dev/null)
    OVRTMP=70
    ALRM=""      
    [[ `echo $TEMPC | cut -d. -f1` -gt ${OVRTMP:-70} ]] && ALRM="TOO HOT! TOO HOT! TOO HOT!"
    TEMPB4OVER=$(echo "$OVRTMP-$TEMPf"|bc -l)
    echo -e "\n         `tput smso` S Y S T E M    T E M P E R A T U R E `tput rmso`   `[[ -n $ALRM ]] || COLOR=green; setterm -foreground ${COLOR:-red}`${ALRM:-OK}"; setterm -foreground white
    echo -e "\n(CPU/GPU) temperature is: '${TEMPf}C'"; setterm -foreground red $ALRM ; setterm -foreground white
    echo -e "${OVRTMP:-70}C HIGH-TEMP LIMIT will be reached in `tput smso`${TEMPB4OVER}C`tput rmso` higher"
    echo -e "\n         `tput smso` S Y S T E M    V O L T A G E S `tput rmso`"
    echo -e "     The Core voltage is      : $(/opt/vc/bin/vcgencmd measure_volts core|awk -F "=" '{print $2}')"
    echo -e "     The sdram Core voltage is: $(/opt/vc/bin/vcgencmd measure_volts sdram_c|awk -F "=" '{print $2}')"    
    echo -e "     The sdram I/O voltage is : $(/opt/vc/bin/vcgencmd measure_volts sdram_i|awk -F "=" '{print $2}')"
    echo -e "     The sdram PHY voltage is : $(/opt/vc/bin/vcgencmd measure_volts sdram_p|awk -F "=" '{print $2 "n"}')"
    
    echo -e "\n         `tput smso` C L O C K    F R E Q U E N C I E S `tput rmso`"    
    for src in arm core h264 isp v3d uart pwm emmc pixel vec hdmi dpi ;do
        echo -e "$srct$(vcgencmd measure_clock $src) Hz"
    done | pr --indent=5 -r -t -2 -e3
    exit
