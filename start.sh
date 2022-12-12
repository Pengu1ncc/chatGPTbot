export PATH=~/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin
Red_font_prefix="\033[31m"
Green_font_prefix="\033[32m"
Font_color_suffix="\033[0m"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"

check_root() {
    [[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
check_qqbot_pid() {
    PID_qqbot=$(ps aux | grep './go-cqhttp' | grep -v grep | awk '{print $2}')
}

check_wechatbot_pid() {
    PID_wechatbot=$(ps -ef | grep 'go run ./main.go' | grep -v grep | awk '{print $2}')
}

check_sys() {
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then
        release="debian"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
        release="debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    fi
} 

Installation_qq_dependency() {
    if [[ ${release} = "centos" ]]; then
  	yum -y update
  	yum install -y coreutils
  	yum install -y python3.8
    else
  	apt -y update
  	apt install -y coreutils
  	apt install -y python3.8
    fi
}
Installation_weixin_dependency() {
    if [[ ${release} = "centos" ]]; then
	yum update -y
 	yum install coreutils -y
  	yum install golang -y
    else
	apt update -y
 	apt install coreutils -y
  	apt install golang -y
    fi
}
Qqbot() {
  clear
  echo -e "
 ${Green_font_prefix}1.${Font_color_suffix} 部署QQGPTBot
 ${Green_font_prefix}2.${Font_color_suffix} 启动QQGPTBot（后台无窗口运行）
 ${Green_font_prefix}3.${Font_color_suffix} 停止QQGPTBot（关闭后台运行）
 ${Green_font_prefix}4.${Font_color_suffix} 修改配置信息
 ———————————————————————————————"
check_qqbot_pid
if [[ ! -z "${PID_qqbot}" ]]; then
    echo -e " QQGPTBot 状态: ${Green_font_prefix}已启动${Font_color_suffix}"
else
    echo -e " QQGPTBot 状态: ${Red_font_prefix}未启动${Font_color_suffix}"
fi
echo

read -e -p " 请输入数字 [1-5]:" qq_bot_choos
    if [[ ${qq_bot_choos} == "1" ]]; then
        Install_qq_bot
    elif [[ ${qq_bot_choos} == "2" ]]; then
        Star_qq_bot
    elif [[ ${qq_bot_choos} == "3" ]]; then
        Stop_qq_bot
    elif [[ ${qq_bot_choos} == "4" ]]; then
        Modify_qq_bot
    else
        echo
        echo -e " ${Error} 请输入正确的数字"
        exit 1
    fi
}

Wechatbot() {
  clear
  echo -e "微信登录需要实名认证，如果扫码登录失败，认证完成以后，重新部署即可
 ${Green_font_prefix}1.${Font_color_suffix} 部署WechatGPTBot
 ${Green_font_prefix}2.${Font_color_suffix} 启动WechatGPTBot（后台无窗口运行）
 ${Green_font_prefix}3.${Font_color_suffix} 停止WechatGPTBot（关闭后台运行）
 ${Green_font_prefix}4.${Font_color_suffix} 修改配置信息
 ———————————————————————————————"
check_wechatbot_pid

if [[ ! -z "${PID_wechatbot}" ]]; then
    echo -e " WechatGPTBot 状态: ${Green_font_prefix}已启动${Font_color_suffix}"
else
    echo -e " WechatGPTBot 状态: ${Red_font_prefix}未启动${Font_color_suffix}"
fi

echo
read -e -p " 请输入数字 [1-4]:" wechat_bot_choos
    if [[ ${wechat_bot_choos} == "1" ]]; then
        Install_wechat_bot
    elif [[ ${wechat_bot_choos} == "2" ]]; then
        Star_wechat_bot
    elif [[ ${wechat_bot_choos} == "3" ]]; then
        Stop_wechat_bot
    elif [[ ${wechat_bot_choos} == "4" ]]; then
        Modify_wechat_bot
    else
        echo
        echo -e " ${Error} 请输入正确的数字"
        exit 1
    fi
}

Install_qq_bot(){
  check_root 
  check_sys
  Installation_qq_dependency
  python3.8 -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
  python3.8  -m pip install Flask==2.2.2 -i https://pypi.tuna.tsinghua.edu.cn/simple
  python3.8  -m pip install openai==0.25.0 -i https://pypi.tuna.tsinghua.edu.cn/simple
  python3.8  -m pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple
  cd ./qqbot
  read -e -p " 请输入qq号：" qq_code
  sed -i "4s#qqcode#${qq_code}#g" config.yml
  sed -i "2s#qqcode#${qq_code}#g" ./app/config.json
  read -e -p " 请输入qq密码：" qq_passwd
  sed -i "5s#qqpasswd#${qq_passwd}#g" config.yml
  read -e -p " 请输入openai_api_key：" qq_openai_key
  sed -i "3s#apiKey#${qq_openai_key}#g" ./app/config.json
  cd ./app
  nohup python3.8 ./main.py >/dev/null 2>1 &
  clear
  read -p "提示运行成功后，按住ctrl+c退出，然后重新进入脚本启动服务即可（按任意键继续）"
  cd ..
  chmod +x ./go-cqhttp
  ./go-cqhttp -faststart
}

Star_qq_bot(){
  cd ./qqbot
  check_qqbot_pid
if [[ ! -z "${PID_qqbot}" ]]; then
    kill 9 $(ps aux | grep 'python3.8 ./main.py' | grep -v grep | awk '{print $2}')
    kill 9 $(ps aux | grep './go-cqhttp' | grep -v grep | awk '{print $2}')
    cd ./app
    nohup python3.8 ./main.py >/dev/null 2>1 &
    cd ..
    nohup ./go-cqhttp -faststart >/dev/null 2>1 &
else
    cd ./app
    nohup python3.8 ./main.py >/dev/null 2>1 &
    cd ..
    nohup ./go-cqhttp >/dev/null 2>1 &
    nohup ./go-cqhttp -faststart >/dev/null 2>1 &
fi
  check_qqbot_pid
if [[ ! -z "${PID_qqbott}" ]]; then
    echo -e "${Green_font_prefix}启动成功${Font_color_suffix}"
else
    echo -e " ${Red_font_prefix}启动失败，请输入ps aux检查进程go-cqhttp与python3.8 ./main.py是否启动，如果其中一个进程没有启动，请手动调试进程。${Font_color_suffix}
    	      ${Font_color_suffix}手动调试命令：
    	      ${Red_font_prefix}1.${Font_color_suffix} cd ./qqbot && ./go-cqhttp
 	      ${Red_font_prefix}2.${Font_color_suffix} cd ./qqbot/app && python3.8 ./main.py
	      ${Font_color_suffix}成功启动后可以退出窗口，重新进入脚本使用后台运行即可。
    "
fi
  exit 0
}

Stop_qq_bot(){
  kill 9 $(ps aux | grep 'python3.8 ./main.py' | grep -v grep | awk '{print $2}')
  kill 9 $(ps aux | grep './go-cqhttp' | grep -v grep | awk '{print $2}')
  check_qqbot_pid
if [[ ! -z "${PID_qqbott}" ]]; then
    echo -e "${Red_font_prefix}停止失败，请手动杀死进程${Font_color_suffix}"
else
    echo -e " ${Green_font_prefix}停止成功${Font_color_suffix}
    "
fi
  exit 0
}
Modify_qqcoade(){
cd ./qqbot
read -r -p "是否修改qq号? [Y/n] " input_one

case $input_one in
    [yY][eE][sS]|[yY])
		read -e -p " 请输入qq号：" qq_code
    sed -i "4s#qqcode#${qq_code}#g" config.yml
    sed -i "2s#qqcode#${qq_code}#g" ./app/config.json
    rm -f session.token
    echo "修改成功"
		;;

    [nN][oO]|[nN])
		return 1
       	;;

    *)
		echo "无效输入"
		exit 1
		;;
esac
}
Modify_qqpasswd(){
  read -r -p "是否修改qq密码? [Y/n] " input_two

case $input_two in
    [yY][eE][sS]|[yY])
    read -e -p " 请输入qq密码：" qq_passwd
    sed -i "5s#qqpasswd#${qq_passwd}#g" config.yml
    echo "修改成功"
		;;

    [nN][oO]|[nN])
		return 1
       	;;

    *)
		echo "无效输入"
		exit 1
		;;
