# Monkey patch for URI.escape removed in Ruby 3.0
# Jekyll 2.5.3 uses URI.escape which was removed
require 'uri'

module URI
  # Simple implementation of URI.escape for compatibility
  def self.escape(str, unsafe = /[^a-zA-Z\d\-._~!$&\'()*+,;=:@\/]/)
    str.to_s.gsub(unsafe) do |unsafe_char|
      '%' + unsafe_char.unpack('H2' * unsafe_char.bytesize).join('%').upcase
    end
  end
end
