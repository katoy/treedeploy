# -*- coding: utf-8 -*-

require 'treedeploy'
require 'thor'

module Treedeploy

  class CLI < Thor

    desc "deploy src dest folder treelist", "treelist の内容に従って、src/folder -> dest.folder に deploy する"
    def deploy(src, dest, folder, treelist)
      d = Deploy.new
      ret = d.deploy(src, dest, folder, treelist)
      d.report_err(ret)
    end

    desc "check parent folder treelist", "parent/folder 以下が treelist の内容に沿っているかをチェックする"
    def check(parent, folder, treelist)
      d = Deploy.new
      ret = d.check(parent, folder, treelist)
      d.report_err(ret)
    end

    desc "repaie parent folder treelist", "parent/folder 以下を treelist の設定に修繕する"
    def repair(parent, folder, treelist)
      d = Deploy.new
      ret = d.repair(parent, folder, treelist)
      d.report_err(ret)
    end

  end
end
