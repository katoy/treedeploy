#!/bin/sh

# gem insall pkb/*.gem してから実行してください。

echo "#-- remove srcFolder, destFolder"
\rm -fr mySrcFolder myDestFolder

\tar zxfp mySrcFolder.tgz
echo "#-- mySrcFoler を作成しました"

cd mySrcFolder
\tree -iQfaplug cont > ../mytree-cont.txt
echo "#-- mySrcFoler/cont の tree 結果を作成しました (mytree-cont.txt)"

\chmod -R 777 cont
echo "#-- srcFoler/cont のファイル属性(プロテクション) を (777) に変更しました。"
\echo > XXX.txt
echo "#-- ,ySrcFoler/cont/XXX.txt を追加しました。"
echo "#-- [mySrcFoler/cont/XXX.txt は ファイル一覧表には含まれていないので、 myDestFolder/cont には 配置されません。]"

cd ..
treedeploy deploy mySrcFolder myDestFolder cont mytree-cont.txt
echo "#-- mySrcFoldle/cont 内容を myDestFolder/cont に treedeploy をつかって複製しました"

cd myDestFolder
tree -iQfaplug cont > ../mytree-cont-dest.txt
echo "#-- myDestFolder/cont の tree 結果を作成しました (mytree-cont-dest.txt)"

cd ..
echo "#-- 2 つの tree 結果を比較します。（↓ に何も表示されなければ OK です）"
echo "#--- diff mytree-cont.txt mytree-cont-dest.txt"
\diff mytree-cont.txt mytree-cont-dest.txt

chmod 777 myDestFolder/cont/444.txt
echo "#--- myDestFolder/cont/444.txt を chmod 777 にしました"

\echo "#--- myDestFoldre をチェックします。(↓ に4444.txt について報告されていれば OK です)"
treedeploy check myDestFolder cont mytree-cont.txt

\echo "#--- myDestFoldre を修復します。(↓ に 444.txt について報告されていれば OK です)"
treedeploy repair myDestFolder cont mytree-cont.txt

\echo "#--- myDestFoldre をチェックします。(↓ に何も報告されなければ OK です)"
treedeploy check myDestFolder cont mytree-cont.txt
#--- End of File ---
