#!/bin/bash

EMPTY_LINES=true
CUSTOM_DELIMETER=false
DELIMETER="#"


remove_empty_lines () {
	sed '/^\s*$/d'
}

remove_comments () {
	if $CUSTOM_DELIMETER; then
		sed "/^$DELIMETER/d" 
	else
		sed -e "/^$DELIMETER/d" -e "s@[[:blank:]]\\$DELIMETER.*@@"
	fi
}

help () {
        echo -e "Usage: cleanup.sh [OPTION] INPUT FROM STDIN\n"
        echo -e "-d DELIM\tspecify custom delimeter"
        echo -e "-W\t\tdo NOT strip empty lines"
        echo -e "-h\t\tprint help"
}

while getopts "Wd:h" opt
do
	case $opt in
		W) EMPTY_LINES=false;;
		d) CUSTOM_DELIMETER=true; DELIMETER="$OPTARG";;
		h) help && exit 0;;
		?) help && exit 1;;
	esac
done

IFS='' # get back my leading whitespaces and tabs
while read line
do
 if $EMPTY_LINES;then
 	echo "${line%%*( )}" | remove_empty_lines | remove_comments 
 else
 	echo "${line%%*( )}" | remove_comments 
 fi
done

exit 0 # GO FOR THIS COMMENT
