require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  class List < Texier::Module
    options :bullets => [
      [/\* +/,        false],
      [/-(?![>-])/,   false],
      [/\+ +/,        false],
      [/1\. +/,       true, nil, /\d{1,3}\. +/]
    ]

    block_element('list') do
      bullets.inject(empty) {|list, style| list | build_list(style)}
    end

    private
    
    def build_list(style)
      item = build_item(style[0])
      
      if style[3]
        next_item = build_item(style[3])
        list = item & discard("\n") & one_or_more(next_item).separated_by("\n")
      else
        list = one_or_more(item).separated_by("\n")
      end
      
      list.map do |*items|
        Texier::Element.new(style[1] ? 'ol' : 'ul', items)
      end
    end
    
    def build_item(pattern)
      bullet = discard(/(#{pattern}) */)
      blocks = indented(one_or_more(block_element).separated_by(/\n*/))
      
      item = bullet & line & optional(discard(/\n+/) & blocks)
      item.map do |*content|
        Texier::Element.new('li', content)
      end
    end
  end
end