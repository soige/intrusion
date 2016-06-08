#!/bin/bash

#################################################################################
#
# Functions
#
#################################################################################
#
#    Function                   Description
#    -----------------------    -------------------------------------------------
#
#    Logger                     Log text strings to logfile, prefixed with date/time



    ################################################################################
    # Name        : Logger()
    # Description : Function logtext (redirect data ($1) to log file)
    #
    # Input       : $1 = text (string)
    # Returns     : Nothing
    # Usage       : Logger "This line goes into the log file"
    ################################################################################

    Logger() {
        if [ ! "${LOGFILE}" = "" ]; then CDATE=`date "+%Y-%m-%d %H:%M:%S"`; echo "${CDATE} $1" >> ${LOGFILE}; fi
    }
    
    ################################################################################
    # Name        : Show()
    # Description : Function show (show data ($1) to screen)
    #
    # Input       : $1 = text (string)
    # Returns     : Nothing
    # Usage       : Show "This line will show in the screen"
    ################################################################################
    Show() {
        echo "[*] $1"
    }
