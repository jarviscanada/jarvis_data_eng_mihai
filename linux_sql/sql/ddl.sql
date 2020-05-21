CREATE TABLE IF NOT EXISTS PUBLIC.host_info (
  id SERIAL PRIMARY KEY, 
  hostname VARCHAR (100) NOT NULL, 
  cpu_number INTEGER NOT NULL, 
  cpu_architecture VARCHAR(10) NOT NULL, 
  cpu_model VARCHAR(50) NOT NULL, 
  cpu_mhz NUMERIC(7, 3) NOT NULL, 
  L2_cache INTEGER NOT NULL, 
  total_mem INTEGER NOT NULL, 
  timestamp TIMESTAMP NOT NULL 
  );

CREATE TABLE IF NOT EXISTS PUBLIC.host_usage (
  id SERIAL PRIMARY KEY, 
  timestamp TIMESTAMP NOT NULL, 
  host_id INT NOT NULL REFERENCES PUBLIC.host_info(id), 
  memory_free INTEGER NOT NULL, 
  cpu_idle NUMERIC(4, 1) NOT NULL, 
  cpu_kernel NUMERIC(4, 1) NOT NULL, 
  disk_io INTEGER NOT NULL, 
  disk_available INTEGER NOT NULL 
  );
