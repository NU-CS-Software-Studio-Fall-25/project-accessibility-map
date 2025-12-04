require "net/http"
require "json"

class AutomaticAltTextService
  HF_MODEL = "Salesforce/blip-image-captioning-base"

  def self.generate_for(attachment)
    return unless attachment.variable? 

    image_url = Rails.application.routes.url_helpers.rails_blob_url(
      attachment,
      only_path: false
    )

    caption = call_huggingface(image_url)
    return unless caption.present?

    # alt text goes into active storage
    attachment.blob.metadata["alt_text"] = caption
    attachment.blob.save

    caption
  end

  def self.call_huggingface(image_url)
    api_key = Rails.application.credentials.dig(:huggingface, :api_key)
    uri = URI("https://api-inference.huggingface.co/models/#{HF_MODEL}")

    headers = {
      "Authorization" => "Bearer #{api_key}",
      "Content-Type" => "application/json"
    }

    payload = { inputs: image_url }.to_json

    response = Net::HTTP.post(uri, payload, headers)
    json = JSON.parse(response.body)

    json.first["generated_text"] rescue nil
  end
end
