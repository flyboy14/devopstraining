#!/bin/bash

EMPTY_LINES=true
CUSTOM_DELIMETER=false
DELIMETER="#"

help() {
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

while read line
do
 if $EMPTY_LINES;then
	if $CUSTOM_DELIMETER;then 
		echo "$line" | sed "/^$DELIMETER/d" | sed -r '/^ ?$/d'
	else
		echo "$line" | sed -E 's@[[:blank:]]*#.*@@;T;/./!d' | sed -r '/^ ?$/d'
	fi
 else
	if $CUSTOM_DELIMETER;then
		echo "$line" | sed "/^$DELIMETER/d"
	else
		echo "$line" | sed -E 's@[[:blank:]]*#.*@@;T;/./!d'
	fi
 fi
done

exit 0 # GO FOR THIS COMMENT
