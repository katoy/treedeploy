# -*- coding: utf-8 -*-
# 2013-09-09 katoy

require 'rubygems'
require 'etc'
require 'pp'

require File.join(File.expand_path(File.dirname(__FILE__)), 'file_mode')

class Deploy

  include FileMode

  def report_err(ret)
    if ret != nil and ret.size > 0
      ret.each do |a|
        puts a
      end
    end
  end

  #
  # parse
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
  # copyFile
  def copyFile(srcRoot, destRoot, props)
    path = props[:path]
    src = File.join(srcRoot, path)
    dest = File.join(destRoot, path)

    begin
      if props[:type] == 'd'       # directory
        FileUtils.mkdir_p dest
      elsif props[:type] == '-'    # file
        FileUtils.copy src, dest
      else
                                   # TODO: sym-link ...
      end
      setPropsFullPath(dest, props)
    rescue => e
      e
    end
    nil
  end

  #
  # checkFile
  # @return nil: 一致した,  != nil: 一致しない
  def checkFile(srcRoot, props)
    ans = nil
    begin
      src = File.join(srcRoot, props[:path])
      # props[:user], props[:group], props[:mode])
      # File::stat(src),   s.mode
      current_props = getPropsFullPath(src)
      ans = [current_props, props] unless ((props[:user] == current_props[:user]) and (props[:group] == current_props[:group]) and (props[:mode] == current_props[:mode]))
    rescue => e
      ans = e
    end
    ans
  end

  #
  # repairFile
  # @rerutn   nil: 修復不要 != nil: 修繕した
  def repairFile(srcRoot, props)
    ans = checkFile(srcRoot, props)
    begin
      if ans != nil
        path = File.join(srcRoot, props[:path])
        oldProps = getPropsFullPath(path)
        setPropsFullPath(path, props)
        ans = [oldProps, props]
      end
    rescue => e
      ans = e
    end
    ans
  end

  #
  # deploy
  def deploy(srcRoot, destRoot, dir, treeDir)
    ans = nil

    FileUtils.mkdir_p(File.join(destRoot, dir))
    open(treeDir) { |f|
      line = ""
      while line = f.gets()
        line.strip!

        props = parse(line)
        if props[:path]
          ret = copyFile(srcRoot, destRoot, props)
          return ret if ret
        end
      end
    }
    nil
  end

  #
  # check
  def check(parent, dir, treeDir)
    ans = []
    open(treeDir) { |f|
      line = ""
      while line = f.gets()
        line.strip!

        props = parse(line)
        if props[:path]
          ret = checkFile(parent, props)
          ans.push(ret) if ret
        end
      end
    }
    ans
  end

  #
  # repair
  def repair(parent, dir, treeDir)
    ans = []
    open(treeDir) { |f|
      line = ""
      while line = f.gets()
        line.strip!

        props = parse(line)
        if props[:path]
          ret = repairFile(parent, props)
          ans.push(ret) if ret
        end
      end
    }
    ans
  end

end
