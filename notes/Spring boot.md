## Maven

多模块开发和设计

一个模块引用另外一个模块，只需要导入坐标即可。

### 依赖传递

路径优先：当依赖中出现相同的资源时，层级越深，优先级越低，层级越浅，优先级越高

声明优先：当资源在相同层级被依赖时，配置顺序靠前的覆盖配置顺序靠后的

特殊优先：当同级配置了相同资源的不同版本，后配置的覆盖先配置的

### 可选依赖

隐藏本模块所引用的模块，即不想本模块所依赖的资源被别的模块在引用时覆盖和冲突

在dependency使用 `<optional>true</optional>` 。隐藏当前模块中的某个依赖，使其不具备传递性。即别人引用本模块时，看不到本模块依赖了某个依赖

### 排除依赖

```xml
<exclusions>
    <exclusion>
    	<groupId></groupId>
        <artifactId></artifactId>
    </exclusion>
</exclusions>
```



### 模块聚合

父亲模块管理多个子模块。

首先配置父模块的打包方式

然后配置父模块所管理的子模块

```xml
<packaging>pom</packaging>
// 子模块
<modules>
    // 子模块的路径，这里是相对路径，针对pom文件所在的路径
    <module>ooo</module>
</modules>
```

> 注：每个maven都有对应的打包方式，默认为jar，wab工程打包方式为war

聚合模块进行构建时，其中每一个模块都会进行构建

### 模块继承

子工程可以继承使用父工程中的配置信息。

> 聚合和继承通常是一起使用的。

配置继承，在子工程中进行配置。
```xml
<parent>
	<groupId></groupId>
    <artifactId></artifactId>
    <version></version>
    // 相对路径，配置继承的哪个位置，可选
    <relativePath>../parent/pom.xml</relativePath>
</parent>
```

### 依赖管理

在父工程中配置

```xml
<dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>junit</groupId>
                <artifactId>junit</artifactId>
                <version>4.13.2</version>
                <scope>test</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

那么子工程中，同样配置此依赖，但是并不需要配置版本，此时会使用父亲的版本，但是如果子类不配置junit这个配置，子类便不会有此依赖。

```xml
 <dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <scope>test</scope>
</dependency>
```

> 依赖管理的作用为：父工程的一些依赖，一些子工程需要，一些子工程不需要，由此可以将其配置在`dependencyManagement`，然后再需要其中所管理的依赖的子工程中配置即可。

**继承、聚合和依赖管理三个部分，能够减少Spring工程中子模块之间的版本冲突，同时简化开发和配置**

### 属性

```xml
<properties>
    <spring.version>5.2.1</spring.version>
</properties>
 <dependency>
    <groupId>org.springframework</groupId>
    <artifactId>sping-jdbc</artifactId>
    <scope>${spring.version}</scope>
</dependency>
```

如上面的属性配置，`spring.version`便为我们定义的一个变量，接下来可以使用`${}`的方式来使用

### 版本管理

* 工程版本
  * snapshot（快照版本）
    * 项目开发过程中临时输出的版本，称为快照版本
    * 快照版本会随着开发的进展不断更新
  * release（发布版本）
    * 项目开发到进入阶段里程碑后，向团队外部发布较为稳定的版本，这种版本所对应的构建文件是稳定的，即便进行功能的后续开发，也不会改变当前发布版本内容，这种版本称为发布版本。
* 发布版本
  * alpha版
  * beta版
  * 纯数字版

### 跳过测试

```xml
<build>
        <finalName>server</finalName>
        <plugins>
            <plugin>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.0.0</version>
                <configuration>
                    <skipTests>true</skipTests>
                </configuration>
            </plugin>
        </plugins>
    </build>
```

上面是跳过全部测试，可以设置为false，然后配置`excludes` or `includes`

### 私有服务器

* maven中配置对私服的访问权限和私服地址
* 项目中配置上传上传的私服中的仓库和地址

```xml
<distributionManagement>
        <repository>
            <id></id>
            <url></url>
        </repository>
    </distributionManagement>
