---
title: JavaScript内功修炼：原型继承
categories: ['前端笔记']
tags: ['前端笔记']
date: 2024-04-01 22:48:00 
---

# JavaScript内功修炼：探索原型机制与各类继承模式

## 对象的多种创建方式

### 字面量创建

- 字面量创建时可以直接设定属性（key）和值（value），多个属性通过逗号隔开。

#### 优点：

1. **简洁明了**：使用对象字面量创建对象时，语法简洁明了，易于理解和编写。
2. **无需额外定义构造函数**：不需要额外定义构造函数，直接通过对象字面量就可以创建对象，省去了定义构造函数的步骤。
3. **灵活性**：可以直接在对象字面量中定义对象的属性和方法，具有较高的灵活性。

#### 缺点：

1. **不利于复用**：对象字面量创建的对象无法直接复用，每次都需要重新定义，无法实现代码的重用。
2. **不利于封装**：对象字面量创建的对象无法实现属性和方法的封装，所有属性和方法都是公开的，可能会导致数据的安全性问题。
3. **无法实现继承**：对象字面量创建的对象无法实现真正的继承，无法共享父类的属性和方法，可能会导致代码的冗余。
4. **无法扩展**：对象字面量创建的对象无法动态添加新的属性和方法，一旦创建完成，就无法再进行修改。

示例代码：

```javascript
var junsen = {name: 'junsen', age: 23};
```

### 构造函数

- 通过构造函数的形式去生成，例如 Person 构造函数，函数可以接收需要传递给对象的参数，对象的 key 在构造器内部定义。

#### 优点：

1. **可重用性**：可以通过构造函数创建多个具有相同属性和方法的对象，提高代码的重用性。
2. **封装性**：可以将对象的属性和方法封装在构造函数内部，外部无法直接访问和修改，从而保证数据的安全性。
3. **可扩展性**：可以在构造函数中添加新的属性和方法，实现对象的扩展和功能的增强。
4. **易于理解和维护**：构造函数提供了一种清晰的方式来创建对象，使代码易于理解和维护。

#### 缺点：

1. **每个对象都会创建新的方法**：使用构造函数创建对象时，每个对象都会拥有一个独立的方法副本，可能会占用较多的内存空间。
2. **不能共享方法**：由于每个对象都拥有独立的方法副本，无法实现方法的共享，可能会导致代码冗余。
3. **无法实现继承**：构造函数无法实现真正的继承，每个对象都是独立的实例，无法共享父类的属性和方法。

示例代码：

```javascript
function Person(name, age) {
    this.name = name;
    this.age = age;
}
var person1 = new Person('Junsen', 23);
```

### Object 构造函数

- 使用 Object 构造函数创建对象的优缺点如下：

#### 优点：

1. **灵活性**：Object 构造函数允许动态创建对象，并在后续的代码中添加或修改属性和方法。
2. **适用于动态属性名**：可以在创建对象时使用动态的属性名，从而实现更灵活的对象结构。
3. **适用于从其他对象继承属性**：可以通过传入其他对象作为参数来继承该对象的属性，实现属性的复用。

#### 缺点：

1. **性能相对较低**：与对象字面量相比，使用 Object 构造函数创建对象的性能较低，因为需要执行额外的构造函数调用。
2. **不直观**：相比于对象字面量，使用 Object 构造函数创建对象可能会显得不够直观和易读，降低了代码的可读性。
3. **无法添加原型方法**：使用 Object 构造函数创建的对象无法直接添加原型方法，需要通过其他方式实现方法的共享，可能会导致代码的冗余。

示例代码：

```javascript
var obj = new Object();
obj.key1 = value1;
obj.key2 = value2;
```

### 工厂函数

- 使用工厂函数创建对象的优缺点如下：

#### 优点：

1. **灵活性**：工厂函数允许根据不同的参数创建不同的对象实例，从而实现对象的灵活性。
2. **封装性**：工厂函数可以封装对象的创建过程，隐藏对象的内部实现细节，提高代码的封装性。
3. **代码重用**：可以在工厂函数中实现对象的公共逻辑，从而提高代码的重用性。
4. **简化对象创建过程**：工厂函数可以简化对象的创建过程，使代码更加清晰和易读。

#### 缺点：

1. **无法实现真正的继承**：工厂函数无法实现真正的继承，每个对象都是独立的实例，无法共享父类的属性和方法。
2. **无法使用 instanceof 运算符**：由于每个对象都是通过工厂函数创建的，无法使用 instanceof 运算符来判断对象的类型，可能会导致类型判断的困难。
3. **无法使用原型链**：工厂函数无法使用原型链来实现方法的共享，可能会导致方法的冗余和内存的浪费。

