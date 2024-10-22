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

## remount_to_system.bat

- 安卓系统盘重新挂载为可读写脚本

```cmd
.\remount_to_system.bat -d 9987AAA0001ZY
```

## upload_ca_cert.bat

- 上传证书到安卓系统证书目录脚本

```cmd
.\upload_ca_cert.bat -d 9987AAA0001ZY -c ca.crt
```

## set_android_proxy.bat

- 设置安卓系统代理

```cmd
.\set_android_proxy.bat -d 9987AAA0001ZY -h 127.0.0.1 -p 8080
```

## vcenter_brute.sh

- 使用ldap协议爆破vCenter用户名和密码

```shell
bash vcenter_brute.sh -h 127.0.0.1 -uf user_dict.txt -pf pass_dict.txt
```

## write_gshark_rule.bat

- 往gshark服务添加二次过滤规则

```cmd
.\write_gshark_rule.bat
```