```

`id`为仓库名，`url`为仓库地址，然后执行`mvn deploy`会将工程的依赖存储在仓库中

# Spring

## IoC（Inversion of Control）

控制反转

* 使用对象时，由主动new产生对象转换为由外部提供对象，此过程中对象创建控制权由程序转移到外部。

在Spring技术中对IoC思想进行了实现

* Spring提供了一共容器，成为IoC容器，用来充当IoC思想中的外部
* IoC容器负责对象的创建、初始化等一系列工作，被创建或被管理的对象在IoC容器中统称为Bean

DI（Dependency Injection）依赖注入

* 在容器中建立bean与bean之间的依赖关系的整个过程，成为依赖注入

对象的创建控制权由程序转移到外部，这种思想成为控制反转

## 深入理解IOC

### 如何去设计一个IOC？

- 加载bean配置
  - 支持不同类型资源的加载，解析生成统一的Bean的定义
- 根据Bean的定义加载生成Bean的实例，并放置在Bean容器中
  - 比如Bean的依赖注入，Bean的嵌套，Bean存放（缓存）
- 基础Bean外，定制化一些特殊Bean
- 对容器中的Bean提供统一的管理和调用
  - 比如使用工厂模式管理，提供方法根据名字/类的类型等从容器中获取Bean

### Spring IoC体系结构设计

> Spring Bean的创建时典型的工厂模式，这一系列的Bean工程，也即IOC容器为开发者管理对象间的依赖关系提供了很多便利和基础服务，在Spring中有许多IOC容器的实现供用户选择和使用，这是IOC容器的基础；在顶层的结构设计主要围绕着BeanFactory和xxxRegistry进行：
>
> - BeanFactory： 工厂模式定义了IOC容器的基本功能规范
> - BeanRegistry：向IOC容器手工注册BeanDefination对象的方法

BeanFactory 

// todo

### Spring如何解决循环依赖问题

> Spring 只解决了单例模式下属性依赖的循环问题，Spring为了解决单例的循环依赖问题，使用了三级缓存

一级缓存：`singletonOnjects` 单例对象缓存池，已经实例化并且属性赋值，这里的对象是成熟对象

二级缓存：`earlySingletonObjects`：单例对象缓存池，已经实例化但尚未属性赋值，这里的对象是半成品对象

三级缓存：`singletonFactories`: 单例工厂的缓存

首先尝试从一级缓存中获取，如果获取不到且对象在建立过程中，则尝试从二级缓存中获取，如果二级缓存仍然获取不到，且允许从三级缓存中通过getObject方法获取，则经过三级缓存中工厂的getObjct方法获取，如果获取成功后，会将这个对象放到二级缓存中，并从三级缓存中删除。

这个过程中最重要的是三级缓存的这个工厂方法缓存。这个缓存中存储的value为`ObjectFactory`这个接口的实现对象，在bean的建立过程中有两处比较重要的匿名内部类实现了此接口。一处使Spring利用其建立bean的时候，一处就是

```java
addSingletonFactory(beanName, new ObjectFactory<Object>() {
   @Override   public Object getObject() throws BeansException {
      return getEarlyBeanReference(beanName, mbd, bean);
   }});
