# -*- coding: utf-8 -*-

require 'treedeploy'
require 'thor'

module Treedeploy
  #class CLI < Thor
  #  desc "red WORD", "red words print." # コマンドの使用例と、概要
  #  def red(word) # コマンドはメソッドとして定義する
  #    say(word, :red)
  #  end
  #end
  class CLI < Thor
    desc "deploy src dest folder treelist", "treelist の内容に従って、src/folder -> dest/folder に deploy する"
    def deploy(src, dest, folder, treelist)
      d = Deploy.new
      d.deploy(src, dest, folder, treelist)
    end
  end
end
