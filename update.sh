time=`date "+%Y-%m-%d %H:%M:%S"`
echo ${time}
git add ./*
git ci -m "${time}"
git push
