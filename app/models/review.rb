# frozen_string_literal: true

# Represents a user review for a location.
# Reviews must be at least 10 characters and are filtered for profanity.
# Reviews belong to both a location and the user who created them.
class Review < ApplicationRecord
  belongs_to :location
  belongs_to :user

  validates :body, length: { minimum: 10, message: "Review must have at least 10 characters" }
  validate :body_is_clean

  private

  def body_is_clean
    return if body.blank?

    if Obscenity.profane?(body)
      errors.add(:body, "contains inappropriate language")
    end
  end
end