esac
}
Modify_qq_openai_api_key(){
  read -r -p "是否修改openai_api_key? [Y/n] " input_three

case $input_three in
    [yY][eE][sS]|[yY])
    read -e -p " 请输入openai_api_key：" qq_openai_key
    sed -i "3s#apiKey#${qq_openai_key}#g" ./app/config.json
    echo "修改成功"
		;;

    [nN][oO]|[nN])
		return 1
       	;;

    *)
		echo "无效输入"
		exit 1
		;;
esac
}
Modify_qq_bot(){
  cd ./qqbot
  Modify_qqcoade
  Modify_qqpasswd
  Modify_qq_openai_api_key
  cd ./apt
  nohup python3.8 ./main.py >/dev/null 2>1 &
  cd ..
  nohup ./go-cqhttp >/dev/null 2>1 &
  nohup ./go-cqhttp -faststart >/dev/null 2>1 &
  echo "启动成功"
  exit 0
}

Install_wechat_bot(){
  check_root
  check_sys
  Installation_weixin_dependency
  cd wechatbot
  rm -f storage.json
  go env -w GO111MODULE=on
  go env -w GOPROXY=https://goproxy.io,direct
  read -e -p " 请输入openai_api_key：" wechat_openai_key
  sed -i "2s#apiKey#${wechat_openai_key}#g" ./config.json
  clear
  read -p "提示运行成功后，按住ctrl+c退出，然后重新进入脚本启动服务即可（按任意键继续）"
  go run main.go
}

