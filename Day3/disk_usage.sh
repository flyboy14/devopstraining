#!/bin/bash

NUM=10

#echo "count is $# and last is ${!#}"
help() {
	echo -e "Usage: disk_usage.sh [OPTION] [DIRECTORY]\n"
	echo -e "-a\tlist both files and dirs"
	echo -e "-n NUM\tspecify number of entries to print"
	echo -e "-h\tprint help"
}

if [[ -z "$@" ]];then 
	help
	exit 1
fi

for arg in "$@"; do
 case "$arg" in
	-a) 
	A="a"
	if [[ -z "$2" ]];then
                help
                exit 1
        fi
	shift; 
	;;

	-n)  
	if [[ -z "$2" ]];then
		help
		exit 1
	fi
	NUM=$2; 
	shift;
	shift;
	;;

	-h) 
	help;
	exit 0;
	;;

	*) 
	if [[ -z "$@" ]];then
		help
		exit 1
	fi 
	FLD=$@; # echo "DIR is $FLD"
	;;
 esac
done

du -h$A $FLD| sort -rh | head -n $NUM
exit 0 


