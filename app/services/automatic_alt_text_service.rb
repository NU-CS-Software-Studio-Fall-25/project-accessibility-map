require "net/http"
require "json"

class AutomaticAltTextService
  HF_MODEL = "Salesforce/blip-image-captioning-base"

  def self.generate_for(attachment)
    return unless attachment&.blob
    file = attachment.download
    encoded = Base64.strict_encode64(file)

    caption = call_huggingface(encoded)
    return unless caption.present?

    # alt text goes into active storage 
    attachment.blob.metadata["alt_text"] = caption
    attachment.blob.save!
    caption
  end

  def self.call_huggingface(image_url)
    api_key = ENV["HUGGINGFACE_API_KEY"] 
    uri = URI("https://api-inference.huggingface.co/models/#{HF_MODEL}")

    headers = {
      "Authorization" => "Bearer #{api_key}",
      "Content-Type" => "application/json"
    }

    puts "Calling Hugging Face API for alt text generation..."

    payload = { inputs: image_url }.to_json

    response = Net::HTTP.post(uri, payload, headers)
    json = JSON.parse(response.body)

    json[0]["generated_text"] rescue nil
  end
end
