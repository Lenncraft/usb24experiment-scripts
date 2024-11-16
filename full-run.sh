#!/bin/bash
# Variables. Change if needed:
REMOTE_USER="drop"
REMOTE_HOST="" # Enter drop server IP here
REMOTE_PATH="/home/drop/exp/$USBNAME/"
TARGET_USER="System-A" # If you change this, replace everywhere in script!
TARGET_HOST="" # Enter test system IP here

# Do not change these:
DIRECTORY_TO_COPY="c:/Users/System-A/Downloads"
TIME_WAIT_USB_DISCONNECT=25

############################
echo "Set USB device Name using env USBNAME. Currently set to $USBNAME"
echo "Test Host: $TARGET_USER@$TARGET_HOST"
echo "Drop Server: $REMOTE_HOST in $REMOTE_PATH"
echo $USBNAME >> listOfUSBNAME.log

sleep 2

echo "(1/10) Creating initial automatic snpashots"

ssh $TARGET_USER@$TARGET_HOST cmd << EOF
    mkdir "C:\Users\System-A\Downloads\init"
    cd "C:\Program Files (x86)\Log Parser 2.2\"
    LogParser.exe "SELECT * FROM APPLICATION" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\init\application.csv"
    LogParser.exe "SELECT * FROM SECURITY" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\init\security.csv"
    LogParser.exe "SELECT * FROM Setup" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\init\setup.csv"
    LogParser.exe "SELECT * FROM SYSTEM" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\init\system.csv"
    LogParser.exe "SELECT * FROM APPLICATION" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\init\application.txt"
    LogParser.exe "SELECT * FROM SECURITY" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\init\security.txt"
    LogParser.exe "SELECT * FROM Setup" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\init\setup.txt"
    LogParser.exe "SELECT * FROM SYSTEM" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\init\system.txt"
    exit
EOF
echo "Event Logs complete. Saving setupapi.dev.log . . ."
ssh $TARGET_USER@$TARGET_HOST powershell << EOF
    cp C:\Windows\INF\setupapi.dev.log C:\Users\System-A\Downloads\init
    exit
EOF

echo "(2/10) Please take the 1st Regshot Snapshot now."
echo "Save at: $DIRECTORY_TO_COPY/init"
# Ask the user for confirmation
echo -en "\007"
read -p "Did you complete the 1st Regshot snapshot? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
  exit 1
fi

############# Connect
echo "(3/10) Please connect the USB device"
read -p "Is the USB device Connected? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
  exit 1
fi
echo "(4/10) Waiting for USB device detection. . ."
echo "(This will take a while)"
# Sleep to allow windows to detect/install the usb device
sleep 15
echo "-45s"
sleep 15
echo "-30s"
sleep 15
echo "-15s"
sleep 10
echo "-5s"
sleep 5

############ Take connected Snapshot
echo "(5/10) Creating automatic snpashots"
ssh $TARGET_USER@$TARGET_HOST cmd << EOF
    mkdir "C:\Users\System-A\Downloads\mid"
    cd "C:\Program Files (x86)\Log Parser 2.2\"
    LogParser.exe "SELECT * FROM APPLICATION" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\mid\application.csv"
    LogParser.exe "SELECT * FROM SECURITY" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\mid\security.csv"
    LogParser.exe "SELECT * FROM Setup" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\mid\setup.csv"
    LogParser.exe "SELECT * FROM SYSTEM" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\mid\system.csv"
    LogParser.exe "SELECT * FROM APPLICATION" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\mid\application.txt"
    LogParser.exe "SELECT * FROM SECURITY" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\mid\security.txt"
    LogParser.exe "SELECT * FROM Setup" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\mid\setup.txt"
    LogParser.exe "SELECT * FROM SYSTEM" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\mid\system.txt"
    exit
EOF
echo "Event Logs complete. Saving setupapi.dev.log . . ."
ssh $TARGET_USER@$TARGET_HOST powershell << EOF
    cp C:\Windows\INF\setupapi.dev.log C:\Users\System-A\Downloads\mid
    exit
EOF

echo "(6/10) Please take the 2nd Regshot Snapshot and Diff now."
echo "Save at: $DIRECTORY_TO_COPY/mid"
# Ask the user for confirmation
echo -en "\007"
read -p "Did you complete the 2nd Regshot snapshot? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
  exit 1
