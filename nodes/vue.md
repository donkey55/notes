# Vue笔记

> 记录一些常用笔记和知识，可能会毫无章法，记录到哪里是哪里

## Vue2

组件间通信



props



全局事件总线



自定义事件





## Vue3

* setup配置函数中进行配置

```js
setup(){
    let name = "sb"
    function test {
        return "sb"
    }
    return {
        name,
        test
    }
}
```

* 实现双向绑定需要使用ref函数

```js
import {ref} from 'vue'
setup(){
    let name = ref("sb")
    function test {
        name.value = "李四" //(响应式修改)
    }
    return {
        name,
        test
    }
}
```

* watch配置项

```js
let person = reactive({
      name:"sb",
      age: 18,
      job: {
        job1: {
          money: 20
        }
      }
    })
    watch(person, (newValue, oldValue) => {
      // 强制开启深度监视，deep配置项无效
      console.log(newValue, oldValue)
    }, {deep: false})

    watch(() => person.name, (newValue, oldValue) => {
      console.log(newValue, oldValue)
    })

    watch(() => person.job, (newValue, oldValue) => {
      // 修改job.job1.money, 此时deep有效
      console.log(newValue, oldValue)
    },{deep: true})
```

* watchEffect

```js
watchEffect(() => {
    // 这个方法里面所使用到的data被改变时，就会被调用
    const x1 = name
    csl("被调用了")
}) 
```

