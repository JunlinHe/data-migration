# 问题背景

## 场景

- 场景一：开发环境，多人共用数据库
  - 开发调试过程中执行SQL查询，突然报错“xxx表不存在”，”xxx字段不存在”，谁偷偷改了表结构？

- 场景二：开发环境，个人搭建数据库
  - 开发完一个功能，提交代码、更新，重启准备调试下，代码报错“XX表不存在”，谁偷偷改了表结构？
  - 新员工：我要搭建一套开发环境，应该执行哪些sql？什么？从开发环境dump过来？我不想要那么多垃圾数据。什么？只导表结构？启动服务打开首页空空如也，菜单没配？

- 场景三：开发提测
  - 张三、李四你们发下这次修改的脚本，我：执行脚本1、2、3...
  - 测试：你这接口报错。我一顿问题排查：忘记提脚本了，你执行下这个sql
  
- 场景四：搭建演示环境
  - 执行SQL脚本1、SQL脚本2、SQL脚本3……启动服务失败！什么？这个脚本N是测试版本的，jar包是已经上线的版本？删库再来一遍，一天过去了

## 思考

上面场景，是我们开发过程中常遇到的问题，如果没遇到，说明开发流程十分规范，否则，我们需要一些手段去规避这些问题，flyway为我们提供了这样的能力。

# Flyway简介

Flyway是一个轻量级的SQL版本控制工具。

引用两张官网的图：

- 版本控制流程：

![flyway version control](https://documentation.red-gate.com/fd/files/183306238/183306334/1/1668097721120/Migration-1-2.png)

- 版本记录表flyway_schema_history：

![flyway_schema_history](https://documentation.red-gate.com/fd/files/184127223/205225997/1/1683034468020/image2023-5-2_14-34-27.png)

flyway使用版本记录表来记录每个版本的执行过程，表记录就是sql版本的元数据。因为记录是按版本号升序排列的，每次执行更新操作时，flyway会扫描版本记录表，获取脚本文件名及checksum，对比脚本目录中的对应文件的checksum，如果不一致，则会抛出异常，并记录失败信息，flyway是不允许对以前的脚本文件进行修改的，这也是规范；脚本目录出现了新的脚本文件（文件命名规则：V3__description.sql），flyway会自动为新的脚本生成一个新的版本记录，这样就保证了每个版本都是有序的。

flyway社区版本提供了多种方式来执行SQL脚本，包括:
- Command-line：使用命令行执行SQL脚本
- Flyway AutoPilot：CI/CD工具自动执行SQL脚本
- Flyway Desktop：桌面工具
- Docker：容器化管理脚本
- API：集成到项目中的Java API，可以做定制
- Maven/Gradle：用于集成到项目中的maven/gradle插件

# 改造方案

## 方案对比

下面简要说明下上面各种方案的利弊：
- AutoPilot改造成本高；
- Command-line和Desktop手动操作的复杂度和不确定性都很大；
- API方式对项目侵入性很大，也没必要每个服务都维护一套脚本，实际上我们的微服务都是共用一个数据库；
- Maven/Gradle插件如果用在独立项目还可以考虑；
- 我推荐使用Docker方式，在工程中使用git管理脚本，持续集成时打包成镜像，持续部署后随容器的创建启动执行脚本，最后随容器销毁

## 具体实施方案

### 创建代码仓库

> [demo项目地址](https://github.com/JunlinHe/data-migration.git)

- 仓库名称：xxx-data-migration
- 目录结构：
  - app/flyway: 存放flyway docker镜像配置文件
  - script：存放持续集成相关脚本
    - Jenkinsfile：Jenkins pipeline脚本，用于存档，而在持续集成平台维护真正执行的脚本，因为若在持续集成流水线中调用当前脚本会增加调试难度
    - k8s.yaml：k8s deployment配置，同样是存档
    - docker-compose.yml：用于本地演示的docker容器编排配置
    - xxx.sh：配合本地演示的相关脚本
  - sql：存放数据库脚本文件
    - init：系统初始化脚本
      - V1__init.sql：创建业务数据库、用户账号，赋权等初始化操作
    - base：文件夹名应与数据库同名
      - V1__init.sql：base数据库的初始化脚本

### 脚本管理

- 脚本目录为sql，子目录名应与数据库同名
- 脚本文件命名规范：V大写，后面跟数字作为版本号，按时间戳命名，后面跟双下划线，再后面是脚本名，示例：V202309221000__feature-1.sql
- 脚本文件命名不符合规范的会被自动忽略
- 旧版sql脚本原则上不允许修改，实在要改也行，在命令行输出的日志中获取被修改的旧版sql脚本的checksum，然后手动修改`flyway_schema_version`中的checksum，并手动执行被修改的部分sql
- 新版本脚本执行失败时，会抛出异常，并会在`flyway_schema_history`记录失败信息，下次容器启动前需要删除该条记录

### flyway 命令

- baseline

不论是新项目还是旧项目，都可以接入flyway，你可以把当前的数据库脚本整理为基线版本`V1__init.sql`，执行`baseline`命令，flyway会自动创建flyway_schema_version表并记录命令的执行情况

```shell
flyway -url=jdbc:mysql://localhost:3306/my-db
       -user=root 
       -password=postgres 
       -baselineVersion=1 
       -baselineDescription=init 
       baseline
```

注意，命令参数`-baselineDescription`值应与基线版本脚本描述`init`一致

- migrate

migrate是flyway的核心命令，用于执行sql迁移任务。实际上，当你配置了环境变量参数`FLYWAY_BASELINE_ON_MIGRATE=true`时，它会像`baseline`命令一样，自动创建`flyway_schema_version`表并使用最小版本的sql文件作为基线版本，所以在执行旧项目改造时，不需要手动执行`baseline`命令，仅需要整理好`V1__init.sql`即可

# 执行数据迁移

## 演示

> 你需要在linux环境中执行演示脚本，它将安装docker，并使用docker-compose运行flyway数据迁移示例

```shell
cd script/quickstart && \ 
sudo sh run.sh init && \ 
sudo sh run.sh up
```

## CI/CD

- 将`script/Jenkinsfile`导入你的持续集成构建计划中
- 将`k8s.yaml`导入你的持续部署流程中
