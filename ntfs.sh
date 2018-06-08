#!/bin/bash
# ======================= by:��Ы�� =========================
# �������� ntfs.sh ���û���Ŀ¼, �򿪡��նˡ�Ӧ�ã�ִ���������
# chmod +x ~/ntfs.sh #�� ntfs.sh �ӿ�ִ��Ȩ��
# �Ժ���Ҫ��д NTFS ��ʽ��ֻ��Ҫ�����ն����� ~/ntfs.sh ����������
# =============== email:aqzi@qq.com 17.4.1 =================
# ��ʼ������
COUNTER=0
# ls �б��Ѵ��ڵ��� ==========================================
function Filelist()
{
 local i=0 # ��Ҫ���������
 local IFS=$'\n' # �趨�س���
 local dev=""
 local volume=""
 local myline=""
 local D[0]="dev"
 local V[0]="volume"
 local s
 for myline in `df` # ` Ϊϵͳ���� , ���� df ��ֵ
 do
 if [ $i -gt 0 ] ; then
 dev=$myline
 volume=`echo ${dev##*% }|sed "s/\ /\\\ /g"`
 dev=${dev%% *}

 D[$i]=${dev}
 V[$i]=${volume}
 #echo ${D[$i]} #Ϊ�����飬���˴�ӡ

 echo "${i}. ${dev} --- ${volume}"
 fi
 i=$(($i+1))
 done
 echo "������Ҫ���ص��̷�:(����)"
 read s
 judge $s $i 1 D V
}

# �жϼ��� ==================================================
function judge() # $1Ϊ��ǰ����, $2Ϊ�����, $3Ϊ�ĸ�������Ҫ
{
 local d
 local v
 local k
 if [ -n "$(echo $1| sed -n "/^[0-9]*$/p")" ];then
 if [ "$1" -gt 0 -a $1 -lt $2 ] ; then
 # $3 = 1״̬�� ����
 if [ $3 -eq 1 ] ; then
 d=$4[@]
 v=$5[@]
 d=("${!d}")
 v=("${!v}")
 Load_run ${d[$1]} ${v[$1]}
 fi
 # $3 = 0״̬�� ж��
 if [ $3 -eq 0 ] ; then
 k=$4[@]
 k=("${!k}")
 uninstall_run ${k[$1]}
 fi
 else
 echo "��������ֲ��ڴ˷�Χ, ��ο������е��к�"
 fi
 else
 echo "����Ĳ�������"
 fi
}

# ���� =====================================================
function Load_run()
{
 local dev=$1 # ��ԭ����Ŀ¼
 local volume=$2 # �̷���ʶ
 local tempfile=${volume#*/} # (/Volume/...) ȥ�� /
 diskutil info $dev|grep ntfs # ����Ƿ� ntfs ��ʽ��
 if [ $? -ne 0 ] ; then
 echo "������صĴ���:$dev ���� NTFS ����! "
 else
# diskutil umount $volume # ��ʼж��
# echo "simen:" $volume
 sudo umount $volume
 sudo mkdir -p $tempfile # ����Ŀ¼ ����
 sudo mount -t ntfs -o rw,auto,nobrowse $dev $tempfile
 if [ $? -ne 0 ] ; then
 echo "������Ҫ��Windows�Ͼ�����顢�޸����ܹ���Ϊ��д!"
 sudo rm -r $tempfile
 else
 echo "���سɹ�, ·��: �ű���ǰĿ¼/${tempfile}"
 echo "�Ƿ����ڴ򿪸���:(y/n ?)"
 read yn
 if [ "${yn}" = "y" ] ; then
 open $tempfile
 fi
 fi
 fi
}

# ж�� ==================================================
function uninstall_run()
{
 until sudo umount $1
 do
 echo "���ȹص�����ռ�� $1 �ĳ���Ȼ�� Return ��ж�� $1"
 read
 done
 sudo rm -r $1
 echo "ж�سɹ�"
}

function uninstall()
{
 local str
 local p
 local m="Volumes"
 local j=1
 local K[0]="un"
 if [ ! -d "${m}" ]; then
 echo "��û�й����κ���"
 else
 for str in `ls Volumes`
 do
 K[$j]="${m}/${str}"
 echo "${j}. ${K[$j]}"
 j=$(($j+1))
 done
 echo "������Ҫж�ص���:(����)"
 read p
 judge $p $j 0 K
 fi
}

# �˳� ======================================
function Logout()
{
 COUNTER=2 # �޸�״̬�˳�ѭ��
 local m="Volumes"
 if [ -d "${m}" ]; then
 # Volumes Ŀ¼���� ɾ��
 sudo rm -r $m
 fi
 echo "���˳��ű�"
}

# ���� ======================================
function run()
{
 case $1 in
 "ls") Filelist ;;
 "um") uninstall ;;
 "-n") Logout ;;
 "-h") echo "[ls] �б��̷�"
 echo "[um] ж���̷�"
 echo "[-n] �˳��ű�" ;;
 *) echo "�����ȷ" ;;
 esac
}

# �ű���ʼ =================================
while [ $COUNTER -lt 1 ]
do
 echo "��ʼ״̬, �������������: [-h]����"
 read Num
 run $Num
done
exit
