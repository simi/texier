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
  # This module provides images.
  class Image < Texier::Module
    options(
      # Root of relative images.
      :root => '/images',
      
      # CSS class for left-aligned images.
      :left_class => nil,
      
      # CSS class for right-aligned images.
      :right_class => nil,
      
      # Default alternative text.
      :default_alt => nil
    )
    
    # TODO: add support for mouseover images. (this feature isn't that useful,
    # in my opinion, so i'll give it very low priority right now)
    
    # TODO: image size [* foo.jpg 123x456 *]
    
    # TODO: determine image size automaticaly (if image is local and some
    # image processing tool (RMagic, for example) is loaded)
    
    inline_element('image') do
      opening = e(/\[\* */).skip
      
      align = e('>') {:right} | e('<') {:left} | e('*') {[nil]}
      space = e(/ */).skip
      closing = space & modifier.maybe & space & align & e(']').skip
      
      image = (opening & everything_up_to(closing)).map do |url, modifier, align|
        element = Texier::Element.new(
          'img', :src => Texier::Utilities.prepend_root(url, root)
        )
        
        apply_align(element, align)
        element.modify(modifier)
        apply_alt(element)
        
        element
      end
      
      image_with_link = (image & link).map do |image, url|
        Texier::Element.new('a', image, :href => url)
      end
      
      image_with_link | image
    end

    private
    
    # Apply alignment to image.
    def apply_align(element, align)
      if align
        if align_class = send("#{align}_class") || processor.align_classes[align]
          element.add_class_name(align_class)
        else
          element.add_style('float', align.to_s)
        end
      end
    end
    
    # Set alternative text of image.
    def apply_alt(element)
      # Use alt instead of title. This is what Texy! does, but i'm not sure if
      # that's right. Maybe there should be configuration option for it (use
      # only alt/use alt and title/only title). I'll see...
      if element.title
        element.alt = element.title
        element.title = nil
      else        
        element.alt = default_alt
      end
    end
  end
end