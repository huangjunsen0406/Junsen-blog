---
title: vue3-ts-vite集成electron记录
categories: ['前端笔记']
tags: ['前端笔记']
date: 2023-11-26 22:33:00
---

# vue3-ts-vite集成electron记录

## 安装electron、electron-builder

> npm install --save-dev electron electron-builder

## 准备工作

> 项目目录结构
>
> │  .cz-config.js
> │  .env
> │  .env.development
> │  .env.production
> │  .eslintrc.cjs
> │  .gitignore
> │  .npmrc
> │  .prettierrc.json
> │  catalogTree.txt
> │  commitlint.config.cjs
> │  env.d.ts
> │  index.html
> │  package.json
> │  pnpm-lock.yaml
> │  README.md
> │  tsconfig.app.json
> │  tsconfig.json
> │  tsconfig.node.json
> │  uno.config.ts
> │  vite.config.ts
> │  
> ├─.husky
> │      commit-msg
> │      pre-commit
> │      
> ├─.vscode
> │      extensions.json
> │      
> ├─electron
> │  │  background.ts
> │  │  
> │  ├─plugins
> │  │      vite-electron-build.ts
> │  │      vite-electron-dev.ts
> │  │      
> │  ├─preload
> │  │      index.ts
> │  │      
> │  └─utils
> │          build.ts
> │          handle-files.ts
> │          
> ├─public
> │      favicon.ico
> │      
> └─src
>     │  App.vue
>     │  env.d.ts
>     │  global.d.ts
>     │  main.ts
>     │  
>     ├─assets
>     │      base.css
>     │      logo.svg
>     │      main.css
>     │      
>     ├─request
>     │      index.ts
>     │      
>     ├─router
>     │      index.ts
>     │      
>     ├─stores
>     │      counter.ts
>     │      
>     ├─utils
>     │      indexed-db.ts
>     │      
>     └─views
>             ThreeDemo.vue

### 根目录新建electron文件夹

> 安装我的项目结构在根目录新建electron文件夹以及文件夹内的所有文件夹与文件

- background.ts 等同于electron文档中介绍的 main.js，因为项目已经存在main.ts，命名冲突

  ```ts
  /**
   * @description electron 主进程文件，因为项目已经有同名的main.ts了，所以使用background.ts
   */
  
  import path from 'path'
  import { app, BrowserWindow } from 'electron'
  
  // 禁用electron缓存
  app.commandLine.appendSwitch('disable-gpu-cache')
  
  function createWindow() {
      const win = new BrowserWindow({
          width: 800,
          height: 600,
          autoHideMenuBar: false,
          webPreferences: {
              preload: process.argv[2]
                  ? path.join(__dirname, '../preload/index.ts')
                  : path.join(__dirname, 'preload/index.js'),
              nodeIntegration: true, // 禁用 Node.js 整合
              contextIsolation: true, // 启用上下文隔离
              sandbox: true, // 启用沙盒模式
              webSecurity: true
          }
      })
  
      if (process.argv[2]) {
          win.webContents.openDevTools()
          win.loadURL(process.argv[2])
      } else {
          win.loadFile('index.html')
      }
  }
  
  app.whenReady().then(() => {
      createWindow()
      app.on('activate', () => {
          if (BrowserWindow.getAllWindows().length === 0) {
              createWindow()
          }
      })
  })
  
  app.on('window-all-closed', () => {
      if (process.platform !== 'darwin') {
          app.quit()
      }
  })
  
  ```

  

- utils里面的build.ts、handle-files.ts，分别处理electron文件的热更新、与项目的dist打包文件同步

  - utils/build.ts

  ```ts
  export const buildBackground = (entryPoints: string, outfile: string) => {
      // entryPoints: ['electron/background.ts'],
      // outfile: 'electron/dist/background.js',
  
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      require('esbuild').buildSync({
          entryPoints: [entryPoints],
          bundle: true,
          target: 'es2020',
          outfile,
          platform: 'node',
          external: ['electron']
      })
  }
  
  
  ```

  - electron/utils/handle-files.ts

    ```ts
    import fs from 'fs'
    import path from 'path'
    
    // 使用 fs 模块进行清空目标目录
    export function emptyDirectorySync(directory: string): void {
        if (fs.existsSync(directory)) {
            const files = fs.readdirSync(directory)
    
            files.forEach((file) => {
                const filePath = path.join(directory, file)
    
                if (fs.lstatSync(filePath).isDirectory()) {
                    emptyDirectorySync(filePath)
                } else {
                    fs.unlinkSync(filePath)
                }
            })
    
            fs.rmdirSync(directory)
        }
    }
    
    // 使用 fs 模块进行复制
    export function copyFolderSync(source: string, target: string) {
        if (!fs.existsSync(target)) {
            fs.mkdirSync(target)
        }
    
        const files = fs.readdirSync(source)
    
        files.forEach((file) => {
            const sourceFilePath = path.join(source, file)
            const targetFilePath = path.join(target, file)
    
            if (fs.lstatSync(sourceFilePath).isDirectory()) {
                copyFolderSync(sourceFilePath, targetFilePath)
            } else {
                fs.copyFileSync(sourceFilePath, targetFilePath)
            }
        })
    }
    
    ```

    