示例代码：

```JavaScript
function createPerson(name) {
    var o = new Object();
    o.name = name;
    o.getName = function () {
        console.log(this.name);
    };

    return

 o;
}

var person1 = createPerson('Junsen');
```

### Object.create()

- 使用 `Object.create()` 方法创建对象的优缺点如下：

#### 优点：

1. **原型链继承**：`Object.create()` 方法可以通过指定原型对象来创建新对象，实现原型链继承，使得新对象可以共享原型对象的属性和方法。
2. **灵活性**：可以通过 `Object.create()` 方法创建具有不同原型的对象，从而实现更灵活的对象结构。
3. **简洁性**：相比于传统的构造函数和原型链继承方式，使用 `Object.create()` 方法创建对象更加简洁明了，代码量更少。
4. **可继承内置对象**：可以使用 `Object.create()` 方法创建继承自内置对象的对象，如 `Array`、`Date` 等。

#### 缺点：

1. **兼容性**：`Object.create()` 方法是 ES5 中的新特性，不兼容旧版的浏览器，需要使用 polyfill 或者转译成 ES5 兼容的代码。
2. **需要手动设置原型对象**：使用 `Object.create()` 方法创建对象时，需要手动设置原型对象，可能会增加一些额外的代码复杂度。
3. **不能直接添加属性和方法**：使用 `Object.create()` 方法创建的对象是没有自身属性和方法的，需要通过原型对象来添加属性和方法，可能会增加一些额外的代码复杂度。

示例代码：

```javascript
var obj = Object.create(null);
obj.key1 = value1;
obj.key2 = value2;
```

### class 关键字（ES6）

- 使用 `class` 关键字（ES6）创建对象的优缺点如下：

#### 优点：

1. **语法简洁**：使用 `class` 关键字可以更清晰地定义对象的结构和行为，代码量更少，可读性更高。
2. **易于理解**：`class` 关键字提供了一种面向对象的语法结构，使得代码更加易于理解和维护。
3. **支持继承**：`class` 关键字支持通过 `extends` 关键字实现类的继承，可以更方便地实现对象之间的关系。
4. **自动添加构造函数**：如果在类中没有定义构造函数，则会自动添加一个默认的构造函数，简化了对象的创建过程。
5. **支持静态方法和静态属性**：`class` 关键字支持在类中定义静态方法和静态属性，使得类的功能更加丰富和灵活。

#### 缺点：

1. **兼容性**：`class` 关键字是 ES6 中的新特性，不兼容旧版的浏览器，需要使用 polyfill 或者转译成 ES5 兼容的代码。
2. **背后仍然是基于原型的**：尽管使用 `class` 关键字可以更加直观地编写面向对象的代码，但实际上 JavaScript 仍然是基于原型的语言，`class` 关键字只是语法糖，背后仍然是基于原型的实现。

示例代码：

```javascript
class Person {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }
}
var person1 = new Person('Junsen', 23);
```



##  JavaScript 参数传递机制（按值传递和共享传递）

### 按值传递

> 什么是按值传递？
>
> - 当value通过foo构造器传递参数时，此时内部会重新新建一份一样的数据，然后拷贝过去给新建的，例如下面的代码foo里面有个形参v，这个就是新建的，会把foo(value)的值拷贝给v，我们就算在foo里面修改也不会影响到外面的value。

```JavaScript
var value = 1;
function foo(v) {
    v = 2;
    console.log(v); //2
}
foo(value);
console.log(value) // 1
```

### 共享传递

> 什么是共享传递？
>
> - 共享传递是指传递对象时，传递的是当前对象的内存地址，例如下面的第一种方式，传递obj给foo，o接收，此时的o存储的是obj在堆内存中的地址，所以通过o.value可以修改obj的value属性的值，如果按照第二种方式的话，修改的是当前foo里面的o为2了，就把原先指向obj的地址替换为2了，不是修改obj为 2

```JavaScript
// 第一种方式
var obj = {
    value: 1
};
function foo(o) {
    o.value = 2;
    console.log(o.value); //2
}
foo(obj);
console.log(obj.value) // 2


//第二种方式
var obj = {
    value: 1
};
function foo(o) {
    o = 2;
    console.log(o); //2
}
foo(obj);
console.log(obj.value) // 1
```

