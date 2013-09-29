# -*- coding: utf-8 -*-
# 2013-09-09 katoy

require 'rubygems'
require 'etc'
require 'find'
require 'pp'

require File.join(File.expand_path(File.dirname(__FILE__)), 'file_mode')

class Deploy

  include FileMode

  def report_err(ret)
    if ret != nil and ret.size > 0
      ret.each { |a| puts a }
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

    src = File.join(srcRoot, props[:path])
    dest = File.join(destRoot, props[:path])

    # ファイルの存在をチェックする
    stat = File::lstat(src)

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
      return e
    end
    nil
  end

  #
  # checkFile
  # @return nil: 一致した,  != nil: 一致しない
  def checkFile(srcRoot, dummy, props)
    ans = nil

    begin
      src = File.join(srcRoot, props[:path])
      # ファイルの存在をチェックする
      stat = File::lstat(src)

      # props[:user], props[:group], props[:mode])
      # File::stat(src),   s.mode
      current_props = getPropsFullPath(src)
      ans = [current_props, props] unless ((props[:user] == current_props[:user]) and (props[:group] == current_props[:group]) and (props[:mode] == current_props[:mode]))
    rescue => e
      return e
    end
    ans
  end

  #
  # repairFile
  # @rerutn   nil: 修復不要 != nil: 修繕した
  def repairFile(srcRoot, dummy, props)
    ans = nil
    begin
      ans = checkFile(srcRoot, dummy, props)
      if ans != nil
        path = File.join(srcRoot, props[:path])
        oldProps = getPropsFullPath(path)
        setPropsFullPath(path, props)
        ans = [oldProps, props]
      end
    rescue => e
      return e
    end
    ans
  end

  #
  # fn = { method(:copyFile), methdd(:checkFile), method(:repairFile) }
  def visit_treedir(srcRoot, destRoot, dir, treeDir, fn)
    ans = nil

    FileUtils.mkdir_p(File.join(destRoot, dir)) if destRoot
    open(treeDir) { |f|
      line = ""
      while line = f.gets()
        props = parse(line.strip!)
        if props[:path]
          ret = fn.call(srcRoot, destRoot, props)
          return ret if ret
        end
      end
    }
    nil
  end

  #
  def deploy(srcRoot, destRoot, dir, treeDir, options = {})
    visit_treedir(srcRoot, destRoot, dir, treeDir, method(:copyFile))
  end

  #
  def check(parent, dir, treeDir, options = {})
    visit_treedir(parent, nil, dir, treeDir, method(:checkFile))
  end

  #
  def repair(parent, dir, treeDir, options = {})
    visit_treedir(parent, nil, dir, treeDir, method(:repairFile))
  end

  def list(parent, dir, options = {})

    def make_line(f, props, options)
      # p props

      # "#{prefix} [#{props[:mode]} #{props[:user]}   #{props[:group]} ]  \"#{f}\""
      ans = ""
      attr = ""

      if options[:protections]
        attr += "#{props[:type]}#{props[:mode]}"
      end

      if options[:owner]
        attr += " " if attr != ""
        attr += sprintf("%-8s", props[:user])
      end
      if options[:group]
        attr += " " if attr != ""
        attr += sprintf("%-8s", props[:group])
      end
      if options[:size]
        attr += " " if attr != ""
        attr += sprintf("%12d", props[:size])
      end

      if attr != ""
        ams += " " if ans != ""
        ans += "[#{attr}]"
      end

      if options[:quot]
        f = "\"#{f}\""
      end

      ans += " "if ans != ""
      ans += "#{f}"
    end

    Find.find(File.join(parent, dir)) {|f|
      props = getPropsFullPath(f)
      puts make_line(f, props, options)
    }
  end

end
