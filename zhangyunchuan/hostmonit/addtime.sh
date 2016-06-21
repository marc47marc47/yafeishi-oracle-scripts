i=0
read -r line
read -r line
read -r line
while read -r line
do
i=$(($i+1))
if [ $(($i%23)) -eq 1 ]
then
   echo "            "$line
   read -r line
   i=$(($i+1))
   echo "            "$line
   read -r line
   i=$(($i+1))
   echo "             "$line
else
   echo "`date +'%Y%m%d%H%M'` $line"
fi
done