改变前：

| 栈内存 | 堆内存   |            |
| ------ | -------- | ---------- |
| obj    | 指针地址 | {value: 1} |
| o      | 指针地址 | {value: 1} |

改变后：

| 栈内存 | 堆内存   |            |
| ------ | -------- | ---------- |
| obj    | 指针地址 | {value: 2} |
| o      | 指针地址 | {value: 2} |

### 总结

- 参数传递传递的是参数的拷贝，如果是引用类型传递进去拷贝的是引用类型的内存地址，如果是常规基础类型的拷贝的是它本身的值
- 基本类型存储于栈中，因为它们的值是简单且固定的大小，可以直接在栈上高效地分配和回收。
- 引用类型存储于堆内存中，传递时是传递堆内存中的实际值的地址，所以修改o.value就会影响到obj



## 继承的多种方式

### 原型链继承

- 引用类型的属性被所有实例共享，举个例子：

```JavaScript
function Parent () {
    this.name = 'Junsen';
    this.skills = ['唱','跳','rap','篮球']
}

Parent.prototype.getName = function () {
    return this.name;
}

function Child () {

}

Child.prototype = new Parent();

var child1 = new Child();

console.log(child1.getName()) // Junsen

child1.skills.push('写代码');

var child2 = new Child();

console.log(child1.skills); // ['唱'，'跳','rap','篮球','写代码']
console.log(child2.skills); // ['唱'，'跳','rap','篮球','写代码']
```

### 构造器借用

- 避免了引用类型的属性被所有实例共享；
- 可以在 Child 中向 Parent 传参；

```javascript
function Parent (name) {
    this.name = name;
    this.skills = ['唱','跳','rap','篮球']
}

Parent.prototype.getName = function () {
    return this.name;
}

function Child (name) {
    Parent.call(this,name);
}

var child1 = new Child('Junsen');

child1.skills.push('写代码');

var child2 = new Child('zhangsan');

console.log(child1.skills); // ['唱'，'跳','rap','篮球','写代码']
console.log(child2.skills); // ['唱'，'跳','rap','篮球']
```

### 组合继承

- 融合原型链继承和构造函数的优点，是 JavaScript 中最常用的继承模式。

```JavaScript
function Parent (name) {
    this.name = name;
    this.skills = ['唱','跳','rap','篮球']
}

Parent.prototype.getName = function () {
    return this.name;
}

function Child (name) {
    Parent.call(this,name); // 借用构造器
}

Child.prototype = new Parent(); // 原型链继承
Child.prototype.constructor = Child; // 将构造器引用指回来

var child1 = new Child('Junsen');

child1.skills.push('写代码');
console.log(child1.getName()) // Junsen
console.log(child1.skills); // ['唱'，'跳','rap','篮球','写代码']

var child2 = new Child('zhangsan');

console.log(child2.getName()) // zhangsan
console.log(child2.skills); // ['唱'，'跳','rap','篮球']
```

### 原型式继承

- 包含引用类型的属性值始终都会共享相应的值，这点跟原型链继承一样。

```javascript
var parent = {
    name: "Parent",
    skills: ["唱", "跳", "rap", "篮球"],
    getName: function() {
        return this.name;
    }
};

var child = Object.create(parent); // 使用 parent 对象作为原型创建一个新对象

child.name = "Junsen"; // 修改新对象的属性
child.skills.push("写代码"); // 修改新对象的属性

console.log(child.getName()); // 输出 "Junsen"
console.log(child.skills); // 输出 ["唱", "跳", "rap", "篮球", "写代码"]

var anotherChild = Object.create(parent); // 创建另一个子对象

console.log(anotherChild.getName()); // 输出 "Parent"
console.log(anotherChild.skills); // 输出 ["唱", "跳", "rap", "篮球", "写代码"]

```

### 寄生式继承

```javascript
// 原型对象
function Parent (name) {
    this.name = name;
    this.skills = ['唱','跳','rap','篮球']
}

Parent.prototype.getName = function () {
    return this.name;
}

// 寄生式继承的函数
function createObj(o){
    var clone = Object.create(o);
    clone.say = function () {
        console.log('hi');
    }
    return clone;
}

var instance = createObj(new Parent("Junsen"));
console.log(instance.getName()); // 输出 "Junsen"
instance.say(); // 输出 "hi"
```

### 寄生组合式

