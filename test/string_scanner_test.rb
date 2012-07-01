# encoding: utf-8
require "#{File.dirname(__FILE__)}/test_helper"

class Texier::StringScannerTest < Test::Unit::TestCase
  attr_accessor :scanner, :string

  def setup
    self.string = 'Nasral Franta na trabanta, Bufalo Bill hovno viděl, v prdeli byl.'
    self.scanner = Texier::StringScanner.new(self.string)
  end

  def test_peek
    assert_equal "", scanner.peek(0)
    assert_equal "N", scanner.peek(1)
    assert_equal "Nasral", scanner.peek(6)

    scanner.pos = 7

    assert_equal "Franta", scanner.peek(6)
  end

  def test_pos
    assert_equal 0, scanner.pos
    scanner.pos = 10
    assert_equal 10, scanner.pos
  end

  def test_scan
    s = Texier::StringScanner.new('stra strb strc')
    tmp = s.scan(/\w+/)
    assert_equal 'stra', tmp

    assert_equal 4, s.pos

    tmp = s.scan(/\s+/)
    assert_equal ' ', tmp

    assert_equal 'strb', s.scan(/\w+/)
    assert_equal ' ',    s.scan(/\s+/)

    tmp = s.scan(/\w+/)
    assert_equal 'strc', tmp

    assert_nil           s.scan(/\w+/)
    assert_nil           s.scan(/\w+/)
  end

  def test_rest
    assert_equal scanner.string, scanner.rest
    scanner.pos = 61
    assert_equal 'byl.', scanner.rest
    scanner.pos = 61
  end

  def test_getch
    assert_equal "N", scanner.getch
    assert_equal "a", scanner.getch

    scanner.pos = 61
    assert_equal "b", scanner.getch
    assert_equal "y", scanner.getch
    assert_equal "l", scanner.getch
    assert_equal ".", scanner.getch
    assert_equal nil, scanner.getch

  end

  def test_array
    s = Texier::StringScanner.new("Fri Dec 12 1975 14:39")
    assert_equal 'Fri Dec 12 ', s.scan(/(\w+) (\w+) (\d+) /)
    assert_equal 'Fri Dec 12 ', s[0]
    assert_equal 'Fri', s[1]
    assert_equal 'Dec', s[2]
    assert_equal '12', s[3]

    s.scan /abc/
    assert_equal nil, s[0]
  end
end
