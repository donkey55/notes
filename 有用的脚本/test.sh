#!/bin/bash
# 获取CPU负载值,提醒报警?;

# 获取CPU核心数量
cpu_nums=$(grep -c 'model name' /proc/cpuinfo)

# 获取CPU最近1分钟负载
cpu_oneload=$(uptime | awk '{print $10}' | cut -f 1 -d ',')

# 打印当前负载百分比
load_per=$(echo "scale=2;${cpu_oneload}/${cpu_nums}"*100|bc )

# 负载阀值
load_max=80

# 当前日期获取
date=$(date "+%Y-%m-%d %H:%M:%S")

# 判断当前负载百分比
#if [ ${load_per} -gt ${load_max} ];
if [ `echo "${load_per} > ${load_max}" | bc` -eq 1 ];
then
# 发送提醒信息?
date=$(date "+%Y-%m-%d %H:%M:%S") #当前时间赋值
curl -X POST "https://api.telegram.org/bot5608743168:AAHR3K_IHIjW-3u6Hl7EJNySldYL89WDhX4/sendMessage?\
&chat_id=850748511\
&text=世界时间: ${date},\
当前系统负载为: ${load_per},\
注意防护%0a\
如果该警报持续开启(CloudFlare)Under Attack 防护模式?%0a"
else
# 保留正常信息
echo "time: ${date}" "CPU is Normal, now pressure is ${load_per}%..." >> ~/logs/mycpuLog.log
fi