- 寄生组合式继承是一种常用的继承方式，它继承了组合继承的优点，并避免了它的缺点, 寄生式组合继承，组合继承的缺点就是使用超类型的实例做为子类型的原型，导致添加了不必要的原型属性。寄生式组合继承的方式是使用超类型的原型的副本来作为子类型的原型，这样就避免了创建不必要的属性。

```javascript
function Parent(name) {
    this.name = name;
    this.skills = ['唱','跳','rap','篮球'];
}

Parent.prototype.getName = function () {
    return this.name;
}

function Child(name, age) {
    Parent.call(this, name); // 第一次调用父类构造函数，继承属性
    this.age = age;
}

// 继承原型方法，避免第二次调用父类构造函数
Child.prototype = Object.create(Parent.prototype);
Child.prototype.constructor = Child; // 修正constructor指向

Child.prototype.getAge = function () {
    return this.age;
}

var child1 = new Child('Junsen', 23);
console.log(child1.getName()); // 输出 "Junsen"
console.log(child1.getAge()); // 输出 23
console.log(child1.skills); // 输出 ['唱','跳','rap','篮球']

```

## new操作符的实现原理

1. 创建一个空对象。
2. 将这个空对象的`[[Prototype]]`（也称为原型）链接到构造函数的`prototype`属性。
3. 将这个空对象作为`this`上下文来调用构造函数。
4. 如果构造函数没有显式返回一个对象，则返回这个新创建的对象。

```javascript
function objectFactory(constructor, ...args) {
    // 创建一个空对象
    let obj = {};
    // 将这个空对象的原型链接到构造函数的prototype属性
    Object.setPrototypeOf(obj, constructor.prototype);
    // 将这个空对象作为this上下文来调用构造函数
    let result = constructor.apply(obj, args);
    // 如果构造函数没有显式返回一个对象，则返回这个新创建的对象
    return result instanceof Object ? result : obj;
  }

  const obj = objectFactory(Person,'Junsen',18)
  console.log(obj); // Person {name: 'Junsen', age: 18}
```

## this/call/apply/bind

### 对this对象的理解

- this是执行上下文中的一个属性，它指向最后一次调用这个方法的对象。在实际开发中，this的指向可以通过四种调用模式来判断
  1. 函数调用模式：当函数作为普通函数调用时，`this` 指向全局对象。
  2. 方法调用模式：当函数作为对象的方法调用时，`this` 指向这个对象。
  3. 构造器调用模式：当函数使用 `new` 关键字调用时，`this` 指向新创建的对象。
  4. apply、call 和 bind 调用模式：这些方法可以显式地指定函数执行时的 `this` 指向。

- 这些模式的优先级按照下面的顺序排列：构造器调用模式 > apply、call 和 bind 调用模式 > 方法调用模式 > 函数调用模式。

### call() 和 apply() ，bind()的区别

> `call()`、`apply()` 和 `bind()` 都是用来改变函数中的 `this` 指向的方法，它们之间有一些区别：

#### 参数传递方式：

- `call()` 和 `apply()` 的主要区别在于传入参数的方式。`call()` 方法传入的参数数量不固定，从第二个参数开始依次传入函数作为参数；而 `apply()` 方法接受两个参数，第一个参数指定了函数体内 `this` 对象的指向，第二个参数为一个数组或类数组对象，这些元素会作为参数传递给被调用的函数。
- 举个例子，假设有一个函数 `foo`，如果想在调用时将 `this` 指向 `obj` 对象，并传入参数 `a` 和 `b`，可以这样调用：
  - 使用 `call()`：`foo.call(obj, a, b)`
  - 使用 `apply()`：`foo.apply(obj, [a, b])`

#### 立即调用与延迟调用：

- `call()` 和 `apply()` 是立即调用的，它们会立即执行函数，并且改变函数中的 `this` 指向。
- `bind()` 则是延迟调用的，它会创建一个新的函数，并将指定的 `this` 对象绑定到新函数上，但不会立即执行。新函数可以在之后任意的时间点被调用，并且 `this` 的指向会保持绑定。

#### 返回值：

- `call()` 和 `apply()` 在调用函数后会立即返回函数执行的结果。
- `bind()` 返回一个新的函数，不会立即执行原函数，而是返回一个绑定了指定上下文的新函数，需要调用这个新函数才会执行原函数。

#### 总结：

`call()` 和 `apply()` 可以实现立即的函数调用，并且可以传入不同形式的参数，而 `bind()` 则是创建一个新的函数，将指定的 `this` 对象绑定到新函数上，之后可以在任意时间点调用这个新函数，并且 `this` 的指向会保持绑定。

