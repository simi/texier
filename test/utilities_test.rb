require 'test/unit'
require File.dirname(__FILE__) + '/../lib/utilities'

class UtilitiesTest < Test::Unit::TestCase
    def test_array_to_hash
        assert_equal({0 => 'hello', 1 => 'world'}, ['hello', 'world'].to_hash)
    end

    def test_hash_downcase_keys
        assert_equal({'foo' => 'hello', 'bar' => 'world'}, {'Foo' => 'hello', 'BAR' => 'world'}.downcase_keys)
    end

    def test_hash_assign_to_all
        assert_equal(
            {'foo' => 'whazup', 'bar' => 'whazup'},
            {'foo' => 'hello', 'bar' => 'world'}.assign_to_all('whazup')
        )
    end
end