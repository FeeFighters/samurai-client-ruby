class Samurai::Message < Samurai::Base # :nodoc:
  def to_xml(options = {})
    builder = options[:builder] || Builder::XmlMarkup.new(options)
    builder.tag!(:message) do
      self.attributes.each do |key, value|
        builder.tag!(key, value)
      end
    end
  end
end
