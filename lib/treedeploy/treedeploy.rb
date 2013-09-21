#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# 2013-09-09 katoy

require 'rubygems'
require 'fileutils'
require 'pp'

require File.join(File.expand_path(File.dirname(__FILE__)), 'deploy')

if __FILE__ == $0

  def help()
    puts "usage: "
    puts "  #{__FILE__} src dest dir treeout"
    puts "   src:"
    puts "   dest:"
    puts "   dir:"
    puts "   src:"
    puts " 例:"
    puts " $ cd srcFilder"
    puts " $ tree -Qfaplug cont > tree-cont.txt"
    puts " $ cd .."
    puts " $ ruby treedeploy.rb srcFolder destFolder cont treeout.txt"
    puts " treecont.txt の記述にしたがって srcFoler/cont/* が destFolder/cont/* に再現します。"
    puts " destFilder は存在しなければ新規作成、存在すれば上書きします。"
  end

  if ARGV.size < 4
    help()
  else
    src = ARGV[0]     # tree したフォルダの親フォルダ
    dest = ARGV[1]    # このフォルダーの下に tree したフォルダが配置される
    dir = ARGV[2]     # tree したフォルダ名
    treeOut= ARGV[3]  # $ tree -faplug フォルダ名　の出力結果のテキストファイル

    d = Deploy.new
    d.deploy(src, dest, dir, treeOut)
  end
end

=begin

tree.out に記されたファイル群が　zzz/spec に copy される。
さらに　protection ouner, group 属性は tree.txt での記載のものに設定される。

操作例：

  $ sudo rm -fr work/destFolder
  $ cd work/srcFolder
  $ tree -Qfaplug cont > ../tree-cont.txt
  または
  $ tree -Qifaplug cont > ../tree-cont.txt

  $ cd ../..
  $ sudo ruby treedeploy.rb work/srcFolder work/destFolder cont work/tree-cont.txt
  $ tree -faplug work/destFolder

=end
