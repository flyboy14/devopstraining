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

remove_trailing_whitespaces () {
	echo ok
}

help () {
        echo -e "Usage: cleanup.sh [OPTION] INPUT FROM STDIN\n"
        echo -e "-d DELIM\tspecify custom delimeter"
        echo -e "-W\t\tdo NOT strip empty lines"
        echo -e "-h\t\tprint help"
}

for arg in "$@"; do
 case "$arg" in
        -W)
        EMPTY_LINES=false
        shift;
        ;;

        -d)
        if [[ -z "$2" ]];then
                echo "Custom delimeter option is choosen but not specified!\n"
		help
                exit 1
        fi
	CUSTOM_DELIMETER=true
        DELIMETER=$2;
        shift;
        shift;
        ;;

        -h)
        help;
        exit 0;
        ;;

        *)
        ;;
 esac
done

IFS=''
while read line
do
 if $EMPTY_LINES;then
 	echo "${line%%*( )}" | remove_empty_lines | remove_comments 
 else
 	echo "${line%%*( )}" | remove_comments 
 fi
done

exit 0 # GO FOR THIS COMMENT
