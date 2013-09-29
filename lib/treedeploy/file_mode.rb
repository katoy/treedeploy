# -*- coding: utf-8 -*-

# 2013-09-09 katoy

# file のパーミッション表記の解釈を行う。

module FileMode

  ReadBit  = 4
  WriteBit = 2
  ExecBit  = 1
  NoBit    = 0
  SymbolicMode = { 'r' => ReadBit, 'w' => WriteBit, 'x' => ExecBit, '-' => NoBit }

  # シンボル表記を8進表記に変換する。
  # "rwxr-xr-x" -> "755" ( = 493)
  def sym_to_oct(sym)
    raise "invalid #{sym}" unless /^([r|\-][w|\-][x\-]){3}$/.match(sym)
    sym3_to_oct(sym[0..2]) + sym3_to_oct(sym[3..5]) + sym3_to_oct(sym[6..8])
  end

  # 8 進表記をシンボル表記に変換する。
  # "755" -> "rwxr-xr-x"
  def oct_to_sym(oct)
    raise "invalid #{oct}" unless /^[0-7][0-7][0-7]$/.match(oct)
    oct_to_sym3(oct[0]) + oct_to_sym3(oct[1]) + oct_to_sym3(oct[2])
  end

  # 8 進表記を integer に変換する。
  # "755" - > 493
  def oct_to_int(oct)
    raise "invalid #{oct}" unless /^[0-7]{3}$/.match(oct)
    oct.to_i(8)
  end

  # integer を 8 進表記に変換する。
  # 493 -> "755"
  def int_to_oct(v)
    raise "invalid #{v}" if v < 0 or v > 0777
    sprintf("%#03o", v)[-3..-1]
  end

  # シンボル表記を 8 進表記に変換する。
  # "rwx" -> 7
  def sym3_to_oct(sym)
    raise "invalid #{sym}" unless /^[r|\-][w|\-][x|\-]$/.match(sym)
    v = SymbolicMode[sym[0]] + SymbolicMode[sym[1]] + SymbolicMode[sym[2]]
    v.to_s(8)
  end

  # 8 進表記を シンボル表記に変換する。
  # "7" -> "rwx"
  def oct_to_sym3(oct)
    raise "invalid #{oct}" unless /^[0-8]$/.match(oct)
    v = oct.to_i(8)
    ans = ''
    ans += (v & ReadBit != 0) ?  'r' : '-'
    ans += (v & WriteBit != 0) ? 'w' : '-'
    ans += (v & ExecBit != 0) ?  'x' : '-'
  end

  FILE_TYPE = {
    "blockSpecial"     => "b", # Block special file.
    "characterSpecial" => "c", # Character special file.
    "directory"        => "d", # Directory.
    "link"             => "l", # Symbolic link.
    "socket"           => "s", # Socket link.
    "fifo"             => "p", # FIFO.
    "file"             => "-", # Regular file.
    "unknown"          => "?"  # unknown
  }

  #
  def getPropsFullPath(path)
    props = {}
    stat = File::lstat(path)

    props[:type] = FILE_TYPE[stat.ftype]
    props[:type] = "?" if props[:type] == nil

    props[:size] = stat.size

    props[:mode] = oct_to_sym(int_to_oct(stat.mode & 00777))
    begin
      props[:user] = Etc.getpwuid(stat.uid).name
    rescue => e
      props[:user] = "#{stat.uid}"
    end
    begin
      props[:group] = Etc.getgrgid(stat.gid).name
    rescue => e
      props[:group] = "#{stat.gid}"
    end
    props
  end

  #
  def setPropsFullPath(path, props)

    # ファイルの存在をチェックする
    stat = File::lstat(path)

    smode = sym_to_oct(props[:mode])
    mode = oct_to_int(smode)
    begin
      FileUtils.chmod(mode, path)
      FileUtils.chown(props[:user], props[:group], path)
      nil
    rescue => e
      "Ignore: #{e}"
    end
  end

end
