# -*- coding: utf-8 -*-

require 'spec_helper'

describe Deploy do

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

end