fi
read -p "Did you save the Diff? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
  exit 1
fi

########## Disconnect
echo "(7/10) Please disconnect the USB device now"
read -p "Is the device disconnected? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
  exit 1
fi
# Sleep to allow windows to detect/uninstall the usb device
echo "Waiting for windows. . ."
sleep $TIME_WAIT_USB_DISCONNECT

######### disconnected snapshot
echo "(8/10) Creating automatic snpashots"
ssh $TARGET_USER@$TARGET_HOST cmd << EOF
    mkdir "C:\Users\System-A\Downloads\final"
    cd "C:\Program Files (x86)\Log Parser 2.2\"
    LogParser.exe "SELECT * FROM APPLICATION" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\final\application.csv"
    LogParser.exe "SELECT * FROM SECURITY" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\final\security.csv"
    LogParser.exe "SELECT * FROM Setup" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\final\setup.csv"
    LogParser.exe "SELECT * FROM SYSTEM" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\final\system.csv"
    LogParser.exe "SELECT * FROM APPLICATION" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\final\application.txt"
    LogParser.exe "SELECT * FROM SECURITY" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\final\security.txt"
    LogParser.exe "SELECT * FROM Setup" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\final\setup.txt"
    LogParser.exe "SELECT * FROM SYSTEM" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\final\system.txt"
    exit
EOF
echo "Event Logs complete. Saving setupapi.dev.log . . ."
ssh $TARGET_USER@$TARGET_HOST powershell << EOF
    cp C:\Windows\INF\setupapi.dev.log C:\Users\System-A\Downloads\final
    exit
EOF

echo "(9/10) Please take the 2nd Regshot Snapshot and Diff now."
echo "Save at: $DIRECTORY_TO_COPY/final"
echo "Clear the previous 2nd snapshot first!"
# Ask the user for confirmation
echo -en "\007"
read -p "Did you complete the 2nd Regshot snapshot? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
  exit 1
fi
read -p "Did you save the Diff? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
  exit 1
fi

################# Reboot
echo "Rebooting now."
ssh $TARGET_USER@$TARGET_HOST shutdown /r /t 10

read -p "Is the system online again? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
  exit 1
fi

ssh $TARGET_USER@$TARGET_HOST cmd << EOF
    mkdir "C:\Users\System-A\Downloads\reboot"
    cd "C:\Program Files (x86)\Log Parser 2.2\"
    LogParser.exe "SELECT * FROM APPLICATION" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\reboot\application.csv"
    LogParser.exe "SELECT * FROM SECURITY" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\reboot\security.csv"
    LogParser.exe "SELECT * FROM Setup" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\reboot\setup.csv"
    LogParser.exe "SELECT * FROM SYSTEM" -o:CSV -q:ON -stats:OFF > "C:\Users\System-A\Downloads\reboot\system.csv"
    LogParser.exe "SELECT * FROM APPLICATION" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\reboot\application.txt"
    LogParser.exe "SELECT * FROM SECURITY" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\reboot\security.txt"
    LogParser.exe "SELECT * FROM Setup" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\reboot\setup.txt"
    LogParser.exe "SELECT * FROM SYSTEM" -q:ON -stats:OFF > "C:\Users\System-A\Downloads\reboot\system.txt"
    exit
EOF
echo "Event Logs complete. Saving setupapi.dev.log . . ."
ssh $TARGET_USER@$TARGET_HOST powershell << EOF
    cp C:\Windows\INF\setupapi.dev.log C:\Users\System-A\Downloads\reboot
    exit
EOF

echo "First load the initial shot into 1st shot. (from Downloads\init\)"
echo "Next take a 2nd shot and diff. Save in Downloads\reboot\ "
echo -en "\007"
read -p "Did you complete the 2nd Regshot snapshot? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
  exit 1
fi
read -p "Did you save the Diff? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
  exit 1
fi

echo "(10/10) Transmitting results."

# Copy resulting files to Remote
# Copy directory to remote server using scp
scp -r $TARGET_USER@$TARGET_HOST:$DIRECTORY_TO_COPY $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH

# Check if the command was successful TODO Validate on remote
if [ $? -eq 0 ]; then
  echo "(Done) Results transmitted successfully."
else
  echo "ERROR: Directory copy failed"
fi
