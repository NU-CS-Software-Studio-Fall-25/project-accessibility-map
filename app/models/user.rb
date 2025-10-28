class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :locations
  has_many :reviews
  has_many_attached :pictures

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
