# -*- coding: utf-8 -*-

# 2013-09-09 katoy

# file のパーミッション表記の解釈を行う。

module FileMode

  READ_BIT  = 4
  WRITE_BIT = 2
  EXEC_BIT  = 1
  NO_BIT    = 0
  SYMBOLIC_MODE = { 'r' => READ_BIT, 'w' => WRITE_BIT, 'x' => EXEC_BIT, '-' => NO_BIT }

  # シンボル表記を8進表記に変換する。
  # "rwxr-xr-x" -> "755" ( = 493)
  def sym_to_oct(sym)
    fail "invalid #{sym}" unless /^([r|\-][w|\-][x\-]){3}$/.match(sym)
    sym3_to_oct(sym[0..2]) + sym3_to_oct(sym[3..5]) + sym3_to_oct(sym[6..8])
  end

  # 8 進表記をシンボル表記に変換する。
  # "755" -> "rwxr-xr-x"
  def oct_to_sym(oct)
    fail "invalid #{oct}" unless /^[0-7][0-7][0-7]$/.match(oct)
    oct_to_sym3(oct[0]) + oct_to_sym3(oct[1]) + oct_to_sym3(oct[2])
  end

  # 8 進表記を integer に変換する。
  # "755" - > 493
  def oct_to_int(oct)
    fail "invalid #{oct}" unless /^[0-7]{3}$/.match(oct)
    oct.to_i(8)
  end

  # integer を 8 進表記に変換する。
  # 493 -> "755"
  def int_to_oct(v)
    fail "invalid #{v}" if (v < 0) || (v > 0777)
    format('%#03o', v)[-3..-1]
  end

  # シンボル表記を 8 進表記に変換する。
  # "rwx" -> 7
  def sym3_to_oct(sym)
    fail "invalid #{sym}" unless /^[r|\-][w|\-][x|\-]$/.match(sym)
    v = SYMBOLIC_MODE[sym[0]] + SYMBOLIC_MODE[sym[1]] + SYMBOLIC_MODE[sym[2]]
    v.to_s(8)
  end

  # 8 進表記を シンボル表記に変換する。
  # "7" -> "rwx"
  def oct_to_sym3(oct)
    fail "invalid #{oct}" unless /^[0-8]$/.match(oct)
    v = oct.to_i(8)
    ans = ''
    ans += (v & READ_BIT) != 0 ?  'r' : '-'
    ans += (v & WRITE_BIT) != 0 ? 'w' : '-'
    ans += (v & EXEC_BIT) != 0 ?  'x' : '-'
    ans
  end

  FILE_TYPE = {
    'blockSpecial'     => 'b', # Block special file.
    'characterSpecial' => 'c', # Character special file.
    'directory'        => 'd', # Directory.
    'link'             => 'l', # Symbolic link.
    'socket'           => 's', # Socket link.
    'fifo'             => 'p', # FIFO.
    'file'             => '-', # Regular file.
    'unknown'          => '?'  # unknown
  }

  #
  def get_props_fullpath(path)
    props = {}
    stat = File::lstat(path)

    props[:type] = FILE_TYPE[stat.ftype]
    props[:type] = '?' unless props[:type]

    props[:size] = stat.size

    props[:mode] = oct_to_sym(int_to_oct(stat.mode & 00777))
    begin
      props[:user] = Etc.getpwuid(stat.uid).name
    rescue
      props[:user] = "#{stat.uid}"
    end
    begin
      props[:group] = Etc.getgrgid(stat.gid).name
    rescue
      props[:group] = "#{stat.gid}"
    end
    props
  end

  #
  def set_props_fullpath(path, props)

    smode = sym_to_oct(props[:mode])
    mode = oct_to_int(smode)

    FileUtils.chmod(mode, path)
    FileUtils.chown(props[:user], props[:group], path)
    nil
  end

end
