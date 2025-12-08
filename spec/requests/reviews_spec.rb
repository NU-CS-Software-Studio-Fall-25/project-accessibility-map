# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Reviews", type: :request) do
  let(:user) do
    User.create!(
      email_address: "test@example.com",
      username: "tester",
      password: "Password!123",
    )
  end

  let(:location) do
    Location.create!(
      name: "Test Place",
      address: "123 Main St",
      city: "Evanston",
      state: "IL",
      zip: "60201",
      country: "USA",
      user_id: user.id,
    )
  end

  # logs in via SessionsController
  def login(user)
    post(session_path, params: {
      email_address: user.email_address,
      password: "Password!123",
    })
  end

  before do
    login(user)
  end

  describe "POST /locations/:location_id/reviews" do
    context "with valid review parameters" do
      it "creates a new review and redirects to the location page" do
        expect do
          post(location_reviews_path(location), params: {
            review: { body: "This place is great for wide aisles and those with sensory issues!" },
          })
        end.to(change { Review.count }.by(1))

        expect(response).to(redirect_to(location_path(location)))
      end
    end

    context "when the review is too short" do
      it "does NOT create the review and re-renders the page" do
        expect do
          post(location_reviews_path(location), params: {
            review: { body: "Too short" },
          })
        end.not_to(change { Review.count })

        expect(response).to(have_http_status(:unprocessable_content))
      end
    end

    context "when the review contains obscene language" do
      it "does NOT create the review and shows an error" do
        expect do
          post(location_reviews_path(location), params: {
            review: { body: "This place is shit" },
          })
        end.not_to(change { Review.count })

        expect(response.body).to(include("inappropriate"))
        expect(response).to(have_http_status(:unprocessable_content))
      end
    end
  end
end
