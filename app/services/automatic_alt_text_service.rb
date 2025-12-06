require "net/http"
require "json"

class AutomaticAltTextService
  HF_MODEL = "Salesforce/blip-image-captioning-base"

  def self.generate_for(attachment)
    return unless attachment&.blob

    file = attachment.download
    caption = call_huggingface(file)
    return unless caption.present?

    # save in active record 
    attachment.blob.metadata["alt_text"] = caption
    attachment.blob.save!
    caption
  end

  def self.call_huggingface(image_url)
    api_key = ENV["HUGGINGFACE_API_KEY"] 
    uri = URI("https://api-inference.huggingface.co/models/#{HF_MODEL}")

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{api_key}"
    request["Content-Type"] = "image/jpeg"   # HF requires binary MIME
    request.body = image_bytes

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    json = JSON.parse(response.body)
    json.first["generated_text"]
  rescue => e
    Rails.logger.error("HuggingFace error: #{e}")
    nil
  end
end
