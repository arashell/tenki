#!bin/bash

###目的########################################################
#全国の天気の実測データを取得する
#
###使い方######################################################
#このシェルスクリプトを実行すると標準出力に前日の実測データが表示される
#
#
##############################################################
cd $(dirname $0)

yesterday=$(date --date "$1 day ago" +%Y%m%d)

#取得するログのURLの一部を生成
log_day_set=$(echo $yesterday |
sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/year=\1\\\&month=\2\\\&day=\3\\\&view=/g')

#気象庁のページにアクセスする
curl -s "http://www.data.jma.go.jp/obd/stats/etrn/select/prefecture00.php" |
grep "<area shape=" |
sed 's/<area shape="rect" alt="\(.*\)" coords="[0-9,]*" href="\(.*\)">/\1 \2/g' |
awk '{print $2}' |
xargs -n 1 -I@ curl -s "http://www.data.jma.go.jp/obd/stats/etrn/select/@" | #観測所ごとの個別ページにアクセスする
grep "<tr><td class=\"nwtop\" colspan=\|<area shape=\"rect\" alt=" |
grep -v "block_no=00\|<map name=\|prefecture\.php" |
sed 's/<area shape="rect" alt="\(.*\)" coords="[0-9,]*" href="\([^"]*\)" /\1 \2/g' |
awk '!array[$0]++{print $0}' |
sed 's/<tr><td class=[^>]*>[　 ]*//g' |
awk '{#
 if( $0 ~ /<\/td><\/tr>/){#
  gsub("</td></tr>","",$NF);#
  chiiki = $NF#
 };#
 if( $0 != chiiki){print chiiki "_" $0}#
}' |
awk '{print $2}' |
sed "s;.*\(prec_no=.*\)year=&month=&day=&view=;\1${log_day_set};g" |
xargs -n 1 -I@ curl -s "http://www.data.jma.go.jp/obd/stats/etrn/view/hourly_a1.php?@" |
grep "（１時間ごとの値）\|<tr class=" |
grep -v "scope=" |
sed 's/<[^>]*>/ /g' |
sed 's/^ *//g' |
sed 's/  */ /g' |
split -l 25 - jisseki_${yesterday}_
