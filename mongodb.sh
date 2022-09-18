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

