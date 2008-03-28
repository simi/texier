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
        # Skip empty lines
        if line =~ /^ *$/
          result << line
          next
        end

        # Indentation of current line.
        current_indent = line[/^ */]

        while current_indent.length < indent_stack.last.length
          result << LIST_ITEM_END
          indent_stack.pop
        end

        # Line begins with bullet.
        if line =~ /^ *- +/
          result << LIST_ITEM_BEGIN
          indent_stack.push(current_indent + ' ')
        end

        # Remove indentation.
        line.sub!(/^#{current_indent}/, '') if indent_stack.size > 1

        result << line
      end

      result << LIST_ITEM_END * (indent_stack.size - 1)
      result
    end

    block_element('list') do
      bullet = discard(/- +/)

      item_begin = discard(LIST_ITEM_BEGIN) & bullet
      item_end = discard(optional("\n")) & discard(LIST_ITEM_END)

      item =
        (item_begin & one_or_more(inline_element) & item_end) | \
        (item_begin & document & item_end)

      item = item.map do |*content|
        Texier::Element.new('li', content)
      end

      one_or_more(item).map do |*items|
        Texier::Element.new('ul', items)
      end
    end

    private
  end
end