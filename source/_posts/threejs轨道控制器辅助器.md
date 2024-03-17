---
title: threejs轨道控制器辅助器
categories: ['threejs']
tags: ['web3d','threejs','webgl']
date: 2024-01-10 17:20:00
---

#  threejs轨道控制器辅助器

> OrbitControlsHelper 由来，由于项目需要threejs默认的轨道控制器无法以模型为中心上下左右旋转，而是以修改相机视角达到视角旋转的效果当通过鼠标右键移动控制器后，相机的旋转会以世界中心旋转。
>
> OrbitControlsHelper 可以把旋转中心从世界中心坐标改为模型中心旋转，可以参考下面的代码去理解。最后的是抽取成辅助类形式去调用

```vue
<template>
  <div ref="container">
    <!-- <canvas ref="canvas"></canvas> -->
    <button @click="test('0°')">回正</button>
    <button @click="test('R45°')">R45°</button>
    <button @click="test('L45°')">L45°</button>
    <button @click="test('R90°')">R90°</button>
    <button @click="test('L90°')">L90°</button>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

const container = ref();
let camera: any;
let controls: any;
let cube: any;
const init = () => {
  // 初始化场景
  const scene = new THREE.Scene();
  camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 1000);
  const renderer = new THREE.WebGLRenderer();
  camera.position.z = 5;
  renderer.setSize(window.innerWidth, window.innerHeight);
  container.value.appendChild(renderer.domElement);

  controls = new OrbitControls(camera, renderer.domElement);
  controls.enableRotate = false;
  controls.enableZoom = false;
  // 如果OrbitControls改变了相机参数，重新调用渲染器渲染三维场景
  controls.addEventListener('change', function () {
    renderer.render(scene, camera); // 执行渲染操作
  }); // 监听鼠标、键盘事件

  //   const gridHelper = new THREE.GridHelper(300, 25, 0x004444, 0x004444);

  //   scene.add(gridHelper);
  const geometry = new THREE.BoxGeometry(1, 1, 1);
  const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
  cube = new THREE.Mesh(geometry, material);
  scene.add(cube);

  // 初始化控制参数
  const state = {
    isLongPressing: false,
    longPressThreshold: 100, // 长按阈值，单位为毫秒
    pressStartTime: 0,
    previousMousePosition: {
      x: 0,
      y: 0,
    },
    longPressTimer: undefined, // 用于存储定时器的ID
  };

  // 鼠标按下事件
  const handleMouseDown = (event: MouseEvent) => {
    if (event.button === 0) {
      // 检查左键
      state.pressStartTime = Date.now();
      state.isLongPressing = false;
      state.previousMousePosition.x = event.clientX;
      state.previousMousePosition.y = event.clientY;
      state.longPressTimer = setTimeout(checkLongPress, state.longPressThreshold) as unknown as any;
    }
  };

  // 鼠标松开事件
  const handleMouseUp = () => {
    state.isLongPressing = false;
    clearTimeout(state.longPressTimer);
  };
  // 检查长按
  function checkLongPress() {
    const currentTime = Date.now();
    if (currentTime - state.pressStartTime >= state.longPressThreshold) {
      // 左键长按的处理代码
      state.isLongPressing = true;
      console.log('左键长按');
    }
  }
  // 鼠标移动事件
  const handleMouseMove = (event: MouseEvent) => {
    if (state.isLongPressing) {
      // 在长按状态下的鼠标移动处理代码
      const deltaMove = {
        x: event.pageX - state.previousMousePosition.x,
        y: event.pageY - state.previousMousePosition.y,
      };
      // 获取关联的 DOM 元素
      const element = renderer.domElement;
      cube.rotation.x += (2 * Math.PI * deltaMove.y) / element.clientHeight;
      cube.rotation.y += (2 * Math.PI * deltaMove.x) / element.clientWidth;
      // 更新鼠标位置
      state.previousMousePosition = {
        x: event.pageX,
        y: event.pageY,
      };
    }
  };
  // 滚轮事件
  const handleWheel = (event: WheelEvent) => {
    // 根据滚轮滚动的差值进行缩放
    const scaleFactor = event.deltaY > 0 ? 0.9 : 1.1;
    cube.scale.multiplyScalar(scaleFactor);
  };

  // 渲染循环
  const animate = () => {
    requestAnimationFrame(animate);
    renderer.render(scene, camera);
  };

  // 初始化相机位置
  camera.position.z = 5;

  // 启动渲染循环
  animate();

  document.addEventListener('mousedown', handleMouseDown);
  document.addEventListener('mouseup', handleMouseUp);
  document.addEventListener('mousemove', handleMouseMove);
  document.addEventListener('wheel', handleWheel);
};

const test = (degToRad: string) => {
  console.log(controls);

  switch (degToRad) {
    // 0°旋转的情况
    case '0°':
      // 设置左右两个相机的旋转
      cube.rotation.set(0, THREE.MathUtils.degToRad(0), 0);
      break;

    // +45°旋转的情况
    case 'R45°':
      cube.rotation.set(0, THREE.MathUtils.degToRad(45), 0);
      break;

    // -45°旋转的情况
    case 'L45°':
      cube.rotation.set(0, -THREE.MathUtils.degToRad(45), 0);
      break;

    // +90°旋转的情况
    case 'R90°':
      cube.rotation.set(0, THREE.MathUtils.degToRad(90), 0);
      break;

    // -90°旋转的情况
    case 'L90°':
      cube.rotation.set(0, -THREE.MathUtils.degToRad(90), 0);
      break;
  }
  // 设置轨道控制器的目标点（target）为初始位置
  controls.target.set(0, 0, 0);

  // 设置相机的位置为默认位置
  camera.position.set(0, 0, 5); // 你可能需要根据实际情况调整 Z 轴的值

  // 使相机重新对准目标点
  controls.update();

  console.log(controls);
};

// 注册事件监听器
onMounted(() => {
  init();
});
</script>


```

