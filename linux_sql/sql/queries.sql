/* Group hosts by hardware info
Group hosts by CPU number and sort by their memory size in descending order(within each cpu_number group) */
SELECT cpu_number,
       id AS host_id,
       total_mem
FROM host_info
ORDER BY cpu_number,
         total_mem desc;

/* Average memory usage
Average used memory in percentage over 5 mins interval for each host. (used memory = total memory - free memory). */
SELECT host_id,
       host_name,
       timestamp,
       AVG(used_mem_percentage) AS avg_used_mem_percentage
FROM
    ( SELECT u.host_id AS host_id,
             i.hostname AS host_name,
             ( ( (i.total_mem - u.memory_free * 1024)/ i.total_mem )* 100 ) AS used_mem_percentage,
             ( DATE_TRUNC('hour', u.timestamp) + INTERVAL '5 minute' * ROUND( DATE_PART('minute', u.timestamp) / 5.0 ) ) AS timestamp
     FROM host_info AS i
     JOIN host_usage AS u ON i.id = u.host_id ) as s
GROUP BY timestamp,
         host_id,
         host_name
ORDER BY timestamp;

