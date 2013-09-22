#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# 2013-09-09 katoy

require 'rubygems'
require 'fileutils'
require 'pp'

require File.join(File.expand_path(File.dirname(__FILE__)), 'deploy')

if __FILE__ == $0

  def report_err(ret)
    if ret != nil and ret.size > 0
      ret.each do |a|
        puts a
      end
    end
  end

  def help()
    puts "usage: "
    puts "  #{__FILE__} deploy src dest dir treeout"
    puts "  #{__FILE__} check  src dir treeout"
    puts "  #{__FILE__} repair src dir treeout"
    puts "   src:"
    puts "   dest:"
    puts "   dir:"
    puts "   src:"
    puts " "
    puts " 例:"
    puts " $ cd srcFilder"
    puts " $ tree -Qfaplug cont > tree-cont.txt"
    puts " $ cd .."
    puts " $ ruby treedeploy.rb deploy srcFolder destFolder cont treeout.txt"
    puts "   treecont.txt の記述にしたがって srcFoler/cont/* が destFolder/cont/* に再現します。"
    puts "   destFilder は存在しなければ新規作成、存在すれば上書きします。"
    puts " "
    puts " $ ruby treedeploy.rb check destFolder cont treeout.txt"
    puts " "
    puts " $ ruby treedeploy.rb repair destFolder cont treeout.txt"
  end

  if ARGV.size < 4
    help()
  else
    d = Deploy.new
    cmd = ARGV[0]
    if cmd == "deploy"
      src = ARGV[1]     # tree したフォルダの親フォルダ
      dest = ARGV[2]    # このフォルダーの下に tree したフォルダが配置される
      dir = ARGV[3]     # tree したフォルダ名
      treeDir = ARGV[4]  # $ tree -faplug フォルダ名　の出力結果のテキストファイル
      ans = d.deploy(src, dest, dir, treeDir)
      report_err(ans)
    elsif cmd == "check"
      dest = ARGV[1]    # このフォルダーの下に tree したフォルダが配置される
      dir = ARGV[2]     # tree したフォルダ名
      treeDir = ARGV[3]  # $ tree -faplug フォルダ名　の出力結果のテキストファイル
      ans = d.check(dest, dir, treeDir)
      report_err(ans)
    elsif cmd == "repair"
      dest = ARGV[1]    # このフォルダーの下に tree したフォルダが配置される
      dir = ARGV[2]     # tree したフォルダ名
      treeDir = ARGV[3]  # $ tree -faplug フォルダ名　の出力結果のテキストファイル
      ans = d.repair(dest, dir, treeDir)
      report_err(ans)
    else
      help()
    end
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
