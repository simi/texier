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

module Texier
  module Expressions
    module Link
      URL = /(https?:\/\/|www\.|ftp:\/\/)[a-z0-9.-][\/a-z\d+\.~%&?@=_:;\#,-]+[\/\w\d+~%?@=_\#]/i
      EMAIL = /[a-z0-9.+_-]{1,64}@[a-z0-9.+_-]{1,252}\.[a-z]{2,6}/i
      
      private
      
      # Expression that matches link.
      def link
        processor.expressions[:link] ||= e(/:((\[[^\]\n]+\])|(\S*[^:);,.!?\s]))/).map do |url|
          sanitize_url(url.gsub(/^:\[?|\]$/, ''))
        end
      end
      
      def sanitize_url(url)
        case url
        when /^www\./
          "http://#{url}"
        when EMAIL
          "mailto:#{url}"
        else
          url
        end
      end
      
      def build_link(content, url)
        Texier::Element.new('a', content, 'href' => sanitize_url(url))
      end
    end
  end
end
