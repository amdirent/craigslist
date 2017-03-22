require 'uri'
module PostHelpers
  def strip_qr_text(message)
    message.sub(/^QR Code Link to This Post\s*/, '')
  end
end
