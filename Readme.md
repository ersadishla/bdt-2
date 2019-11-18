# Tugas 2 Basis Data Terdistribusi

## Implementasi Cluster MongoDB
* Versi MongoDB : 4.2
* Provision menggunakan Vagrant
* Cluster terdiri dari :
  * 2 Config server
  * 3 Sharding server
  * 1 Query Router

### Detail Provision :

* Spesifikasi
![Gambar_Spesifikasi](img/specification.png)

* Setting VagrantFile  
VagrantFile digunakan untuk melakukan instalasi mongoDB pada masing-masing node
  ```ruby
    Vagrant.configure("2") do |config|

    config.vm.define "mongo_query_router" do |mongo_query_router|
        mongo_query_router.vm.hostname = "mongo-query-router"
        mongo_query_router.vm.box = "bento/ubuntu-18.04"
        mongo_query_router.vm.network "private_network", ip: "192.168.17.16"
        
        mongo_query_router.vm.provider "virtualbox" do |vb|
        vb.name = "mongo-query-router"
        vb.gui = false
        vb.memory = "512"
        end

        mongo_query_router.vm.provision "shell", path: "provision/allhosts.sh", privileged: false
    end

    config.vm.define "mongo_config_1" do |mongo_config_1|
        mongo_config_1.vm.hostname = "mongo-config-1"
        mongo_config_1.vm.box = "bento/ubuntu-18.04"
        mongo_config_1.vm.network "private_network", ip: "192.168.17.17"
        
        mongo_config_1.vm.provider "virtualbox" do |vb|
        vb.name = "mongo-config-1"
        vb.gui = false
        vb.memory = "512"
        end

        mongo_config_1.vm.provision "shell", path: "provision/allhosts.sh", privileged: false
    end

    config.vm.define "mongo_config_2" do |mongo_config_2|
        mongo_config_2.vm.hostname = "mongo-config-2"
        mongo_config_2.vm.box = "bento/ubuntu-18.04"
        mongo_config_2.vm.network "private_network", ip: "192.168.17.18"
        
        mongo_config_2.vm.provider "virtualbox" do |vb|
        vb.name = "mongo-config-2"
        vb.gui = false
        vb.memory = "512"
        end

        mongo_config_2.vm.provision "shell", path: "provision/allhosts.sh", privileged: false
    end

    config.vm.define "mongo_shard_1" do |mongo_shard_1|
        mongo_shard_1.vm.hostname = "mongo-shard-1"
        mongo_shard_1.vm.box = "bento/ubuntu-18.04"
        mongo_shard_1.vm.network "private_network", ip: "192.168.17.19"
            
        mongo_shard_1.vm.provider "virtualbox" do |vb|
        vb.name = "mongo-shard-1"
        vb.gui = false
        vb.memory = "512"
        end

        mongo_shard_1.vm.provision "shell", path: "provision/allhosts.sh", privileged: false
    end

    config.vm.define "mongo_shard_2" do |mongo_shard_2|
        mongo_shard_2.vm.hostname = "mongo-shard-2"
        mongo_shard_2.vm.box = "bento/ubuntu-18.04"
        mongo_shard_2.vm.network "private_network", ip: "192.168.17.20"
        
        mongo_shard_2.vm.provider "virtualbox" do |vb|
        vb.name = "mongo-shard-2"
        vb.gui = false
        vb.memory = "512"
        end

        mongo_shard_2.vm.provision "shell", path: "provision/allhosts.sh", privileged: false
    end

    
    config.vm.define "mongo_shard_3" do |mongo_shard_3|
        mongo_shard_3.vm.hostname = "mongo-shard-3"
        mongo_shard_3.vm.box = "bento/ubuntu-18.04"
        mongo_shard_3.vm.network "private_network", ip: "192.168.17.21"
        
        mongo_shard_3.vm.provider "virtualbox" do |vb|
        vb.name = "mongo-shard-3"
        vb.gui = false
        vb.memory = "512"
        end

        mongo_shard_3.vm.provision "shell", path: "provision/allhosts.sh", privileged: false
    end

    end
  ```
