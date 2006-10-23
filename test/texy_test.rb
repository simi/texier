require 'test/unit'
require File.dirname(__FILE__) + '/../lib/texy'

class TexyTest < Test::Unit::TestCase

    FIXTURES_DIR = File.dirname(__FILE__) + '/fixtures'

    def setup
        @texy = Texy.new
        @texy.notice_shown = true # disable notice
        @texy.formatter_module.line_wrap = 0 # disable line wrapping
    end

    # Generate one test method for each fixture found.
    #
    # Add file foo.texy and foo.html to directory
    # fixtures/simple to create new test case that will assert
    # that content of foo.html is equal to texy-ized content of
    # foo.texy.
    Dir.glob("#{FIXTURES_DIR}/simple/*.texy") do |texy_file|
        method_name = File.basename(texy_file).gsub('.texy', '')

        # next unless method_name == 'tables5'

        define_method "test_#{method_name}".to_sym do
            source = File.read texy_file
            expected = File.read texy_file.gsub('.texy', '.html')

            assert_equal expected, @texy.process(source)
        end
    end

    def test_dynamic_headings
        source = File.read "#{FIXTURES_DIR}/headings.texy"

        @texy.heading_module.top = 2
        @texy.heading_module.balancing = :dynamic

        assert_equal File.read("#{FIXTURES_DIR}/headings_dynamic.html"), @texy.process(source)
    end
end