## 抽取后的代码

```ts
// eslint-disable-next-line filename-rules/match
export class OrbitControlsHelper {
  state: any = {
    // 是否正在长按的状态，初始值为 false
    isLongPressing: false,

    // 长按的阈值，单位为毫秒，如果按下的时间超过这个阈值，则认为是长按
    longPressThreshold: 100,

    // 记录按下鼠标的时间，用于计算是否长按
    pressStartTime: 0,

    // 记录上一次鼠标的位置，用于计算鼠标移动的距离
    previousMousePosition: {
      x: 0,
      y: 0,
    },

    // 用于存储定时器的 ID，定时器用于检查是否长按
    longPressTimer: undefined,

    // 存储双指触摸开始时的距离，用于计算缩放比例
    touchStartDistance: 0,

    // 存储触摸缩放因子，用于在触摸移动时计算新的缩放比例
    ScaleFactor: [-0, 0, 0],
    Rotation: [0, 0, 0],
  };

  // 存储 THREE.js 模型的数组，每个模型都是一个 THREE.Group 对象
  models: THREE.Group<THREE.Object3DEventMap>[] = [];

  // 存储画布
  private element: HTMLCanvasElement;

  // 构造函数，接收一个 HTMLCanvasElement 参数，为其添加事件监听器
  constructor(private el: HTMLCanvasElement) {
    this.element = el!;
    // 添加鼠标按下事件监听器，用于处理鼠标按下事件
    this.element.addEventListener('mousedown', this.handleMouseDown);

    // 添加鼠标抬起事件监听器，用于处理鼠标抬起事件
    this.element.addEventListener('mouseup', this.handleMouseUp);

    // 添加鼠标移动事件监听器，用于处理鼠标移动事件
    this.element.addEventListener('mousemove', this.handleMouseMove);

    // 添加滚轮滚动事件监听器，用于处理滚轮滚动事件
    this.element.addEventListener('wheel', this.handleWheel);

    // 添加触摸开始事件监听器，用于处理触摸开始事件
    this.element.addEventListener('touchstart', this.handleTouchStart, { passive: false });

    // 添加触摸结束事件监听器，用于处理触摸结束事件
    this.element.addEventListener('touchend', this.handleTouchEnd);

    // 添加触摸移动事件监听器，用于处理触摸移动事件
    this.element.addEventListener('touchmove', this.handleTouchMove, { passive: false });
  }

  // 检查是否长按的方法
  checkLongPress = () => {
    // 获取当前时间
    const currentTime = Date.now();

    // 如果从按下鼠标到现在的时间超过了长按阈值，则认为是长按
    if (currentTime - this.state.pressStartTime >= this.state.longPressThreshold) {
      // 设置长按状态为 true
      this.state.isLongPressing = true;
    }
  };

  // 处理鼠标抬起的方法
  handleMouseUp = () => {
    // 鼠标抬起时，设置长按状态为 false，并清除长按检查的定时器
    this.state.isLongPressing = false;
    clearTimeout(this.state.longPressTimer);
  };

  // 处理鼠标按下的方法
  handleMouseDown = (event: MouseEvent) => {
    // 只处理左键按下事件
    if (event.button === 0) {
      // 记录按下鼠标的时间，设置长按状态为 false，记录鼠标的位置，并设置一个定时器来检查是否长按
      this.state.pressStartTime = Date.now();
      this.state.isLongPressing = false;
      this.state.previousMousePosition.x = event.clientX;
      this.state.previousMousePosition.y = event.clientY;
      this.state.longPressTimer = setTimeout(this.checkLongPress, this.state.longPressThreshold) as unknown as any;
    }
  };

  // 处理鼠标移动的方法
  handleMouseMove = (event: MouseEvent) => {
    // 只在长按状态下处理鼠标移动事件
    if (this.state.isLongPressing) {
      // 计算鼠标移动的距离
      const deltaMove = {
        x: event.pageX - this.state.previousMousePosition.x,
        y: event.pageY - this.state.previousMousePosition.y,
      };

      // 遍历所有模型
      this.models.forEach((model) => {
        if (model) {
          // 计算新的旋转角度公式：新的角度 = 旧的角度 + (2π * 移动的距离 / 元素的高度或宽度)。
          // 当鼠标在元素上从一端移动到另一端时，模型应该旋转 360 度（即 2π 弧度）。
          const newRotationX = model.rotation.x + (2 * Math.PI * deltaMove.y) / this.element.clientHeight;
          const newRotationY = model.rotation.y + (2 * Math.PI * deltaMove.x) / this.element.clientWidth;

          // 将角度转换为度数公式为：度数 = 弧度 * (180 / π)。
          const newRotationXInDegrees = newRotationX * (180 / Math.PI);
          const newRotationYInDegrees = newRotationY * (180 / Math.PI);

          // 检查新的旋转角度是否在 -90 度到 90 度的范围内，如果是，则更新模型的旋转角度
          if (newRotationXInDegrees >= -90 && newRotationXInDegrees <= 90) {
            model.rotation.x = newRotationX;
          }
          if (newRotationYInDegrees >= -90 && newRotationYInDegrees <= 90) {
            model.rotation.y = newRotationY;
          }

          this.state.Rotation = [...model.rotation];
        }
      });

      // 更新鼠标的位置，以便下次计算移动距离
      this.state.previousMousePosition = {
        x: event.pageX,
        y: event.pageY,
      };
    }
  };

  // 处理滚轮滚动的方法
  handleWheel = (event: WheelEvent) => {
    // 根据滚轮滚动的差值进行缩放，滚轮向下滚动时缩小，向上滚动时放大
    const scaleFactor = event.deltaY > 0 ? 0.9 : 1.1;

    this.models.forEach((model) => {
      if (model) {
        // 计算新的缩放值，新的缩放值 = 旧的缩放值 * 缩放因子
        const newScale = model.scale.clone().multiplyScalar(scaleFactor);

        // 设置缩放范围，例如，假设缩放范围在 -40 到 40 之间
        const minScale = -60;
        const maxScale = 60;
        if (newScale.x <= -2) {
          // 限制缩放值在范围内
          newScale.clampScalar(minScale, maxScale);
          this.state.ScaleFactor = [...newScale];
          // 应用新的缩放值
          model.scale.copy(newScale);
        }
      }
    });
  };

  // 处理触摸结束的方法
  handleTouchEnd = () => {
    // 触摸结束时，调用 handleMouseUp 方法处理
    this.handleMouseUp();
  };

  // 将触摸事件转换为鼠标事件的方法
  convertTouchEvent = (event: TouchEvent): MouseEvent => {
    // 获取第一个触摸点
    const touch = event.touches[0] || event.changedTouches[0];

    // 创建一个新的鼠标事件，并设置其 clientX 和 clientY 为触摸点的位置
    return new MouseEvent('mousemove', {
      clientX: touch.clientX,
      clientY: touch.clientY,
    });
  };

  // 处理触摸开始的方法
  handleTouchStart = (event: TouchEvent) => {
    // 阻止默认行为
    event.preventDefault();

    if (event.touches.length === 1) {
      // 单指触摸时，调用 handleMouseDown 方法处理，并将触摸事件转换为鼠标事件
      this.handleMouseDown(this.convertTouchEvent(event));
    } else if (event.touches.length === 2) {
      // 双指触摸时，计算两个触摸点之间的距离
      this.state.touchStartDistance = this.getTouchesDistance(event.touches);
    }
  };

  // 处理触摸移动的方法
  handleTouchMove = (event: TouchEvent) => {
    // 阻止默认行为
    event.preventDefault();

    if (event.touches.length === 1) {
      // 单指移动时，调用 handleMouseMove 方法处理，并将触摸事件转换为鼠标事件
      this.handleMouseMove(this.convertTouchEvent(event));
    } else if (event.touches.length === 2) {
      // 双指移动时，计算两个触摸点之间的新距离
      const newDistance = this.getTouchesDistance(event.touches);

      // 设置一个阈值，例如10个像素，以确定是否进行了显著的缩放操作
      const threshold = 10;
      const distanceChange = Math.abs(newDistance - this.state.touchStartDistance);

      if (distanceChange > threshold) {
        // 只有当距离变化超过阈值时，才进行缩放。如果新距离大于起始距离，放大模型，否则缩小模型
        const scaleFactor = newDistance > this.state.touchStartDistance ? 1.1 : 0.9;

        this.models.forEach((model) => {
          if (model) {
            // 计算新的缩放值，新的缩放值 = 旧的缩放值 * 缩放因子
            const newScale = model.scale.clone().multiplyScalar(scaleFactor);
            const minScale = -60;
            const maxScale = 60;

            if (newScale.x <= -2) {
              // 限制缩放值在范围内
              newScale.clampScalar(minScale, maxScale);
              this.state.ScaleFactor = [...newScale];
              // 应用新的缩放值
              model.scale.copy(newScale);
            }
          }
        });

        // 更新起始距离，以便下次计算距离变化
        this.state.touchStartDistance = newDistance;
      }
    }
  };

  // 计算两个触摸点之间的距离的方法
  getTouchesDistance = (touches: TouchList) => {
    // 计算两个触摸点在 x 轴和 y 轴上的差值
    const dx = touches[0].pageX - touches[1].clientX;
    const dy = touches[0].pageY - touches[1].clientY;

    // 使用勾股定理计算两个触摸点之间的距离
    return Math.sqrt(dx * dx + dy * dy);
  };

  // 加载模型的方法
  loadModels = (models: THREE.Group<THREE.Object3DEventMap>[]) => {
    // 将传入的模型赋值给 this.models
    this.models = models;
  };

  destroyed() {
    this.element.removeEventListener('mousedown', this.handleMouseDown);
    this.element.removeEventListener('mouseup', this.handleMouseUp);
    this.element.removeEventListener('mousemove', this.handleMouseMove);
    this.element.removeEventListener('wheel', this.handleWheel);
    this.element.removeEventListener('touchstart', this.handleTouchStart);
    this.element.removeEventListener('touchend', this.handleTouchEnd);
    this.element.removeEventListener('touchmove', this.handleTouchMove);
  }

  // 计算缩放比
  calculateScalingRatio(aspectRatio) {
    // 初始化缩放比
    // 计算新的缩放比例
    // const aspectRatio = sceneWidth / sceneHeight;
    let scaleRatio = aspectRatio / 0.5; // 计算缩放比例
    scaleRatio = Math.min(scaleRatio, 1); // 限制缩放比例的最大值为1，确保模型不会变得过大
    const scale = Math.abs(-8 * scaleRatio); // 取绝对值，确保缩放比例始终为正值
    // 更新模型的缩放比例
    this.state.ScaleFactor = [-scale, scale, scale];
  }
}

```

