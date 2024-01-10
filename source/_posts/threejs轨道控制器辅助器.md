---
title: threejs轨道控制器辅助器
categories: ['web3d','threejs','webgl']
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
  state = {
    isLongPressing: false,
    longPressThreshold: 100, // 长按阈值，单位为毫秒
    pressStartTime: 0,
    previousMousePosition: {
      x: 0,
      y: 0,
    },
    longPressTimer: undefined, // 用于存储定时器的ID,
    // element: HTMLCanvasElement
  };

  models: THREE.Group<THREE.Object3DEventMap>[] = [];
  constructor(private element: HTMLCanvasElement) {}

  checkLongPress = () => {
    const currentTime = Date.now();
    if (currentTime - this.state.pressStartTime >= this.state.longPressThreshold) {
      // 左键长按的处理代码
      this.state.isLongPressing = true;
      console.log('左键长按');
    }
  };

  handleMouseUp = () => {
    this.state.isLongPressing = false;
    clearTimeout(this.state.longPressTimer);
  };

  handleMouseDown = (event: MouseEvent) => {
    if (event.button === 0) {
      // 检查左键
      this.state.pressStartTime = Date.now();
      this.state.isLongPressing = false;
      this.state.previousMousePosition.x = event.clientX;
      this.state.previousMousePosition.y = event.clientY;
      this.state.longPressTimer = setTimeout(this.checkLongPress, this.state.longPressThreshold) as unknown as any;
    }
  };

  handleMouseMove = (event: MouseEvent) => {
    if (this.state.isLongPressing) {
      // 在长按状态下的鼠标移动处理代码
      const deltaMove = {
        x: event.pageX - this.state.previousMousePosition.x,
        y: event.pageY - this.state.previousMousePosition.y,
      };
      // 获取关联的 DOM 元素
      this.models.forEach((model) => {
        if (model) {
          model.rotation.x += (2 * Math.PI * deltaMove.y) / this.element.clientHeight;
          model.rotation.y += (2 * Math.PI * deltaMove.x) / this.element.clientWidth;
        }
      });
      // 更新鼠标位置
      this.state.previousMousePosition = {
        x: event.pageX,
        y: event.pageY,
      };
    }
  };

  handleWheel = (event: WheelEvent) => {
    // 根据滚轮滚动的差值进行缩放
    const scaleFactor = event.deltaY > 0 ? 0.9 : 1.1;

    this.models.forEach((model) => {
      if (model) {
        // 计算新的缩放值
        const newScale = model.scale.clone().multiplyScalar(scaleFactor);

        // 设置缩放范围，例如，假设缩放范围在 -20 到 20 之间
        const minScale = -30;
        const maxScale = 30;

        console.log(newScale);
        if (newScale.x <= -5) {
          // 限制缩放值在范围内
          newScale.clampScalar(minScale, maxScale);

          // 应用新的缩放值
          model.scale.copy(newScale);
        }
      }
    });
  };

  loadModels = (models: THREE.Group<THREE.Object3DEventMap>[]) => {
    this.models = models;
  };
}

```

## 使用方式

```
let orbitControlsHelper: any;

# 创建轨道控制器辅助器
orbitControlsHelper = new OrbitControlsHelper(renderer.value.domElement);

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

