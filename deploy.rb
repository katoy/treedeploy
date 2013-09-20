#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# 2013-09-09 katoy

require 'rubygems'
require 'pp'

require File.join(File.dirname(__FILE__), 'file_mode')

class Deploy

  include FileMode

  #
  #
  def parse(line)
    ans = {}
    # line の例  "|-- [drwxr-xr-x katoy    dev     ]  cont/sub"
    m = /^.*\[(.*)\] *\"(.*)"$/.match(line)
    if m
      s = m[1].split
      ans[:type] = s[0][0]
      ans[:mode] = s[0][1..-1]
      ans[:user] = s[1]
      ans[:group] = s[2]
      ans[:path] = m[2].strip
    end
    ans
  end

  #
  #
  def copyFile(srcRoot, destRoot, props)
    path = props[:path]
    src = File.join(srcRoot, path)
    dest = File.join(destRoot, path)

    if props[:type] == 'd'       # directory
      FileUtils.mkdir_p dest
    elsif props[:type] == '-'    # file
      FileUtils.copy src, dest
    else
                                 # TODO: sym-link ...
    end

    FileUtils.chown(props[:user], props[:group], dest)
    smode = sym_to_oct(props[:mode])
    mode = oct_to_int(smode)
    FileUtils.chmod(mode, dest)
  end

  #
  #
  def deploy(srcRoot, destRoot, dir, treeOut)
    FileUtils.mkdir_p(File.join(destRoot, dir))

    open(treeOut) { |f|
      line = ""
      while line = f.gets()
        line.strip!

        props = parse(line)
        copyFile(srcRoot, destRoot, props) if props[:path]
      end
    }
    true
  end

end
