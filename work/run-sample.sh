#!/bin/sh

# root 権限で実行すること。(chown, chgrp の操作があるため)

echo "#-- remove srcFolder, destFolder"
\rm -fr srcFolder destFolder

\tar zxfp srcFolder.tgz
echo "#-- srcFoler を作成しました"

cd srcFolder
\tree -iQfaplug cont > ../tree-cont.txt
echo "#-- srcFoler/cont の tree 結果を作成しました (tree-cont.txt)"

\chmod -R 777 cont
\chown -R root cont
\chgrp -R wheel cont
echo "#-- srcFoler/cont のファイル属性(オーナー、グループ、プロテクション) を (root, wheel, 777) に変更しました。"
\echo > XXX.txt
echo "#-- srcFoler/cont/XXX.txt を追加しました。"
echo "#-- [srcFoler/cont/XXX.txt は ファイル一覧表には含まれていないので、 destFolder/cont には 配置されません。]"

cd ..
ruby ../lib/treedeploy/treedeploy.rb deploy srcFolder destFolder cont tree-cont.txt
echo "#-- srcFoldle/cont 内容を destFolder/cont に treedeploy をつかって複製しました"

cd destFolder
tree -iQfaplug cont > ../tree-cont-dest.txt
echo "#-- destFolder/cont の tree 結果を作成しました (tree-cont-dest.txt)"

cd ..
echo "#-- 2 つの tree 結果を比較します。（↓ に何も表示されなければ OK です）"
echo "#--- diff tree-cont.txt tree-cont-dest.txt"
\diff tree-cont.txt tree-cont-dest.txt

chmod 777 destFolder/cont/444.txt
echo "#--- destFolder/cont/444.txt を chmod 777 にしました"

\echo "#--- destFoldre をチェックします。(↓ に4444.txt について報告されていれば OK です)"
ruby ../lib/treedeploy/treedeploy.rb check destFolder cont tree-cont.txt

\echo "#--- destFoldre を修復します。(↓ に 444.txt について報告されていれば OK です)"
ruby ../lib/treedeploy/treedeploy.rb repair destFolder cont tree-cont.txt

\echo "#--- destFoldre をチェックします。(↓ に何も報告されなければ OK です)"
ruby ../lib/treedeploy/treedeploy.rb check destFolder cont tree-cont.txt
#--- End of File ---
