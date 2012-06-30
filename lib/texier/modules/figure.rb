# 
# Copyright (c) 2008 Adam Ciganek <adam.ciganek@gmail.com>
# 
# This file is part of Texier.
# 
# Texier is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free
# Software Foundation.
# 
# Texier is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# Texier. If not, see <http://www.gnu.org/licenses/>.
# 
# For more information please visit http://code.google.com/p/texier/
# 

module Texier::Modules
  # This module provides figures - images with descritpions.
  class Figure < Base
    options :class_name => 'figure'
    
    # NOTE: left_class and right_class are taken from image module. This differs
    # from Texy!, but i think there is no need to duplicate these options.
    
    # TODO: option width_delta and it's functionality like in Texy!
    
    block_element('figure') do
      separator = e(/ *\*{3,} */).skip
      eol = e(/$/) {[nil]}

      description = inline_element.one_or_more.group

      figure = image & separator & description.up_to(modifier | eol)
      figure = figure.map do |image, description, modifier|
        element = build(
          'div', [image, build('p', description)],
          'class' => class_name
        )
        
        element.modify(modifier)
        apply_align(element)
        
        element
      end
    end
    
    private
    
    # Take align from image and apply it to the whole figure.
    def apply_align(figure)
      image = figure.content[0]
      
      [:left, :right].each do |align|
        align_class = base.image_module.send("#{align}_class") ||
          base.align_classes[align]
      
        figure.add_class_name(image.class_name.delete(align_class))
      end
      
      figure.style['float'] = image.style.delete('float')
    end
  end
end
