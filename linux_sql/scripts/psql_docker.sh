#!/bin/bash

# arguments
cmd=$1
user=$2
pass=$3

# container and volume details
cnt_name=jrvs-psql
cnt_ports=5432:5432
vol_name=pgdata
vol_path=${vol_name}:/var/lib/postgresql/data

# script run
scr_run=./psql_docker.sh

#check if argument(s) given
if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
	echo "ERROR: invalid arguments"
	echo "INFO: run $scr_run ? for usage"
	exit 1
fi

case $cmd in

    'stop')
	 if [ $(sudo docker container ls -a -f name=$cnt_name | wc -l) -eq 2 ];
	 then
	      	#stop psql
       		 sudo docker container stop $cnt_name
       		 exit 0
     	 else
     		 # print message if container is not created
		 echo "INFO: container does not exist, nothing to stop"
		 exit 1
	 fi

	 exit $?
      ;;

    'start')
	 #start docker if docker server is not running
	 sudo systemctl status docker || sudo systemctl start docker
	 if [ $? -eq 0 ]; then
		 echo "docker running"
	 fi

	 if [ $(sudo docker container ls -a -f name=$cnt_name | wc -l) -ne 2 ]; then
		 #print error message if container is not created
		 echo "ERROR: container does not exist, use create command"
		 exit 1
	 fi
 
	 #start psql
	 sudo docker container start $cnt_name

	 if [ $? -eq 0 ]; then
		 echo "docker container started"
	 fi

	 exit $?
       ;;

    'create')
	 #check container exists
	 if [ $(sudo docker container ls -a -f name=$cnt_name | wc -l) -eq 2 ]; then
		 echo "ERROR: container $cnt_name already exists"
		 exit 1
	 fi

	 if [[ ! $user ]] || [[ ! $pass ]]; then
		 echo "ERROR: enter both user and password"
		 echo "INFO: run $scr_run ? for usage"
	 exit 1
	 fi

	 sudo docker volume create $vol_name
	 sudo docker run --name $cnt_name -e POSTGRES_PASSWORD=$pass -e POSTGRES_USER=$user -d -v $vol_path -p $cnt_ports postgres

	 exit $?
	 ;;

    '?') #help
	 echo "start | stop | create [username] [password]"
	 echo "start = starts docker if it is not running and the psql docker container"
	 echo "stop = stops the psql docker container"
	 echo "create = create a psql docker container with the given username and password."
     
	 exit 0
     	 ;;

    *)  #wrong command
	 echo "ERROR: $cmd is not a recognized command"
	 echo "INFO: run $scr_run ? for usage"
	 exit 1
     	 ;;
esac

exit 0
