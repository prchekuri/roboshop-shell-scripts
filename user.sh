LOG_FILE=/tmp/user

source common.sh

echo "Setup Nodejs Repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>LOG_FILE
StatusCheck $?

echo "Install NodeJS"
yum install nodejs -y &>>LOG_FILE
StatusCheck $?

#check whether roboshop user is existing or not. If not, go ahead and add else skip
id roboshop &>>LOG_FILE
if [ $? -ne 0 ]; then
  echo "Add Roboshop Application User"
  useradd roboshop &>>LOG_FILE
 StatusCheck $?
fi

echo "Download Catalogue Application code"
curl -s -L -o /tmp/user.zip "https://github.com/roboshop-devops-project/user/archive/main.zip" &>>LOG_FILE
StatusCheck $?

cd /home/roboshop

echo "Clean all old App content"
rm -rf catalogue &>>LOG_FILE
StatusCheck $?

echo "Extracting Catalogue Application code"
unzip /tmp/user.zip &>>LOG_FILE
StatusCheck $?

mv user-main user
cd /home/roboshop/user

echo "Install NodeJS dependencies"
npm install &>>LOG_FILE
StatusCheck $?

echo "Update SystemD service file"
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' /home/roboshop/user/systemd.service
StatusCheck $?

echo "Setup user Service"
mv /home/roboshop/user/systemd.service /etc/systemd/system/user.service &>>LOG_FILE
StatusCheck $?

systemctl daemon-reload &>>LOG_FILE
systemctl enable user &>>LOG_FILE

echo "Start user Service"
systemctl start user &>>LOG_FILE
StatusCheck $?
