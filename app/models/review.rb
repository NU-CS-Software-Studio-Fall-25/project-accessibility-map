# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :location
  belongs_to :user

  validates :body, length: { minimum: 10, message: "Review must have at least 10 characters" }
end
