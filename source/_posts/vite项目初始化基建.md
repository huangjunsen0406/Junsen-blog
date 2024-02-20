---
title: vite项目初始化基建
categories: ['前端']
tags: ['前端']
date: 2024-02-21 01:51:00
---


## 配置eslint

### 什么是eslint?

> ESLint 是一个 JavaScript 和 TypeScript 的静态代码分析工具，它用于识别代码中的问题并提供一致性和规范性。简单来说，它的作用是：
>
> 1. **检测错误和潜在的问题：** ESLint 可以帮助你找到代码中的错误、潜在的 bug 以及不规范的写法，从而提高代码的质量和稳定性。
> 2. **强制执行代码风格规范：** 它可以根据预定义的规则或自定义的规则来强制执行一致的代码风格，以确保团队成员之间的代码风格一致，提高代码的可读性和可维护性。
> 3. **提供自定义规则和插件支持：** ESLint 允许你根据项目的特定需求定义自定义规则，并且支持各种插件，可以满足不同项目的特定需求。
>
> 总的来说，ESLint 可以帮助开发人员编写更加干净、可靠和符合规范的代码。

### 安装命令

```cmd
# 方案1 
pnpm i -D eslint
```

### 规则方案

```cmd
# 使用集成方案，内置好了所需规则
pnpm i -D @antfu/eslint-config 

# eslint默认方案，通过命令初始化eslint规则
npx eslint --init
```

#### eslint集成方案

> 先安装方案一的@antfu/eslint-config 
>
> 在根目录新建 eslint.config.js即可

```javascript
import antfu from '@antfu/eslint-config'

export default antfu({
})
```



#### eslint初始化默认方案（可选）

##### 第一步 选择检测类型

- 仅检查语法

- 检查语法并查找问题

- 若要检查语法、寻找问题并胁迫执行程式码样式

  **选择第二个，To check syntax and find problems**

