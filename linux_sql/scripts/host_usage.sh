#! /bin/bash

#script to populate host_usage table.
#usage: 
# ./host_usage.sh psql_host psql_port db_name psql_user psql_password

#validate number of arguments
if [ "$#" -ne 5 ]; then
    echo "ERROR: Wrong number of parameters, there should be 5"
    echo "INFO: ./host_usage.sh psql_host psql_port db_name psql_user psql_password"
    exit 1
fi

#store arguments in variables
host=$1
port=$2
db=$3
user=$4
pass=$5

hostname=$(hostname -f)

hostID=$(cat <<-END
SELECT id
FROM PUBLIC.host_info 
WHERE hostname='$hostname'
END
)

#save usage 
usage=$(vmstat --unit M | awk 'NR==3')

timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

mem_free=$(echo $usage | awk '{print $4}')

cpu_idle=$(echo $usage | awk '{print $15}')
cpu_kernel=$(echo $usage | awk '{print $14}')

disk_io=$(vmstat -d | grep -i sda | awk '{print $10}')
disk_avail=$(df -BM / | awk '{print $4}' | sed 's/[A-Za-z]*//g' | xargs)

insert=$(cat <<-END
INSERT INTO PUBLIC.host_usage
VALUES (DEFAULT, '$timestamp', ($hostID), $mem_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_avail)
END
)

export PGPASSWORD=$pass
psql -h $host -p $port -d $db -U $user -c "$insert"

exit 0:
