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
  class Image < Texier::Module
    
    options(
      # Root of relative images.
      :root => '/images',
      
      # CSS class for left-aligned images.
      :left_class => nil,
      
      # CSS class for right-aligned images.
      :right_class => nil
    )
    
    inline_element('image') do
      opening = e(/\[\* */).skip
      
      align = e('>') {:right} | e('<') {:left} | e('*') {[nil]}
      closing = e(/ */).skip & align & e(']').skip
      
      (opening & everything_up_to(closing)).map do |url, align|
        element = Texier::Element.new(
          'img', :src => Texier::Utilities.prepend_root(url, root)
        )
        
        align_image(element, align)
      end
    end

    private
    
    # Apply alignment to image.
    def align_image(element, align)
      if align
        if align_class = send("#{align}_class") || processor.align_classes[align]
          element.add_class_name(align_class)
        else
          element.add_style('float', align.to_s)
        end
      end
      
      element
    end
  end
end