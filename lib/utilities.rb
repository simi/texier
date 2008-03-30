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

module Texier::Utilities
  # Convert string to web safe characters [a-z0-9-].
  def self.webalize(string)
    # TODO: transliterate
    string.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^\-+|\-+$/, '')
  end

  # Escape <, > and &
  def self.escape_html(string)
    string.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
  end

  # Add number to the end of a string or increment it if it is there already.
  def self.sequel(string, separator = '-')
    if /(\d+)$/ =~ string
      "#{$`}#{$1.to_i + 1}"
    else
      "#{string}#{separator}2"
    end
  end
end