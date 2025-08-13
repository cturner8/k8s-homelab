#!/bin/bash

ZSH_CUSTOM="/home/vscode/.oh-my-zsh/custom"

path="${ZSH_CUSTOM}/minikube.zsh"

echo "# MiniKube Aliases" > ${path}

echo "alias mks='minikube start --driver=docker --ports=8000,8080,8443'" >> ${path}
echo "alias mkt='minikube tunnel --bind-address=\"*\"'" >> ${path}
echo "alias mkd='minikube dashboard --port 8000'" >> ${path}
