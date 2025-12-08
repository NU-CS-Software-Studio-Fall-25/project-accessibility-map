# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Review", type: :model) do
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
      latitude: 42.057853,
      longitude: -87.676143,
      user_id: user.id,
    )
  end

  describe "associations" do
    it "belongs to a user" do
      review = Review.new(
        body: "This is a valid review body that is long enough",
        user: user,
        location: location,
      )
      expect(review.user).to(eq(user))
    end

    it "belongs to a location" do
      review = Review.new(
        body: "This is a valid review body that is long enough",
        user: user,
        location: location,
      )
      expect(review.location).to(eq(location))
    end

    it "requires a user" do
      review = Review.new(
        body: "This is a valid review body that is long enough",
        location: location,
      )
      expect(review).not_to(be_valid)
      expect(review.errors[:user]).to(include("must exist"))
    end

    it "requires a location" do
      review = Review.new(
        body: "This is a valid review body that is long enough",
        user: user,
      )
      expect(review).not_to(be_valid)
      expect(review.errors[:location]).to(include("must exist"))
    end
  end

  describe "validations" do
    context "body length validation" do
      it "is valid with a body of at least 10 characters" do
        review = Review.new(body: "This is valid", user: user, location: location)
        expect(review).to(be_valid)
      end

      it "is invalid with a body shorter than 10 characters" do
        review = Review.new(body: "Too short", user: user, location: location)
        expect(review).not_to(be_valid)
        expect(review.errors[:body]).to(include("Review must have at least 10 characters"))
      end

      it "is invalid with an empty body" do
        review = Review.new(body: "", user: user, location: location)
        expect(review).not_to(be_valid)
        expect(review.errors[:body]).to(include("Review must have at least 10 characters"))
      end

      it "is invalid with a nil body" do
        review = Review.new(body: nil, user: user, location: location)
        expect(review).not_to(be_valid)
        expect(review.errors[:body]).to(include("Review must have at least 10 characters"))
      end

      it "is valid with exactly 10 characters" do
        review = Review.new(body: "1234567890", user: user, location: location)
        expect(review).to(be_valid)
      end
    end

    context "profanity validation" do
      it "is invalid when body contains profanity" do
        review = Review.new(
          body: "This place is shit and terrible",
          user: user,
          location: location,
        )
        expect(review).not_to(be_valid)
        expect(review.errors[:body]).to(include("contains inappropriate language"))
      end

      it "is valid when body does not contain profanity" do
        review = Review.new(
          body: "This place is great and wonderful",
          user: user,
          location: location,
        )
        expect(review).to(be_valid)
      end

      it "allows blank body for profanity check (handled by length validation)" do
        review = Review.new(body: "", user: user, location: location)
        # Should fail length validation, not profanity
        expect(review).not_to(be_valid)
        expect(review.errors[:body]).not_to(include("contains inappropriate language"))
      end
    end

    context "combined validations" do
      it "requires both valid length and clean content" do
        review = Review.new(body: "shit", user: user, location: location)
        expect(review).not_to(be_valid)
        # Should have at least one body error
        expect(review.errors[:body].length).to(be >= 1)
      end

      it "is valid when all validations pass" do
        long_ok_body =
          "This is a wonderful place with great accessibility features!"

        review = Review.new(
          body: long_ok_body,
          user: user,
          location: location,
        )
        expect(review).to(be_valid)
      end
    end
  end

  describe "creation" do
    it "can be created and saved with valid attributes" do
      long_body =
        "This is a valid review body that is long enough to pass all validations"

      review = Review.create!(
        body: long_body,
        user: user,
        location: location,
      )

      expect(review).to(be_persisted)
      expect(review.id).to(be_present)
      expect(review.body).to(eq(long_body))
    end

    it "cannot be created without required associations" do
      review = Review.new(body: "This is a valid review body that is long enough")
      expect { review.save! }.to(raise_error(ActiveRecord::RecordInvalid))
    end
  end

  describe "scopes and queries" do
    let!(:review1) do
      Review.create!(
        body: "First review that is long enough to pass validation",
        user: user,
        location: location,
      )
    end

    let!(:review2) do
      Review.create!(
        body: "Second review that is long enough to pass validation",
        user: user,
        location: location,
      )
    end

    it "can be queried by location" do
      expect(location.reviews.count).to(eq(2))
      expect(location.reviews).to(include(review1, review2))
    end

    it "can be queried by user" do
      expect(user.reviews.count).to(eq(2))
      expect(user.reviews).to(include(review1, review2))
    end
  end
end