![image-20240220075859922](https://tuchuang.junsen.online/i/2024/02/20/cjxore-2.png)

##### 第二步 选择项目是什么类型的模块

**有以下三个选项，根据项目所需选择，这里使用的是js模块选择第一个即可**

- JavaScript模块（导入/导出）
- CommonJS（require/exports）
- 没有这些

![image-20240220080700457](https://tuchuang.junsen.online/i/2024/02/20/dcgx0e-2.png)

##### 第三步 选择所使用的框架 根据你的项目选择即可

![image-20240220080847042](https://tuchuang.junsen.online/i/2024/02/20/ddcik6-2.png)

##### 第四步 是否使用了ts,根据自己项目的选择

![image-20240220080951098](https://tuchuang.junsen.online/i/2024/02/20/ddyrnf-2.png)

##### 第五步 选择运行环境，一般选浏览器，也就是第一个browser

![image-20240220081029606](https://tuchuang.junsen.online/i/2024/02/20/defi6y-2.png)

##### 第六步 选择配置文件的类型，一般第一个即可

![image-20240220081125789](https://tuchuang.junsen.online/i/2024/02/20/dezy1j-2.png)

##### 第七步 是否需要以下依赖，直接yes就行了，如果不用选no

![image-20240220081248294](https://tuchuang.junsen.online/i/2024/02/20/dfqdaq-2.png)

##### 第八步 选择安装依赖的方式，根据你项目所需的包管理选择

![image-20240220081400408](https://tuchuang.junsen.online/i/2024/02/20/dgn0by-2.png)

**执行完毕后的样子，根目录会多出 .eslintrc.cjs 的文件，在里面配置规则即可**

![image-20240220081552312](https://tuchuang.junsen.online/i/2024/02/20/dhjk9n-2.png)



### .vscode/settings.json

> 这个配置文件是用来配置编辑器（如 VSCode）的，主要针对 ESLint 和 Prettier 的设置。具体含义如下：
>
> - `"eslint.experimental.useFlatConfig": true`: 启用 ESLint 的扁平配置支持。
> - `"prettier.enable": false`: 禁用默认的格式化程序，改用 ESLint 来格式化代码。
> - `"editor.formatOnSave": false`: 关闭在保存时自动格式化代码的功能。
> - `"editor.codeActionsOnSave"`: 在保存时执行的代码操作，其中 `"source.fixAll.eslint": "explicit"` 表示显式地自动修复 ESLint 报告的所有问题，`"source.organizeImports": "never"` 表示不进行导入组织操作。
> - `"eslint.rules.customizations"`: 定制 ESLint 规则，将一些样式规则的严重程度设置为 "off"，这样编辑器会静默地忽略这些规则，但仍会自动修复它们。
> - `"eslint.validate"`: 启用 ESLint 对各种语言的验证，包括 JavaScript、TypeScript、Vue、HTML、Markdown 等。

```json
{
  // 启用 ESLint 的扁平配置支持
  "eslint.experimental.useFlatConfig": true,

  // 禁用默认的格式化程序，改用 ESLint
  "prettier.enable": false,
  "editor.formatOnSave": false,

  // 自动修复
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "never"
  },

  // 在编辑器中静默规避样式规则，但仍然自动修复它们
  "eslint.rules.customizations": [
    { "rule": "style/*", "severity": "off" },
    { "rule": "format/*", "severity": "off" },
    { "rule": "*-indent", "severity": "off" },
    { "rule": "*-spacing", "severity": "off" },
    { "rule": "*-spaces", "severity": "off" },
    { "rule": "*-order", "severity": "off" },
    { "rule": "*-dangle", "severity": "off" },
    { "rule": "*-newline", "severity": "off" },
    { "rule": "*quotes", "severity": "off" },
    { "rule": "*semi", "severity": "off" }
  ],

  // 对所有支持的语言启用 ESLint
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "html",
    "markdown",
    "json",
    "jsonc",
    "yaml",
    "toml"
  ]
}

```

## 配置husky

### 安装husky与lint-staged

```cmd
pnpm install -D husky lint-staged
```

### 初始化husky

> 在package.json scripts里面新增下面语句初始化husky,也可以执行执行 npx husky-init，执行完毕后会在项目根目录自动新增.husky文件夹

```
"prepare": "husky install"
```

### 指定husky给lint-staged执行

> 使用 lint-staged 的主要原因是它可以让 lint 工具只针对暂存区中的文件运行，而不是整个项目，这样可以提高 lint 的效率，只检查即将提交的代码，而不是整个项目的所有代码。这在大型项目中尤其有用，因为 lint-staged 可以帮助减少 lint 运行的时间，提高开发效率。

```
npx husky add .husky/pre-commit "npx lint-staged"
```

## 配置commitlint

> 由于实际开发中会多人参与，对于我们的commit信息，也是有统一规范的，不能随便写,要让每个人都按照统一的标准来执行，我们可以利用**commitlint**来实现。根据***Angular***的提交规范会有以下几种

| **类型** | **描述**                                               |
| -------- | ------------------------------------------------------ |
| build    | 编译相关的修改，例如发布版本、对项目构建或者依赖的改动 |
| chore    | 其他修改, 比如改变构建流程、或者增加依赖库、工具等     |
| ci       | 持续集成修改                                           |
| docs     | 文档修改                                               |
| feat     | 新特性、新功能                                         |
| fix      | 修改bug                                                |
| perf     | 优化相关，比如提升性能、体验                           |
| refactor | 代码重构                                               |
| revert   | 回滚到上一个版本                                       |
| style    | 代码格式修改, 注意不是 css 修改                        |
| test     | 测试用例修改                                           |



### 安装  commitlint

```cmd
pnpm add @commitlint/config-conventional @commitlint/cli -D
```

### 根目录 新建 commitlint.config.cjs

```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  // 校验规则
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',
        'fix',
        'docs',
        'style',
        'refactor',
        'perf',
        'test',
        'chore',
        'revert',
        'build',
      ],
    ],
    'type-case': [0],
    'type-empty': [0],
    'scope-empty': [0],
    'scope-case': [0],
    'subject-full-stop': [0, 'never'],
    'subject-case': [0, 'never'],
    'header-max-length': [0, 'always', 72],
  },
}
```

### 在`package.json`中配置scripts命令

```
# 在scrips中添加下面的代码
{
"scripts": {
    "commitlint": "commitlint --config commitlint.config.cjs -e -V"
  },
}
```

### 给 husky新增commit-msg钩子指令

```
npx husky add .husky/commit-msg 

# 在生成的commit-msg文件中添加下面的命令(路径在.husky/)

#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"
pnpm commitlint
```

> 当我们git commit -m 时需要指定上面提到的前缀才能正常commit ，feat后面的冒号要英文的 :
>
> git commit -m "feat: 新增commitlint规范Commit记录"



## 配置环境变量配置

> 1. **安全性：** 将敏感信息（如 API 密钥、数据库密码等）存储在环境变量中比直接硬编码在代码中更安全。这样做可以避免将这些敏感信息泄露到版本控制系统中，降低了信息泄露的风险。
> 2. **灵活性：** 使用环境变量可以使你的应用程序在不同的环境中（例如开发、测试、生产）运行时具有不同的配置。你可以针对不同的环境设置不同的环境变量，而不需要修改代码。
> 3. **可维护性：** 将配置信息放在环境变量中可以使代码更易于维护。如果需要更改配置，只需更改环境变量的值，而不需要修改代码并重新部署应用程序。
> 4. **可移植性：** 使用环境变量可以使你的应用程序更具可移植性。你可以在不同的环境中轻松地部署应用程序，而无需担心配置信息的硬编码问题。
>
> 综上所述，配置环境变量是一种良好的实践，可以提高应用程序的安全性、灵活性、可维护性和可移植性。

### 根目录新建开发、测试、生产环境配置文件

> 下面命令执行不了可以直接根目录新建文件.env.development这种方式

```cmd
touch .env.development
touch .env.production
touch .env.test 
```

### 文件内容

#### 开发环境模板

```env
NODE_ENV = 'development'
# 项目名称
VITE_APP_TITLE = 'Vue 3 + Vite + TSX'
# 请求根路径
VITE_APP_BASE_API = '/dev-api'
# 请求地址
VITE_APP_BASE_URL = 'http://localhost:3000'
```

#### 生产环境模板

```
NODE_ENV = 'production'
# 项目名称
VITE_APP_TITLE = 'Vue 3 + Vite + TSX'
# 请求根路径
VITE_APP_BASE_API = '/prod-api'
# 请求地址
VITE_APP_BASE_URL = 'http://junsen.online:3000'
```

#### 测试环境模板

```
# 变量必须以 VITE_ 为前缀才能暴露给外部读取
NODE_ENV = 'test'
# 项目名称
VITE_APP_TITLE = 'Vue 3 + Vite + TSX'
# 请求根路径
VITE_APP_BASE_API = '/test-api'
# 请求地址
VITE_APP_BASE_URL = 'http://junsen.online:7001'
```

#### 启动时设置环境变量

> package.json scripts里面新增以下两条命令

```
"build:test": "vue-tsc && vite build --mode test",
"build:pro": "vue-tsc && vite build --mode production",
```

#### 给import.meta.env 添加变量提示

> 项目src目录下新增env.d.ts

```ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_APP_TITLE: string
  // 更多环境变量...
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

```

![image-20240221012925698](https://tuchuang.junsen.online/i/2024/02/21/24ycux-2.png)





## 新增路径别名

### 在vite.config.ts中新增以下配置

> 引入path冒红需要安装node头文件因为ts识别不出，执行pnpm add @types/node

```ts
resolve: {
    alias: {
      '@': path.resolve('./src'),
    },
  },
```

![image-20240221014556916](https://tuchuang.junsen.online/i/2024/02/21/2eo2iz-2.png)



## 总结

> 为什么不适用 prettier格式化？
>
> - 引用 antfu 的原话：如果你需要使用 ESLint，它也可以像 Prettier 一样格式化代码 - 而且更加可配置、Prettier + ESLint 仍然需要大量的配置 - 它并没有让你的生活变得更简单
>
>   
>
> 为什么要如此配置？
>
> - 可以规范化项目。从代码格式到校验、以及提交规范，开发环境区分，可以解决大部分因为规范引起代码混乱，不便于code review，
> - 加上在ts的加持下，提供了静态类型检查的功能，可以在编译时捕获类型错误，避免在运行时出现类型相关的错误。这可以提高代码的可靠性和可维护性以及强大的代码提示和自动完成功能，可以帮助开发人员更快地编写代码、发现 API 和库的用法，并减少错误。
>
> 还会有后续文章吗？
>
> - 会有的，后续的规划是复习node、webpack、vite等内容，从构建工具底层原理入手。