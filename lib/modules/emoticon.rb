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
  # This module repalces emoticons (smilies) with images. It is disabled by
  # default (can be enabled using processor.allowed['emoticon'] = true)
  class Emoticon < Texier::Module
      
    # TODO: root and file_root
    
    options(
      # What emoticon will be replaced with what image.
      :icons => {
        ':-)' => 'smile.gif',
        ':-(' => 'sad.gif',
        ';-)' => 'wink.gif',
        ':-D' => 'biggrin.gif',
        '8-O' => 'eek.gif',
        '8-)' => 'cool.gif',
        ':-?' => 'confused.gif',
        ':-x' => 'mad.gif',
        ':-P' => 'razz.gif',
        ':-|' => 'neutral.gif',
      },

      # CSS class for emoticon images. NOTE: this is called just "class" in
      # Texy!, but that would conflict with +class+ method.
      :class_name => nil
    )
    
    inline_element('emoticon') do
      icons.inject(nothing) do |result, (pattern, image)|
        result | e(/#{Regexp.quote(pattern)}+/).map do
          Texier::Element.new(
            'img', 'src' => image, 'alt' => pattern, 'class' => class_name
          )
        end
      end
    end
      
    def processor=(processor)
      super
      
      # Disable emoticons by default.
      processor.allowed['emoticon'] = false
    end
  end
end
