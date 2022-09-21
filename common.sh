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

NODEJS(){
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

  echo "Download ${COMPONENT} Application code"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>LOG_FILE
  StatusCheck $?

  cd /home/roboshop

  echo "Clean all old App content"
  rm -rf ${COMPONENT} &>>LOG_FILE
  StatusCheck $?

  echo "Extracting ${COMPONENT} Application code"
  unzip /tmp/${COMPONENT}.zip &>>LOG_FILE
  StatusCheck $?

  mv ${COMPONENT}-main ${COMPONENT}
  cd /home/roboshop/${COMPONENT}

  echo "Install NodeJS dependencies"
  npm install &>>LOG_FILE
  StatusCheck $?

  echo "Update SystemD service file"
  sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service
  StatusCheck $?

  echo "Setup ${COMPONENT} Service"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>LOG_FILE
  StatusCheck $?

  systemctl daemon-reload &>>LOG_FILE
  systemctl enable ${COMPONENT} &>>LOG_FILE

  echo "Start ${COMPONENT} Service"
  systemctl start ${COMPONENT} &>>LOG_FILE
  StatusCheck $?

}