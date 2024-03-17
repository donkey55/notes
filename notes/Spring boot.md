## Maven

- mvn compile
-  

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

### Spring 事务

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

## Spring boot

## 简介

**约定大于配置**

内嵌Tomcat等服务器

## 启动流程

1. 加载Spring Boot配置文件：SpringBoot会先加载内部的spring-boot-autoconfiguration 和 spring-boot-starter等Starter，然后加载用户自定义的配置文件，并将其中的配置项加载到Spring环境中
2. 自动配置IOC容器：SpringBoot根据应用程序所引入的依赖和上下文的配置，自动配置Spring IOC容器。它会自动扫描所有带有@Component以及派生注解的bean，并添加相应的依赖关系，从而构建出整个应用程序的bean容器
3. 扫描处理注解：SpringBoot根据配置文件中的@ComponentScan注解指定的扫描路径，扫描所有带有注解的类，并进行相关的处理，例如扫描@RestController,@RequestMapping @Service等注解的类，并将其注册到SpringIOC容器，从而构建整个应用程序的bean
4. 开启Web服务器：如果应用程序时Web应用程序，SpringBOot会自动开启内嵌的Tomcat等Web服务器，并将应用程序注册到服务器中，使其可以响应请求，
5. 运行CommandLineRunner和ApplicationRunner：如果应用程序中有实现了COmmandLineRunner或者ApplicationRunner接口的bean，SpringBoot会在容器启动完成后自动调用他们的run()方法
6. 注册ServletCOntextListener：Spring Boot会自动注册SpringBootServletInitializer，ServletContextListener和Filter等，以保证程序正常运行。

