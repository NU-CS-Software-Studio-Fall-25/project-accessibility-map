# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  validates :email_address, presence: true, uniqueness: true
  validates :username, presence: true
  validates :password,
    length: { minimum: 12, message: "must be at least 12 characters long" },
    format: {
      with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[[:^alnum:]])/,
      message: "must include at least one lowercase letter, one uppercase letter, one digit, and one special character",
    },
    if: :password_digest_changed?
  has_many :sessions, dependent: :destroy
  has_many :locations
  has_many :reviews
  has_many_attached :pictures
  has_one_attached :profile_photo
  has_and_belongs_to_many :favorite_locations, class_name: "Location", join_table: "favorites"

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