Star_wechat_bot(){
  cd wechatbot
  check_wechatbot_pid
if [[ ! -z "${PID_wechatbot}" ]]; then
    kill 9 $(ps -ef | grep 'go run ./main.go' | grep -v grep | awk '{print $2}')
    kill 9 $(ps aux | grep 'exe/main' | grep -v grep | awk '{print $2}')
    nohup go run ./main.go >/dev/null 2>1 &
else
    nohup go run ./main.go >/dev/null 2>1 &
fi
  check_wechatbot_pid
if [[ ! -z "${PID_wechatbot}" ]]; then
    echo -e "${Green_font_prefix}启动成功${Font_color_suffix}"
else
        echo -e " ${Red_font_prefix}启动失败，请输入ps aux检查进程go run ./main.go是否启动，如果进程没有启动请输入cd ./wechatbot && go run ./main.go手动调试进程，调试成功后关闭窗口，重新启动脚本后台运行即可。${Font_color_suffix}"
fi
  exit 0
}

Stop_wechat_bot(){
  kill 9 $(ps -ef | grep 'go run ./main.go' | grep -v grep | awk '{print $2}')
  kill 9 $(ps aux | grep 'exe/main' | grep -v grep | awk '{print $2}')
    check_wechatbot_pid
if [[ ! -z "${PID_wechatbot}" ]]; then
    echo -e "${Red_font_prefix}停止失败，请手动关闭进程${Font_color_suffix}"
else
    echo -e "${Green_font_prefix}停止成功${Font_color_suffix}"
  fi

  exit 0
}

Modify_wechat_bot(){
  cd wechatbot
  read -e -p " 请输入openai_api_key：" wechat_openai_key
  sed -i "2s#apiKey#${wechat_openai_key}#g" ./config.json
  echo -e "修改成功"
  nohup go run ./main.go >/dev/null 2>1 &
  echo "启动成功"
  exit 0
}


echo && echo -e " ChatGPTBot 一键部署脚本
1.选择你要部署的bot类型
2.进入选择后未部署bot的选择第一个选项进行bot部署，部署完成后关闭窗口
3.部署完成后，重新启动脚本，选择你要启动的bot服务，即可后台无窗口运行

 ${Green_font_prefix}1.${Font_color_suffix} QQGPTBot
 ${Green_font_prefix}2.${Font_color_suffix} WeichatGPTBot
"
echo
read -e -p " 请输入数字:" num
case "$num" in
1)
    Qqbot
    ;;
2)
    Wechatbot
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
