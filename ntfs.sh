#!/bin/bash
# ======================= by:黑蝎子 =========================
# 保存名字 ntfs.sh 放用户根目录, 打开“终端”应用，执行如下命令：
# chmod +x ~/ntfs.sh #给 ntfs.sh 加可执行权限
# 以后想要读写 NTFS 格式了只需要运行终端输入 ~/ntfs.sh 按操作即可
# =============== email:aqzi@qq.com 17.4.1 =================
# 初始化变量
COUNTER=0
# ls 列表已存在的盘 ==========================================
function Filelist()
{
 local i=0 # 需要控制最大数
 local IFS=$'\n' # 设定回车符
 local dev=""
 local volume=""
 local myline=""
 local D[0]="dev"
 local V[0]="volume"
 local s
 for myline in `df` # ` 为系统命令 , 返回 df 的值
 do
 if [ $i -gt 0 ] ; then
 dev=$myline
 volume=`echo ${dev##*% }|sed "s/\ /\\\ /g"`
 dev=${dev%% *}

 D[$i]=${dev}
 V[$i]=${volume}
 #echo ${D[$i]} #为方便检查，加了打印

 echo "${i}. ${dev} --- ${volume}"
 fi
 i=$(($i+1))
 done
 echo "请输入要挂载的盘符:(数字)"
 read s
 judge $s $i 1 D V
}

# 判断集合 ==================================================
function judge() # $1为当前输入, $2为最大数, $3为哪个命令需要
{
 local d
 local v
 local k
 if [ -n "$(echo $1| sed -n "/^[0-9]*$/p")" ];then
 if [ "$1" -gt 0 -a $1 -lt $2 ] ; then
 # $3 = 1状态是 挂载
 if [ $3 -eq 1 ] ; then
 d=$4[@]
 v=$5[@]
 d=("${!d}")
 v=("${!v}")
 Load_run ${d[$1]} ${v[$1]}
 fi
 # $3 = 0状态是 卸载
 if [ $3 -eq 0 ] ; then
 k=$4[@]
 k=("${!k}")
 uninstall_run ${k[$1]}
 fi
 else
 echo "输入的数字不在此范围, 请参考命令中的行号"
 fi
 else
 echo "输入的不是数字"
 fi
}

# 挂载 =====================================================
function Load_run()
{
 local dev=$1 # 盘原挂载目录
 local volume=$2 # 盘符标识
 local tempfile=${volume#*/} # (/Volume/...) 去掉 /
 diskutil info $dev|grep ntfs # 检查是否 ntfs 格式盘
 if [ $? -ne 0 ] ; then
 echo "最近挂载的磁盘:$dev 不是 NTFS 磁盘! "
 else
# diskutil umount $volume # 开始卸载
# echo "simen:" $volume
 sudo umount $volume
 sudo mkdir -p $tempfile # 创建目录 挂载
 sudo mount -t ntfs -o rw,auto,nobrowse $dev $tempfile
 if [ $? -ne 0 ] ; then
 echo "磁盘需要在Windows上经过检查、修复才能挂载为可写!"
 sudo rm -r $tempfile
 else
 echo "挂载成功, 路径: 脚本当前目录/${tempfile}"
 echo "是否现在打开该盘:(y/n ?)"
 read yn
 if [ "${yn}" = "y" ] ; then
 open $tempfile
 fi
 fi
 fi
}

# 卸载 ==================================================
function uninstall_run()
{
 until sudo umount $1
 do
 echo "请先关掉正在占用 $1 的程序，然后按 Return 键卸载 $1"
 read
 done
 sudo rm -r $1
 echo "卸载成功"
}

function uninstall()
{
 local str
 local p
 local m="Volumes"
 local j=1
 local K[0]="un"
 if [ ! -d "${m}" ]; then
 echo "还没有挂载任何盘"
 else
 for str in `ls Volumes`
 do
 K[$j]="${m}/${str}"
 echo "${j}. ${K[$j]}"
 j=$(($j+1))
 done
 echo "请输入要卸载的盘:(数字)"
 read p
 judge $p $j 0 K
 fi
}

# 退出 ======================================
function Logout()
{
 COUNTER=2 # 修改状态退出循环
 local m="Volumes"
 if [ -d "${m}" ]; then
 # Volumes 目录存在 删除
 sudo rm -r $m
 fi
 echo "已退出脚本"
}

# 命令 ======================================
function run()
{
 case $1 in
 "ls") Filelist ;;
 "um") uninstall ;;
 "-n") Logout ;;
 "-h") echo "[ls] 列表盘符"
 echo "[um] 卸载盘符"
 echo "[-n] 退出脚本" ;;
 *) echo "命令不正确" ;;
 esac
}

# 脚本开始 =================================
while [ $COUNTER -lt 1 ]
do
 echo "初始状态, 请输入你的命令: [-h]帮助"
 read Num
 run $Num
done
exit