- preload是electron的预加载文件，例如IPC通信、vue与electron通信桥梁都可以在这里面定义，以下是electron官网的介绍

  > 什么是预加载脚本，并且学会如何使用预加载脚本来安全地将特权 API 暴露至渲染进程中。 不仅如此，你还会学到如何使用 Electron 的进程间通信 (IPC) 模组来让主进程与渲染进程间进行通信。
  >
  > Electron 的主进程是一个拥有着完全操作系统访问权限的 Node.js 环境。 除了 [Electron 模组](https://www.electronjs.org/zh/docs/latest/api/app) 之外，您也可以访问 [Node.js 内置模块](https://nodejs.org/dist/latest/docs/api/) 和所有通过 npm 安装的包。 另一方面，出于安全原因，渲染进程默认跑在网页页面上，而并非 Node.js里。
  >
  > 为了将 Electron 的不同类型的进程桥接在一起，我们需要使用被称为 **预加载** 的特殊脚本。
  >
  > [  electron预加载文档  ](https://www.electronjs.org/zh/docs/latest/tutorial/tutorial-preload)

  - preload/index.ts

  ```ts
  /* eslint-disable eslint-comments/disable-enable-pair */
  /* eslint-disable @typescript-eslint/no-var-requires */
  
  const { contextBridge, ipcRenderer } = require('electron')
  
  contextBridge.exposeInMainWorld('versions', {
      node: () => process.versions.node,
      chrome: () => process.versions.chrome,
      electron: () => process.versions.electron
      // 除函数之外，我们也可以暴露变量
  })
  
  console.log(ipcRenderer)
  
  ```

  

- plugins目录是vite-plugins，处理elctron开发环境与生产环境

  - electron/plugins/vite-electron-build.ts

  ```ts
  # electron/plugins/vite-electron-build.ts
  
  // 生产环境插件
  import fs from 'node:fs'
  import path from 'node:path'
  import type { Plugin } from 'vite'
  import * as electronBuilder from 'electron-builder'
  import { buildBackground } from '../utils/build'
  import { emptyDirectorySync, copyFolderSync } from '../utils/handle-files'
  
  // 源文件夹路径
  const sourcePath = path.resolve(process.cwd(), 'dist')
  
  // 目标文件夹路径
  const targetPath = path.resolve(process.cwd(), './electron/dist')
  
  // 导出 Vite 插件
  export const ElectronBuildPlugin = (): Plugin => {
      return {
          name: 'electron-build',
          closeBundle: () => {
              // 清空目标目录
              emptyDirectorySync(targetPath)
  
              // 执行复制操作
              copyFolderSync(sourcePath, targetPath)
  
              // 构建 Electron 后台脚本
              buildBackground('electron/background.ts', 'electron/dist/background.js')
              // 构建 preload预加载
              buildBackground('electron/preload/index.ts', 'electron/dist/preload/index.js')
  
              // 读取 package.json 文件并更新其中的 "main" 字段
              const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf-8'))
              packageJson.main = './background.js'
  
              // 写入更新后的 package.json 到目标文件夹
              fs.writeFileSync('./electron/dist/package.json', JSON.stringify(packageJson, null, 4))
  
              // 配置 Electron Builder 并执行构建
              const outputDir = './electron/dist/node_modules'
  
              // 确保输出目录不存在时再创建
              if (!fs.existsSync(outputDir)) {
                  fs.mkdirSync(outputDir)
              }
  
              electronBuilder.build({
                  config: {
                      directories: {
                          output: path.resolve(process.cwd(), './electron/release'),
                          app: targetPath
                      },
                      asar: true,
                      appId: 'gzjstech.com',
                      productName: 'vite-electron',
                      nsis: {
                          oneClick: false,
                          perMachine: false,
                          allowToChangeInstallationDirectory: true
                      }
                  }
              })
          }
      }
  }
  
  ```

  - vite-electron-dev.ts

    ```ts
    // 开发环境插件
    import type { AddressInfo } from 'net'
    import fs from 'node:fs'
    import { spawn, type ChildProcessWithoutNullStreams } from 'child_process'
    import type { Plugin } from 'vite'
    import { buildBackground } from '../utils/build'
    
    // 定义 Electron 进程变量
    let ElectronProcess: ChildProcessWithoutNullStreams
    
    // 导出 Vite 插件
    export const ElectronDevPlugin = (): Plugin => {
        return {
            name: 'electron-dev',
            configureServer: (server) => {
                // 构建 Electron 后台脚本
                buildBackground('electron/background.ts', 'electron/dist/background.js')
    
                // 在服务器监听事件时
                server.httpServer?.on('listening', () => {
                    // 获取服务器地址信息
                    const addressInfo = server.httpServer?.address() as AddressInfo
                    const IP = `http://localhost:${addressInfo.port}`
    
                    // 启动 Electron 进程
                    // eslint-disable-next-line @typescript-eslint/no-var-requires
                    ElectronProcess = spawn(require('electron') as unknown as string, [
                        'electron/dist/background.js',
                        IP
                    ])
    
                    // 监听后台脚本文件的变化，重新启动 Electron 进程
                    fs.watchFile('electron/background.ts', () => {
                        ElectronProcess.kill() // 终止现有 Electron 进程
                        buildBackground('electron/background.ts', 'electron/dist/background.js') // 重新构建后台脚本
                        // eslint-disable-next-line @typescript-eslint/no-var-requires
                        ElectronProcess = spawn(require('electron') as unknown as string, [
                            'electron/dist/background.js',
                            IP
                        ]) // 启动新的 Electron 进程
                    })
    
                    // 监听 Electron 进程的错误输出
                    ElectronProcess.stderr.on('data', (data) => {
                        console.log(`electron process: ${data.toString()}`)
                    })
                })
            }
        }
    }
    
    ```



	## vite.config.ts

- 引入我们编写的vite插件并注册

```ts
import { fileURLToPath, URL } from 'node:url'
import UnoCSS from 'unocss/vite'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { ElectronDevPlugin } from './electron/plugins/vite-electron-dev'
import { ElectronBuildPlugin } from './electron/plugins/vite-electron-build'

