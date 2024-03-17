---
title: JavaScript内功修炼：编译原理、执行上下文与作用域链全方位实战解析
categories: ['前端笔记']
tags: ['前端笔记']
date: 2024-03-18 01:51:00
---


# JavaScript内功修炼：编译原理、执行上下文与作用域链全方位实战解析

尽管通常将 JavaScript 视为“动态”或“解释型”语言，但它不同于传统预编译语言之处在于，JavaScript 代码不是提前编译的，且编译结果不能直接移植到其他环境。JavaScript被归类为“动态”或“解释执行”语言，主要是由于以下两个方面的特点：

1. 动态类型系统：在 JavaScript 中，变量的类型可以在运行时动态改变。例如，变量 `num` 可以先初始化为数字 `1`，然后重新赋值为字符串 `"1"`。这与静态类型语言（如 Java）中变量声明时即确定类型的机制不同，在 JavaScript 中，变量内存大小由其当前存储的值决定而非声明时指定。
2. 解释执行：JavaScript 引擎逐行解释并执行代码，而不是像 C++ 或 Java 那样先编译成机器码再执行。这种特性允许代码在运行时被修改和执行，如通过 `eval()` 函数执行字符串形式的 JavaScript 代码片段。

### 编译流程概览

#### 分词/词法分析（Tokenizing/Lexing）

词法分析是编译过程的第一步，它将源代码分解为一系列有意义的基本单元——词法单元（tokens），比如关键字、标识符、运算符、数字等。例如，对于表达式 `var a = 2;`，词法分析器会识别出 `'var'`、`'a'`、`'='` 和 `';'` 等词法单元。

#### 解析/语法分析（Parsing）

解析阶段将词法单元流转换为抽象语法树（Abstract Syntax Tree, AST）。AST 是一个结构化的树形数据模型，表示程序的语法结构。以 `var a = 2;`为例，对应的 AST 中包含一个顶层节点 `VariableDeclaration`，下级有 `Identifier`（`a`）节点和 `AssignmentExpression` 节点，后者又有一个子节点 `NumericLiteral`（值为 `2`）。AST 描述了代码的逻辑层次关系，便于后续编译或解释阶段使用。

#### 代码生成

代码生成阶段将 AST 转换为可执行代码。对于给定的语句 `var a = 2;`，目标是在执行时创建变量 `a`，分配内存，并将数值 `2` 存储至该内存地址中。JavaScript 引擎不仅在执行前进行编译，还会进行即时编译（JIT）、延迟编译等多种优化手段来提升性能。



## 原型和原型链

- 构造函数（constructor）：构造函数是用于创建对象的特殊函数，通过 `new` 关键字调用来创建新的对象，并将对象的原型指向构造函数的原型（prototype）。
- 原型（prototype）：每个对象都具有一个特殊属性 `__proto__`，指向该对象的构造函数的原型对象。构造函数的 `prototype` 属性则指向了该构造函数创建的所有实例对象的原型对象。
- 原型链（prototype chain）：原型链是通过对象的 `__proto__` 属性构成的链式结构，用于实现对象之间的继承关系。当访问对象的属性时，JavaScript 引擎会沿着原型链向上查找，直到找到匹配的属性或者到达原型链的顶端（即 `Object.prototype`）为止。
- 总结：
  1. 构造函数通过 `prototype` 属性指向原型对象，对象通过 `__proto__` 属性指向构造函数的原型对象，这构成了原型链。当访问对象属性时，如果原型链查找到顶部仍未找到，则返回 `null`。
  2. **Function函数是所有函数的祖先函数：**`Function` 函数是 JavaScript 中所有函数的祖先函数，因为所有函数都是由 `Function` 构造函数创建的。
  3. **所有构造函数都有一个 prototype 属性：** 所有构造函数都具有一个 `prototype` 属性，这个属性指向了该构造函数创建的所有实例对象的原型对象。
  4. **所有原型对象都有一个 constructor 属性：** 所有原型对象都具有一个 `constructor` 属性，指向其对应的构造函数。
  5. **所有函数都是对象：** 在 JavaScript 中，函数也是一种对象。函数可以被赋值给变量，作为对象的属性，传递给函数等，因此它们也是对象的一种。
  6. **所有对象都有一个 `__proto__` 属性：** 所有对象都具有一个 `__proto__` 属性，它指向了该对象的原型对象。这个属性构成了原型链的基础。

