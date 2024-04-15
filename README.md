### Stacks:
- MariaDB 10.x
- Docker
- Maxscale

### Steps
- create dir
```
mkdir -p /var/lib/mysql
```

- goto dir and clone
```
cd /var/lib/mysql
git clone https://github.com/rendyproklamanta/docker-mariadb-replication.git .
```

- Change Password by using text replacing tool
```
cd /var/lib/mysql
find -type f -exec sed -i 's/MASTER_ROOT_PASSWORD_SET/YOUR_PASSWORD/g' {} +
find -type f -exec sed -i 's/SLAVE1_ROOT_PASSWORD_SET/YOUR_PASSWORD/g' {} +
find -type f -exec sed -i 's/SUPER_PASSWORD_SET/YOUR_PASSWORD/g' {} +
```

- Set permission if using linux
```
chmod +x start.sh
```
- Run script
```
On Linux
./start.sh

On Windows
./dev.sh
```

- Enable auto start on reboot and re-sync mariadb :
```
> Enable startup service :
cp mariadb-repl.service /etc/systemd/system/mariadb-repl.service
sudo systemctl enable mariadb-repl.service

> Check status after reboot :
sudo journalctl -u mariadb-repl.service
```

### Access :
- Access database using PMA
```
Link : http://localhost:8000 or http://[YOUR_IP_ADDRESS]:[PORT]
user : super_usr
pass : SUPER_PASSWORD_SET
```

- Access database using remote app like navicat, etc..
```
host : maxscale or [YOUR_IP_ADDRESS]
user : super_usr
pass : SUPER_PASSWORD_SET
port : 6033
```

- Access MaxScale web UI
```
Link : http://localhost:8989 or http://[YOUR_IP_ADDRESS]:[8989]
user : admin
pass : mariadb
```

### Note :
- If GTID not sync between servers
```
> Execute start.sh again : 
-- linux : ./start.sh
-- windows : ./start-non-swarm.sh

> Check if tables not sync beetwen servers :
-- Login to mysqlclient : maxscale server
-- Run Query Lock : FLUSH TABLES WITH READ LOCK;
-- Dump database {dbname}
-- Import database {dbname} to {dbname_new}
-- Rename {dbname_new} to {dbname} 
-- Run Query Unlock : UNLOCK TABLES;
-- Check if all tables synced up
```

> If GTID not sync beetwen servers :
-- Login to mysqlclient : maxscale server
-- Run Query Lock : FLUSH TABLES WITH READ LOCK;
-- Dump database {dbname}
-- Import database {dbname} to {dbname_new}
-- Rename {dbname_new} to {dbname} 
-- Run Query Unlock : UNLOCK TABLES;
-- Check if all tables synced up
```