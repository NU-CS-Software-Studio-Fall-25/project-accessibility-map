# frozen_string_literal: true
class Location < ApplicationRecord
  validates :name, presence: true
  validates :address, presence: true

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
