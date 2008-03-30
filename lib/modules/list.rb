module Texier::Modules
  class List < Texier::Module
    options :bullets => [
      # first bullet | is ordered? | style        | next bullets
      [/\* +/,         false],
      [/-(?![>-])/,    false],
      [/\+ +/,         false],
      [/1\. +/,        true,         nil,           /\d{1,3}\. +/],
      [/\d{1,3}\) +/,  true],
      [/I\. +/,        true,         'upper-roman', /[IVX]{1,4}\. +/],
      [/[IVX]+\) +/,   true,         'upper-roman'],
      # TODO: lower roman?
      [/[a-z]\) +/,    true,         'lower-alpha'],
      [/[A-Z]\) +/,    true,         'upper-alpha']
    ]

    # Ordered and unordered lists.
    block_element('list') do
      bullets.inject(empty) {|list, style| list | build_list(style)}
    end
    
    # Definition lists.
    block_element('definition') do
      term = inline_element.one_or_more.up_to(e(":").skip).map do |content|
        Texier::Element.new('dt', content)
      end
      
      definition = build_item(/-(?![>-])/, 'dd')
      definitions = definition.one_or_more.separated_by(/\n+/).indented
      
      list = term & modifier.maybe & e("\n").skip & definitions
      list.map do |term, modifier, *definitions|
        Texier::Element.new('dl', [term] + definitions).modify!(modifier)
      end
    end

    private
    
    # Build expression that matches list.
    def build_list(style)
      item = build_item(style[0], 'li')
      
      if style[3]
        next_item = build_item(style[3], 'li')
        items = item & e("\n").skip & next_item.one_or_more.separated_by("\n")
      else
        items = item.one_or_more.separated_by("\n")
      end
      
      list = (modifier & e("\n").skip).maybe & items
      list.map do |modifier, *items|
        element = Texier::Element.new(style[1] ? 'ol' : 'ul', items)
        
        if style[2]
          element.style ||= {}
          element.style['list-style-type'] = style[2]
        end
        
        element.modify!(modifier)
      end
    end
    
    # Build expression that matches list item.
    def build_item(pattern, tag)
      bullet = e(/(#{pattern}) */).skip
      first_line = inline_element.one_or_more.up_to(modifier.maybe & e(/$/).skip)
      blocks = block_element.one_or_more.separated_by(/\n*/).indented
      
      item = bullet & first_line & (e(/\n+/).skip & blocks).maybe
      item.map do |first, modifier, *rest|
        Texier::Element.new(tag, first + rest).modify!(modifier)
      end
    end
  end
end