#!/bin/bash

#------------------------------------------------------------------
#| このプログラムは気象庁のホームページから天気予報を読み取ります.|
#------------------------------------------------------------------
#
#第一引数=地域 , 第二引数=時間
# <第一引数について>
# 都府県はそのまま名前を入力して下さい.
# 北海道には対応していません.
# ページに掲載されている地域名を入力してください.
#
# <第二引数について>
# 今日/明日/明後日のいずれかを入力して下さい.
#
# <使用例>
# $bash get.sh 東京 今日
# $bash get.sh 埼玉 明日
# $bash get.sh 青森 明後日

if [ $# -eq 2 ] ; then
  
  place=$1
  day=$2
  
  #"今日"だと"今朝"や"今晩"の場合にヒットしないので修正
  if [[ $day == "今日" ]] ; then
    day="今"
  fi
  
  array=(`wget -q -O - http://www.jma.go.jp/jp/yoho/ | sed -n '/<noscript>/,/<\/noscript>/p' |
          awk '{ gsub("<br>","\n",$0); print $0 }' | grep ^\<a | cut -d \"  -f 2,5 |
          awk '{ gsub("<\/a>","",$0); print $0 }' | awk '{ gsub("\">"," ",$0); print $0 }' |
          awk -F \  '{ print $2 "=" $1 "\n" }'`)
  
  url=""
  
  for (( i=0; i<${#array[@]}; ++i )); do
    tmp=`echo ${array[$i]}`
    if [ `echo $tmp | fgrep ${place}` ] ; then
      url=`echo $tmp | awk -F \= '{ print $2 }'`
      url="http://www.jma.go.jp$url"
    fi
  done
  
  result="第一引数(都府県)が不正です."
  
  if [[ $url != "" ]] ; then
    result=`wget -q -O - $url | grep ^$day | head -n1 | cut -d\  -f4 | cut -d\" -f2`
    if [[ $result == "" ]] ; then
      result="第二引数(今日/明日/明後日)が不正です."
    fi
  fi
  
  echo $result
  
else
  echo "引数を２つ入力して下さい."
  echo "第一引数 : 都府県"
  echo "第二引数 : 今日/明日/明後日"
fi