// https://vitejs.dev/config/
export default defineConfig({
    envPrefix: 'APPLET_',
    plugins: [vue(), UnoCSS(), ElectronDevPlugin(), ElectronBuildPlugin()],
    base: './',
    resolve: {
        alias: {
            '@': fileURLToPath(new URL('./src', import.meta.url))
        }
    },
    server: {
        proxy: {
            // 跨域代理
            '/apis': {
                target: 'http://' + env.VUE_APP_BASE_API,
                changeOrigin: true,
                rewrite: (path) => path.replace(/^\/apis/, '')
            }
            // 代理 WebSocket 或 socket
            // '/socket.io': {
            //   target: 'ws://localhost:3000',
            //   ws: true
            //  }
        }
    }
})

```



## preload注入后无法在web层获取相关变量

- 需要在scr下新建global.d.ts，并且在tsconfig.app.json里面引入

  ```ts
  import type { Method, ResponseType } from 'axios'
  
  export {}
  declare global {
      interface Window {
          // 这里新增preload里面的注入变量，防止window.versions报错
          electronAPI?: any //全局变量名
          versions?: any //
      }
      interface AxiosConfig {
          params?: any
          data?: any
          url?: string
          method?: Method
          headersType?: string
          responseType?: ResponseType
      }
  
      interface IResponse<T = any> {
          code: string
          data: T extends any ? T : T & any
      }
      type AxiosHeaders =
          | 'application/json'
          | 'application/x-www-form-urlencoded'
          | 'multipart/form-data'
  }
  declare const window: any
  
  ```

  - tsconfig.app.json

    ```json
    {
      "extends": "@vue/tsconfig/tsconfig.dom.json",
      // "include": ["env.d.ts", "src/**/*", "src/**/*.vue"],
      "include": ["src/**/*.ts", "src/**/*.d.ts", "src/**/*.tsx", "src/**/*.vue", "electron/**/*.ts"],
      "exclude": ["src/**/__tests__/*"],
      "compilerOptions": {
        "composite": true,
        "baseUrl": "./",
        "paths": {
          "@/*": ["./src/*"]
        },
        "types": ["three"]
      }
    }
    
    ```

    



## 打包注意点

- 需要在根目录新建 .npmrc文件把下面的三行复制进去，这样打包才不会报错

```js
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
registry=https://registry.npm.taobao.org/
electron_builder_binaries_mirror=https://npm.taobao.org/mirrors/electron-builder-binaries/
```



> 集成方案来自b站up主小满zs，与借鉴了electron-vite框架，在他们的基础上完善了这一版，通过vite生命周期实现打包完成vite后再打包electron，这样开发模式启动时就能带起electron

