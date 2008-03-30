module Texier::Modules
  # This module provides block quotations.
  class BlockQuote < Texier::Module
    block_element('blockquote') do
      content = one_or_more(block_element).separated_by(/\n+/).group
      block_quote = optional(modifier & e("\n").skip) \
        & indented(content, /^>( |$)/) & optional(e("\n>").skip & link)
      
      block_quote.map do |modifier, content, cite_url|
        element = Texier::Element.new('blockquote', content, :cite => cite_url)
        element.modify!(modifier)
      end
    end
  end
end