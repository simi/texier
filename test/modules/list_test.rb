require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::List class
class ListTest < Test::Unit::TestCase
  def test_simple_list
    #    assert_output(
    #      '<ul><li>one</li><li>two</li><li>three</li></ul>',
    #      '
    #      - one
    #      - two
    #      - three'
    #    )
  end
  
  #  def test_nested_list
  #    assert_output(
  #      '
  #      <ul>
  #          <li>one</li>
  #          <li>two
  #              <ul>
  #                  <li>two one</li>
  #                  <li>two two</li>
  #                  <li>two three</li>
  #              </ul>
  #          </li>
  #          <li>three</li>
  #      </ul>',
  # 
  #      '
  #      - one
  #      - two
  #          - two one
  #          - two two
  #          - two three
  #      - three'
  #    )
  #  end
end