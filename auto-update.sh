#!/bin/bash

#Set the first argument to the full path of the project folder
main_dir=${1}

#The second argument sets the port to be forced to open
kill_port=${2}

#Output start log
echo "Script Start..."

#Moving the working directory
cd $main_dir

#Check Update
fetch=$(git fetch 2>&1)
fetch_code=$?

#Check to see if fetch has been completed successfully
if [ "$fetch_code" -ne 0 ]; then
    #Terminated as no renewal
    echo "fetch_error"
    exit 1
else
    echo "fetch OK"
fi

#Check the need for updates from the results of fetch runs
if echo "$fetch" | grep -q "From"; then
    echo "Update is needed."
else
    echo "Update did not exist"
    exit 0
fi

#Terminate the container
docker-compose down

#Open an occupied port
kill $(lsof -t -i:"$kill_port")

#Update
git pull

#Check to see if the update was completed successfully
if [ "$?" = 0 ];then
    echo "Git pull OK"
else
    echo "Git pull failed"
    exit 1
fi

#Restart Container
docker-compose up -d

#Check to see if the container was successfully started.
if [ "$?" = 0 ];then
    docker ps
    echo "Restart Container OK"
else
    echo "Restart Container failed"
    exit 1
fi

exit 0