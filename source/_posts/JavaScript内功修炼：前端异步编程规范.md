---
title: JavaScript内功修炼：前端异步编程规范
categories: ['前端笔记']
tags: ['前端笔记']
date: 2024-04-03 15:54:00 
---

## 异步编程背景和`Promise`的引入原因

### 异步编程的前置知识

> 异步编程在JavaScript中出现和发展的原因，主要是由JavaScript的执行环境和其单线程的特性所决定。这里有几个关键点来解释为什么异步编程变得如此重要。
>
> - **单线程执行环境**
>   - JavaScript最初被设计为一种在浏览器中运行的脚本语言，用于添加交互性和动态性。它在设计之初就是单线程的，这意味着在任何给定时刻，JavaScript在同一执行上下文中只能执行一个任务。这种设计简化了事件处理和DOM操作，因为它避免了多线程编程中常见的复杂性，如数据竞争和锁定问题。
> - **非阻塞I/O**
>   - 由于JavaScript是单线程的，阻塞式操作（如长时间运行的计算或网络请求）会冻结整个程序，导致不良的用户体验。为了避免这种情况，JavaScript环境提供了非阻塞I/O操作，这意味着可以在等待某些操作（如数据从服务器加载）完成时，继续执行其他脚本。
> - **事件循环和回调函数**
>   - JavaScript利用事件循环和回调函数来实现异步编程。事件循环允许JavaScript代码、事件回调和系统I/O等任务在适当的时候从任务队列中被取出执行，而不会阻塞主线程。这种模型支持了异步的回调形式，使得开发者可以编写非阻塞的代码，从而提高应用性能和响应速度。
> - **提高性能和响应性**
>   - 异步编程允许在等待操作完成（如从服务器获取数据）的同时，继续处理用户界面的交互和其他脚本，从而提高了Web应用的性能和响应性。用户不需要等待所有数据都加载完成才能与页面交互，这对于创建流畅的用户体验至关重要。
> - **发展需求**
>   - 随着Web技术的发展和应用越来越复杂，对于更高效、更可靠的异步编程模式的需求也随之增加。这推动了诸如`Promise`、`async/await`等新的异步编程模式的出现，使得管理复杂的异步操作和链式调用更加简单和直观。
>
> 相关文章：
>
> - [异步 JavaScript 简介](https://developer.mozilla.org/zh-CN/docs/Learn/JavaScript/Asynchronous/Introducing)
> - [异步编程那些事](https://yanhaijing.com/javascript/2017/08/02/talk-async/)
> - [真丶深入理解JavaScript异步编程（一）：异步](https://www.jeremyjone.com/766/)

### `Promise`的引入原因

> 随着Web应用程序变得越来越复杂，传统的回调方式开始显得力不从心。虽然回调函数提供了一种处理异步操作的手段，但它们也带来了所谓的"回调地狱"（Callback Hell），尤其是在处理多个异步操作时，代码会变得难以理解和维护。因此，为了解决这些问题，`Promise`应运而生。
>
> - **简化异步代码**：`Promise`提供了一种更优雅的方式来处理异步操作。通过使用`Promise`，可以避免深层嵌套的回调函数，使代码结构更加清晰和简洁。
> - **链式调用**：`Promise`支持链式调用（thenable链），这意味着可以按顺序排列异步操作，而不需要嵌套回调函数。这使得读写代码变得更加直观，也便于理解异步操作的流程。
> - **错误处理**：在传统的回调模式中，错误处理往往比较复杂且容易出错。`Promise`通过`catch`方法提供了一种集中处理错误的机制，使得错误处理更加一致和可靠。
> - **状态管理**：`Promise`对象有三种状态：pending（等待中）、fulfilled（已成功）和rejected（已失败）。这种状态管理让异步操作的结果和状态变得可预测，并且只能从`pending`状态转换到`fulfilled`或`rejected`状态，且状态一旦改变就不会再变，这为异步编程提供了更稳定的基础。
> - **改进的并发控制**：`Promise`还提供了`Promise.all`和`Promise.race`等静态方法，使得并发执行和管理多个异步操作变得更加简单和高效。
>
> `Promise`的引入是为了解决回调模式中存在的问题，同时提供了一种更强大、更灵活、更易于管理的异步编程解决方案。随后，ES2017标准引入的`async/await`语法进一步简化了异步操作的编写，但底层机制仍然基于`Promise`，说明了`Promise`在现代JavaScript异步编程中的核心地位。

## Promise的拆解

### 拆解resolve和reject

```javascript
let p1 = new Promise((resolve, reject) => {
    resolve('success')
    reject('fail')
})
console.log('p1', p1)

let p2 = new Promise((resolve, reject) => {
    reject('success')
    resolve('fail')
})
console.log('p2', p2)

let p3 = new Promise((resolve, reject) => {
    throw('error')
})
console.log('p3', p3)
```

![image-20240403155828077](https://tuchuang.junsen.online/i/2024/04/09/prv98a-2.png)



> 执行了resolve或者reject后状态会发生改变，分别对应fulfilled和rejected，状态不可逆转，除了Pending状态其他的两个状态只要为其中一个后就不会再发生变更。
>
> Promise中有throw相当于执行了reject

### 实现resolve与reject

> 初始状态为Pending，this指向执行它们的MyPromise实例，防止随着函数执行环境的改变而改变。

```javascript
// 第一步定义Promise状态
const PENDING = 'pending';
const FULFILLED = 'fulfilled';
const REJECTED = 'rejected'

// 第二步
class MyPromise {
    // 第三步定义基础属性
    PromiseState;
    PromiseResult;
    constructor(executor) {
        // 初始化状态
        this.initValue()
        // 第七步执行传进来的函数,在Promise中可以捕获抛出的异常
        try{
            // 有个前提，resolve和reject需要绑定执行它的那个Promise实例
            // 给resolve和reject绑定this
            executor(this.#resolve.bind(this),this.#reject.bind(this))
        }catch(error){
            // 如果执行器抛出异常，则调用reject方法，并传入异常
            this.#reject(error)
        }

    }

    // 第四步初始化Promise的状态
    initValue(){
        this.PromiseState = PENDING;
        this.PromiseResult = undefined;
    }

    // 第五步定义统一的状态变更函数
    #changeStatus(PromiseStatus, value){
        // Promise只有成功或失败，如果状态不是默认的Pending就表明已经变更过了，不能执行后续的代码
        if(this.PromiseState !== PENDING) return;
        this.PromiseState = PromiseStatus;
        this.PromiseResult = value;
    }

    // 第六五步定义resolve方法和reject方法
    #resolve(value){
        // 调用Promise状态变更函数
        this.#changeStatus(FULFILLED, value)
    }

    #reject(reason){
        // 调用Promise状态变更函数
        this.#changeStatus(REJECTED, reason)
    }


}
```

测试代码：状态变更

```javascript
const test1 = new MyPromise((resolve, reject) => {
    resolve('success')
})
console.log(test1) // MyPromise { PromiseState: 'fulfilled', PromiseResult: 'success' }

const test2 = new MyPromise((resolve, reject) => {
    reject('fail')
})
console.log(test2) // MyPromise { PromiseState: 'rejected', PromiseResult: 'fail' }
```

![image-20240403162104687](https://tuchuang.junsen.online/i/2024/04/09/prxbiq-2.png)

测试代码：状态不可变更

```javascript
const test1 = new MyPromise((resolve, reject) => {
    // 只以第一次为准
    resolve('success')
    reject('fail')
})
console.log(test1) // MyPromise { PromiseState: 'fulfilled', PromiseResult: 'success' }
```

![image-20240403162330753](https://tuchuang.junsen.online/i/2024/04/09/pry3jx-2.png)

测试代码：捕获Promise回调内的异常

```javascript
const test3 = new MyPromise((resolve, reject) => {
    throw('fail')
})
console.log(test3) // MyPromise { PromiseState: 'rejected', PromiseResult: 'fail' }
```

![image-20240403162451594](https://tuchuang.junsen.online/i/2024/04/09/ps84tj-2.png)

### 拆解then方法

```javascript
// 马上输出 ”success“
const p1 = new Promise((resolve, reject) => {
    resolve('success')
}).then(res => console.log(res), err => console.log(err))

// 1秒后输出 ”fail“
const p2 = new Promise((resolve, reject) => {
    setTimeout(() => {
        reject('fail')
    }, 1000)
}).then(res => console.log(res), err => console.log(err))

// 链式调用 输出 200
const p3 = new Promise((resolve, reject) => {
    resolve(100)
}).then(res => 2 * res, err => console.log(err))
  .then(res => console.log(res), err => console.log(err))
```

![image-20240403162635677](https://tuchuang.junsen.online/i/2024/04/09/hfmiq6-2.png)

> 根据上述代码可以确定：
>
> 1. then接收两个回调，一个是成功回调，一个是失败回调；
> 2. 当Promise状态为fulfilled执行成功回调，为rejected执行失败回调；
> 3. 如resolve或reject在定时器里，则定时器结束后再执行then；
> 4. then支持链式调用，下一次then执行受上一次then返回值的影响；
>
> 如何实现？
>
> 1. 结构和初始化
>
>    首先，`MyPromise`的构造函数需要接收一个执行器函数，此执行器立即执行，并接收两个参数：`resolve`和`reject`。我们需要定义三种状态（`pending`，`fulfilled`，`rejected`），以及用于存储成功/失败回调的数组。
>
> 2. `then` 方法和状态变更
>
>    `then` 方法应返回一个新的`MyPromise`对象，以支持链式调用。在`then`方法中，我们需要检查`MyPromise`的当前状态，以决定立即执行回调还是将回调存储起来待状态改变后执行。
>
>    对于定时器或异步操作，当`resolve`或`reject`在这些操作内部调用时，`then`注册的回调应在操作完成后执行。这意味着我们需要在状态仍为`pending`时收集这些回调，并在`resolve`或`reject`被调用时按顺序执行它们。
>
> 3. 链式调用和值的传递
>
>    为了支持链式调用，每次调用`then`时都应创建并返回一个新的`MyPromise`对象。这个新的`MyPromise`对象的解决或拒绝应基于前一个`then`回调的返回值。
>
>    如果回调函数返回一个值，这个值应传递给链中下一个`then`的成功回调。如果回调函数抛出异常，则应将异常传递给链中下一个`then`的失败回调。如果回调函数返回一个新的`MyPromise`，则该`Promise`的结果应决定链中下一个`then`的调用。

### 实现then

- `#executeCallbacks`执行缓存的promise
- `resolvePromise` 处理不同的返回值类型
- `onFulfilledCallbacks`和 `onRejectedCallbacks` 存储对应状态的执行任务

```javascript
// 第一步定义Promise状态
const PENDING = 'pending';
const FULFILLED = 'fulfilled';
const REJECTED = 'rejected'

// 第二步
class MyPromise {
    // 第三步定义基础属性
    PromiseState;
    PromiseResult;
    onFulfilledCallbacks = []; // 初始化成功回调的存储数组
    onRejectedCallbacks = []; // 初始化失败回调的存储数组
    constructor(executor) {
        // 初始化状态
        this.initValue()
        // 第七步执行传进来的函数,在Promise中可以捕获抛出的异常
        try {
            // 有个前提，resolve和reject需要绑定执行它的那个Promise实例
            // 给resolve和reject绑定this
            executor(this.#resolve.bind(this), this.#reject.bind(this))
        } catch (error) {
            // 如果执行器抛出异常，则调用reject方法，并传入异常
            this.#reject(error)
        }

    }

    // 第四步初始化Promise的状态
    initValue() {
        this.PromiseState = PENDING;
        this.PromiseResult = undefined;
    }

    // 第五步定义统一的状态变更函数
    #changeStatus(PromiseState, value) {
        // Promise只有成功或失败，如果状态不是默认的Pending就表明已经变更过了，不能执行后续的代码
        if (this.PromiseState !== PENDING) return;
        this.PromiseState = PromiseState;
        this.PromiseResult = value;

        // 每次状态变更后都要执行#executeCallbacks方法，根据当前状态执行对应的回调函数
        this.#executeCallbacks()
    }

    // 第六五步定义resolve方法和reject方法
    #resolve(value) {
        // 调用Promise状态变更函数
        this.#changeStatus(FULFILLED, value)
    }

    #reject(reason) {
        // 调用Promise状态变更函数
        this.#changeStatus(REJECTED, reason)
    }

    #executeCallbacks() {
        // 根据当前状态，执行对应的回调函数
        if (this.PromiseState === FULFILLED) {
            while (this.onFulfilledCallbacks.length) {
                // 因为数组本身就和队列的性质一样，通过shift方法可以取出数组中的第一个元素,然后执行里面缓存的回调函数，把当前状态传进去（这里执行的就是存入数组的resolvePromise辅助函数）
                this.onFulfilledCallbacks.shift()(this.PromiseResult)
            }
        } else if (this.PromiseState === REJECTED) {
            while (this.onRejectedCallbacks.length) {
                this.onRejectedCallbacks.shift()(this.PromiseResult)
            }
        }
    }

    // 第八步定义then方法接收两个回调 onFulfilled, onRejected
    then(onFulfilled, onRejected) {
        // 判断是否是函数如果不是包装下返回值为函数
        onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : value => value;
        onRejected = typeof onRejected === 'function' ? onRejected : reason => { throw reason };
        // 根据上面分析得知，then是支持链式调用，返回的一个包装后的promise对象并且传递给下一个then的成功回调，失败的给失败的
        const thenPromise = new MyPromise((resolve, reject) => {
            // 通过queueMicrotask来异步执行回调，以确保符合Promise规范的异步行为。这也解决了thenPromise变量作用域的问题，因为handleCallback是在thenPromise被定义之后才使用的。
            // 创建辅助函数resolvePromise
            const resolvePromise = (callback, resolve, reject) => {
                // 使用js提供的微任务环境，因为then本身就是微任务
                queueMicrotask(() => {
                    try {
                        // 立即执行传入的onFulfilled或onRejected方法，拿到结果存起来
                        const result = callback(this.PromiseResult)
                        // 判断结果是不是和当前返回的promise对象是同一个，如果是则抛出异常，因为循环引用了
                        if (result && result === thenPromise) {
                            throw new Error('循环引用');
                        }
                        // 判断当前结果是不是一个Promise对象，如果是则调用then方法，把结果传进去，把then返回的promise对象作为结果返回
                        if (result instanceof MyPromise) {
                            result.then(resolve, reject)
                        } else {
                            resolve(result);
                        }
                    } catch (error) {
                        // 拦截thenPromise内部的异常返回回去，然后继续往外抛出
                        reject(error)
                        throw new Error(error);
                    }
                })
            }

            // 根据状态处理不同状态的回调函数
            if (this.PromiseState === FULFILLED) {
                // 如果当前为成功状态，执行第一个回调
                resolvePromise(onFulfilled, resolve, reject)
            } else if (this.PromiseState === REJECTED) {
                // 如果当前为失败状态，执行第二个回调
                resolvePromise(onRejected, resolve, reject)
            } else if (this.PromiseState === PENDING) {
                // 如果当前为等待状态，把回调函数存起来，等状态变更后再执行
                this.onFulfilledCallbacks.push(() => resolvePromise(onFulfilled, resolve, reject))
                this.onRejectedCallbacks.push(()=>resolvePromise(onRejected, resolve, reject))
            }
        })

        return thenPromise;
    }

}
```

测试用例

```javascript
// 测试用例 1: 基本的resolve和链式调用
const promise1 = new MyPromise((resolve, reject) => {
    resolve(1);
});
promise1.then(value => {
    console.log(value); // 应打印 1
    return value + 1;
}).then(value => {
    console.log(value); // 应打印 2
});

// 测试用例 2: 使用setTimeout来模拟异步操作
const promise2 = new MyPromise((resolve, reject) => {
    setTimeout(() => {
        resolve(2);
    }, 1000);
});
promise2.then(value => {
    console.log(value); // 1秒后应打印 2
    return new MyPromise((resolve, reject) => {
        setTimeout(() => {
            resolve(value + 2);
        }, 1000);
    });
}).then(value => {
    console.log(value); // 2秒后应打印 4
});

// 测试用例 3: 错误处理
const promise3 = new MyPromise((resolve, reject) => {
    throw new Error('Test Error');
});
promise3.then(value => {
    console.log(value);
}, error => {
    console.error(error.message); // 应打印 "Test Error"
})

```

## queueMicrotask

相关链接：[queueMicrotask](https://developer.mozilla.org/zh-CN/docs/Web/API/HTML_DOM_API/Microtask_guide)

> GPT的解释
>
> `queueMicrotask`是一个在现代浏览器和Node.js环境中内置的全局函数，用于将一个函数安排在所有正在执行的宏任务（例如setTimeout、setInterval、I/O操作等）和当前正在执行的微任务（例如Promise的回调）之后、但在下一个宏任务开始之前执行。它提供了一种方式来异步执行代码，而不会延迟到下一个宏任务，从而能够在当前任务和下一个事件循环之间快速地运行一个任务。
>
> `queueMicrotask`的主要用途是安排微任务（microtask），这是执行异步操作的一种方式，比起宏任务来说，微任务具有更高的优先级。在Promise相关操作中使用`queueMicrotask`可以确保按照正确的顺序执行异步代码，尤其是在实现自定义Promise或处理与Promise相关的微任务队列时。

```javascript
console.log('Script start');

setTimeout(() => {
  console.log('setTimeout'); // 宏任务
}, 0);

queueMicrotask(() => {
  console.log('queueMicrotask'); // 微任务
});

Promise.resolve().then(() => {
  console.log('Promise.then'); // 微任务
});

console.log('Script end');

```

### 手写queryMicrotask

- 写法是渡一袁老师的写法，学习如何实现一个`queueMicrotask`

```javascript
function runMicroTask(runc) {
    if (typeof process === 'object' && typeof process.nextTick === 'function') {
        // Node.js 环境
        process.nextTick(runc);
    } else if (typeof MutationObserver === 'function') {
        // 浏览器环境，使用 MutationObserver
        let counter = 1;
        const observer = new MutationObserver(() => {
            runc();
            observer.disconnect(); // 清理，避免重复调用和内存泄漏
        });
        const textNode = document.createTextNode(String(counter));
        observer.observe(textNode, {
            characterData: true
        });
        counter = (counter + 1) % 2; // 切换值以触发MutationObserver
        textNode.data = String(counter);
    } else {
        // 作为最后的回退，使用 setTimeout
        setTimeout(runc, 0);
    }
}

```





## Promise A+ 规范实现

```javascript
// 第一步定义Promise状态
const PENDING = 'pending';
const FULFILLED = 'fulfilled';
const REJECTED = 'rejected'

function isPromise(obj) {
    return !!(obj && typeof obj === 'object' && typeof obj.then === 'function');
}

// 第二步
class MyPromise {
    // 第三步定义基础属性
    PromiseState;
    PromiseResult;
    onFulfilledCallbacks = []; // 初始化成功回调的存储数组
    onRejectedCallbacks = []; // 初始化失败回调的存储数组
    constructor(executor) {
        // 初始化状态
        this.initValue()
        // 第七步执行传进来的函数,在Promise中可以捕获抛出的异常
        try {
            // 有个前提，resolve和reject需要绑定执行它的那个Promise实例
            // 给resolve和reject绑定this
            executor(this.#resolve.bind(this), this.#reject.bind(this))
        } catch (error) {
            // 如果执行器抛出异常，则调用reject方法，并传入异常
            this.#reject(error)
        }

    }

    // 第四步初始化Promise的状态
    initValue() {
        this.PromiseState = PENDING;
        this.PromiseResult = undefined;
    }

    // 第五步定义统一的状态变更函数
    #changeStatus(PromiseState, value) {
        // Promise只有成功或失败，如果状态不是默认的Pending就表明已经变更过了，不能执行后续的代码
        if (this.PromiseState !== PENDING) return;
        this.PromiseState = PromiseState;
        this.PromiseResult = value;

        // 每次状态变更后都要执行#executeCallbacks方法，根据当前状态执行对应的回调函数
        this.#executeCallbacks()
    }

    // 第六五步定义resolve方法和reject方法
    #resolve(value) {
        // 调用Promise状态变更函数
        this.#changeStatus(FULFILLED, value)
    }

    #reject(reason) {
        // 调用Promise状态变更函数
        this.#changeStatus(REJECTED, reason)
    }

    #executeCallbacks() {
        // 根据当前状态，执行对应的回调函数
        if (this.PromiseState === FULFILLED) {
            while (this.onFulfilledCallbacks.length) {
                // 因为数组本身就和队列的性质一样，通过shift方法可以取出数组中的第一个元素,然后执行里面缓存的回调函数，把当前状态传进去（这里执行的就是存入数组的resolvePromise辅助函数）
                this.onFulfilledCallbacks.shift()(this.PromiseResult)
            }
        } else if (this.PromiseState === REJECTED) {
            while (this.onRejectedCallbacks.length) {
                this.onRejectedCallbacks.shift()(this.PromiseResult)
            }
        }
    }

    // 第八步定义then方法接收两个回调 onFulfilled, onRejected
    then(onFulfilled, onRejected) {
        // 判断是否是函数如果不是包装下返回值为函数
        onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : value => value;
        onRejected = typeof onRejected === 'function' ? onRejected : reason => { throw reason };
        // 根据上面分析得知，then是支持链式调用，返回的一个包装后的promise对象并且传递给下一个then的成功回调，失败的给失败的
        const thenPromise = new MyPromise((resolve, reject) => {
            // 通过queueMicrotask来异步执行回调，以确保符合Promise规范的异步行为。这也解决了thenPromise变量作用域的问题，因为handleCallback是在thenPromise被定义之后才使用的。
            // 创建辅助函数resolvePromise
            const resolvePromise = (callback, resolve, reject) => {
                // 使用js提供的微任务环境，因为then本身就是微任务
                queueMicrotask(() => {
                    try {
                        // 立即执行传入的onFulfilled或onRejected方法，拿到结果存起来
                        const result = callback(this.PromiseResult)
                        // 判断结果是不是和当前返回的promise对象是同一个，如果是则抛出异常，因为循环引用了
                        if (result && result === thenPromise) {
                            throw new Error('循环引用');
                        }
                        // 判断当前结果是不是一个Promise对象，如果是则调用then方法，把结果传进去，把then返回的promise对象作为结果返回
                        if (isPromise(result)) {
                            result.then(resolve, reject)
                        } else {
                            resolve(result);
                        }
                    } catch (error) {
                        // 拦截thenPromise内部的异常返回回去，然后继续往外抛出
                        reject(error)
                        throw new Error(error);
                    }
                })
            }

            // 根据状态处理不同状态的回调函数
            if (this.PromiseState === FULFILLED) {
                // 如果当前为成功状态，执行第一个回调
                resolvePromise(onFulfilled, resolve, reject)
            } else if (this.PromiseState === REJECTED) {
                // 如果当前为失败状态，执行第二个回调
                resolvePromise(onRejected, resolve, reject)
            } else if (this.PromiseState === PENDING) {
                // 如果当前为等待状态，把回调函数存起来，等状态变更后再执行
                this.onFulfilledCallbacks.push(() => resolvePromise(onFulfilled, resolve, reject))
                this.onRejectedCallbacks.push(() => resolvePromise(onRejected, resolve, reject))
            }
        })

        return thenPromise;
    }

    static resolve(data) {
        return new MyPromise((resolve, reject) => {
            if (isPromiseLike(data)) {
                data.then(resolve, reject);
            } else {
                resolve(data);
            }
        });
    }

    static reject(reason) {
        return new MyPromise((resolve, reject) => {
            reject(reason);
        });
    }


    static all(promises) {
        const result = [];
        let count = 0;

        return new MyPromise((resolve, reject) => {
            const addData = (index, value) => {
                result[index] = value;
                count++;
                if (count === promises.length) {
                    resolve(result);
                }
            }

            promises.forEach((promise, index) => {
                if (isPromise(promise)) {
                    promise.then(res => {
                        addData(index, res);
                    }, error => reject(error));
                } else {
                    addData(index, promise);
                }
            })
        })
    }

    static race(promises) {
        return new MyPromise((resolve, reject) => {
            promises.forEach(promise => {
                if(isPromise(promise)) {
                    promise.then(res => {
                        resolve(res)
                    }, err => {
                        reject(err)
                    })
                } else {
                    resolve(promise)
                }
            })
        })
    }

    static allSettled(promises) {
        return new Promise((resolve, reject) => {
            const res = []
            let count = 0
            const addData = (status, value, i) => {
                res[i] = {
                    status,
                    value
                }
                count++
                if (count === promises.length) {
                    resolve(res)
                }
            }
            promises.forEach((promise, i) => {
                if (isPromise(promise)) {
                    promise.then(res => {
                        addData('fulfilled', res, i)
                    }, err => {
                        addData('rejected', err, i)
                    })
                } else {
                    addData('fulfilled', promise, i)
                }
            })
        })
    }

    static any(promises) {
        return new Promise((resolve, reject) => {
            let count = 0
            promises.forEach((promise) => {
                promise.then(val => {
                    resolve(val)
                }, err => {
                    count++
                    if (count === promises.length) {
                        reject(new AggregateError('All promises were rejected'))
                    }
                })
            })
        })
    }

    catch(onRejected) { 
        return this.then(null, onRejected); 
    }

    finally(onSettled) {
        return this.then(
            (data) => {
                onSettled();
                return data;
            },
            (reason) => {
                onSettled();
                throw reason;
            }
        );
    }
}
```

## 测试案例

### 基本的链式调用

```javascript
// 基本的链式调用
const promise = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('First promise resolved');
  }, 1000);
});

promise.then((result) => {
  console.log(result); // 输出: First promise resolved
  return 'Second promise value';
}).then((result) => {
  console.log(result); // 输出: Second promise value
});
```

### 返回新的 Promise 对象

```javascript
const promise2 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 2 resolved');
  }, 1000);
});

promise2.then((result) => {
  console.log(result); // 输出: Promise 2 resolved
  return new MyPromise((resolve, reject) => {
    setTimeout(() => {
      resolve('Nested Promise resolved');
    }, 1000);
  });
}).then((result) => {
  console.log(result); // 输出: Nested Promise resolved
});

```

### 抛出错误

```javascript
const promise3 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 3 resolved');
  }, 1000);
});

promise3.then((result) => {
  console.log(result); // 输出: Promise 3 resolved
  throw new Error('Custom error');
}).catch((error) => {
  console.error(error); // 输出: Error: Custom error
});
```

### 返回新的 Promise 对象，并且处理错误

```javascript
const promise4 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 4 resolved');
  }, 1000);
});

promise4.then((result) => {
  console.log(result); // 输出: Promise 4 resolved
  return new MyPromise((resolve, reject) => {
    setTimeout(() => {
      reject('Nested Promise rejected');
    }, 1000);
  });
}).catch((error) => {
  console.error(error); // 输出: Nested Promise rejected
});
```

### 异步操作

```JavaScript
const promise5 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 5 resolved');
  }, 1000);
});

promise5.then((result) => {
  return new MyPromise((resolve, reject) => {
    setTimeout(() => {
      resolve(result + ' with additional data');
    }, 1000);
  });
}).then((result) => {
  console.log(result); // 输出: Promise 5 resolved with additional data
});
```

### 使用 all 方法

```javascript
const promise1 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 1 resolved');
  }, 1000);
});

const promise2 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 2 resolved');
  }, 2000);
});

const promise3 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 3 resolved');
  }, 3000);
});

MyPromise.all([promise1, promise2, promise3]).then(values => {
  console.log(values);
}).catch(error => {
  console.error(error);
});

```

### 使用 any 方法

```javascript
const promise4 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    reject('Promise 4 rejected');
  }, 1000);
});

const promise5 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 5 resolved');
  }, 2000);
});

const promise6 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 6 resolved');
  }, 3000);
});

MyPromise.any([promise4, promise5, promise6]).then(value => {
  console.log(value);
}).catch(errors => {
  console.error(errors);
});
```

### 使用 race 方法

```javascript
const promise7 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 7 resolved');
  }, 1000);
});

const promise8 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 8 resolved');
  }, 2000);
});

const promise9 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 9 resolved');
  }, 3000);
});

MyPromise.race([promise7, promise8, promise9]).then(value => {
  console.log(value);
}).catch(error => {
  console.error(error);
});

```

### 使用 allSettled 方法

```javascript
const promise10 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 10 resolved');
  }, 1000);
});

const promise11 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    reject('Promise 11 rejected');
  }, 2000);
});

const promise12 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve('Promise 12 resolved');
  }, 3000);
});

MyPromise.allSettled([promise10, promise11, promise12]).then(results => {
  console.log(results);
});
```

