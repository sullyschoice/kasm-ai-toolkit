#!/usr/bin/env bash
cd /opt/ai-toolkit
source venv/bin/activate
cd ui
xfce4-terminal --hold --command "npm run start" &
UI_SERVER="127.0.0.1:8675"
check_web_server() {
    curl -s -o /dev/null http://$UI_SERVER && return 0 || return 1
}
while ! check_web_server; do
  sleep 1
done

sleep 2
google-chrome http://$UI_SERVER --start-maximized &