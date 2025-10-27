class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :locations
  has_many :reviews

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
