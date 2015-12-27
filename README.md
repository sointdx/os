##### 一、下载原版ubuntu系统

点[下载地址](http://releases.ubuntu.com/trusty/ubuntu-14.04.3-desktop-i386.iso "原版镜像下载地址")即可下载，下载后检查一下MD5是否为`0bc058cdc75fb75d4922c7c74c4cd6b1`并复制到用户主目录 

##### 二、下载定制脚本及其需要的文件

用git下载所需文件。先安装git
```
sudo apt-get -y install git
```

用git取定制所需的文件，取完后会以目录tdxos的形式存在于用户主目录中
```
git clone https://github.com/sointdx/tdxos.git
```

##### 三、定制系统

**注意**：整个定制过程要保证所有的联网请求都经过代理，如果实现不了请不要定制！

`cd tdxos`，第一次运行如下命令即可定制系统
```
sudo ./tdxos.sh init
sudo ./tdxos.sh custom
```

以后每次修改完文件，输入命令`sudo ./tdxos.sh custom` 即可定制
