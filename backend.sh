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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disablle nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

useradd expense &>>$LOG_FILE
VALIDATE $? "User add expense"