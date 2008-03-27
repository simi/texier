require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  class List < Texier::Module
    # NOTE: unicode noncharacters: U+FDD0..U+FDEF (in utf8:
    # \xEF\xB7\x90..\xEF\xB7\xAF)

    # Special tokens
    #    LIST_ITEM_BEGIN = "\xEF\xB7\x90"
    #    LIST_ITEM_END = "\xEF\xB7\x91"

    LIST_ITEM_BEGIN = '[LIST_ITEM_BEGIN]'
    LIST_ITEM_END = '[LIST_ITEM_END]'


#    def before_parse(input)
#      indent_stack = ['']
#      result = ''
#
#      input.each_line do |line|
#        current_indent = line[/^ */]
#
#        while current_indent.length < indent_stack.last.length
#          result << LIST_ITEM_END
#          indent_stack.pop
#        end
#
#        if line =~ /^ *-/ # line begins with bullet
#          result << LIST_ITEM_BEGIN
#          line.sub!(/^#{current_indent}/, '')
#          indent_stack.push(current_indent + ' ')
#        else
#          line.sub!(/^#{indent_stack.last}/, '')
#        end
#
#        result << line
#      end
#
#      result << LIST_ITEM_END * (indent_stack.size - 1)
#      result
#    end
#    
#    def after_render(output)
#      output.gsub(LIST_ITEM_BEGIN, '').gsub(LIST_ITEM_END, '')
#    end
#
#    block_element('list') do
#      item_begin = discard(LIST_ITEM_BEGIN)
#      item_end = discard(LIST_ITEM_END)
#
#      bullet = discard(/- +/)
#      content = one_or_more(inline_element) & discard(optional("\n"))
#      item = (item_begin & bullet & content & item_end).map do |*content|
#        Texier::Element.new('li', content)
#      end
#
#      one_or_more(item).map do |*items|
#        Texier::Element.new('ul', items)
#      end
#    end

    private
  end
end
