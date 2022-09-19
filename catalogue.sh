LOG_FILE=/tmp/catalogue

ID=$(id -u)
if [ $ID -ne 0 ]; then
  echo You should run this script as a root user or with sudo privileges.
  exit 1
fi

echo "Setup Nodejs Repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>LOG_FILE
if [ $? -eq 0 ]
then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "Install NodeJS"
yum install nodejs -y &>>LOG_FILE
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

id roboshop &>>LOG_FILE
if [ $? -ne 0 ]; then
  echo "Add Roboshop Application User"
  useradd roboshop &>>LOG_FILE
  if [ $? -eq 0 ]; then
    echo Status = SUCCESS
  else
    echo Status = FAILURE
    exit 1
  fi
fi

echo "Download Catalogue Application code"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>LOG_FILE
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

cd /home/roboshop

echo "Clean all old App content"
rm -rf catalogue &>>LOG_FILE
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "Extracting Catalogue Application code"
unzip /tmp/catalogue.zip &>>LOG_FILE
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

mv catalogue-main catalogue
cd /home/roboshop/catalogue

echo "Install NodeJS dependencies"
npm install &>>LOG_FILE
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "Setup Catalogue Service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>LOG_FILE
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

systemctl daemon-reload &>>LOG_FILE
systemctl enable catalogue &>>LOG_FILE

echo "Start Catalogue Service"
systemctl start catalogue &>>LOG_FILE
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi
