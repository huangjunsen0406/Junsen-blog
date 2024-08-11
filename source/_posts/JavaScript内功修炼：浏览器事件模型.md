---
title: JavaScript内功修炼：浏览器事件模型
categories: ['前端笔记']
tags: ['前端笔记']
date: 2024-08-11 17:37:00
---

## Dom

> DOM`(Document Object Model`，文档对象模型)是针对HTML文档和XML文档的一个API。DOM描绘了一个层次化的节点树，允许开发人员添加、移出和修改页面的某一部分，DOM 脱胎于Netscape 及微软公司创始的 DHTML（动态HTML）。但现在它已经成为表现和操作页面标记的真正跨平台、语言中立的方式。
>
> `Netscape Navigator 4` 和 `IE4` 分别发布于 1997 年的 6 月和 10 月发布的 DHTML，由于 `IE4` 和 `Netscape Navigator4` 分别支持不同的 DHTML，为了统一标准，W3C开始制定 DOM。1998 年10 月 W3C 总结了 IE 和 Navigator4 的规范，制定了 DOMLevel 1即 DOM1，之前 IE 与 Netscape 的规范则被称为 DOMLevel 0 即 DOM0 。

### 节点（Node）

- 文档节点（Document Node）：整棵文档树的根节点。
- 元素节点（Element Node）：代表 HTML 或 XML 标签。
- 文本节点（Text Node）：元素或属性中的文本内容。
- 属性节点（Attribute Node）：元素的属性。
- 注释节点（Comment Node）：文档中的注释。

### 属性（Attributes）

- 可以通过 `element.getAttribute(name)`、`element.setAttribute(name, value)` 和 `element.removeAttribute(name)` 方法来访问和操作元素的属性。

### 方法（Methods）

- `document.getElementById(id)`：通过 ID 查找元素。
- `document.getElementsByClassName(className)`：通过类名查找元素。
- `document.getElementsByTagName(tagName)`：通过标签名查找元素。
- `document.querySelector(selector)`：通过 CSS 选择器查找第一个匹配的元素。
- `document.querySelectorAll(selector)`：通过 CSS 选择器查找所有匹配的元素。

### 节点操作

- `element.appendChild(newNode)`：添加子节点。
- `element.removeChild(node)`：移除子节点。
- `element.replaceChild(newNode, oldNode)`：替换子节点。
- `element.insertBefore(newNode, referenceNode)`：在指定节点前插入新节点。

### 节点属性

- `element.childNodes`：获取子节点列表。
- `element.firstChild` 和 `element.lastChild`：获取第一个和最后一个子节点。
- `element.parentNode`：获取父节点。
- `element.nextSibling` 和 `element.previousSibling`：获取下一个和上一个兄弟节点。

### 事件的基本概念

- **事件（Event）**：浏览器中发生的某种动作或事件，比如用户的鼠标点击、键盘输入、页面加载等。
- **事件监听器（Event Listener）**：一种函数，用于监听和处理特定类型的事件。
- **事件目标（Event Target）**：触发事件的对象，通常是 DOM 元素。
- **事件对象（Event Object）**：当事件被触发时，浏览器会生成一个事件对象，包含与事件相关的信息，如事件类型、目标、坐标等。

### 事件的类型

- **用户界面事件**：如 `click`、`dblclick`、`mousemove`、`mouseover`、`mouseout`、`mousedown`、`mouseup`、`focus`、`blur` 等。
- **键盘事件**：如 `keydown`、`keypress`、`keyup`。
- **表单事件**：如 `submit`、`change`、`input`、`select`。
- **窗口事件**：如 `load`、`resize`、`scroll`、`unload`。
- **触摸事件**：如 `touchstart`、`touchmove`、`touchend`（在移动设备上使用）。

### DOM0

> **DOM Level 0** 是早期浏览器支持的一组非标准特性，主要用于简单的动态交互。
>
> **特点**：通过内联事件处理器直接在 HTML 元素上定义事件，不需要通过 JavaScript 代码动态添加事件监听。但是在 IE 中，在使用 DOM0 级方法添加事件处理程序时，event 是作 window 对象的一个属性而存在的。此时访问事件对象需要通过 `window.event`。

```html
<!DOCTYPE html>
<html>
<head>
  <title>DOM Level 0 Example</title>
</head>
<body>
  <button onclick="alert('Button clicked!')">Click me</button>
</body>
</html>


<!-- HTML -->
<button id="btn">Click</button>

<!-- JavaScript -->
<script>
    var btn = document.getElementById('btn');
    btn.onclick = function() {
      alert('xxx');
    };
	// 解除事件绑定
    btn.onclick = null
</script>

```

### DOM2

> W3C 后来将 DOM1 升级为 DOM2，DOM2级规范开始尝试以一种符合逻辑的方式来标准化 DOM事件。DOM0级 可以认为 onclick 是 btn 的一个属性，DOM2级 则将属性升级为队列。
>
> DOM2级 事件定义了两个方法，用于处理指定和删除事件处理程序的操作，`addEventListener()`和`removeEventListener()`，所有的 DOM 节点中都包含这两个方法，它们都接收 3 个参数。
>
> 1. 要处理的事件名；
> 2. 作为事件处理程序的函数；
> 3. 布尔值，true 代表在捕获阶段调用事件处理程序，false 表示在冒泡阶段调用事件处理程序，默认为 false；
>
> **注意点**：引入了 `addEventListener()` 方法，支持事件捕获和冒泡。增强了事件模型的灵活性，当dom通过`addEventListener()`将事件加入到监听队列中，浏览器发现用户点击按钮时，click 队列中依次执行匿名函数，通过`addEventListener()`添加的事件只能由`removeEventListener()`来移除，并且`removeEventListener()`只能移除具名函数，不能移除匿名函数。

```html
<!DOCTYPE html>
<html>
<head>
  <title>DOM Level 2 Example</title>
</head>
<body>
  <p id="demo">Hello, World!</p>
  <button id="changeText">Change Text</button>
  <script>
    var button = document.getElementById('changeText');
    button.addEventListener('click', function() {
      var paragraph = document.getElementById('demo');
      paragraph.textContent = 'Hello, DOM Level 2!';
    });
  </script>
</body>
</html>

```

```JavaScript
btn.addEventListener('click',function(){
  //  do something
})
btn.addEventListener('click',function(){
  //  do something else
})

```

### IE中 DOM2级事件

> IE8 及之前，实现类似`addEventListener()`和`removeEventListener()`的两个方法是`attachEvent()`和`detachEvent()`，这两个方法接受相同的两个参数。
>
> 1. 要处理的事件名；
> 2. 作为事件处理程序的函数；
>
> IE8 之前的只支持事件冒泡，所以通过`attachEvent()`添加的事件处理程序只能添加到冒泡阶段。
>
> 当用户点击时，click 队列依次`fn1.call(undefined,undefined)`，`fn2.call(undefined,undefined)`。
>
> 类似的`detachEvent()`也只能移除具名函数，不能移除匿名函数。

```JavaScript
btn.attachEvent('click',fn1)
btn.attachEvent('click',fn2)
```

### dom事件总结

> 1. DOM2级的好处是可以添加多个事件处理程序；DOM0对每个事件只支持一个事件处理程序；
> 2. 通过DOM2添加的匿名函数无法移除，上面写的例子就移除不了，`addEventListener`和`removeEventListener`的handler必须同名；
> 3. 作用域：DOM0的handler会在所属元素的作用域内运行，IE的handler会在全局作用域运行，`this === window`；
> 4. 触发顺序：添加多个事件时，DOM2会按照添加顺序执行，IE会以相反的顺序执行；
> 5. 跨浏览器的事件处理程序

### 事件传播

事件传播有三个阶段：

- **捕获阶段（Capture Phase）**：事件从文档的根节点向事件目标传播。

- **目标阶段（Target Phase）**：事件到达事件目标，事件处理器在此阶段执行。

- **冒泡阶段（Bubble Phase）**：事件从事件目标向文档的根节点传播。

  ![1723364402492](https://tuchuang.junsen.online/i/2024/08/11/qsje4q-2.jpg)

### 自定义事件

- 开发者可以使用 `CustomEvent` 构造函数创建和触发自定义事件。

  ```js
  var myEvent = new CustomEvent('myCustomEvent', { detail: { key: 'value' } });
  element.dispatchEvent(myEvent);
  ```

### 事件委托

> ### 事件委托的机制
>
> - **事件冒泡**：事件在触发时会从目标元素开始向上传递（冒泡），直到到达 `document` 或 `window` 对象。这一过程允许父元素监听子元素的事件。
> - **目标节点获取**：父节点在事件处理函数中可以通过 `event.target` 属性获取实际的目标节点，即用户与之交互的子元素。这允许父节点能够识别哪个子元素被点击或触发了事件。
> - **减少内存消耗**：由于只需要在父节点上绑定一次事件监听器，而不是为每个子节点绑定，减少了浏览器需要管理的事件监听器数量，从而降低内存使用。
> - **动态元素处理**：当新的子元素动态添加到 DOM 中时，无需为新元素单独设置事件处理程序，因为事件监听器已经在父节点上。这样，新增的子元素会自动受到事件委托机制的影响。
> - **简化代码**：通过在父节点处理子元素事件，可以集中管理和处理，代码更加简洁和易于维护。
>
> ### 缺点
>
> - **复杂性增加**：在事件处理逻辑中，需要通过 `event.target` 检查和确认事件的实际目标元素，这可能导致代码复杂度增加，尤其是在复杂的 DOM 结构中。
>
> - **事件冒泡的依赖**：事件委托依赖于事件冒泡机制，如果某个子元素使用了 `event.stopPropagation()` 方法来阻止事件冒泡，那么事件将不会到达父元素，导致事件委托失效。
>
> - **潜在的性能问题**：对于非常大的 DOM 树或高度嵌套的结构，事件冒泡可能会导致性能下降，尽管这种情况在现代浏览器中很少见。
> - **不支持某些事件**：某些事件，例如 `focus` 和 `blur`，默认不支持冒泡。这意味着这些事件不能被委托，需要使用 `focusin` 和 `focusout` 事件替代。
>
> - **延迟事件处理**：由于事件需要冒泡到父元素才被处理，这可能会导致事件响应时间略高于直接在目标元素上处理，尽管通常这种延迟是可以忽略不计的。
>
> - **复杂交互时的调试困难**：当多个事件处理器通过委托方式绑定在父元素上时，调试特定事件处理器可能会比较困难。
>
> ### 局限性
>
> - **CSS 样式和伪类的限制**：事件委托不能直接处理与 CSS 伪类相关的事件，例如 `:hover` 或 `:active`。这些事件需要通过直接绑定或额外的 JavaScript 逻辑来处理。
> - **事件目标不易获取**：在复杂的 DOM 结构中，准确获取 `event.target` 并验证其属性可能需要额外的代码，这会增加事件处理函数的复杂性。
>
> - **动态变化的 DOM 结构**：虽然事件委托适用于动态添加的元素，但在频繁修改 DOM 结构的场景中，可能需要额外的逻辑来确保事件处理器正常工作。
>
> - **特定业务逻辑的局限性**：对于某些特定的业务逻辑，可能需要在事件处理器中做出复杂的判断和分支处理，导致代码冗长和难以维护。
> - **兼容性问题**：某些浏览器或某些事件类型（例如某些旧版本浏览器中的 `focus` 和 `blur` 事件）可能不支持事件冒泡，从而影响事件委托的实现。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Event Delegation Example</title>
    <style>
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            cursor: pointer;
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        li:hover {
            background-color: #f0f0f0;
        }
    </style>
</head>
<body>

    <ul id="itemList">
        <li>Item 1</li>
        <li>Item 2</li>
        <li>Item 3</li>
        <li>Item 4</li>
        <li>Item 5</li>
    </ul>

    <script>
        // 获取 ul 元素
        var itemList = document.getElementById('itemList');

        // 使用事件委托为 ul 添加事件监听器
        itemList.addEventListener('click', function(event) {
            // 检查点击事件的目标是否为 li 元素
            if (event.target && event.target.nodeName === 'LI') {
                // 打印被点击的 li 的文本内容
                alert('Clicked on: ' + event.target.textContent);
            }
        });
    </script>

</body>
</html>

```

### preventDefault与stopPropagation

> preventDefault：比如链接被点击会导航到其href指定的URL，这个就是默认行为；
>
> stopPropagation：立即停止事件在DOM层次中的传播，包括捕获和冒泡事件；
>
> IE中对应的属性：
>
> - srcElement => target
> - returnValue => preventDefaukt()
> - cancelBubble => stopPropagation()

### 事件订阅兼容写法

```js
var EventUtil = {
  // element是当前元素，可以通过getElementById(id)获取
  // type 是事件类型，一般是click ,也有可能是鼠标、焦点、滚轮事件等等
  // handle 事件处理函数
  addHandler: (element, type, handler) => {
    // 先检测是否存在DOM2级方法,再检测IE的方法，最后是DOM0级方法（一般不会到这）
    if (element.addEventListener) {
      // 第三个参数false表示冒泡阶段
      element.addEventListener(type, handler, false);
    } else if (element.attachEvent) {
      element.attachEvent(`on${type}`, handler)
    } else {
      element[`on${type}`] = handler;
    }
  },

  removeHandler: (element, type, handler) => {
    if (element.removeEventListener) {
      // 第三个参数false表示冒泡阶段
      element.removeEventListener(type, handler, false);
    } else if (element.detachEvent) {
      element.detachEvent(`on${type}`, handler)
    } else {
      element[`on${type}`] = null;
    }
  },
  // 获取event对象
  getEvent: (event) => {
    return event ? event : window.event
  },
  // 获取当前目标
  getTarget: (event) => {
    return event.target ? event.target : event.srcElement
  },
  // 阻止默认行为
  preventDefault: (event) => {
    if (event.preventDefault) {
      event.preventDefault()
    } else {
      event.returnValue = false
    }
  },
  // 停止传播事件
  stopPropagation: (event) => {
    if (event,stopPropagation) {
      event.stopPropagation()
    } else {
      event.cancelBubble = true
    }
  }
}

// 获取元素
var btn = document.getElementById('btn');
// 定义handler
var handler = function(e) {
  console.log('我被点击了');
}
// 监听事件
EventUtil.addHandler(btn, 'click', handler);
// 移除事件监听
// EventUtil.removeHandler(button1, 'click', clickEvent);
```

## BOM

> BOM（Browser Object Model）是浏览器对象模型，它提供了与浏览器窗口进行交互的接口。BOM 不像 DOM 那样是标准化的，但它是现代浏览器实现的一部分，用于控制浏览器的各个方面，如窗口、历史记录、导航等。以下是 BOM 的主要组成部分

### Window对象 - 常用方法和属性

> **概述**：`window` 是 BOM 的核心对象，表示浏览器窗口。所有全局 JavaScript 对象、函数和变量都是 `window` 的属性。

- `alert(message)`: 显示警告框。
- `confirm(message)`: 显示确认框，并返回布尔值。
- `prompt(message, defaultValue)`: 显示提示框，并返回用户输入的字符串。
- `setTimeout(function, delay)`: 设置定时器，执行一次。
- `setInterval(function, interval)`: 设置间隔执行。
- `clearTimeout(timeoutID)`: 清除定时器。
- `clearInterval(intervalID)`: 清除间隔执行。
- `open(url, name, specs)`: 打开新窗口。
- `close()`: 关闭当前窗口。

###  Navigator 对象

> 提供浏览器的信息，常用于检测浏览器类型和版本。

- `navigator.userAgent`: 用户代理字符串，包含浏览器信息。
- `navigator.language`: 浏览器的语言设置。
- `navigator.platform`: 操作系统的信息。

### Location 对象

> - **HashRouter**：使用 URL 中的 hash (`#`) 来保持 UI 和 URL 同步。因此，`location.pathname` 和 `location.search` 在这种模式下并不改变，因为 URL 的 hash 部分不会被视为路径或查询字符串的一部分，而是被用于客户端的路由控制。
> - **BrowserRouter**：使用 HTML5 的历史 API (`pushState`、`replaceState`) 来实现路由，因此 `location.pathname` 和 `location.search` 可以正常工作，反映 URL 的路径和查询参数。
>
> 在使用 `HashRouter` 时，只能通过 `window.location.hash` 来获取 hash 部分的内容，而 `BrowserRouter` 可以完整地支持路径和查询字符串。

- `location.href`: 当前页面的完整 URL。
- `location.protocol`: URL 的协议部分（如 `http:`）。
- `location.host`: 主机名和端口号。
- `location.pathname`: 路径部分。
- `location.search`: 查询字符串。
- `location.hash`: URL 中的哈希部分。
- `location.assign(url)`: 加载新的文档。
- `location.reload()`: 重新加载当前文档。

```js
// Example URL: http://example.com:8080/path/page.html?query=123#section

// 获取当前页面的完整 URL
console.log(location.href); // 输出: "http://example.com:8080/path/page.html?query=123#section"

// 获取 URL 的协议部分
console.log(location.protocol); // 输出: "http:"

// 获取主机名和端口号
console.log(location.host); // 输出: "example.com:8080"

// 获取路径部分
console.log(location.pathname); // 输出: "/path/page.html"

// 获取查询字符串
console.log(location.search); // 输出: "?query=123"

// 获取 URL 中的哈希部分
console.log(location.hash); // 输出: "#section"

// 加载新的文档
location.assign('http://example.com/newpage.html');

// 重新加载当前文档
location.reload();

```



### History 对象

> 用于操作浏览器的会话历史记录。

- `history.back()`: 加载历史记录中的前一个 URL。
- `history.forward()`: 加载历史记录中的下一个 URL。
- `history.go(n)`: 加载相对于当前页面位置的某个 URL，`n` 可以是正数、负数或零。

```js
window.history.go(-2); 	// 返回上上页
window.history.go(-1); 	// 返回上一页
window.history.go(0); 	// 刷新当前页
window.history.go(1); 	// 前往下一页

window.history.back(); // 上一页

window.history.forward(); // 下一页
```



### Screen 对象

> 提供有关用户屏幕的信息。

- `screen.width` 和 `screen.height`: 屏幕的宽度和高度。
- `screen.availWidth` 和 `screen.availHeight`: 可用屏幕的宽度和高度（不包括任务栏等）。