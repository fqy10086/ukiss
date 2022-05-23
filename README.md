# ukiss

[toc]

# UKISS 合约

## 1. 合约说明
```text
   合约遵循ERC20标准，依赖openzeppelin开源库，主合约，业务合约均为可升级合约; 
   源码地址:https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable
  
   合约区分管理权限(部署权限)，业务执行权限(owner权限)
```

## 2. 合约分类

| 合约名称     | 说明   | 类型|
| ----------  | --------|--------|
| ProxyAdmin | 管理合约 |基础合约|
| TransparentUpgradeableProxy | 可升级代理合约  |基础合约|
| UKissFixedSupply | UKISS ERC20   |主合约|
| FoundersTokenVesting | 发起团队 Founders   |业务合约|
| AdvisorsTokenVesting | 顾问团，公司主要人员   |业务合约|


## 3. UKissFixedSupply

```
固定数量合约
```


## 4. FoundersTokenVesting

| 类别     | 说明 |
| ----------  | --------|
| initialize 初始化方法名 |  |
| 默认管理权限 | 0x0000000000000000000000000000000000000000000000000000000000000000  |
| PAUSER权限 | 0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a  |
| 逻辑合约地址 | -  |
| 代理合约地址 | -  |

**初始化参数说明**:

| 参数     | 说明 |
| ----------  | --------|
| _token | UKISS 代理合约地址 |
| _owner | 合约释放UKISS地址-（外部提供）  |
| _start | 合约上线时间搓,单位秒(s)  |


## 5. AdvisorsTokenVesting

| 类别     | 说明 |
| ----------  | --------|
| initialize 初始化方法名 |  |
| 默认管理权限 | 0x0000000000000000000000000000000000000000000000000000000000000000  |
| PAUSER权限 | 0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a  |
| 逻辑合约地址 | -  |
| 代理合约地址 | -  |

**初始化参数说明**:

| 参数     | 说明 |
| ----------  | --------|
| _token | UKISS 代理合约地址 |
| _owner | 合约释放UKISS地址-（外部提供）  |
| _start | 合约上线时间搓,单位秒(s)  |

## 6. 部署顺序

- ProxyAdmin 管理合约
- UKissFixedSupply合约  逻辑合约部署后；部署 TransparentUpgradeableProxy合约执行：deploy方法
- FoundersTokenVesting发起人合约  逻辑合约部署后；部署 TransparentUpgradeableProxy合约执行：deploy方法
- AdvisorsTokenVesting顾问团队合约   逻辑合约部署后；部署 TransparentUpgradeableProxy合约执行：deploy方法
- 执行合约方法:
     
  1. 调用UKissFixedSupply合约
  2. 调用FoundersTokenVesting合约 执行  initParam (初始化参数方法)
  3. 调用AdvisorsTokenVesting合约 执行 initParam (初始化参数方法)

## 7. 源码

```text
   参见源码文件
```




