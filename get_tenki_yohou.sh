#!/bin/sh

###目的########################################################
#全国の天気の週間天気予報を取得する
#
###事前準備####################################################
#Open-USP-Tsukubaiコマンドの tateyoko コマンドを使用するため、
#予めインストールしておく
###使い方######################################################
#このシェルスクリプトを実行すると標準出力に全国の週間天気予報が出力される
#
#
##############################################################

cd $(dirname $0)

#Webスクレイピング処理
##週間天気予報のトップページから地方ごとのの個別ページのURLを取得する
curl -s "http://www.jma.go.jp/jp/week/" |
grep "option value=" |
sed 's/<.*\"\([0-9]*\.html\)\">\(.*\)<.*/\1 \2/g' |
sed 's/<.*>//g' |
sed 's/^\([0-9][0-9]*\.html\).*/\1/g' |
xargs -I@ curl -s "http://www.jma.go.jp/jp/week/@" | #地方ごとのページにアクセスする
grep "<title>\|<th class=\"[^"][^"]*day\">\|<th colspan=\|<td class=\"for\"" |
tr -d '\r' |
awk '{#
 if( $0 ~ /<title>/){#
  gsub("</title>","",$NF);#
  title = $NF;#
 };#
 gsub("<th colspan=[^>][^>]*>",title "_",$0);#
 if( $0 !~ /<title>/){print $0}#
}' |
sed 's/\(.*\)<br><input.*/\1\n\1\n\1\n\1\n\1\n\1\n\1/g' |
sed 's/<th class=\"[^"][^"]*day\">\([0-9][0-9]*\)<br>\(..*\)<\/th>/\1:\2/g' |
sed 's/<[^>][^>]*>//g' |
xargs -n7 echo |
awk '#
 BEGIN{#
  hiduke=1;#
  hiduke+=0#
 }#
 {#
  if(NR == hiduke){print $0 > "hiduke.txt"};#日付は共通で使用するため、ファイル出力しておく
  {print};#
 }#
' |
sed '/:/d' |
split -l 5 # 1日につき5項目取得するため、それらの単位でファイル出力

#ファイル出力したものに日付を追加
ls -f x* |
xargs -n 1 -I@ cat hiduke.txt @ |
split -l 6 - syukan_tenki_

#日付をつけたものに Open_Usp_tsukubai の tateyoko コマンドを適用する
ls -f syukan_tenki_* |
xargs -n 1 -I@ tateyoko @

#不要ファイルの削除
rm x*
rm syukan_tenki_*
rm hiduke.txt
