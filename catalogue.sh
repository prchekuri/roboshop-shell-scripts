LOG_FILE=/tmp/catalogue

ID=$(id -u)
if [ $ID -ne 0 ]; then
  echo You should run this script as a root user or with sudo privileges.
  exit 1
fi

StatusCheck(){
  if [ $1 -eq 0 ]; then
    echo -e Status = "\e[32mSUCCESS\e[0m"
  else
    echo -e Status = "\e[31mFAILURE\e[0m"
    exit 1
  fi
}

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
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>LOG_FILE
StatusCheck $?

cd /home/roboshop

echo "Clean all old App content"
rm -rf catalogue &>>LOG_FILE
StatusCheck $?

echo "Extracting Catalogue Application code"
unzip /tmp/catalogue.zip &>>LOG_FILE
StatusCheck $?

mv catalogue-main catalogue
cd /home/roboshop/catalogue

echo "Install NodeJS dependencies"
npm install &>>LOG_FILE
StatusCheck $?

echo "Setup Catalogue Service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>LOG_FILE
StatusCheck $?

systemctl daemon-reload &>>LOG_FILE
systemctl enable catalogue &>>LOG_FILE

echo "Start Catalogue Service"
systemctl start catalogue &>>LOG_FILE
StatusCheck $?
