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
        echo -e "$2 is $G successful. $N" &>>$LOG_FILE
    else
        echo -e "$2 is $R failed.... please check $N" | tee -a $LOG_FILE
        echo -e "$R Script completed execution with error at: $(date) $N" | tee -a $LOG_FILE
        exit 1
    fi
}


CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabled mysql-server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Started mysql-server"

mysql -h 52.90.214.243 -u root -pExpenseApp@1 -e 'show databases;'
if [ $? -eq 0 ]
then
    echo -e "$Y Password for root user has been already set. $N" &>>$LOG_FILE
else
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
    VALIDATE $? "Setting up root password"
fi

echo -e "$Y Script completed execution successfully at: $(date) $N" | tee -a $LOG_FILE