​							!![image-20240316135952389](https://tuchuang.junsen.online/i/2024/03/18/3c041e-2.png)				

```javascript
// 构造函数
function Person(){}

// prototype是实例原型
Person.prototype.name = "Junsen";

// 实例对象
const person = new Person();

console.log(person.name);
// 实例对象person的__proto__指向实例原型Person.prototype
console.log(person.__proto__ === Person.prototype);

// Person构造函数与prototype的桥梁是constructor
console.log(Person === Person.prototype.constructor);

// Person的__proto__指向 Function.prototype
console.log(Person.__proto__ === Function.prototype);

// Person实例原型的__proto__指向 Object.prototyp
console.log(Person.prototype.__proto__ === Object.prototype);

// Function.prototype.constructor指向 Function
console.log(Function.prototype.constructor === Function);

// Function的__proto__ 指向 Function的实例原型
console.log(Function.__proto__ === Function.prototype);

// Function实例原型的__proto__ 指向 Object.prototype
console.log(Function.prototype.__proto__ === Object.prototype);

// Object的__proto__又指向 Function的实例原型prototype
console.log(Object.__proto__ === Function.prototype);

// Object实例原型的contructor指向Object
console.log(Object.prototype.constructor === Object);

// Object实例原型指向null
console.log(Object.prototype.__proto__ === null);
```



## 执行上下文与作用域

### 执行上下文

- 先进后出后进先出（LIFO）
- **动态创建和销毁：** 每当代码开始执行时，js引擎都会创建一个新的执行上下文，并将其推入执行上下文栈的顶部。当代码执行完毕后出栈
- **执行上下文栈管理：**执行上下文以堆栈的形式组织，被称为执行上下文栈或者调用栈。栈的特效保证了执行上下文的正确管理和代码执行顺序的维护。
- **变量提升：**在执行上下文中，变量和函数声明都会被提升到作用域顶部，这被称为变量提升。这意味着可以在声明前访问变量和函数。
- **作用域链接：**每个执行上下文都有一个词法环境，包含了当前作用域的变量和函数声明，同时也引用了外部执行的上下文词法环境，形成作用于链。作用域链决定了变量和函数的查找顺序，
- **闭包的产生：** 作用域链的存在使得内部函数可以访问外部的函数的变量，从而形成了闭包，闭包可以保留对其词法作用域的引用，使得函数可以在定义的作用域之外执行，并且仍然可以访问定义时的变量。
- **变量和函数的生命周期：** 变量和函数的生命周期与其所在的执行上下文相关联。在执行上下文被销毁时，其中的变量和函数也会被销毁，释放内存空间。



#### 顺序执行

- 代码从上到下执行

```javascript
var foo = function () {

    console.log('foo1');

}

foo();  // foo1

var foo = function () {

    console.log('foo2');

}

foo(); // foo2
```

#### 可执行代码

- 全局代码（Global code）：全局代码是指全局作用域中执行的代码，即不包含在任何函数内部的代码。当程序启动时，会先执行全局代码。全局代码可以包含变量声明、函数声明、以及其他可执行语句。
- 函数代码（Function code）：函数代码是指在函数内部定义的代码块。每当函数调用时，都会创建一个新的执行上下文（Execution Context），并执行函数代码。函数代码可以包含变量声明、语句、和其他函数的定义等。
- eval代码（Eval code）：当使用 `eval` 函数执行字符串作为 JavaScript 代码时，该代码会被动态解析和执行，并插入到当前执行上下文中。然而，由于 `eval` 具有动态性，可能导致代码执行的不可预测性和安全性问题，因此应该谨慎使用。
- 总结：在 JavaScript 中，可执行代码（executable code）主要分为三种类型：全局代码（global code）、函数代码（function code）和 eval 代码。

#### 执行上下文栈

- 执行上下文栈（Execution Context Stack）是JavaScript引擎用来管理执行上下文的数据结构。它是一个栈，用于存储当前执行代码的执行上下文。
- 每当代码开始执行时都会创新一个新的上下文，并将其推入执行上下文栈的顶部。
- 当代码执行完成后，对应的执行执行上下文就会被弹出栈。这种先进后出的方式确保了执行上下文的正确管理，保证了代码的执行顺序。
- 执行上下文栈主要的作用是跟踪代码执行的过程中的上下文信息，包含变量、作用域链、this指向等、通过执行上下文栈，JavaScript引擎能够在代码执行过程中准确地确定变量和函数的作用域，以及各种执行环境的关系。

### 作用域是什么？

> 作用域是 JavaScript 中管理变量可见性和生命周期的规则集合。它决定了变量在哪里可以被访问以及何时创建和销毁。作用域链的概念保证了在嵌套的作用域中正确查找变量，而闭包正是由于作用域链的存在，使得内部函数能够访问外部函数的变量，即使在外部函数执行完毕后仍然能够保持对外部变量的引用。

#### 执行上下文栈的模拟

```javascript
// 定义执行上下文对象
class ExecutionContext {
    constructor(name) {
        this.name = name;
    }
}

// 定义执行上下文栈
class ExecutionContextStack {
    constructor() {
        this.stack = [];
    }

    // 推入执行上下文
    push(context) {
        this.stack.push(context);
    }

    // 弹出执行上下文
    pop() {
        return this.stack.pop();
    }

    // 获取当前栈顶执行上下文
    peek() {
        return this.stack[this.stack.length - 1];
    }

    // 获取执行上下文栈的大小
    size() {
        return this.stack.length;
    }
}

```

##### Case1

```javascript
// case 1
var scope = "global scope";
function checkscope(){
    var scope = "local scope";
    function f(){
        return scope;
    }
    return f();
}
checkscope();

// 创建全局上下文栈实例
const ecs = new ExecutionContextStack();

// 模拟执行上下文的创建和销毁过程
ecs.push(new ExecutionContext('Global')) // 创建全局执行上下文推入栈中

function checkScope(){
    ecs.push(new ExecutionContext('checkScope')); //创建 checkScope 函数执行上下文并推入栈中
    var scope = "local scope"
    function f(){
        ecs.push(new ExecutionContext('f')); //创建f函数执行上下文并推入栈中
        console.log('current context:',ecs.peek().name); // 打印当前执行上下文的名称
        ecs.pop(); // 弹出栈顶执行上下文
        return scope;
    }
    const result = f();
    ecs.pop(); // 弹出栈顶执行上下文
    return result;
}

const result = checkScope();
console.log("Return value：", result);
```

- 总结：在这个案例中，`checkScope`函数被调用后会立即执行，并且在执行过程中会创建一个新的执行上下文`checkScope`。在`checkScope`中又定义了个`f`函数，并且在`f`函数中访问了外部函数`checkScope`的scope变量。由于JavaScript的词法作用域规则，`f`函数在查找变量时会首先查找自身函数的作用域，如果没有就会向上查找,所以获取到了checkScope的scope。因此`f`函数返回的scope是checkScope的scope值，即`local scope`

##### Case2

```javascript
// case 2
var scope = "global scope";
function checkscope(){
    var scope = "local scope";
    function f(){
        return scope;
    }
    return f;
}
checkscope()();


// 创建执行上下文栈实例
const ecs = new ExecutionContextStack();

// 模拟执行上下文的创建销毁过程
ecs.push(new ExecutionContext('Global')); // 创建全局执行上下文并推入栈中

var scope = "global scope";

function checkScope(){
    ecs.push(new ExecutionContext('checkScope')); // 创建checkScope的执行上下文并推入栈
    var scope = 'local scope';
    
    function f(){
        ecs.push(new ExecutionContext('f')); //创建f函数的执行上下文并推入栈中
        console.log('Current context：', ecs.peek().name); //打印当前执行上下文的名称
        ecs.pop(); //弹出栈顶的执行上下文
        return scope;
    }
    
    const result = f;
    ecs.pop(); // 弹出栈顶执行上下文
    return result;
}

const result = checkScope()();
console.log('Return value:',result);
```

- 这个案例中，`checkScope`函数被调用后返回一个内部定义的函数 `f`。此时并没有立即执行`f`函数，而是将其作为值通过return返回出去给外部调用。因此外部调用`checkScope()()`时，实际上是在执行返回的`f`函数。由于词法作用域的规则，`f`函数在查找变量时仍会按照静态作用域的规则向上查找外部的作用域。所以返回的结果是`local scope`。

##### 总结：

- 在这两个案例中，不同的是第一个是`Global上下文`、`checkScope上下文`、`f上下文`的入栈执行，然后`f上下文`、`checkScope上下文`、`Global上下文`的顺序出栈，第二个案例f函数作为返回值返回来。在外部调用`checkScope`时然后再调用`f`函数,所以它们的出入栈顺序是 Global上下文，`checkScope`上下文，此时`checkScope`上下文已经执行完毕出栈，但是`f`函数又被调用了，此时`f`函数入栈继续执行，执行完毕后出栈，才到`Global上下文`出栈

## 变量对象与作用域链

### 变量对象

- JavaScript中的“变量对象”是执行上下文“Execution Context”中用来存储变量和函数声明的内部数据结构，在代码执行过程中起着重要的作用，用来管理变量和函数的创建、访问和执行。

  - **创建阶段：** 在此阶段，变量对象被创建，并且在变量对象中存储了所有的变量和函数声明。但是这个阶段中，变量和函数声明的实际赋值操作并没执行。
  - **执行阶段：** 在此阶段，JavaScript引擎会逐行执行代码，并按照代码的顺序对变量对象中的变量进行赋值操作。

  变量对象包含以下内容：

  - **函数参数：** 在函数上下文中，函数的参数会被存储在变量对象中，每个参数都会被作为变量对象的属性，属性名为参数名，属性值为传入的参数值。如果调用函数时没有提供参数，则对应的属性值为undefined。
  - **函数声明：** 在函数上下文中，通过function关键字声明的函数会被整体存储在变量对象中。函数声明会被视为变量对象的属性，属性名为函数名，属性值为对应的函数对象。如果变量对象已经存在相同名称的属性，则会完全替换该属性，以最新声明的函数为准。
  - **变量声明：** 在函数上下文中，通过var关键字声明的变量会被存储在变量对象中。变量声明会被视为变量对象的属性，属性名为变量名，属性值为undefined。如果变量名与已经声明的形式参数或函数名相同，则变量声明不会干扰已经存在的这类属性，即不会覆盖已存在的属性。

> Vo（Variable Object）和Ao（Activation Object）是早期ECMAScript规范中使用的术语，用于描述执行上下文中变量对象的不同阶段。它们本质上都是同一个东西，只是表现得状态不一样。
>
> - Vo（Variable Object）：这是执行上下文进入创建阶段时生成的内部数据结构，它包含了所有变量声明和函数声明。在这个阶段，只记录变量名和函数声明而不进行实际赋值。
> - Ao（Activation Object）：当代码开始执行，即进入执行阶段时，激活对象作为动态生成的对象出现，它用于存储变量的实际值以及对函数引用的访问。Ao是对变量对象的一种扩展，在现代JavaScript引擎中，这个概念通常不再明确区分，而是统一为执行上下文中的一个单一变量对象，并随着执行过程逐步填充变量的实际值。
>
> 在现代JavaScript引擎中，激活对象已经不再是一个显式的概念，而是被整合到执行上下文中的变量对象中。

### 进入执行上下文

```js
function foo(a) {
  var b = 2;
  function c() {}
  var d = function() {};

  b = 3;

}

foo(1);

在进入执行上下文后，这时候的 AO 是：
AO = {
    arguments: {
        0: 1,
        length: 1
    },
    a: 1,
    b: undefined,
    c: reference to function c(){},
    d: undefined
}
```

### 代码执行

- 在代码执行阶段，会顺序执行代码，根据代码，修改变量对象的值

```js
AO = {
    arguments: {
        0: 1,
        length: 1
    },
    a: 1,
    b: 3,
    c: reference to function c(){},
    d: reference to FunctionExpression "d"
}
```

### 总结：

- **全局上下文的变量对象初始化**：全局上下文的变量对象初始化为全局对象，即全局变量和全局函数都会成为全局对象的属性。
- **函数上下文的变量对象初始化**：函数上下文的变量对象初始化只包括 `arguments` 对象，用于存储传入函数的参数信息。
- **进入执行上下文时的变量对象初始化**：在进入执行上下文时，会给变量对象添加形参、函数声明、变量声明等初始的属性值。形参作为属性名，对应的值为传入的参数值；函数声明和变量声明作为属性名，对应的值分别为函数引用和 `undefined`。
- **代码执行阶段的变量对象更新**：在代码执行阶段，会根据代码的逐行执行，对变量对象的属性值进行修改和更新。函数和变量的赋值操作会更新变量对象中对应属性的值。

### 自定义Ecs模拟

```js
// 定义执行上下文对象
class ExecutionContext {
    constructor(name) {
        this.name = name;
        this.variableObject = {}; // 变量对象
        this.scopeChain = []; // 作用域链
        this.thisValue = undefined; // this
    }
}

// 定义执行上下文栈
class ExecutionContextStack {
    constructor() {
        this.stack = [];
    }

    // 推入执行上下文
    push(context) {
        // 更新作用域链
        if (this.stack.length > 0) {
            context.scopeChain = [...this.stack[this.stack.length - 1].scopeChain, context.variableObject];
        } else {
            context.scopeChain = [context.variableObject];
        }
        this.stack.push(context);
        
        console.log('stack',this.stack);
        console.log('context',context);
    }

    // 弹出执行上下文
    pop() {
        console.log('stack',this.stack);
        return this.stack.pop();
    }

    // 获取当前栈顶执行上下文
    peek() {
        return this.stack[this.stack.length - 1];
    }

    // 获取执行上下文栈的大小
    size() {
        return this.stack.length;
    }
}

```

#### Case1

```js
var scope = "global scope"; // 声明一个全局变量 scope，赋值为 "global scope"
function checkscope(){ // 定义函数 checkscope
    var scope = "local scope"; // 声明一个局部变量 scope，赋值为 "local scope"
    function f(){ // 定义内部函数 f
        return scope; // 返回当前作用域中的 scope 变量的值
    }
    return f(); // 调用内部函数 f 并返回其结果
}
checkscope(); // 调用函数 checkscope

// 创建全局上下文栈实例
const ecs = new ExecutionContextStack();

// 创建全局执行上下文
const globalContext = new ExecutionContext("global"); // 创建全局执行上下文对象，名称为 "global"
globalContext.variableObject.scope = "global scope"; // 将全局变量 scope 的值设置为 "global scope"
ecs.push(globalContext)
console.log("current context:",ecs.peek().name); // 打印当前执行上下文的名称

//创建checkScope函数执行上下文。
const checkScopeContext = new ExecutionContext("checkscope"); // 创建 checkscope 函数执行上下文对象，名称为 "checkscope"
checkScopeContext.variableObject.scope = undefined; // 在 checkscope 函数执行上下文中，变量对象中的 scope 属性为 undefined
checkScopeContext.variableObject.arguments = {length: 0}; // 在 checkscope 函数执行上下文中，变量对象中的 arguments 属性为一个对象，表示没有传入参数

function checkScope(){ // 定义函数 checkScope
    ecs.push(checkScopeContext); // 将 checkScope 函数执行上下文推入执行上下文栈中，表示进入了 checkScope 函数的执行过程
	checkScopeContext.variableObject.scope = "local scope"; // 将局部变量 scope 的值设置为 "local scope"，表示进入了 checkScope 函数内部的执行过程
    var scope = 'local scope'; // 声明一个局部变量 scope，赋值为 "local scope"
    // 创建 f 函数执行上下文
    const fContext = new ExecutionContext("f"); // 创建内部函数 f 的执行上下文对象，名称为 "f"
    fContext.variableObject.scope = undefined; // 在 f 函数执行上下文中，变量对象中的 scope 属性为 undefined
    fContext.variableObject.arguments = {length: 0}; // 在 f 函数执行上下文中，变量对象中的 arguments 属性为一个对象，表示没有传入参数
    function f(){ // 定义内部函数 f
        ecs.push(fContext); // 将 f 函数执行上下文推入执行上下文栈中，表示进入了 f 函数的执行过程
         // 模拟 VO 到 AO 的变化
    	fContext.variableObject = { scope: "local scope" };
        console.log("current context:",ecs.peek().name); // 打印当前执行上下文的名称
        ecs.pop(); // 弹出栈顶执行上下文，表示退出了 f 函数的执行过程
        return scope; // 返回当前作用域中的 scope 变量的值
    }
    const result = f(); // 调用内部函数 f，并将结果保存在 result 变量中
    ecs.pop(); // 弹出栈顶执行上下文，表示退出了 checkScope 函数的执行过程
    return result; // 返回函数执行结果
}

const result = checkScope(); // 调用函数 checkScope，并将结果保存在 result 变量中
console.log('Return value:',result); // 打印函数执行结果

```

#### Case2

```js
var scope = "global scope"; // 声明一个全局变量 scope，赋值为 "global scope"
function checkscope(){ // 定义函数 checkscope
    var scope = "local scope"; // 声明一个局部变量 scope，赋值为 "local scope"
    function f(){ // 定义内部函数 f
        return scope; // 返回当前作用域中的 scope 变量的值
    }
    return f; // 调用内部函数 f 并返回其结果
}
checkscope()(); // 调用函数 checkscope

// 创建全局上下文栈实例
const ecs = new ExecutionContextStack();

// 创建全局执行上下文
const globalContext = new ExecutionContext("global"); // 创建全局执行上下文对象，名称为 "global"
globalContext.variableObject.scope = "global scope"; // 将全局变量 scope 的值设置为 "global scope"
ecs.push(globalContext)
//创建checkScope函数执行上下文。
const checkScopeContext = new ExecutionContext("checkscope"); // 创建 checkscope 函数执行上下文对象，名称为 "checkscope"
checkScopeContext.variableObject.scope = undefined; // 在 checkscope 函数执行上下文中，变量对象中的 scope 属性为 undefined
checkScopeContext.variableObject.arguments = {length: 0}; // 在 checkscope 函数执行上下文中，变量对象中的 arguments 属性为一个对象，表示没有传入参数

function checkScope(){ // 定义函数 checkScope
    ecs.push(checkScopeContext); // 将 checkScope 函数执行上下文推入执行上下文栈中，表示进入了 checkScope 函数的执行过程
	checkScopeContext.variableObject.scope = "local scope"; // 将局部变量 scope 的值设置为 "local scope"，表示进入了 checkScope 函数内部的执行过程
    var scope = 'local scope'; // 声明一个局部变量 scope，赋值为 "local scope"
    // 创建 f 函数执行上下文
    const fContext = new ExecutionContext("f"); // 创建内部函数 f 的执行上下文对象，名称为 "f"
    fContext.variableObject.scope = undefined; // 在 f 函数执行上下文中，变量对象中的 scope 属性为 undefined
    fContext.variableObject.arguments = {length: 0}; // 在 f 函数执行上下文中，变量对象中的 arguments 属性为一个对象，表示没有传入参数
   
     // 定义内部函数 f
    function f(){
         ecs.push(fContext); // 将 f 函数执行上下文推入执行上下文栈中，表示进入了 f 函数的执行过程
         // 模拟 VO 到 AO 的变化
    	fContext.variableObject = { scope: "local scope" };
        console.log("current context:",ecs.peek().name); // 打印当前执行上下文的名称
        ecs.pop(); // 弹出栈顶执行上下文，表示退出了 f 函数的执行过程
        return scope; // 返回当前作用域中的 scope 变量的值
    }
    ecs.pop(); // 弹出栈顶执行上下文，表示退出了 checkScope 函数的执行过程
    return f; // 返回函数执行结果
}
console.log('ecs',ecs.size())
const result = checkScope()();
console.log('Return value:',result); // 打印函数执行结果


```





### 作用域链

在 JavaScript 中，作用域链是理解变量访问规则的关键概念之一。简单来说，作用域链决定了在代码执行过程中如何查找变量。下面是对作用域链的优化解释：

1. **ES6 前后的变量声明方式**：
   - 在 ES6 之前，我们使用 `var` 关键字声明变量时，它们会被提升到所在函数作用域的顶部，而没有块级作用域的概念。这意味着变量的作用域由函数的边界确定。
   - ES6 引入了 `let` 和 `const` 关键字，它们允许我们在任意代码块（比如 `{}`）内创建变量，从而引入了块级作用域的概念。这让我们更加灵活地管理变量的作用域范围。
2. **作用域链的形成**：
   - 作用域链并不仅仅是由大括号的嵌套关系决定的，而是由函数的嵌套关系决定的。在 JavaScript 中，函数内部可以访问外部的变量，这导致了作用域链的形成。
   - 每当 JavaScript 引擎执行代码时，会创建一个执行上下文，并按照函数的嵌套关系形成作用域链。作用域链的顶部是当前执行代码的作用域，然后依次向上查找，直到找到变量或达到全局作用域。
3. **作用域链的查找规则**：
   - JavaScript 引擎按照就近原则从当前作用域开始查找变量。如果在当前作用域找不到变量，则会依次向上层作用域查找，直到找到变量或者达到全局作用域为止。
4. **全局作用域的特殊性**：
   - 全局作用域是所有函数作用域的外层作用域。这是因为 JavaScript 引擎在执行代码时首先创建一个全局执行上下文，其中包含了整个代码的执行环境。函数在定义时会捕获所在的作用域链，因此可以访问外部的变量。

> 总之，作用域链决定了 JavaScript 中变量的访问规则，而理解作用域链对于编写高质量的 JavaScript 代码至关重要。

```javascript
// 全局作用域
var x = "global";

function fn1(){
    // 一级作用域
    var x = "outer";

    function fn2(){
        // 二级作用域
        console.log(x); // 在这里访问变量 x
    }

    fn2(); // 调用 fn2 函数
}

fn1(); // 调用 fn1 函数

```

在这个例子中，我们在不同的作用域中定义了同名的变量 `x`。现在让我们来看一下执行时的作用域链：

1. 在 `fn2` 函数内部，我们尝试访问变量 `x`。由于 `fn2` 内部并没有定义变量 `x`，JavaScript 引擎会沿着作用域链向上查找。
2. 在 `fn2` 函数的外部（即 `fn1` 函数内部），我们定义了变量 `x`，其值为 `"outer"`。因此，JavaScript 引擎在这一级找到了变量 `x`，并将其值打印出来。
3. 如果在 `fn1` 函数内部也没有定义变量 `x`，JavaScript 引擎会继续向上查找，最终到达全局作用域。在全局作用域中，我们定义了变量 `x`，其值为 `"global"`。

所以，最终输出的结果将会是 `"outer"`，因为在作用域链中，`fn2` 函数可以访问到 `fn1` 函数内部定义的变量 `x`，而不是全局作用域中的变量 `x`。

## 预解析

在浏览器执行 JavaScript 代码时，首先进行的是预解析（Hoisting），这是一个重要的步骤。预解析阶段并不是直接执行代码，而是对代码进行加工处理，以便后续的逐行执行。

在预解析阶段，主要有以下几个规则：

1. **变量和函数声明提升**：
   - 使用 `var` 关键字声明的变量以及函数声明会被提升到当前作用域的顶部。这意味着变量和函数可以在它们被声明之前被引用。
   - 使用 `let` 和 `const` 关键字声明的变量不会被提升，它们只能在声明后才能被访问。
2. **变量与函数同名时的处理**：
   - 如果在同一个作用域内，既有变量又有函数使用了相同的名称，那么函数声明会优先于变量声明被提升到作用域顶部。
   - 这意味着在预解析阶段，同名函数会覆盖同名变量的声明，因此在预解析后，该名称会被认定为函数。
3. **代码的顺序保持不变**：
   - 在进行预解析后，虽然变量和函数的声明被提升到了作用域顶部，但是原始代码的书写顺序不会改变。预解析只是将声明提升到了最顶部，而不会改变代码的执行顺序。

总的来说，预解析是 JavaScript 在执行之前对代码进行的一种预处理，它确保了变量和函数的声明在执行时可以被正确地访问。理解预解析对于理解 JavaScript 的执行机制是非常重要的。

### 预解析练习1

```javascript
 var num = 123;
fun()
function fun(){
    console.log(num);
    var num = 456;
}
/**
 * 
 var num;
 function fun(){
    var num;
    console.log(num); undefined
    num = 456;
}
num = 123;
fun();
 */
```

### 预解析练习2

```JavaScript
var a = 666;
test()
function test(){
    var b = 777;
    console.log(a);
    console.log(b);
    console.log(c);
    var a = 888;
    let c = 999;
}

/* 
var a;
function test(){
    var b;
    var a;
    b = 777;
    console.log(a); undefined
    console.log(b); 777
    console.log(c); 报错
    a = 888;
    let c = 999;
}
a = 666;
test() */
```

### 预解析练习3

```javascript
if(true){
    function demo(){
        console.log('demo() 1');
    }
}else {
    function demo(){
        console.log('demo() 2');
    }
}
demo()


/* 
在es6之前没有块级作用域，并没有将下面的函数定义到其他函数中所以这两个函数是全局作用域的。
注意点：高级浏览器不会对花括号中的函数进行函数提升，只会在低级浏览器中按照正常方式解析,
（低级浏览器ie11以下的）正常情况是输出demo() 1，但在低级浏览器中会输出demo() 2
function demo(){
    console.log('demo() 1');
}
function demo(){
    console.log('demo() 2');
}
if(true){}else{}
demo()
*/
```

### 预解析练习4

```javascript
console.log(value)
var value = 123;
function value(){
    console.log('fn value');
}
console.log(value)

/* 
注意点：变量与函数名称相同时，函数的优先级高于变量

function value(){
    console.log('fn value');
}
console.log(value)
var value;
value = 123;
console.log(value)
*/

```





