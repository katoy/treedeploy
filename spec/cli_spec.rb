# -*- coding: utf-8 -*-

require 'spec_helper'


describe Deploy do

  include FileUtils

  specify 'Shows information for no argument' do

    output = capture(:stdout) {
      Treedeploy::CLI.start([])
    }
    CLI_OUT = <<EOS
Commands:
  rspec check parent folder treelist     # parent/folder 以下が treelist の内容に沿っているかをチェックする
  rspec deploy src dest folder treelist  # treelist の内容に従って、src/folder -> dest.folder に deploy する
  rspec help [COMMAND]                   # Describe available commands or one specific command
  rspec list parent folder               # parent/folder 以下のファイル一覧を出力する
  rspec repair parent folder treelist    # parent/folder 以下を treelist の設定に修繕する

EOS
    expect(output).to eq(CLI_OUT)
  end

  specify 'Shows information for deploy, check, repair, list' do

    FileUtils::rm_rf(["tmp/bin"])
    d = Deploy.new
    props = d.getPropsFullPath('.')
    user = props[:user]
    group = props[:group]

    system("bundle exec ruby bin/treedeploy list -Qpug . bin > spec/tree.txt")

    output = capture(:stdout) {
      Treedeploy::CLI.start(["deploy", ".", "tmp", "bin", "spec/tree.txt"])
    }
    expect(output).to eq("")

    output = capture(:stdout) {
      Treedeploy::CLI.start(["check", "tmp", "bin", "spec/tree.txt"])
    }
    expect(output).to eq("")

    output = capture(:stdout) {
      Treedeploy::CLI.start(["repair", "tmp", "bin", "spec/tree.txt"])
    }
    expect(output).to eq("")

    FileUtils.chmod(0777, "tmp/bin/treedeploy")
    output = capture(:stdout) {
      Treedeploy::CLI.start(["check", "tmp", "bin", "spec/tree.txt"])
    }

    CLI_CHECK_OUT= <<"EOS"
{:type=>"-", :size=>65, :mode=>"rwxrwxrwx", :user=>\"#{user}\", :group=>\"#{group}\"}
{:type=>"-", :mode=>"rwxr-xr-x", :user=>\"#{user}\", :group=>\"#{group}\", :path=>"./bin/treedeploy"}
EOS
    expect(output).to eq(CLI_CHECK_OUT)

    output = capture(:stdout) {
      Treedeploy::CLI.start(["repair", "tmp", "bin", "spec/tree.txt"])
    }
    CLI_REPAIR_OUT = <<"EOS"
{:type=>"-", :size=>65, :mode=>"rwxrwxrwx", :user=>\"#{user}\", :group=>\"#{group}\"}
{:type=>"-", :mode=>"rwxr-xr-x", :user=>\"#{user}\", :group=>\"#{group}\", :path=>"./bin/treedeploy"}
EOS
    expect(output).to eq(CLI_REPAIR_OUT)

    output = capture(:stdout) {
      Treedeploy::CLI.start(["list", "./", "bin", "-Qpug"])
    }
    CLI_LIST_OUT = <<"EOS"
[drwxr-xr-x #{sprintf('%-8s', user)} #{sprintf('%-8s', group)}] "./bin"
[-rwxr-xr-x #{sprintf('%-8s', user)} #{sprintf('%-8s', group)}] "./bin/treedeploy"
EOS
    expect(output).to eq(CLI_LIST_OUT)
  end

end
