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

        define_method "test_simple_#{method_name}".to_sym do
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

    def test_fixed_headings
        source = File.read "#{FIXTURES_DIR}/headings.texy"

        @texy.heading_module.top = 1
        @texy.heading_module.balancing = :fixed

        assert_equal File.read("#{FIXTURES_DIR}/headings_fixed.html"), @texy.process(source)
    end

    def test_html_trust_mode
        source = File.read "#{FIXTURES_DIR}/html.texy"

        @texy.html_module.trust_mode

        assert_equal File.read("#{FIXTURES_DIR}/html_trust.html"), @texy.process(source)
    end

    def test_html_all
        source = File.read "#{FIXTURES_DIR}/html.texy"

        @texy.html_module.trust_mode(false)

        assert_equal File.read("#{FIXTURES_DIR}/html_all.html"), @texy.process(source)
    end

    def test_html_safe_mode
        source = File.read "#{FIXTURES_DIR}/html.texy"

        @texy.html_module.safe_mode

        assert_equal File.read("#{FIXTURES_DIR}/html_safe.html"), @texy.process(source)
    end

    def test_html_none
        source = File.read "#{FIXTURES_DIR}/html.texy"

        @texy.html_module.safe_mode(false)

        assert_equal File.read("#{FIXTURES_DIR}/html_none.html"), @texy.process(source)
    end

    def test_html_custom
        source = File.read "#{FIXTURES_DIR}/html.texy"

        @texy.allowed_tags = {
            'myExtraTag' => ['attr1'],
            'strong' => []
        }

        assert_equal File.read("#{FIXTURES_DIR}/html_custom.html"), @texy.process(source)
    end

    def test_images
        source = File.read "#{FIXTURES_DIR}/images.texy"

        @texy.reference_handler = proc do |ref_name, texy|
            if ref_name == '*user*'
                el_ref = Texy::ImageReference.new(texy)
                el_ref.urls = 'image.gif | image-over.gif | big.gif'
                el_ref.modifier.title = 'Texy! logo'
                el_ref
            else
                false
            end
        end

        @texy.image_module.root = 'imagesdir/'
        @texy.image_module.linked_root = 'imagesdir/big/'
        @texy.image_module.left_class = 'my-left-class'
        @texy.image_module.right_class = 'my-right-class'
        @texy.image_module.default_alt = 'default alt. text'

        assert_equal File.read("#{FIXTURES_DIR}/images.html"), @texy.process(source)
    end

    def test_modifiers_all
        source = File.read "#{FIXTURES_DIR}/modifiers.texy"

        @texy.allowed_classes = :all
        @texy.allowed_styles = :all

        assert_equal File.read("#{FIXTURES_DIR}/modifiers_all.html"), @texy.process(source)
    end

    def test_modifiers_none
        source = File.read "#{FIXTURES_DIR}/modifiers.texy"

        @texy.allowed_classes = false
        @texy.allowed_styles = false

        assert_equal File.read("#{FIXTURES_DIR}/modifiers_none.html"), @texy.process(source)
    end

    def test_modifiers_custom
        source = File.read "#{FIXTURES_DIR}/modifiers.texy"

        @texy.allowed_classes = ['one', '#id']
        @texy.allowed_styles = ['color']

        assert_equal File.read("#{FIXTURES_DIR}/modifiers_custom.html"), @texy.process(source)
    end

    def test_smilies
        source = File.read "#{FIXTURES_DIR}/smilies.texy"

        @texy.smilies_module.allowed = true
        @texy.smilies_module.root = 'images/'
        @texy.smilies_module.icon_class = 'smilie'
        @texy.smilies_module.icons[':oops:'] = 'redface.gif'

        assert_equal File.read("#{FIXTURES_DIR}/smilies.html"), @texy.process(source)
    end

    def test_references
        source = File.read "#{FIXTURES_DIR}/references.texy"

        @texy.reference_handler = proc do |ref_name, texy|
            names = {'0' => 'Me', '1' => 'Punkrats', '2' => 'Serwhats', '3' => 'Bonnyfats'}

            return false unless names[ref_name]

            name = names[ref_name]

            el_ref = Texy::LinkReference.new(texy)

            el_ref.url = '#comm-' + ref_name
            el_ref.label = "[#{ref_name}] **#{name}**"
            el_ref.modifier.classes << 'comment'

            # to enable rel="nofollow", set this:   $elRef->modifier->classes[] = 'nofollow';

            el_ref
        end

        @texy.safe_mode

        assert_equal File.read("#{FIXTURES_DIR}/references.html"), @texy.process(source)
    end

    def test_complex
        source = File.read "#{FIXTURES_DIR}/complex.texy"
        assert_equal File.read("#{FIXTURES_DIR}/complex.html"), @texy.process(source)
    end
end