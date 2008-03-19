module Texier::Utilities
  # Convert string to web safe characters [a-z0-9-].
  def self.webalize(string)
    # TODO: transliterate
    string.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^\-+|\-+$/, '')
  end
  
  # Add number 2 to the end of a string. If there is already a number, increment
  # it.
  def self.sequel(string, separator = '-')
    if /(\d+)$/ =~ string
      "#{$`}#{$1.to_i + 1}"
    else
      "#{string}#{separator}2"
    end
  end
end
