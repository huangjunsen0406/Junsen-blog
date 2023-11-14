#!/bin/bash
echo ""
#输出当前时间
date --date='0 days ago' "+%Y-%m-%d %H:%M:%S"
echo "Start"
#git项目路径
gitPath="/www/wwwroot/junsen.online"
#git 网址
gitHttp="git@github.com:Huang-junsen/Junsen-blog.git"
 
echo "Web站点路径：$gitPath"
 
#判断项目路径是否存在
if [ -d "$gitPath" ]; then
        cd $gitPath
        #判断是否存在git目录
        if [ ! -d ".git" ]; then
                echo "在该目录下克隆 git"
                cd ..
                git clone $gitHttp 
                # mv gittemp/.git .
                # rm -rf gittemp 
                echo "End"
        else  
              echo "在该目录下拉取 git"
              git pull 2>&1
              echo "End"
        fi
        exit
else
        echo "该项目路径不存在"
        echo "End"
        exit
fi
# git config --global user.name "HuangJunsen"
# git config --global user.email "951434130@qq.com"
# git config --global user.password "Huangjunsen0406"