```

这一步是发生在createBeanInstance后，也就是单例对象此时已经被建立出来了，对象已经被产生，虽然还没有进行bean初始化的第二步和第三步，但已经可以通过对象引用定位到堆中，因此Spring将此对象放到三级缓存中，让程序能够看到他。

好比“A对象setter依赖B对象，B对象setter依赖A对象”，A首先完成了初始化的第一步，而且将本身提早曝光到singletonFactories中，此时进行初始化的第二步，发现本身依赖对象B，此时就尝试去get(B)，发现B尚未被create，因此走create流程，B在初始化第一步的时候发现本身依赖了对象A，因而尝试get(A)，尝试一级缓存singletonObjects(确定没有，由于A还没初始化彻底)，尝试二级缓存earlySingletonObjects（也没有），尝试三级缓存singletonFactories，因为A经过ObjectFactory将本身提早曝光了，因此B可以经过ObjectFactory.getObject拿到A对象(半成品)，B拿到A对象后顺利完成了初始化阶段一、二、三，彻底初始化以后将本身放入到一级缓存singletonObjects中。此时返回A中，A此时能拿到B的对象顺利完成本身的初始化阶段二、三，最终A也完成了初始化，进去了一级缓存singletonObjects中，并且更加幸运的是，因为B拿到了A的对象引用，因此B如今hold住的A对象完成了初始化。

#### Spring为什么不能够解决非单例属性之外的循环依赖？

> 根据以下几个问题协助理解

##### Spring为什么不能解决构造器的循环依赖？

构造器注入形成的循环依赖： 也就是beanB需要在beanA的构造函数中完成初始化，beanA也需要在beanB的构造函数中完成初始化，这种情况的结果就是两个bean都不能完成初始化，循环依赖难以解决。

Spring解决循环依赖主要是依赖三级缓存，但是的**在调用构造方法之前还未将其放入三级缓存之中**，因此后续的依赖调用构造方法的时候并不能从三级缓存中获取到依赖的Bean，因此不能解决。

##### Spring为什么不能解决prototype作用域循环依赖？

这种循环依赖同样无法解决，因为spring不会缓存‘prototype’作用域的bean，而spring中循环依赖的解决正是通过缓存来实现的。

##### Spring为什么不能解决多例的循环依赖？

多实例Bean是每次调用一次getBean都会执行一次构造方法并且给属性赋值，根本没有三级缓存，因此不能解决循环依赖

##### 生成代理对象产生的循环依赖?

这类循环依赖问题解决方法很多，主要有：

1. 使用@Lazy注解，延迟加载
2. 使用@DependsOn注解，指定加载先后关系
3. 修改文件名称，改变循环依赖类的加载顺序

## bean

* 默认为单例模式

### bean实例化

* 使用反射调用bean的无参构造方法创建的
* 静态工厂，配置静态工厂类
* 实例工厂（非静态工厂），配置实例工厂类

### bean的生命周期

* 可以配置一个bean的初始化时执行的方法和销毁时执行的方法
* 或者bean类实现一些接口来实现。

## 依赖注入

* setter注入
  * 写个属性的set方法即可
* 构造器注入
  * 增加一个构造方法，参数为需要被注入的依赖类型。
* 推荐使用setter方法
* 自动装配
  * 按照类型。@Autowired，使用反射完成的
  * 按照名称。@Resuource
  * 按照构造方法
  * 不启用自动装配
  * 自动装配的优先级低于setter注入与构造器注入，图，同时出现时，自动装配配置失效。

## 容器

### 创建容器

* 加载类路径下的文件，创建容器。`ClassPathXmlApplicationContext`

* 从文件系统加载配置文件，创建容器.`FileSystemXmlApplicationContext`

### 获取bean

* ctx.getBean()

BeanFactory是ApplicationContext的顶层接口。BeanFactory中使用懒加载bean，ApplicationContext是采用即时加载。

## 注解开发

bean的注解

`@Component`，下面是其衍生注解，功能完全一致

* `@Service`
* `@Repository`
* `@Controller`

纯注解开发，这里需要创建一个带有 `@Configuration` 注解的SpringConfig类，然后在加载时，不再采用ClassPathXmlApplication来进行加载容器，而是采用 `AnnotationConfigApplicationContext(SpringConfig.class)`的方式来加载和创建容器。，同时config类中需要用注解指明需要被bean所在包 `@ComponentScan('xxx.xxx.xxx')`

### bean管理

`@Scope('prototype')`修饰类，用来控制bean是否为单例模式

`@PostConstruct` 修饰方法，即在构造方法之后被调用

`@PreDestroy` 修饰方法，即bean在被销毁前调用

### 依赖注入

> 自动装配方式

`@Autowired` 注解注入

* 这里采用的是类型注入
* 类型注入失败后，如果没有指定bean名称默认会采用按照名字注入（按照被注入的类属性的名称），可以使用`@Qualifier`指定注入的bean名称

`@PropertySource("xx.properties")` 在SpringConfig类加上，会从此配置文件中读取配置，并在类中使用 `@Value("${name}")` 类似此方式读取配置文件的一些配置

### 管理第三方bean

在配置类中，对一个返回值为第三方bean的方法添加`@Bean`注解，在这个方法中创建第三方bean的类对象，并进行设置后作为返回返回值返回即可。如果此方法中需要用到其他的引用类型bean，可以将需要的引用类型bean写进此方法的形参中，spring会自动按照类型装配。

## AOP

Aspect Oriented Programming 面向切面编程，一种编程范式，指导开发者如何组织程序结构

在不惊动原始设计的基础上为其进行增强。

### 概念

* 通知（Advice）。在切入点执行的操作
* 切面（Aspect）。描述通知和切入点的对应关系
* 切入点，匹配连接点的式子
  * 在SpringAOP中，一个切入点可以描述一个具体的方法，也可以匹配多个方法
    * 一个具体方法：com.itheima.dao包下的BookDao接口中的无形参无返回值的save方法
    * 匹配多个方法：所有save方法，所有的get开头的方法，所有以Dao结尾的接口中的任意方法，所有带有一个参数的方法....等等形式进行匹配
* 连接点，被增强的方法，在SpringAOP中理解为方法的执行。

AOP工作流程

![image-20240310173815564](https://s2.loli.net/2024/03/10/kJD3liVLOuyYzsg.png)

### Aop切入点表达式

标准格式：动作关键词（访问修饰符 返回值 包名.类/接口名.方法（参数）异常名）

其中可以使用通配符

* `*` ，单个独立的任意符号，可以独立出现，也可以 作为前准或者后缀的匹配符出现
* `..`多个连续的任意符号，常用于简化包名与参数的书写
* `+`，专用于匹配子类类型

### Aop通知类型

* @Before
* @After
* @Around
  * 需要增加一个参数(ProceedingJoinPoint ) 并在合适的位置调用，来作为原始操作的前后的分割点
    * `ProceedingJoinPoint`包含了切入点方法的信息，包括参数、名字、返回值等等，这里就可以对方法调用前进行一些校验、检查以及参数替换等等，还要方法调用结束后的一些处理

### Spring AOP的实现方式

通过动态代理实现的，如果spring为某个bean配置了切面，那么spring在创建这个bean时，实际创建的是这个bean 的代理对象，后续对bean中方法的调用实际上调用的是代理类重写的代理方法。具体来说有两种动态代理：

- JDK的动态代理。如果一个类实现了接口，那么Spring就会使用这种方式实现动态代理。
- CGLib 的动态代理。如果类没有实现接口，那么就采用CGLib来生成代理对象。

#### JDK的动态代理

`JDK`的动态代理是基于**反射**实现。`JDK`通过反射，生成一个代理类，这个代理类实现了原来那个类的全部接口，并对接口中定义的所有方法进行了代理。当我们通过代理对象执行原来那个类的方法时，代理类底层会通过反射机制，回调我们实现的`InvocationHandler`接口的`invoke`方法。**并且这个代理类是Proxy类的子类**（记住这个结论，后面测试要用）。这就是`JDK`动态代理大致的实现方式。

优点：

- JDK原生，不需要任何依赖即可使用
- 通过反射生成代理类的速度更快

缺点：

- 只能代理实现了接口的类
- **只能代理那些在接口中定义的方法**，即一个类实现了接口，但我们为一个不在接口中的方法配置了切面，那么Spring仍然会使用JDK动态代理，但其实这个代理是无效，这个切面也是无效，此切面不会被织入
- JDK动态代理执行代理方法时，需要通过反射机制进行回调，此时方法的执行效率比较低。

#### CGLib 动态代理

`CGLib`实现动态代理的原理是，底层采用了`ASM`字节码生成框架，直接对需要代理的类的字节码进行操作，生成这个类的一个子类，并重写了类的所有可以重写的方法，在重写的过程中，将我们定义的额外的逻辑（简单理解为`Spring`中的切面）织入到方法中，对方法进行了增强。而通过字节码操作生成的代理类，和我们自己编写并编译后的类没有太大区别。

优点

- 不需要实现接口
- CGLib生成的是类的子类，那么能够代理所有能够被子类重写的方法
- 代理类在对方法的调用上，执行效率要高于JDK动态代理

缺点

- 继承实现的，所以针对类为final时，无法进行动态代理
- 针对方法而言，那些final方法或者private方法时无法被代理的
- 生成方式通过操作字节码的方式，这种方式生成代理类的速度要比JDK代理的速度更慢

## Spring 事务

* `@Transactional` 来开启事务，修饰方法，表示该方法是一个事务

* 创建事务管理器bean，返回类型为 `PlatformTransactionManager`

* 配置Spring 开启事务 `@EnableTransactionManagement`

#### Spring事务角色

* 事务管理员：发起事务方，在Spring中通常指代业务层开启事务的方法
* 事务协调员：加入事务方，在spring中通常指代数据层方法，也可以是业务层方法

#### Spring事务属性

* readOnly 设置事务是否为只读
* timeout，设置事务超时时间
* rollbackFor，设置事务回滚异常（xxx.class），即遇到了某种异常便会回滚，因为有些异常不会被回滚，所以想要其回滚，那么需要加入进去
* rollbackForClassName,设置事务回滚异常（String）
* noRollbackFor,设置事务不回滚异常（xxx.class）
* noRollbackForClassName，设置事务不回滚异常（String）
* propagation，设置事务传播行为。即设置事务协调员针对事务管理员所携带的事务，应该采取的操作（加入 or 不加入等）

## SpringMVC

这里我们想要创建一个MVC的服务，可以分为以下几个部分：

* 创建controller对应的类，实现对一个请求路径的响应

* 创建Spring MVC配置类，扫描controlller的bean所在包，即将该controller能够被加载到Spring的容器中

* 定义一个servlet容器启动的配置类，继承于 `AbstractDispatcherServletInitializer`,实现部对应的方法，如下：

  ```java
  public class ServletConfig extends AbstractDispatcherServletInitializer {
      @Override
      protected WebApplicationContext createServletApplicationContext() {
          AnnotationConfigWebApplicationContext ctx = new AnnotationConfigWebApplicationContext();
          // 这里即为第二步所配置的Spring的配置类
          ctx.register(SpringMVCConfig.class);
          return ctx;
      }
  
      @Override
      protected String[] getServletMappings() {
          // 配置哪些请求被容器给管理，这里是全部的都给Spring MVC
          return new String[]{"/"};
      }
  
      @Override
      protected WebApplicationContext createRootApplicationContext() {
          return null;
      }
  }
  ```

* 配置tomcat容器的maven插件然后maven运行tomcat

![image-20240317222818135](https://s2.loli.net/2024/03/17/9mKWYOjzLpoGqkP.png)

> 注：这里的SpringMVC的bean和前面的Spring的bean，如service层的bean，两者是由不同的context管理的，此时如果我们想要Spring的其他容器不加载MVC的bean，应该精确控制bean的扫描范围来抛除这些controller的bean

注解

`@Controller`

`@RequestMapping`

`@ResponseBody` 设置当前控制器方法响应内容为当前函数的返回值，无需解析

### 请求参数传递

#### get和post

>  **注，这里的传递参数都是使用x-www-form-urlencoded来进行传参**,即请求参数中的**Content-Type: application/x-www-form-urlencoded**

-  普通参数可以直接写入到controller参数内，如`name`参数，则可以使用`String name`，只要名称对应到即可。很简单，对于post请求也是一样，请求体内的字段是什么，方法参数名称写什么即可，如果二者不一致，则方法拿不到对应的值，会为null

- 使用`@RequestParam("xxx")` 来指定前端传参的名字，这样就可以让方法参数和请求参数不同。

- 方法参数可以为一个类，如 `User user`,如下为传参示例和嵌套传参形式

  ```java
  请求体参数：
  {
      "name": "xxx",
      "age": 123，
      "address.code": "123";
  }
  
  // 方法声明
  public String save(User user) {
      
  }
  public class User {
      class Address{
          String code;
      }
      String name;
      String age;
  }
  ```

- 传递数组，如`List<String> likes`，`String[] likes`,注意这里如果是List形式，需要使用 `@RequestParam List<String> likes`

  ```json
  // 传参形式
  {
      "likes": "game",
      "likes": "ooo",
      "likes": "sss"
  }
  ```

  其实就是Spring帮忙创建对象，然后使用set方法，set到对象中。

> **如果想要使用body中发送json请求数据(即Content-Type：application/json)，需要手动开启一个配置 `@EnableWebMvc`，使用`@RequestBody`来注解controller中的方法的参数，这样就可以从body里面将json请求数据转换为我们需要的对象。**

#### 日期类型传输

日期型参数 

```java
public String dataParam(Date date) {
    
}
// 请求使用路径参数
http://url/date?date=2008/08/08 √
http://url/date?date=2008-08-08 ×
```

针对不同的形式的字符串参数，需要配置一定的格式

```java
public String dataParam(@DateTimeFormat(pattern="YYYY-MM-DD") Date date) {
}
http://url/date?date=2008-08-08 √
```

##### 原理：

使用`Converter`接口，很多类实现了这个接口，来帮忙实现数据格式转换

### 响应

返回数据，使用 `@ResponseBody` 返回数据，然后会使用jackon来进行转换为json。

这个注解设置当前控制器的返回值作为响应体

##### 原理：

使用`HttpMessageConverter`接口

### 异常处理

使用AOP方式

```Java
@RestControllerAdvice
public class ExceptionAdvice {
    @ExceptionHandler(Exception.class) 
    public Result doException(Exception ex) {
        return new Result(500, "sbsbsbsb");
    }
}
```

类似上述方式，可以针对多种异常进行处理

### 拦截器

`intercepter` 配置主要分为两步：

第一步是实现具体拦截时的操作，这里需要一个实现了`HandlerInterceptor`的接口的bean，然后在其中重写方法

```java
@Component
public class AuthHandlerInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object handler) throws Exception {
    }
}
```

第二步，配置和注册拦截器的拦截配置类，这里需要实现 `WebMvcConfigurer` 接口

```java
@Configuration
public class AuthWebMvcConfigurer implements WebMvcConfigurer {

