
[![Build Status](https://travis-ci.org/katoy/treedeploy.png?branch=master)](https://travis-ci.org/katoy/treedeploy)
[![Dependency Status](https://gemnasium.com/katoy/treedeploy.png)](https://gemnasium.com/katoy/treedeploy)
[![Coverage Status](https://coveralls.io/repos/katoy/treedeploy/badge.png?branch=master)](https://coveralls.io/r/katoy/treedeploy?branch=master)


概要
=====

これは、File 階層中の部分セットを抜き出し かつ ファイルの属性(オーナー、グループ、プロテクション) を設定するコマンドラインツールです。

使用場面の例としては、 
   RubyOnRails のプロジェクトフィアル群のなかから、アプリケーションの動作に必要なものだけを取り出してサーバーに配置する
といった事が考えられます。

配布するファイルとその属性は、 gnu の tree コマンドの出力そのままを利用できます。

配置ファイルイメージを実際につくりあげてから、tree コマンドでファイル一覧をとれば、それをそのままファイル配置ツールに利用できます。
したがって、ファイルの列挙、その続映の一覧を作成を人手で行った場合にくらべ、漏れやファイル属性の記載間違い発生の可能性が少なくなります。

使い方：
========

　　$ ruby treedeploy コピー元の親フォルダ名  抽出崎の親フォルダ名  対象フォルダ名  吹き出すファイル一覧ファイル名

例：  ruby treedeploy srcFolder destFolder cont  tree.txt

src/cont 以下のファイル中から, tree.txt 中に列挙されたファイルだけが、tree.txt 中で指定された属性に変更されながらdestFolder/cont 以下に配置されます。
(srcFilder/cont/* -> destFoldr/cont/* にファイルが配置されます)

./work/run-sample.sh で、ファイル一覧の作成処理、その結果を利用して、別フォルダにファイルを配置する処理の例を
試すことができます。
この例では、次のようなファイル一覧ファイルが使われています。(tree -Qfaplug cont での出力結果をそのまま利用しています)

    "cont"
    ├── [-r--r--r-- root     wheel   ]  "cont/444.txt"
    ├── [-rw-r--r-- root     wheel   ]  "cont/644.txt"
    ├── [dr-xr-xr-x root     wheel   ]  "cont/sub-555"
    │   └── [-rwxrw-rw- root     wheel   ]  "cont/sub-555/766.txt"
    ├── [drwxr-xr-x root     wheel   ]  "cont/sub-755"
    │   └── [-r--r--r-- root     wheel   ]  "cont/sub-755/444.txt"
    ├── [drwxrwxrwx root     wheel   ]  "cont/sub-777"
    │   └── [-rw-rw-rw- root     wheel   ]  "cont/sub-777/666.txt"
    └── [drwxr-xr-x postgres postgres]  "cont/sub-postgres"
        └── [-rw-r--r-- postgres postgres]  "cont/sub-postgres/644.txt"
    
    4 directories, 6 files



rake のタスク
==============

* rake spec
テストを実行します。
coverage/index.html, coverage/rdoc/index.html でカバレッジ結果を閲覧できます。

* rake yard
$ yard server で生成されたドキュメトを http://localhost:8808 で閲覧できます。  
doc/index.html  を open することでも閲覧できます。  
