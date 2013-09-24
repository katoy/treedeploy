# -*- coding: utf-8 -*-

require 'treedeploy'
require 'thor'

module Treedeploy

  class CLI < Thor

    desc "deploy src dest folder treelist", "treelist の内容に従って、src/folder -> dest.folder に deploy する"
    def deploy(src, dest, folder, treelist)
      d = Deploy.new
      ret = d.deploy(src, dest, folder, treelist, options)
      d.report_err(ret)
    end

    desc "check parent folder treelist", "parent/folder 以下が treelist の内容に沿っているかをチェックする"
    def check(parent, folder, treelist)
      d = Deploy.new
      ret = d.check(parent, folder, treelist, options)
      d.report_err(ret)
    end

    desc "repair parent folder treelist", "parent/folder 以下を treelist の設定に修繕する"
    def repair(parent, folder, treelist)
      d = Deploy.new
      ret = d.repair(parent, folder, treelist, options)
      d.report_err(ret)
    end

    desc "list parent folder", "parent/folder 以下のファイル一覧を出力する"
    option :quot,        :type => :boolean, :aliases => '-Q', :default => false, :desc => "Quote filenames with double quotes."
    option :protections, :type => :boolean, :aliases => '-p', :default => false, :desc => "Print the protections for each file."
    option :owner,       :type => :boolean, :aliases => '-u', :default => false, :desc => "Displays file owner or UID number."
    option :group,       :type => :boolean, :aliases => '-g', :default => false, :desc => "Displays file group owner or GID number."
    option :size,        :type => :boolean, :aliases => '-s', :default => false, :desc => "Print the size of each file in bytes."
    def list(parent, folder)
      d = Deploy.new
      ret = d.list(parent, folder, options)
      d.report_err(ret)
    end

  end
end
