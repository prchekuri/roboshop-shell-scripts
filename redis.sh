LOG_FILE=/tmp/redis

source common.sh

echo "setup yum repos for redis"
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOG_FILE
StatusCheck $?

echo "Enable redis yum module"
dnf module enable redis:remi-6.2 -y &>>$LOG_FILE
StatusCheck $?

echo "Install Redis"
yum install redis -y &>>$LOG_FILE
StatusCheck $?

echo "Update Redis listen address from 127.0.0.1 to 0.0.0.0"
sed -i -e 's/127.0.0.1/0.0.0.0' /etc/redis.conf /etc/redis/redis.conf
StatusCheck $?

systemctl enable redis

echo "Starting Redis service"
systemctl start redis
StatusCheck $?