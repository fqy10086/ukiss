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
| UKiss | UKISS ERC20   |主合约|
| FoundersTokenVesting | 发起团队 Founders   |业务合约|
| AdvisorsTokenVesting | 顾问团，公司主要人员   |业务合约|


## 3. UKiss

| 类别     | 说明 |
| ----------  | --------|
| initialize 初始化方法名 | 0x8129fc1c |
| 默认管理权限 | 0x0000000000000000000000000000000000000000000000000000000000000000  |
| PAUSER权限 | 0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a  |
| MINT权限 | 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6  |
| 逻辑合约地址 | -  |
| 代理合约地址 | -  |
| mintInit 批量铸币方法 | 地址数组，额度数组；特别说明：decimals 18位，额度参数无需乘10^18处理 |

**铸币逻辑**: 需要铸币权限
```text
//mint ukiss
function mutilMint(address[] memory _addresses,uint256[] memory _amounts) public onlyRole(MINTER_ROLE){
    require(_addresses.length > 0 && _amounts.length > 0 && _addresses.length == _amounts.length,"UKiss:the array lengths are not equal");
    require(hasMint < maxMint,"UKiss: exceed max value");
    for(uint256 i = 0; i < _addresses.length; i++){
        require(_addresses[i] != address(0) && _addresses[i] != address(this),"UKiss:bad mint address");
        require(_amounts[i] > 0,"UKiss:cannot mint zero value");
        uint256 mintVal = _amounts[i]*10**18;
        require((hasMint + mintVal) < maxMint,"UKiss: exceed max value");
        _mint(_addresses[i], mintVal);
        hasMint = hasMint + mintVal;
    }
}
```

## 4. FoundersTokenVesting

| 类别     | 说明 |
| ----------  | --------|
| initialize 初始化方法名 | 0x8129fc1c |
| 默认管理权限 | 0x0000000000000000000000000000000000000000000000000000000000000000  |
| PAUSER权限 | 0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a  |
| 逻辑合约地址 | -  |
| 代理合约地址 | -  |
| initParam 部署成功，初始化参数 | - |

**初始化参数说明**:

| 参数     | 说明 |
| ----------  | --------|
| _token | UKISS 代理合约地址 |
| _owner | 合约释放UKISS地址-（外部提供）  |
| _start | 合约上线时间搓,单位秒(s)  |

**初始化参数逻辑**: 需要管理权限，且只能执行一次
```text
function initParam(address _token,address _owner,uint256 _start) public onlyRole(DEFAULT_ADMIN_ROLE) {
    require(!locked,"Funders: repeated execute");
    require(_token != address(0) && _token != address(this),"Funders: bad Ukiss token");
    require(_owner != address(0) && _owner != address(this),"Funders: bad release address");

    token = _token;
    releaseAddress = _owner;
    start = _start;

    cliff = 31536000;
    nextTime = start.add(cliff);
    releasedTimes = 0;
    lastTime = 0;
    yearRelease = [3600000000000000000000000,3600000000000000000000000,3600000000000000000000000,
    3600000000000000000000000,3600000000000000000000000];
    
    locked = true;
}
```

## 5. AdvisorsTokenVesting

| 类别     | 说明 |
| ----------  | --------|
| initialize 初始化方法名 | 0x8129fc1c |
| 默认管理权限 | 0x0000000000000000000000000000000000000000000000000000000000000000  |
| PAUSER权限 | 0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a  |
| 逻辑合约地址 | -  |
| 代理合约地址 | -  |
| initParam 部署成功，初始化参数 | - |

**初始化参数说明**:

| 参数     | 说明 |
| ----------  | --------|
| _token | UKISS 代理合约地址 |
| _owner | 合约释放UKISS地址-（外部提供）  |
| _start | 合约上线时间搓,单位秒(s)  |

**初始化参数逻辑**: 需要管理权限，且只能执行一次
```text
function initParam(address _token,address _owner,uint256 _start) public onlyRole(DEFAULT_ADMIN_ROLE) {
    require(!locked,"Advisors: repeated execute");
    require(_token != address(0) && _token != address(this),"Advisors: bad UKiss token");
    require(_owner != address(0) && _owner != address(this),"Advisors: bad release address");

    token = _token;
    releasedAddress = _owner;
    start = _start;

    afterTgeDuration = 15768000; //6 mouth
    remainDuration = 15768000; //6 mouth
    duration = 15768000; // 6 mouth
    releaseTimes = 0;
    lastTime = 0;
    nextTime = start.add(afterTgeDuration);

    releasedArr = [200000000000000000000000,800000000000000000000000,800000000000000000000000,
    800000000000000000000000,800000000000000000000000,800000000000000000000000,800000000000000000000000];
    
    locked = true;
}
```

## 6. 部署顺序

- ProxyAdmin 管理合约
- UKiss合约  逻辑合约部署后；部署 TransparentUpgradeableProxy合约执行：deploy方法
- FoundersTokenVesting发起人合约  逻辑合约部署后；部署 TransparentUpgradeableProxy合约执行：deploy方法
- AdvisorsTokenVesting顾问团队合约   逻辑合约部署后；部署 TransparentUpgradeableProxy合约执行：deploy方法
- 执行合约方法:
     
  1. 调用UKiss合约，(整理铸币地址)实现批量铸币
  2. 调用FoundersTokenVesting合约 执行  initParam (初始化参数方法)
  3. 调用AdvisorsTokenVesting合约 执行 initParam (初始化参数方法)

## 7. 源码

```text
   参见源码文件
```




