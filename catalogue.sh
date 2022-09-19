LOG_FILE=/tmp/catalogue

echo "Setup Nodejs Repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>LOG_FILE
echo Status = $?

echo "Install NodeJS"
yum install nodejs -y &>>LOG_FILE
echo Status = $?

echo "Add Roboshop Application User"
useradd roboshop &>>LOG_FILE
echo Status = $?

echo "Download Catalogue Application code"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>LOG_FILE
echo Status = $?

cd /home/roboshop

echo "Extracting Catalogue Application code"
unzip /tmp/catalogue.zip &>>LOG_FILE
echo Status = $?

mv catalogue-main catalogue
cd /home/roboshop/catalogue

echo "Install NodeJS dependencies"
npm install &>>LOG_FILE
echo Status = $?

echo "Setup Catalogue Service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>LOG_FILE
echo Status = $?

systemctl daemon-reload &>>LOG_FILE
systemctl enable catalogue &>>LOG_FILE

echo "Start Catalogue Service"
systemctl start catalogue &>>LOG_FILE
echo Status = $?