* Setting Provision  
Command yang dijalankan pada masing-masing node
  ```sh
    # Add hostname
    sudo bash -c \\"echo '192.168.17.16 mongo-query-router' >> /etc/hosts\\"
    sudo bash -c \\"echo '192.168.17.17 mongo-config-1' >> /etc/hosts\\"
    sudo bash -c \\"echo '192.168.17.18 mongo-config-2' >> /etc/hosts\\"
    sudo bash -c \\"echo '192.168.17.19 mongo-shard-1' >> /etc/hosts\\"
    sudo bash -c \\"echo '192.168.17.20 mongo-shard-2' >> /etc/hosts\\"
    sudo bash -c \\"echo '192.168.17.21 mongo-shard-3' >> /etc/hosts\\"

    # Copy APT sources list
    sudo cp /vagrant/sources/sources.list /etc/apt/
    sudo cp /vagrant/sources/mongodb-org-4.2.list /etc/apt/sources.list.d/

    # Add MongoDB repo key
    sudo apt-get install gnupg
    wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -

    # Update Repository
    sudo apt-get update
    # sudo apt-get upgrade -y

    # Install MongoDB
    sudo apt-get install -y mongodb-org

    # Start MongoDB
    sudo service mongod start
  ```
* Setting Manual  
Command yang dijalankan pada masing-masing node  
  ### 1. Registrasi hosts pada masing-masing node
  ```sh
   192.168.17.16        mongo-query-router
   192.168.17.17        mongo-config-1
   192.168.17.18        mongo-config-2
   192.168.17.19        mongo-shard-1
   192.168.17.20        mongo-shard-2
   192.168.17.21        mongo-shard-3
  ```
  ### 2. Registrasi user pada mongo-config-1  
  Login pada mongo-config-1
  ```
  mongo
  ```
  ```
  use admin
  ```
  ```
  db.createUser({user: "mongo-admin", pwd: "password", roles:[{role: "root", db: "admin"}]})
  ```
  ### 3. Setting Config Server
  * Ubah /etc/mongod.conf
  ```
  port: 27019
  bindIp: alamat_IP

  replication:
    replSetName: configReplSet

  sharding:
    clusterRole: "configsvr"
  ```
  * Restart mongoDB
  ```
  sudo systemctl restart mongod
  ```
  * Pada salah satu config node
  ```
  mongo mongo-config-1:27019 -u mongo-admin -p --authenticationDatabase admin
  ```
  ```sh
  rs.initiate( { _id: "configReplSet", configsvr: true, members: [ { _id: 0, host: "192.168.17.17:27019" }, { _id: 1, host: "192.168.17.18:27019" } ] } )
  ```
  * Cek status
  ```
  rs.status()
  ```
  * Jika config sudah benar
  ```sh
  {
    "set" : "configReplSet",
    "date" : ISODate("2016-11-22T14:11:18.382Z"),
    "myState" : 1,
    "term" : NumberLong(1),
    "configsvr" : true,
    "heartbeatIntervalMillis" : NumberLong(2000),
    "members" : [
        {
            "_id" : 0,
            "name" : "mongo-config-1:27019",
            "health" : 1,
            "state" : 1,
            "stateStr" : "PRIMARY",
            "uptime" : 272,
            "optime" : {
                "ts" : Timestamp(1479823872, 1),
                "t" : NumberLong(1)
            },
            "optimeDate" : ISODate("2016-11-22T14:11:12Z"),
            "infoMessage" : "could not find member to sync from",
            "electionTime" : Timestamp(1479823871, 1),
            "electionDate" : ISODate("2016-11-22T14:11:11Z"),
            "configVersion" : 1,
            "self" : true
        },
        {
            "_id" : 1,
            "name" : "mongo-config-2:27019",
            "health" : 1,
            "state" : 2,
            "stateStr" : "SECONDARY",
            "uptime" : 17,
            "optime" : {
                "ts" : Timestamp(1479823872, 1),
                "t" : NumberLong(1)
            },
            "optimeDate" : ISODate("2016-11-22T14:11:12Z"),
            "lastHeartbeat" : ISODate("2016-11-22T14:11:17.758Z"),
            "lastHeartbeatRecv" : ISODate("2016-11-22T14:11:14.283Z"),
            "pingMs" : NumberLong(1),
            "syncingTo" : "mongo-config-1:27019",
            "configVersion" : 1
        },
        {
            "_id" : 2,
            "name" : "mongo-config-3:27019",
            "health" : 1,
            "state" : 2,
            "stateStr" : "SECONDARY",
            "uptime" : 17,
            "optime" : {
                "ts" : Timestamp(1479823872, 1),
                "t" : NumberLong(1)
            },
            "optimeDate" : ISODate("2016-11-22T14:11:12Z"),
            "lastHeartbeat" : ISODate("2016-11-22T14:11:17.755Z"),
            "lastHeartbeatRecv" : ISODate("2016-11-22T14:11:14.276Z"),
            "pingMs" : NumberLong(0),
            "syncingTo" : "mongo-config-1:27019",
            "configVersion" : 1
        }
    ],
    "ok" : 1
  }
  ```
  ### 4. Config Query Router
  * Buat file config baru pada /etc/mongos.conf
  ```
  # where to write logging data.
  systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongos.log
  
  # network interfaces
  net:
  port: 27017
  bindIp: 192.168.17.16
  
  sharding:
  configDB: configReplSet/192.168.17.17:27019,192.168.17.18:27019
  ```
  * Buat file config baru pada /lib/systemd/system/mongos.service
  ```sh
  [Unit]
  Description=Mongo Cluster Router
  After=network.target
  
  [Service]
  User=mongodb
  Group=mongodb
  ExecStart=/usr/bin/mongos --config /etc/mongos.conf
  # file size
  LimitFSIZE=infinity
  # cpu time
  LimitCPU=infinity
  # virtual memory size
  LimitAS=infinity
  # open files
  LimitNOFILE=64000
  # processes/threads
  LimitNPROC=64000
  # total threads (user+kernel)
  TasksMax=infinity
  TasksAccounting=false
  
  [Install]
  WantedBy=multi-user.target
  ```
  ### 4. Config Node Shard
  Pada masing-masing sharding cluster
  * Masukkan alamat IP
  ```
  bindIp: alamat_IP
  ```
  Pada salah satu sharding cluster
  * Login ke query router
  ```
  mongo 192.168.17.16:27017 -u mongo-admin -p --authenticationDatabase admin
  ```
  * Registrasi masing-masing sharding cluster
  ```
  sh.addShard( "192.168.17.19:27017" )
  ```
  ```
  sh.addShard( "192.168.17.20:27017" )
  ```
  ```
  sh.addShard( "192.168.17.21:27017" )
  ```
  ### 5. Aktifkan Sharding
  ### Level Database
  * Login ke Query Router
  ```
  mongo mongo-query-router:27017 -u mongo-admin -p --authenticationDatabase admin
  ```
  ```
  use namaDatabase
  ```
  ```
  sh.enableSharding("namaDatabase")
  ```
  ### Level Collection
  * Login ke Query Router
  ```
  mongo mongo-query-router:27017 -u mongo-admin -p --authenticationDatabase admin
  ```
  ```
  use namaDatabase
  ```
  ```
  db.namaCollection.ensureIndex( { _id : "hashed" } )
  ```
  ```
  sh.shardCollection( "namaDatabase.namaCollection", { "_id" : "hashed" } )
  ```
## Menentukan Dataset

## Implementasi Aplikasi CRUD