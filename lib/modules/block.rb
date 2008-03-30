module Texier::Modules
  class Block < Texier::Module
    block_element('text') do
      opening = e(/\/--+ *text *\n/).skip

      (opening & everything_up_to(closing)).map do |content|
        content = Texier::Utilities.escape_html(content)
        lines = content.split("\n")
        breaks = Array.new(lines.size - 1, Texier::Element.new('br'))

        # Put one line break between each two lines.
        lines.zip(breaks).flatten
      end
    end

    block_element('code') do
      opening = e(/\/--+ *code */).skip & optional(/[^ \n]+/) & e(/ *\n/).skip

      (opening & everything_up_to(closing)).map do |language, content|
        Texier::Element.new(
          'pre', Texier::Element.new('code', content), 'class' => language
        )
      end
    end

    block_element('html') do
      # TODO: sanitize html
      opening = e(/\/--+ *html *\n/).skip
      opening & everything_up_to(closing)
    end

    # TODO: later
    #    block_element('div') do
    #      opening = discard(/\/--+ *div *\n/)
    # 
    #      (opening & document & closing).map do |*content|
    #        Texier::Element.new('div', content)
    #      end
    #    end

    private

    def closing
      @closing ||= e(/\n\\--+ */).skip
    end
  end
end
