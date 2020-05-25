#! /bin/bash

#script to populate host_info table.
#usage: 
# ./host_info.sh psql_host psql_port db_name psql_user psql_password

#validate number of arguments
if [ "$#" -ne 5 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "INFO: ./host_info.sh psql_host psql_port db_name psql_user psql_password"
    exit 1
fi

#store arguments in variables
host=$1
port=$2
db=$3
user=$4
pass=$5


#save CPU architecture information to a variable
lscpu_out=`lscpu`

#hardware
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out" | grep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$($lscpu_out | grep "Architecture:" | awk '{print $2}' | xargs)
cpu_model=$($lscpu_out | grep 'Model name:' | sed -n 's/Model name: //p' | xargs)
cpu_mhz=$($lscpu_out | grep "CPU MHz:" | awk '{print $3}' | xargs)
l2_cache=$($lscpu_out | grep "L2 cache:" | awk '{print $3}' | sed 's/[A-Za-z]*//g')
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

insert=$(cat <<-END
INSERT INTO PUBLIC.host_info 
VALUES (DEFAULT, $hostname, $cpu_number, $cpu_architecture, $cpu_model, $cpu_mhz, $l2_cache, $total_mem, '$timestamp')
END
)

export PGPASSWORD=$pass
psql -h $host -p $port -d $db -U $user -c "$insert"

exit 0
