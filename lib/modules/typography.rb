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
  class Typography < Base
    
    # TODO: The Texy! implementation of this module relies heavily on feature of
    # regular expressions called lookbehind. Lookbehinds are not supported in
    # ruby 1.8, so lot of things might not work as expected. They will be
    # supported in ruby 1.9, but until then i should figure out some workaround.

    # Locale specific settings.
    LOCALES = {
      'cs' => {
        :single_quotes => ["\xe2\x80\x9a", "\xe2\x80\x98"], # U+201A, U+2018
        :double_quotes => ["\xe2\x80\x9e", "\xe2\x80\x9c"], # U+201E, U+201C
      },

      'en' => {
        :single_quotes => ["\xe2\x80\x98", "\xe2\x80\x99"], # U+2018, U+2019
        :double_quotes => ["\xe2\x80\x9c", "\xe2\x80\x9d"]  # U+201C, U+201D
      },

      'fr' => {
        :single_quotes => ["\xe2\x80\xb9", "\xe2\x80\xb9"], # U+2039, U+203A
        :double_quotes => ["\xc2\xab", "\xc2\xbb"]          # U+00AB, U+00BB
      }

      # TODO: add more locales
    }

    # These locales have the same settings as some of the previously defined
    # ones.
    LOCALES['cz'] = LOCALES['cs']
    LOCALES['sk'] = LOCALES['cs']
    
    # Current locale. Can be one of locales specified in the LOCALES hash.
    options :locale => 'en'

    inline_element('typography') do
      quote = e('"').skip
      double_quotes = quote & inline_element.one_or_more.up_to(quote)
      double_quotes = double_quotes.map do |*content|
        quote(:double_quotes, content)
      end

      quote = e('\'').skip
      single_quotes = quote & inline_element.one_or_more.up_to(quote)
      single_quotes = single_quotes.map do |*content|
        quote(:single_quotes, content)
      end

      ellipsis = e(/\.{3,4}(?!\.)/) {"\xe2\x80\xa6"}

      en_dash = e(/\d+| |^/) & e(/-(?=[\d ]|$)/).skip
      en_dash = en_dash.map {|prefix| "#{prefix}\xe2\x80\x93"}

      # TODO: en-dash alphanum--alphanum

      # TODO: date 1. 1. 1970

      # TODO: date 1. 1.

      em_dash = e(' --- ') {"\xc2\xa0\xe2\x80\x94 "}

      # TODO: non-breaking space after dash

      left_right_arrow = e(/<-{1,2}>/) {"\xe2\x86\x94"}
      left_arrow = e(/<-+/) {"\xe2\x86\x90"}
      right_arrow = e(/-+>/) {"\xe2\x86\x92"} | e(/=+>/) {"\xe2\x87\x92"}

      dimension_sign = e(/\d+/) & e(/(?:(?:(?: x )|x)(?=\d))|(?:x(?= |,|.|$))/)
      dimension_sign = dimension_sign.map {|number, _| "#{number}\xc3\x97"}
      
      trademark = e(/ ?\(tm\)/i) {"\xe2\x84\xa2"}
      registered = e(/ ?\(r\)/i) {"\xc2\xae"}
      copyright = e(/\(c\)(?= ?\S)/i) {"\xc2\xa9"}
      
      euro_sign = e(/\(eur\)/i) {"\xe2\x82\xac"}
      
      # TODO: maybe more currency signs? (GBP, JPY, CNY, KRW, ... anything that
      # has special symbol)
      
      phone_number = e(/\d{1,3}/) & e(/ (?=\d{3})/)
      phone_number = phone_number.map {|number, _| "#{number}\xc2\xa0"}

      # TODO: space before last short word (wtf?)
      
      # TODO: nbsp space between number (optionally followed by dot) and word,
      # symbol, punctation, currency symbol

      # TODO: space between preposition and word

      single_quotes | double_quotes | ellipsis | en_dash | em_dash |
      left_right_arrow | left_arrow | right_arrow | dimension_sign | trademark | 
      registered | copyright | euro_sign | phone_number
    end

    private

    def quote(type, content)
      [LOCALES[locale][type][0]] + content + [LOCALES[locale][type][1]]
    end
  end
end