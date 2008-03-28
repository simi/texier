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