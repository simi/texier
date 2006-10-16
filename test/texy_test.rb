require 'test/unit'
require File.dirname(__FILE__) + '/../lib/texy'

class TexyTest < Test::Unit::TestCase

    # Assert that result produced by Texy is equal to expected result.
    def assert_texy(expected, source)
        texy = Texy.new

        assert_equal expected, texy.process(source)
    end



    def test_paragraphs
        source = <<END
První odstavec lorem ipsum dolor sit amet.

Druhý odstavec, který tvoří jeden řádek.
A druhý řádek textu. Texy! je spojí.
END

        expected = <<END
<p>První odstavec lorem ipsum dolor sit amet.</p>

<p>Druhý odstavec, který tvoří jeden řádek.
A druhý řádek textu. Texy! je spojí.</p>
END

        assert_texy expected, source
    end

#     def test_complex
#         texy = Texy.new
#
#         source = File.read File.dirname(__FILE__) + '/fixtures/complex.texy'
#
#         expected = File.read File.dirname(__FILE__) + '/fixtures/complex.html'
#         actual = texy.process source
#
#         assert_equal expected, actual
#     end
end