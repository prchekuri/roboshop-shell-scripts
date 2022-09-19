LOG_FILE=/tmp/mongodb

echo "Setting up MongoDB Repo"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>$LOG_FILE
  echo Status = $?

echo "Installing MongoDB server"
yum install -y mongodb-org &>>$LOG_FILE
echo Status = $?

echo "updating mongodb listen address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
echo Status = $?

echo "Starting MOngoDB service"
systemctl enable mongod &>>$LOG_FILE
systemctl restart mongod &>>$LOG_FILE
echo Status = $?

echo "Downloading mongodb schema"
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>$LOG_FILE
echo Status = $?

cd /tmp
echo "Extracting mongodb schema file"
unzip mongodb.zip &>>$LOG_FILE

cd mongodb-main

echo "Load catalogue service schema"
mongo < catalogue.js &>>$LOG_FILE
echo Status = $?

echo "Load User service schema"
mongo < users.js &>>$LOG_FILE
echo Status = $?