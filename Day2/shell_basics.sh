#!/bin/bash

# You may want to specify you desired folder to execute script task with a parameter
# If no parameter given, using /home/student as default
##
# Check whether folder exists
# If not, exit 1

FLD=${1:-"/home/student"}
if [[ ! -d $FLD ]]; then 
	echo "Directory $FLD doesn't exist!"
	exit 1
fi

cd $FLD
echo "Siarhei_Kazak" > student
echo "Created file student"

FLDN="`cat student`"
mkdir -p "./$FLDN"
echo "Created dir $FLDN"

for i in {1..100}
do
   mkdir -p $FLDN/$i
done
echo "Created 100 dirs in $FLDN"

truncate -s 1K $FLDN/10/test1 && echo "Created file $FLDN/10/test1 with size of 1K"
truncate -s 1M $FLDN/20/test2 && echo "Created file $FLDN/10/test2 with size of 1M"
truncate -s 10M $FLDN/30/test3 && echo "Created file $FLDN/10/test3 with size of 10M"

mkdir -p $FLD/centos/day2
find $FLD -type f -mmin -60 2>/dev/null | sed "s@$FLD/@@g" | sort > $FLD/centos/day2/1h
echo "Created file $FLD/centos/day2/1h with files in $FLD accessed < 1h ago"

find $FLD -type f -size +5M 2>/dev/null | sed "s@$FLD/@@g" | sort > $FLD/centos/day2/5M
echo "Created file $FLD/centos/day2/5M with files in $FLD larger than 5M"

cd $FLDN

tar -czf mytest.tar.gz 10/test1 20/test2
echo "Created mytest.tar.gz with test1 and test2 files"
gunzip mytest.tar.gz
tar -uf mytest.tar 30/test3
gzip mytest.tar
echo "Updated mytest.tar.gz with test3 file"

cd $FLD
mkdir -p $FLDN/mytest
echo "Created dir $FLDN/mytest"

mv $FLDN/mytest.tar.gz $FLDN/mytest/
echo "Moved mytest.tar.gz to $FLDN/mytest/"
tar -xzf $FLDN/mytest/mytest.tar.gz -C $FLDN/mytest/
echo "Extracted mytest.tar.gz in place"

echo "Done!"
exit 0
