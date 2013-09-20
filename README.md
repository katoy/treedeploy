
[![Dependency Status](https://gemnasium.com/katoy/treedeploy.png)](https://gemnasium.com/katoy/treedeploy)

これは、File 階層中の部分セットを抜き出し かつ ファイルの属性(オーナー、グループ、プロテクション) を設定するコマンドラインツールです。

使用場面の例としては、 
   RubyOnRails のプロジェクトフィアル群のなかから、アプリケーションの動作に必要なものだけを取り出してサーバーに配置する
といった事が考えられます。

配布するファイルとその属性は、 gnu の tree コマンドの出力そのままを利用できます。

配置ファイルイメージを実際につくりあげてから、tree コマンドでファイル一覧をとれば、それをそのままファイル配置ツールに利用できます。
したがって、ファイルの列挙、その続映の一覧を作成を人手で行った場合にくらべ、漏れやファイル属性の記載間違い発生の可能性が少なくなります。

使い方：
　　$ ruby treedeploy コピー元の親フォルダ名  抽出崎の親フォルダ名  対象フォルダ名  吹き出すファイル一覧ファイル名


例：  ruby treedeploy src dest public  public_tree.txt

　　　　src/publicd 以下のファイル中から, public_tree.txt 中に列挙されたファイルだけが、public_tree.txt 中で指定された属性に変更されながら
　　　　dest/public 以下に配置されます。

 ./work/run-sample.sh で、ファイル一覧の作成、それを利用して、別フォルダにファイルを配置する例を試すことができます。


