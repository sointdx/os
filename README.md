#### 一、下载原版ubuntu系统

点[下载地址](http://releases.ubuntu.com/14.04/ubuntu-14.04.1-desktop-i386.iso "原版镜像下载地址")即可下载，下载后检查一下MD5是否为`a4fc15313ef2a516bfbf83ce44281535`并复制到用户主目录 

#### 二、下载定制脚本及其需要的文件

这里有两种方法下载这些文件：

1、翻墙后，可以通过点击本页面右边的**Download ZIP**按钮下载这些文件，下载后是一个压缩文件，需要解压缩。

2、用git下载所需文件。先安装git
```
sudo apt-get -y install git
```

在用git取文件之前您可能需要先运行下面两条命令设置git经过自由门代理(*可选*，**推荐**，这种方式没有设置DNS的代理)
```
git config --global http.proxy 'socks5://127.0.0.1:8580'
git config --global https.proxy 'socks5://127.0.0.1:8580'
```

用git取定制所需的文件，取完后会以目录os的形式存在与用户主目录中
```
git clone https://github.com/sointdx/os.git
```

#### 三、定制系统

進入解压缩的文件夹（如果您是用git取的文件，需要進入主目录的os文件夹），第一次运行如下命令即可定制系统
```
sudo ./ubuntu.sh init
sudo ./ubuntu.sh custom
```

以后每次修改完文件，输入命令`sudo ./ubuntu.sh custom` 即可定制