    @Autowired
    AuthHandlerInterceptor authHandlerInterceptor;
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authHandlerInterceptor)
                .addPathPatterns("/**");
    }
}
```

> **注：这个 `WebMvcConfigurer`接口中除了此拦截器之外，还有其他的功能，如资源路径映射等**

#### 拦截器参数

上面preHandle的函数中的handler对象

#### 拦截器顺序

可以配置多个拦截器，按照配置的顺序执行。

因为拦截器中包含着 `preHandle` `postHandle` `afterCompletion`,所以会有多个拦截器的执行顺序的问题

## Spring中的设计模式

工厂模式

单例模式



## Spring boot

### 简介

**约定大于配置**

内嵌Tomcat等服务器

### 启动流程

1. 加载Spring Boot配置文件：SpringBoot会先加载内部的spring-boot-autoconfiguration 和 spring-boot-starter等Starter，然后加载用户自定义的配置文件，并将其中的配置项加载到Spring环境中
2. 自动配置IOC容器：SpringBoot根据应用程序所引入的依赖和上下文的配置，自动配置Spring IOC容器。它会自动扫描所有带有@Component以及派生注解的bean，并添加相应的依赖关系，从而构建出整个应用程序的bean容器
3. 扫描处理注解：SpringBoot根据配置文件中的@ComponentScan注解指定的扫描路径，扫描所有带有注解的类，并进行相关的处理，例如扫描@RestController,@RequestMapping @Service等注解的类，并将其注册到SpringIOC容器，从而构建整个应用程序的bean
4. 开启Web服务器：如果应用程序时Web应用程序，SpringBOot会自动开启内嵌的Tomcat等Web服务器，并将应用程序注册到服务器中，使其可以响应请求，
5. 运行CommandLineRunner和ApplicationRunner：如果应用程序中有实现了COmmandLineRunner或者ApplicationRunner接口的bean，SpringBoot会在容器启动完成后自动调用他们的run()方法
6. 注册ServletCOntextListener：Spring Boot会自动注册SpringBootServletInitializer，ServletContextListener和Filter等，以保证程序正常运行。

### 基础配置

三种配置形式

* `.properties` 
* `.yml` (**主流**)
* `.yaml` 

加载顺序：

`.properties` > `.yml` > `.yaml`

#### 四级配置文件

1. file: copnfig/application.yml （**这里的file是jar包所在的文件夹**）【最高】

2. file: application.yml  （**这里的file是jar包所在的文件夹**）
3. classpath: config/application.yml    **项目工程中的classpath，即resources目录下**
4. classpath: application.yml 【最低】 **项目工程中的classpath，即resources目录下**

1与2，留作系统打包后设置通用属性

3与4 用于系统开发阶段设置通用属性

#### yaml语法规则

- 大小写敏感
- 属性层级关系使用多行描述，每行结尾使用冒号结束
- 使用缩进表示层级关系，同层级左侧对其，只允许使用空格 （不可以使用tab）
- 属性值前面要加空格
- \# 表示冒号 

#### yaml数据读取方式

- `@Value`的方式

- 依赖注入 `Environment` ，可以拿到配置的所有内容

- 定义实体类

  - ```java
    @Component
    @ConfigurationProperties(prefix = "user.xx.xx")
    public class User() {
        
    }
    ```

    然后依赖注入即可

#### 多环境开发

命令行启动，类似如下形式可以在启动的时候指定一些参数，覆盖jar包中的属性

```shell
java -jar springboot.jar --spring.profiles.active=dev

