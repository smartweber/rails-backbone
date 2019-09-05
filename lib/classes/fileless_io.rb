require 'base64'

class FilelessIO < StringIO
  attr_accessor :original_filename, :type, :extension, :encoder, :raw_data

  def initialize(base64_str)
    splitBase64(base64_str)
    decodedStr = Base64.decode64(@raw_data)
    @original_filename = "attachment.#{extension}"
    super(decodedStr)
  end

private

  def splitBase64(base64_str)
    if base64_str.match(/data:(.*?);(.*?),(.*)/)
      @type      = $1
      @extension = $1.split('/')[1]
      @encoder   = $2
      @raw_data  = $3
    end
  end
end
