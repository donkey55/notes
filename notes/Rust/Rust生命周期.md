## Rust生命周期

假设有两个引用 `&'a i32` 和 `&'b i32`，它们的生命周期分别是 `'a` 和 `'b`，若 `'a` >= `'b`，则可以定义 `'a:'b`，表示 `'a` 至少要活得跟 `'b` 一样久。

```rust
#![allow(unused)]
struct DoubleRef<'a,'b:'a, T> {
    r: &'a T,
    s: &'b T
}
```

### 函数生命周期消除规则



> 闭包生命周期消除与函数生命周期消除区别较大。如下
>
> ```rust
> 
> #![allow(unused)]
> fn main() {
> fn fn_elision(x: &i32) -> &i32 { x }
> let closure_slision = |x: &i32| -> &i32 { x };
> }
> 
> ```

