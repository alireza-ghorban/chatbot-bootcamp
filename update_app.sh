#!/bin/bash

set -e
date
echo "Updating Python application on VM..."

APP_DIR="/home/azureuser/chatbot-bootcamp"
REPO_URL="github.com/alireza-ghorban/chatbot-bootcamp.git"
BRANCH="stage-6"
GITHUB_TOKEN=$GITHUB_TOKEN

# Update code
if [ -d "$APP_DIR" ]; then
    sudo -u azureuser bash -c "cd $APP_DIR && git pull origin $BRANCH"
else
    sudo -u azureuser git clone -b $BRANCH "https://${GITHUB_TOKEN}@${REPO_URL}"
    sudo -u azureuser bash -c "cd $APP_DIR"
fi

# Install dependencies
sudo -u azureuser /home/azureuser/miniconda3/envs/stage6/bin/pip install --upgrade pip
sudo -u azureuser /home/azureuser/miniconda3/envs/stage6/bin/pip install -r ${APP_DIR}/requirements.txt


# Restart the service
sudo systemctl restart backend
sudo systemctl restart frontend

echo "Python application update completed!"