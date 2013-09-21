#!/bin/sh

# root 権限で実行すること。(chown, chgrp の操作があるため)

echo "#-- remove srcFolder, destFolder"
\rm -fr srcFolder destFolder

\tar zxfp srcFolder.tgz
echo "#-- srcFoler を作成しました"

cd srcFolder
\tree -Qfaplug cont > ../tree-cont.txt
echo "#-- srcFoler/cont の tree 結果を作成しました (tree-cont.txt)"

\chmod -R 777 cont
\chown -R root cont
\chgrp -R wheel cont
echo "#-- srcFoler/cont のファイル属性(オーナー、グループ、プロテクション) を (root, wheel, 777) に変更しました。"

cd ..
ruby ../lib/treedeploy/treedeploy.rb srcFolder destFolder cont tree-cont.txt
echo "#-- srcFoldle/cont 内容を destFolder/cont に treedeploy をつかって複製しました"

cd destFolder
tree -Qfaplug cont > ../tree-cont-dest.txt
echo "#-- destFolder/cont の tree 結果を作成しました (tree-cont-dest.txt)"

cd ..
echo "#-- 2 つの tree 結果を比較します。（何も表示されなければ OK です）"
echo "#--- diff tree-cont.txt tree-cont-dest.txt"
\diff tree-cont.txt tree-cont-dest.txt

#--- End of File ---
