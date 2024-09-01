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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disablle default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "expense unsr not exists... $G Creating $N"
    useradd expense &>>$LOG_FILE
    VALIDATE $? "User add expense"
else
    echo -e "expense user already exists... $Y SKIPPING. $N"
fi

mkdir -p /app
VALIDATE $? "Creating app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOG_FILE
VALIDATE $? "Downloading backend application code"

# cd /app
# unzip /tmp/backend.zip  &>>$LOG_FILE
# VALIDATE $? "Extracting backend application code"