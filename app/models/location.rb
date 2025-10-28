# frozen_string_literal: true

class Location < ApplicationRecord
  belongs_to :user
  has_many :reviews, dependent: :destroy
  has_and_belongs_to_many :features, join_table: :locations_features

  include PgSearch::Model
  pg_search_scope :search_locations,
    against: [:name, :address, :city, :zip],
    using: {
      tsearch: { prefix: true },
    }

  before_validation :normalize_fields

  geocoded_by :full_address

  before_validation :normalize_fields
  before_validation :geocode_if_address_present

  validates :name, :address, :city, :state, :zip, :country, presence: true
  validates :address, uniqueness: {
    scope: [:city, :state, :zip, :country],
    case_sensitive: false,
    message: "has already been taken for this city, state, zip, and country",
  }

  validate :require_coordinates_after_geocoding

  def full_address
    [address, city, state, zip, country].compact_blank.join(", ")
  end

  private

  def normalize_fields
    [:address, :city, :state, :zip, :country].each do |attr|
      self[attr] = self[attr].to_s.strip.squeeze(" ")
    end
    self.state = state.upcase if state.present?
    self.country = country.to_s.strip
  end

  def geocode_if_address_present
    return if full_address.blank?

    self.latitude = nil
    self.longitude = nil

    begin
      geocode
    rescue => e
      Rails.logger.warn("[Geocoding] #{e.class}: #{e.message}")
    end
  end

  def require_coordinates_after_geocoding
    if full_address.present? && (latitude.blank? || longitude.blank?)
      errors.add(:base, "Could not geocode the provided address. Please check the address details.")
    end
  end
end