### 手写call

- call函数的实现步骤
  1. **检查调用对象**：首先，要检查调用 `call()` 方法的对象是否是一个函数，因为只有函数才能调用 `call()` 方法。如果不是函数，则抛出类型错误。
  2. **获取参数**：从 `arguments` 对象中获取除了第一个参数（即要绑定的 `this` 对象）之外的所有参数，这些参数会作为调用函数的参数。
  3. **确定调用对象**：判断传入的 `this` 对象是否为 `undefined` 或 `null`，如果是，则将其设置为全局对象（在浏览器环境下是 `window`）。
  4. **绑定函数**：将调用 `call()` 方法的函数设置为传入的 `this` 对象的一个属性，以便后续调用。
  5. **调用函数**：通过设置的 `this` 对象来调用函数，并传入参数。
  6. **获取返回值**：如果函数有返回值，可以将其保存下来，以便后续返回。
  7. **清理环境**：调用完函数后，删除在 `this` 对象上设置的函数属性，以保持环境的清洁。
  8. **返回结果**：返回函数执行的结果。

```javascript
Function.prototype.myCall = function(context) {
  // 判断调用对象是否是函数
  if (typeof this !== "function") {
    console.error("type error");
  }
  // 获取参数
  let args = [...arguments].slice(1),
    result = null;
  // 判断 context 是否传入，如果未传入则设置为 window
  context = context || window;
  // 将调用函数设为对象的方法
  context.fn = this;
  // 调用函数
  result = context.fn(...args);
  // 将属性删除
  delete context.fn;
  return result;
};

```

### 手写apply

- apply函数的实现步骤
  1. **检查调用对象**：首先，要检查调用 `apply()` 方法的对象是否是一个函数，如果不是函数，则抛出类型错误。
  2. **确定上下文对象**：判断传入的上下文对象是否存在，如果不存在，则将其设置为全局对象 `window`。
  3. **绑定函数**：将调用 `apply()` 方法的函数设置为传入的上下文对象的一个属性。
  4. **判断参数**：判断传入的参数数组是否存在，如果不存在，则设置为空数组。
  5. **调用函数**：使用上下文对象来调用这个方法，并传入参数数组。
  6. **获取返回值**：如果函数有返回值，保存返回结果。
  7. **清理环境**：调用完函数后，删除在上下文对象上设置的函数属性。
  8. **返回结果**：返回函数执行的结果。

```javascript
Function.prototype.myApply = function(context, argsArray) {
  // 1. 判断调用对象是否为函数
  if (typeof this !== 'function') {
    throw new TypeError('The object is not callable');
  }
  
  // 2. 判断传入上下文对象是否存在，如果不存在，则设置为 window
  context = context || window;
  
  // 3. 将函数作为上下文对象的一个属性
  const fn = Symbol();
  context[fn] = this;
  
  // 4. 判断参数值是否传入
  argsArray = argsArray || [];
  
  // 5. 使用上下文对象来调用这个方法，并保存返回结果
  const result = context[fn](...argsArray);
  
  // 6. 删除刚才新增的属性
  delete context[fn];
  
  // 7. 返回结果
  return result;
};

```

### 手写bind

- bind函数的实现步骤
  1. **检查调用对象是否为函数**：首先，要检查调用 `bind()` 方法的对象是否是一个函数，如果不是函数，则抛出类型错误。
  2. **确定绑定对象**：将传入的 `this` 对象保存到变量 `self` 中，以便后续调用。
  3. **获取参数**：从剩余参数 `...args` 中获取传入的参数数组，如果没有传入参数，则设置为空数组。
  4. **返回新函数**：创建一个新的函数，并在函数内部将传入的参数和新函数调用时的参数合并，然后调用原函数，并绑定指定的上下文对象。
  5. **返回结果**：返回新函数。

```javascript
Function.prototype.myBind = function(context, ...args) {
  // 1. 检查调用对象是否为函数
  if (typeof this !== 'function') {
    throw new TypeError('The object is not callable');
  }
  
  // 2. 确定绑定对象
  const self = this;
  
  // 3. 获取参数
  args = args || [];
  
  // 4. 返回新函数
  return function(...innerArgs) {
    // 将固定的参数和新函数调用时传入的参数合并
    const allArgs = args.concat(innerArgs);
    // 调用原函数，并绑定上下文对象
    return self.apply(context, allArgs);
  };
};

```

