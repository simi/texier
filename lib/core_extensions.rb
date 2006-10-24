##########################################################################################
#
# This file is part of TexieR - universal text to html converter.
#
# == Author
#
# rane <rane@metatribe.org>
#
# == Copyright
#
# Original version:
#   Copyright (c) 2004-2006 David Grudl
#
# Ruby port:
#   Copyright (c) 2006 rane
#
# Texier is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free Software
# Foundation.
#
# Texier is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# == Version
#
#  0.1 ($Revision: 24 $ $Date: 2006-10-24 18:53:21 +0200 (Ut, 24 okt 2006) $)
#
##########################################################################################

class String
    # Emulation of PHP's word wrap function.
    def word_wrap(width)
        self.gsub(/\n/, "\n\n").gsub(/(.{1,#{width}})(\s+|$)/, "\\1\n").strip
    end

    # Remove HTML tags, leave only plain text.
    def strip_html_tags
        self.gsub(/<[^>]>/, '')
    end
end

class Symbol
    # Turns the symbol into a simple proc, which is especially useful for enumerations. Examples:
    #
    #   # The same as people.collect { |p| p.name }
    #   people.collect(&:name)
    #
    #   # The same as people.select { |p| p.manager? }.collect { |p| p.salary }
    #   people.select(&:manager?).collect(&:salary)
    def to_proc
        Proc.new do |obj, *args|
            obj.send self, *args
        end
    end
end


class Array
    # Convert array to hash by converting indices to keys. Example:
    #
    #   ['hello', 'world'].to_hash # produces {0 => 'hello', 1 => 'world'}
    def to_hash
        result = {}

        self.each_index do |index|
            result[index] = self[index]
        end

        result
    end
end


class Hash
    # Convert hash keys to lowercase.
    def downcase_keys
        result = {}
        self.each do |key, value|
            result[key.to_s.downcase] = value
        end

        result
    end

    # Assign value to all elements of hash
    def assign_to_all(value)
        self.each_key do |key|
            self[key] = value
        end
    end
end