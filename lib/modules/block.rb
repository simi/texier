module Texier::Modules
  class Block < Texier::Module
    block_element('text') do
      opening = discard(/\/--+ *text *\n/)
      closing = discard(/\n\\--+ */)
      
      (opening & everything_up_to(closing)).map do |content|
        content = Texier::Utilities.escape_html(content)
        lines = content.split("\n")
        breaks = Array.new(lines.size - 1, Texier::Element.new('br'))

        # Put one line break between each two lines.
        lines.zip(breaks).flatten
      end
    end  
    
    block_element('code') do
      opening = discard(/\/--+ *code */) & optional(/[^ \n]+/) & discard(/ *\n/)
      closing = discard(/\n\\--+ */)
        
      (opening & everything_up_to(closing)).map do |language, content|
        Texier::Element.new(
          'pre', Texier::Element.new('code', content), 'class' => language
        )
      end
    end
  end
end
