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