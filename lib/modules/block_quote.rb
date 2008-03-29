module Texier::Modules
  # This module provides block quotations.
  class BlockQuote < Texier::Module
    block_element('blockquote') do
      content = one_or_more(block_element).separated_by(/\n+/).group
      block_quote = optional(modifier & discard("\n")) \
        & indented(content, /^>( |$)/) & optional(discard("\n>") & link)
      
      block_quote.map do |modifier, content, cite_url|
        element = Texier::Element.new('blockquote', content, :cite => cite_url)
        element.modify!(modifier)
      end
    end
  end
end