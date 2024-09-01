#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

mkdir -p $LOGS_FOLDER

USER=$(id -u)

#text colors
#31m -> Red
#31m -> Green
#33m -> Yellow

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
echo -e "$Y Script started execution at: $(date) $N" | tee -a $LOG_FILE
CHECK_ROOT(){
    if [ $USER -ne 0 ]
    then
        echo -e "$R Please run this script with root privileges $N" | tee -a $LOG_FILE
        echo -e "$R Script completed execution with error at: $(date) $N" | tee -a $LOG_FILE
        exit 1
    fi

}

VALIDATE() {
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is $G SUCCESS. $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is $R FAILED.... please check $N" | tee -a $LOG_FILE
        echo -e "$R Script completed execution with error at: $(date) $N" | tee -a $LOG_FILE
        exit 1
    fi
}


CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enable Nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Start Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extract frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE
VALIDATE $? "Configured expense config"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarted Nginx"