java -jar springboot.jar --server.port=9999
```

## MyBatisPlus

### 分页

* 添加配置类，增加`IPage`插件的支持
* 使用`IPage`即可

### 条件查询

```java
LambdaQueryWrapper<UserEntity> lqw = new LambdaQueryWrapper<>();
lqw.ge(UserEntity::getName, "a").or().eq(UserEntity::getName, "b");
```

### 表与实体类的映射

* `@TableField(value="xxx", select=false)`，其中value表示数据库中的字段名，select为false表示不参与查询。
* `@TableName("tb_user")` 实体类和数据库表名的映射

### id生成

`@TableId(type=IdTYpe.xxx)` 有多种

* 自增 `AUTO`
* 雪花id `ASSIGN_ID`
* uuid `ASSIGN_UUID`
* 手动指定 `INPUT`

[](https://lsp-1259035619.cos.ap-beijing.myqcloud.com/typora/image-20240319011455131.png)



![image-20240319011819882](https://s2.loli.net/2024/03/19/fFHcEQdN2awRgtG.png)

### 逻辑删除

实体类属性注解

`@TableLogin(value="", delval="")`

value 代表未删除的状态的值，delval代表删除状态的值。

这样在删除的时候不会删除数据，而是进行数据状态修改

也可以在配置文件中，进行全局配置。

```yml
mybatis-plus:
  global-config:
    db-config:
      logic-delete-field: delete
      logic-delete-value: "0"
      logic-not-delete-value: "1"
```

### 乐观锁

`@Version`

* 字段上加上version字段
* 增加拦截器 `OptimisticLockerInnerInterceptor`

原理类似CAS操作

即查询的时候拿到version，然后在修改的查询条件中增加一个条件，去查看当前的version是不是我拿到的这个version（CAS的期望值），如果是则可以修改，否则不能修改
