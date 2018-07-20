#!/bin/sh
# redis-notify.sh

MAIL_FROM="alert@example.com"
MAIL_TO="abc@example.com"

if [ "$#" = "2" ]; then
    mail_subject="Redis Notification"
    mail_body=`cat << EOB
============================================
Redis Notification Script called by Sentinel
============================================
Event Type: ${1}
Event Description: ${2}
Check the redis status.
EOB`
    echo "${mail_body}" | mail -r "${MAIL_FROM}" -s "${mail_subject}" "${MAIL_TO}"
fi
