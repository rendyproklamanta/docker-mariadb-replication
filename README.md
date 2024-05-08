## MariaDB replication using MaxScale
<hr>

### Stacks:
- MariaDB 10.x
- Docker
- Maxscale

### Servers
> If one server's down, just run it again. it'll automatically sync the replication GTID
- Master
- Slave

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
- Adding port to firewall
```
ufw allow 3306
ufw allow 6033
ufw allow 3301
ufw allow 3302
ufw allow 8989
```

- Create network
```
docker network create --driver overlay mysql-network
```

- Set permission if using linux
```
chmod +x start.sh
```
- Run script
```
On Linux
./start.sh

On Windows OR non docker-swarm
./start.non-swarm.sh
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
Link : http://localhost:8000 or http://[YOUR_IP_ADDRESS]:8000
user : super_usr
pass : SUPER_PASSWORD_SET
```

- Access using MySql client, like navicat, etc..
```
host : maxscale or [YOUR_IP_ADDRESS]
user : super_usr
pass : SUPER_PASSWORD_SET
port : 6033 (proxy) | 3301 (master) | 3302 (slave)
```

- Access MaxScale web UI
```
Link : http://localhost:8989 or http://[YOUR_IP_ADDRESS]:8989
user : admin
pass : mariadb
```

### Note :
- If server down
```
* Execute start.sh again : 
-- linux : ./start.sh
-- windows : ./start-non-swarm.sh

* Check if 1 or more database not sync beetwen servers :
-- Login to mysqlclient : maxscale server
-- Run Query Lock : FLUSH TABLES WITH READ LOCK;
-- Export database {dbname}
-- Import database {dbname} to {dbname_new}
-- Delete old database {dbname}
-- Rename {dbname_new} to {dbname}
-- Run query unlock : UNLOCK TABLES;
-- Check if all tables synced up
```

- If GTID not sync between servers :
```
cd resync
chmod +x main.sh && ./main.sh
```
