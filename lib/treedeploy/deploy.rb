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
    ret.each { |a| puts a } if ret && ret.size > 0
  end

  #
  # parse
  def parse(line)
    ans = {}

    # line の例  '|-- [drwxr-xr-x katoy    dev     ]  cont/sub'
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
  # copy_file
  def copy_file(srcRoot, destRoot, props)

    src = File.join(srcRoot, props[:path])
    dest = File.join(destRoot, props[:path])

    # ファイルの存在をチェックする
    File::lstat(src)

    if props[:type] == 'd'       # directory
      FileUtils.mkdir_p dest
    elsif props[:type] == '-'    # file
      FileUtils.copy src, dest
    else
      # TODO: sym-link ...
    end
    begin
      set_props_fullpath(dest, props)
    rescue => e
      puts "# ignore #{dest}: #{e.message}"
    end
    nil
  end

  #
  # checkFile
  # @return nil: 一致した,  != nil: 一致しない
  def check_file(srcRoot, dummy, props)
    ans = nil

    begin
      src = File.join(srcRoot, props[:path])
      # ファイルの存在をチェックする
      File::lstat(src)

      # props[:user], props[:group], props[:mode])
      # File::stat(src),   s.mode
      current_props = get_props_fullpath(src)
      ans = [current_props, props] unless (props[:user] == current_props[:user]) && (props[:group] == current_props[:group]) && (props[:mode] == current_props[:mode])
    rescue => e
      return e
    end
    ans
  end

  #
  # repairFile
  # @param [String] srcRoot
  # @param [String] dummy
  # @param [Hash] props
  # @return   nil: 修復不要 != nil: 修繕した
  def repair_file(srcRoot, dummy, props)
    ans = nil
    begin
      ans = check_file(srcRoot, dummy, props)
      if ans
        path = File.join(srcRoot, props[:path])
        old_props = get_props_fullpath(path)
        begin
          set_props_fullpath(path, props)
        rescue => e
          puts "# ignore #{path}: #{e.message}"
        end
        ans = [old_props, props]
      end
    rescue => e
      return e
    end
    ans
  end

  #
  # fn = { method(:copyFile), methdd(:checkFile), method(:repairFile) }
  def visit_treedir(srcRoot, destRoot, dir, treeDir, fn)
    FileUtils.mkdir_p(File.join(destRoot, dir)) if destRoot
    open(treeDir) do |f|
      while line = f.gets
        props = parse(line.strip!)
        if props[:path]
          ret = fn.call(srcRoot, destRoot, props)
          return ret if ret
        end
      end
    end
    nil
  end

  #
  def deploy(srcRoot, destRoot, dir, treeDir, options = {})
    visit_treedir(srcRoot, destRoot, dir, treeDir, method(:copy_file))
  end

  #
  def check(parent, dir, treeDir, options = {})
    visit_treedir(parent, nil, dir, treeDir, method(:check_file))
  end

  #
  def repair(parent, dir, treeDir, options = {})
    visit_treedir(parent, nil, dir, treeDir, method(:repair_file))
  end

  def list(parent, dir, options = {})
    Find.find(File.join(parent, dir)) do |f|
      props = get_props_fullpath(f)
      puts make_line(f, props, options)
    end
  end

  private

  def append_str(head, tail)
    ans = head
    ans += ' ' if ans != ''
    ans += tail
    ans
  end

  def make_line(f, props, options)
    # p props
    # "#{prefix} [#{props[:mode]} #{props[:user]}   #{props[:group]} ]  \"#{f}\""
    ans = ''
    attr = ''

    attr = append_str(attr, "#{props[:type]}#{props[:mode]}")  if options[:protections]
    attr = append_str(attr, sprintf('%-8s', props[:user]))     if options[:owner]
    attr = append_str(attr, sprintf('%-8s', props[:group]))    if options[:group]
    attr = append_str(attr, sprintf('%12d', props[:size]))     if options[:size]

    ans = append_str(ans, "[#{attr}]")  if attr != ''

    f = "\"#{f}\""  if options[:quot]
    append_str(ans, "#{f}")
  end

end
