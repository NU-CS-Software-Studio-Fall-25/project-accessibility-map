# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  validates :email_address, uniqueness: true
  validates :password,
    length: { minimum: 12, message: "must be at least 12 characters long" },
    format: {
      with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[[:^alnum:]])/,
      message: "must include at least one lowercase letter, one uppercase letter, one digit, and one special character",
    }
  has_many :sessions, dependent: :destroy
  has_many :locations
  has_many :reviews
  has_many_attached :pictures
  has_and_belongs_to_many :favorite_locations, class_name: "Location", join_table: "favorites"

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
