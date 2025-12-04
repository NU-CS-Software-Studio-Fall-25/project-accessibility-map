class AutomaticAltTextService
    def self.generate_for(picture)
        return unless attachment.variable?
        image_url = Rails.application.routes.url_helpers.rails_blob_url(
            attachment, 
            only_path: false 
        )

        caption = call_openai(image_url)

        attachment.blob.metadata["alt_text"] = caption
        attachment.blob.save
    end

    def self.call_openai(image_url)
        client = OpenAI::Client.new

        response = client.chat(parameters: {
            model: "gpt-4o-mini",
            messages: [
                {
                    role: "user", content: [
                        { type: "input_text", text: "Generate a short alt text for this accessibility-related photo." }
                        { type: "input_image", image_url: image_url }
                    ]
                }
            ]
        })

        response.dig("choices", 0, "message", "content") || "image"
    end
end