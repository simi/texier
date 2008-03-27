require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  class List < Texier::Module
    # Special tokens delimiting list item.
    LIST_ITEM_BEGIN = unique_token
    LIST_ITEM_END = unique_token

    def before_parse(input)
      # Lists are defined using "2D layout" syntax (syntax based on
      # indentation). This kind of syntax is difficult to parse using recursive
      # descend parsers (like the one i'm using here). So i preprocess the
      # document a little, to make things easier. Basicaly i'm replacing
      # indentation with LIST_ITEM_BEGIN and LIST_ITEM_END tokens, so the syntax
      # become "1D" and therefore easy to parse.
      indent_stack = ['']
      result = ''

      input.each_line do |line|
        current_indent = line[/^ */]

        while current_indent.length < indent_stack.last.length
          result << LIST_ITEM_END
          indent_stack.pop
        end

        if line =~ /^ *-/ # line begins with bullet
          result << LIST_ITEM_BEGIN
          line.sub!(/^#{current_indent}/, '')
          indent_stack.push(current_indent + ' ')
        else
          line.sub!(/^#{indent_stack.last}/, '')
        end

        result << line
      end

      result << LIST_ITEM_END * (indent_stack.size - 1)
      result
    end

    block_element('list') do
      item_begin = discard(LIST_ITEM_BEGIN)
      item_end = discard(LIST_ITEM_END)
      
      bullet = discard(/- +/)

      item = item_begin & bullet \
        & one_or_more(inline_element).up_to(discard(optional("\n")) & item_end)
      item = item.map do |*content|
        Texier::Element.new('li', content)
      end

      one_or_more(item).map do |*items|
        Texier::Element.new('ul', items)
      end
    end
    
    # Remove unused tokens.
    inline_element do
      discard(/#{LIST_ITEM_BEGIN}|#{LIST_ITEM_END}/)
    end
    

    private
  end
end
