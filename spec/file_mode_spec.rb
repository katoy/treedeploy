# -*- coding: utf-8 -*-

require 'spec_helper'

describe FileMode do

  PATTERNS = [
    # synm,        oct,  int
    ['---------', '000', 0],
    ['--------x', '001', 01],
    ['-------w-', '002', 02],
    ['-------wx', '003', 03],
    ['------r--', '004', 04],
    ['------r-x', '005', 05],
    ['------rw-', '006', 06],
    ['------rwx', '007', 07],

    ['-----x---', '010', 010],
    ['----w----', '020', 020],
    ['----wx---', '030', 030],
    ['---r-----', '040', 040],
    ['---r-x---', '050', 050],
    ['---rw----', '060', 060],
    ['---rwx---', '070', 070],

    ['--x------', '100', 0100],
    ['-w-------', '200', 0200],
    ['-wx------', '300', 0300],
    ['r--------', '400', 0400],
    ['r-x------', '500', 0500],
    ['rw-------', '600', 0600],
    ['rwx------', '700', 0700],

    ['rwxr-xr-x', '755', 0755],
  ]

  include FileMode

  specify 'sym_to_oct' do
    PATTERNS.each do |data|
      expect(data[1]).to eq(sym_to_oct(data[0]))
    end
  end

  specify 'oct_to_sym' do
    PATTERNS.each do |data|
      expect(data[0]).to eq(oct_to_sym(data[1]))
    end
  end

  specify 'oct_to_int' do
    PATTERNS.each do |data|
      expect(data[2]).to eq(oct_to_int(data[1]))
    end
  end

  specify 'int_to_oct' do
    PATTERNS.each do |data|
      expect(data[1]).to eq(int_to_oct(data[2]))
    end
  end

end

