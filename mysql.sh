LOG_FILE=/tmp/mysql
source common.sh

if [ -z "${ROBOSHOP_MYSQL_PASS}" ]; then
  echo -e "\e[31m Roboshop Mysql Password env var is needed\e[0m"
  exit 1
fi

echo "Setting up mysql Repo"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo  &>>$LOG_FILE
StatusCheck $?

echo "Disable mysql default module to enable MySQL 5.7"
dnf module disable mysql -y &>>$LOG_FILE
StatusCheck $?

echo "Install MySQL"
yum install mysql-community-server -y &>>$LOG_FILE
StatusCheck $?

echo "start MySQL service"
systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld &>>$LOG_FILE
StatusCheck $?


DEFAULT_PASSWORD=$(sudo grep 'A temporary password'  /var/log/mysqld.log | awk '{print $NF}')

echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${ROBOSHOP_MYSQL_PASS}');
FLUSH PRIVILEGES;" >/tmp/root-pass.sql

echo "show databases;" | mysql -uroot -p${ROBOSHOP_MYSQL_PASS} &>>$LOG_FILE
if [ $? -ne 0 ]; then
  echo "change the default root password"
  mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" </tmp/root-pass.sql &>>$LOG_FILE
  StatusCheck $?
fi

echo 'show plugins;'| mysql -uroot -p${ROBOSHOP_MYSQL_PASS}  2>/dev/null | grep validate_password &>>$LOG_FILE
if [ $? -eq 0 ]; then
  echo  "Uninstall Validate Password Plugin"
  echo "uninstall plugin validate_password;" | mysql -uroot -p${ROBOSHOP_MYSQL_PASS} &>>$LOG_FILE
  StatusCheck $?
fi


echo "Download Schema"
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>$LOG_FILE
StatusCheck $?

echo "Extract Schema"
cd /tmp
unzip -o mysql.zip &>>$LOG_FILE
StatusCheck $?

echo "Load Schema"
cd mysql-main
mysql -u root -p${ROBOSHOP_MYSQL_PASS} <shipping.sql &>>$LOG_FILE
StatusCheck $?