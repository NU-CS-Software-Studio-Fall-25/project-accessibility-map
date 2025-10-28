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

  validates :name, :address, :city, :state, :zip, :country, :latitude, :longitude, presence: true

  def full_address
    [address, city, state, zip, country].compact_blank.join(", ")
  end

  geocoded_by :full_address

  before_validation :geocode_if_address_changed

  private

  def geocode_if_address_changed
    return if full_address.blank?

    if will_save_change_to_address? ||
        will_save_change_to_city?    ||
        will_save_change_to_state?   ||
        will_save_change_to_zip?     ||
        will_save_change_to_country?
      begin
        geocode
      rescue => e
        Rails.logger.warn("[Geocoding] #{e.class}: #{e.message}")
      end
    end
  end
end
