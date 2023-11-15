---
title: git配置
categories: ['环境配置']
tags: ['环境配置']
date: 2023-11-15 14:28:00
---

# 新环境配置git多配置

## 创建文件

```
ssh-keygen -t rsa -C 'xxx@qq.com' -f ~/.ssh/gitee_id_rsa
ssh-keygen -t rsa -C 'xxx@qq.com' -f ~/.ssh/github_id_rsa
ssh-keygen -t rsa -C 'xxx@qq.com' -f ~/.ssh/gitlab_id_rsa
```

## config配置

```
# gitee
Host gitee.com
HostName gitee.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/gitee_id_rsa
# github
Host github.com
HostName github.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/github_id_rsa
# 璟胜gitlab
Host gitlab.xxx.com
HostName gitlab.xxx.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/githlab_id_rsa
```