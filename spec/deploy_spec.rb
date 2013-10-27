# -*- coding: utf-8 -*-

require 'spec_helper'

describe Deploy do

  include FileUtils

  d = Deploy.new

  specify 'parse 0' do
    p = d.parse('"cont"')
    expect(0).to eq(p.size)
  end

  specify 'parse 1' do
    p = d.parse("  ─ [-r--r--r-- root     wheel   ] \"cont/444.txt\"")
    expect(p).to eq(
                    { type: "-",
                      mode: "r--r--r--",
                      user: "root",
                      group: "wheel",
                      path: "cont/444.txt"
                    }
                    )
  end

  specify 'parse 3' do
    p = d.parse('4 directories, 6 files')
    expect(0).to eq(p.size)
  end

  specify 'copyFile, checkFile, repairFile, setPropsFulloath, getPropsFullPath' do

    FileUtils::rm_rf(["tmp/bin"])

    props = d.getPropsFullPath('.')
    user = props[:user]
    group = props[:group]

    props = d.parse("  ─ [drwxr-xr-x #{user}  #{group}  ] \"bin\"")
    ret = d.copyFile('.', './tmp', props)
    expect(ret).to eq(nil)
    ret = d.getPropsFullPath("tmp/bin")
    ret[:size] = 0  # directory のサイズは環境に依存するので ...
    expect(ret).to eq({:type=>"d", :size=>0, :mode=>"rwxr-xr-x", :user=> user, :group=> group})

    ret = d.checkFile('.', nil, props)
    expect(ret).to eq(nil)

    ret = d.repairFile('./tmp', nil, props)
    expect(ret).to eq(nil)

    props = d.parse("  ─ [-r--r--r-- #{user}  #{group}  ] \"bin/treedeploy\"")
    ret = d.copyFile('.', './tmp', props)
    expect(ret).to eq(nil)
    props = d.getPropsFullPath("tmp/bin/treedeploy")
    expect(props).to eq({:type=>"-", :size=>65, :mode=>"r--r--r--", :user=> user, :group=> group})

    props[:mode] = "rwxrw-r--"
    ret = d.setPropsFullPath("tmp/bin/treedeploy", props)
    expect(ret).to eq(nil)
    props = d.getPropsFullPath("tmp/bin/treedeploy")
    expect(props).to eq({:type=>"-", :size=>65, :mode=>"rwxrw-r--", :user=> user, :group=> group})

    props[:user] = 'uuu'
    expect {
      d.setPropsFullPath("tmp/bin/treedeploy", props)
    }.to raise_error(ArgumentError, "can't find user for uuu")

    props[:user] = user
    props[:group] = 'ggg'
    expect {
      d.setPropsFullPath("tmp/bin/treedeploy", props)
    }.to raise_error(ArgumentError, "can't find group for ggg")

  end

  specify 'copyFile, checkFile, repairFile, setPropsFulloath, getPropsFullPath for no-exist file' do

    FileUtils::rm_rf(["tmp/bin"])

    props = d.getPropsFullPath('.')
    user = props[:user]
    group = props[:group]

    props = d.parse("  ─ [drwxr-xr-x #{user}  #{group}  ] \"no-exist\"")
    expect {
      d.copyFile('.', './tmp', props)
    }.to raise_error(Errno::ENOENT, "No such file or directory - ./no-exist")
    expect {
      d.getPropsFullPath("tmp/no-exist")
    }.to raise_error(Errno::ENOENT, "No such file or directory - tmp/no-exist")
    expect {
      d.setPropsFullPath("tmp/no-exist", props)
    }.to raise_error(Errno::ENOENT, "No such file or directory - tmp/no-exist")

    ret = d.checkFile('.', nil, props)
    expect("#{ret}").to eq("No such file or directory - ./no-exist")

    ret = d.repairFile('.', nil, props)
    expect("#{ret}").to eq("No such file or directory - ./no-exist")
  end

  specify 'deploy, check, repair' do

    system("bundle exec ruby bin/treedeploy list -Qpug . bin > tmp/tree.txt")

    FileUtils::rm_rf(["tmp/bin"])

    props = d.getPropsFullPath('.')
    user = props[:user]
    group = props[:group]

    ret = d.deploy('.', 'tmp', 'bin', "tmp/tree.txt")
    expect(ret).to eq(nil)

    ret = d.check('./tmp', 'bin', "tmp/tree.txt")
    expect(ret).to eq(nil)

    ret = d.repair('./tmp', 'bin', "tmp/tree.txt")
    expect(ret).to eq(nil)

    props = d.getPropsFullPath('./tmp/bin/treedeploy')
    props[:mode] = "r--------"
    d.setPropsFullPath('./tmp/bin/treedeploy', props)
    ret = d.check('./tmp', 'bin', "tmp/tree.txt")
    expect(ret).to eq([{:type=>"-", :size=>65, :mode=>"r--------", :user=>user, :group=>group}, {:type=>"-", :mode=>"rwxr-xr-x", :user=>user, :group=>group, :path=>"./bin/treedeploy"}]
)

    ret = d.repair('./tmp', 'bin', "tmp/tree.txt")
    expect(ret).to eq([{:type=>"-", :size=>65, :mode=>"r--------", :user=>user, :group=>group}, {:type=>"-", :mode=>"rwxr-xr-x", :user=>user, :group=>group, :path=>"./bin/treedeploy"}])
    # 修正されたことをチェック
    ret = d.check('./tmp', 'bin', "tmp/tree.txt")
    expect(ret).to eq(nil)

  end

  specify 'list' do
    ret = nil
    output = capture(:stdout) {
      ret = d.list('.', 'bin')
    }
    expect(ret).to eq(nil)
    expect(output).to eq("./bin\n./bin/treedeploy\n")

    opts = {:protections => true, :owner => true, :group => true, :size => true, :quot => true}
    output = capture(:stdout) {
      ret = d.list('.', 'bin', opts)
    }
    expect(ret).to eq(nil)

    props = d.getPropsFullPath('tmp/bin')
    user = props[:user]
    group = props[:group]
    size = props[:size]
LIST_OUT = <<"EOS"
[drwxr-xr-x #{sprintf('%-8s', user)} #{sprintf('%-8s', group)} #{sprintf('%12d', size)}] "./bin"
[-rwxr-xr-x #{sprintf('%-8s', user)} #{sprintf('%-8s', group)}           65] "./bin/treedeploy"
EOS
    expect(output).to eq(LIST_OUT)

  end

  specify 'err in copyFile' do
    user = "xxxx"
    group = "xxxx"
    props = d.parse("  ─ [drwxr-xr-x #{user}  #{group}  ] \"bin\"")
    out = capture(:stdout) {
      out = d.copyFile('.', './tmp', props)
    }
    expect(out).to eq("# ignore ./tmp/bin: can't find user for xxxx\n")
  end

  specify 'err in repair' do
    user = "xxxx"
    group = "xxxx"
    props = d.parse("  ─ [drwxr-xr-x #{user}  #{group}  ] \"bin\"")
    out = capture(:stdout) {
      out = d.repairFile('.', './tmp', props)
    }
    expect(out).to eq("# ignore ./bin: can't find user for xxxx\n")
  end

end
