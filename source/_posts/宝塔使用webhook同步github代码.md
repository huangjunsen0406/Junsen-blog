---
title: 宝塔使用webhook同步github代码
---

宝塔使用webhook同步github代码



### 服务器设置git

- 先去 服务器上设置github用户名、邮箱、密码

- 然后获取rsa密钥用于代码拉取

  ```bash
  git config --global user.name "xxx"
  git config --global user.email "xxx@qq.com"
  git config --global user.password "xxx"
  
  #生成公钥
  ssh-keygen -t rsa
  #获取公钥
  cat ~/.ssh/id_rsa.pub
  ```

  

## 宝塔软件商店搜索 webhook

![image-20231114174342741](https://tuchuang.junsen.online//i/2023/11/14/stzy0l-1.png)

- 点击设置添加hook，名称随便填，脚本复制以下的改下仓库地址和部署目录
- **注意点：** 仓库的代码需要是编译后的代码。可以利用git action自动编译

```bash
#!/bin/bash
echo ""
#输出当前时间
date --date='0 days ago' "+%Y-%m-%d %H:%M:%S"
echo "Start"
#git项目路径
gitPath="/www/wwwroot/部署文件夹"
#git 网址
gitHttp="仓库地址"
 
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
```

- 获取添加后的 hook地址去github仓库里的设置点击webhook添加宝塔生成的hook地址，填完后点击add webhook即可，第一次需要点击下宝塔webhook的测试按钮

  ![image-20231114175358845](https://tuchuang.junsen.online//i/2023/11/14/t01js2-1.png)

![image-20231114175513385](https://tuchuang.junsen.online//i/2023/11/14/t0yp1j-1.png)

![image-20231114175524611](https://tuchuang.junsen.online//i/2023/11/14/t111g1-1.png)