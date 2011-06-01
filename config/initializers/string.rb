class String
  def to_url
    string = self.downcase.strip
    string = string[0..1500] if string.length > 1500
    string.gsub(/\ /,'-').urlize
  end

  def normalize
    result = self
    ["\r", "\n", "  ", "  "].each do |junk|
      result = result.gsub(junk, ' ')
    end
    result
  end
end
