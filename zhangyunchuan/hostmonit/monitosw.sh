
######################################################################
# First check to see if oswbb is already running
######################################################################
ps -ef | grep OSWatcher  | grep -v grep > /dev/null
if [ $? -eq 0 ]; then
        echo "An OSWatcher process has been detected."
        echo "Please stop it before starting a new OSWatcher process."
        exit
fi
cd /orabak/oswbb
nohup /orabak/oswbb/startOSWbb.sh 30 120 gzip &
