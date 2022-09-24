LOG_FILE=/tmp/mysql
source common.sh

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

echo "change the default root password"
mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" </tmp/root-pass.sql &>>$LOG_FILE
StatusCheck $?


# mysql_secure_installation

# mysql -uroot -pRoboShop@1

# > uninstall plugin validate_password;



# curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"

# cd /tmp
# unzip mysql.zip
# cd mysql-main
# mysql -u root -pRoboShop@1 <shipping.sql