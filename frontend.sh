LOG_FILE=/tmp/frontend

source ./common.sh

echo Installing nginx software..
yum install nginx -y &>>$LOG_FILE
StatusCheck $?

echo downloading nginx web content
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG_FILE
StatusCheck $?

cd /usr/share/nginx/html

echo Removing the old web content
rm -rf * &>>$LOG_FILE
StatusCheck $?

echo Extracting the web content
unzip /tmp/frontend.zip &>>$LOG_FILE
StatusCheck $?

mv frontend-main/static/* . &>>$LOG_FILE
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE

echo Starting Nginx service
systemctl enable nginx &>>$LOG_FILE
systemctl restart nginx &>>$LOG_FILE
StatusCheck $?