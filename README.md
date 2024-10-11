# Awesome-Script

## tcp_scan.sh

- TCP端口扫描脚本，基于telnet原理实现

```shell
bash tcp_scan.sh 192.168.1.1 8080,443,9090,443-1000
```

## nc_scan.sh

- netcat端口扫描脚本

```shell
bash tcp_scan.sh 192.168.1.1 8080,443,9090,443-1000
```

## remount.bat

- 安卓系统盘重新挂载为可读写脚本

```cmd
.\remount.bat -d 9987AAA0001ZY
```

## upload_ca_cert.bat

- 上传证书到安卓系统证书目录脚本

```cmd
.\upload_ca_cert.bat -d 9987AAA0001ZY -c ca.crt
```

## proxy_tool.bat

```cmd
.\proxy_tool.bat -d 9987AAA0001ZY -h 127.0.0.1 -p 8080
```
