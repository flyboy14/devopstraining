#!/bin/bash

NUM=10
help() {
	echo -e "\nUsage: disk_usage.sh [OPTION] [DIRECTORY]\n"
	echo -e "-a\tlist both files and dirs"
	echo -e "-n NUM\tspecify number of entries to print"
	echo -e "-h\tprint help"
}

if [[ -z "$@" ]]; then 
	echo -e "$0: directory not specified"
	help
	exit 1
fi

while getopts "an:h" opt
do
	case $opt in
		a) A="a";;
		n) NUM="$OPTARG";;
		h) help $$ exit 0;;
		?) help && exit 1;;
	esac
done

FLD="${!#}"
if [[ ! -d $FLD ]]; then
	echo -e "$0: no such directory \"$FLD\""
	help
	exit 1
fi

du -h$A $FLD| sort -rh | head -n $NUM
exit 0 


