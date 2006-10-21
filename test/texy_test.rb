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
    Dir.glob("#{FIXTURES_DIR}/*.texy") do |texy_file|
        method_name = File.basename(texy_file).gsub('.texy', '')

        # next unless method_name == 'links'

        define_method "test_#{method_name}".to_sym do
            source = File.read texy_file
            expected = File.read texy_file.gsub('.texy', '.html')


            assert_equal expected, @texy.process(source)
        end
    end
end