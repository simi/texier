require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # This module provides block quotations.
  class BlockQuote < Texier::Module
    block_element('blockquote') do
      block_quote = one_or_more(block_element).separated_by(/\n+/)
      block_quote = indented(block_quote, /^>( |$)/)
      
      block_quote.map do |*content|
        Texier::Element.new('blockquote', content)
      end
    end
  end
end
