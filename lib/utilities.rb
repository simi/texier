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
  
  # Turn array [a, b, c, ...] into hash {a => true, b => true, ...}. This hash
  # can then be used for quickly determining if certain element was present in
  # the array. (hash[foo] is much faster than array.include?(foo))
  def self.presence_hash(*attr)
    Hash[*attr.zip(Array.new(attr.size, true)).flatten]
  end
end
