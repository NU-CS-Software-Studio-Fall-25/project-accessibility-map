# frozen_string_literal: true

class Location < ApplicationRecord
  has_many :reviews, dependent: :destroy

  include PgSearch::Model
  pg_search_scope :search_locations,
    against: [:name, :address, :city, :zip],
    using: {
      tsearch: { prefix: true },
    }

  validates :name, :address, :city, :state, :zip, :country, :latitude, :longitude, presence: true
end