## 使用方式

```ts
let orbitControlsHelper: any;

# 创建轨道控制器辅助器
orbitControlsHelper = new OrbitControlsHelper(renderer.value.domElement);
orbitControlsHelper.calculateScalingRatio(cameraLeft.aspect);
# 禁用 轨道控制器缩放和平移旋转事件
controls.enableRotate = false;
controls.enableZoom = false;

# 订阅鼠标按键事件
renderer.value.domElement.addEventListener('mousedown', orbitControlsHelper.handleMouseDown);
renderer.value.domElement.addEventListener('mouseup', orbitControlsHelper.handleMouseUp);
renderer.value.domElement.addEventListener('mousemove', orbitControlsHelper.handleMouseMove);
renderer.value.domElement.addEventListener('wheel', orbitControlsHelper.handleWheel);

#在执行动画渲染的函数加载需要修改的模型
/**
 * 执行动画渲染的函数
 */
const animate = () => {
  requestAnimationFrame(animate);
  # 加载模型
  orbitControlsHelper.loadModels([FaceModelOne, FaceModelTwo, HistoryFaceModel]);
  // 渲染左眼场景
  renderer.value.setViewport(0, 0, width.value, height.value);
  renderer.value.setScissor(0, 0, width.value, height.value);
  renderer.value.setScissorTest(true);
  renderer.value.render(sceneLeft, cameraLeft.value);
  renderer.value.setPixelRatio(window.devicePixelRatio);

  // 渲染右眼场景
  renderer.value.setViewport(width.value, 0, width.value, height.value);
  renderer.value.setScissor(width.value, 0, width.value, height.value);
  renderer.value.setScissorTest(true);
  renderer.value.render(sceneRight, cameraRight.value);
  renderer.value.setPixelRatio(window.devicePixelRatio);
};
```

