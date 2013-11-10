# -*- coding: utf-8 -*-

require 'spec_helper'
require 'thor/runner'

describe Deploy do

  include FileUtils
  include Treedeploy

  specify 'Shows information for unkown command' do

    expect(Treedeploy::CLI::Runner).to receive :exit
    output = capture(:stderr) do
      Treedeploy::CLI::Runner.start ['xxx']
    end
    expect(output).to eq("Could not find command \"xxx\".\n")

  end

  specify 'Shows information for no argument' do

    output = capture(:stdout) do
      Treedeploy::CLI.start []
      # Treedeploy::CLI::Runner.start []
    end
    expect(output).to match(/check parent folder treelist/)
    expect(output).to match(/deploy src dest folder treelist/)
    expect(output).to match(/help \[COMMAND\]/)
    expect(output).to match(/list parent folder/)
    expect(output).to match(/repair parent folder treelist/)
  end

  specify 'Shows information for deploy, check, repair, list' do

    FileUtils::rm_rf(['tmp/bin'])
    d = Deploy.new
    props = d.get_props_fullpath('.')
    user = props[:user]
    group = props[:group]

    FileUtils.chmod(0755, './bin/treedeploy')
    FileUtils.chmod(0755, './bin')
    system 'bundle exec ruby bin/treedeploy list -Qpug . bin > spec/tree.txt'

    output = capture(:stdout) do
      Treedeploy::CLI.start ['deploy', '.', 'tmp', 'bin', 'spec/tree.txt']
    end
    expect(output).to eq('')

    output = capture(:stdout) do
      Treedeploy::CLI.start ['check', 'tmp', 'bin', 'spec/tree.txt']
    end
    expect(output).to eq('')

    output = capture(:stdout) do
      Treedeploy::CLI.start ['repair', 'tmp', 'bin', 'spec/tree.txt']
    end
    expect(output).to eq('')

    FileUtils.chmod(0777, 'tmp/bin/treedeploy')
    output = capture(:stdout) do
      Treedeploy::CLI.start ['check', 'tmp', 'bin', 'spec/tree.txt']
    end

    CLI_CHECK_OUT = <<"EOS"
{:type=>"-", :size=>65, :mode=>"rwxrwxrwx", :user=>\"#{user}\", :group=>\"#{group}\"}
{:type=>"-", :mode=>"rwxr-xr-x", :user=>\"#{user}\", :group=>\"#{group}\", :path=>"./bin/treedeploy"}
EOS
    expect(output).to eq(CLI_CHECK_OUT)

    output = capture(:stdout) do
      Treedeploy::CLI.start ['repair', 'tmp', 'bin', 'spec/tree.txt']
    end
    CLI_REPAIR_OUT = <<"EOS"
{:type=>"-", :size=>65, :mode=>"rwxrwxrwx", :user=>\"#{user}\", :group=>\"#{group}\"}
{:type=>"-", :mode=>"rwxr-xr-x", :user=>\"#{user}\", :group=>\"#{group}\", :path=>"./bin/treedeploy"}
EOS
    expect(output).to eq(CLI_REPAIR_OUT)

    output = capture(:stdout) do
      Treedeploy::CLI.start ['list', './', 'bin', '-Qpug']
    end
    CLI_LIST_OUT = <<"EOS"
[drwxr-xr-x #{sprintf('%-8s', user)} #{sprintf('%-8s', group)}] "./bin"
[-rwxr-xr-x #{sprintf('%-8s', user)} #{sprintf('%-8s', group)}] "./bin/treedeploy"
EOS
    expect(output).to eq(CLI_LIST_OUT)
  end

end
