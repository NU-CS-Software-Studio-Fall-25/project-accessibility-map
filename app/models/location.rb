# frozen_string_literal: true
class Location < ApplicationRecord
    has_many :reviews, dependent: :destroy
    has_many :photos, dependent: :destroy

    include PgSearch::Model
    pg_search_scope :search_locations,
        against: [:name, :address, :city, :zip],
        using: {
        tsearch: { prefix: true },
        }

    before_validation :normalize_fields

    geocoded_by :full_address
    before_validation :geocode_if_address_changed

    validates :name, :address, :city, :state, :zip, :country, presence: true
    validates :address, uniqueness: {
        scope: %i[city state zip country],
        case_sensitive: false,
        message: "has already been taken for this city, state, zip, and country"
    }

    validate :require_coordinates_after_geocoding

    def full_address
        [address, city, state, zip, country].compact_blank.join(", ")
    end

    geocoded_by :full_address

    before_validation :geocode_if_address_changed

    private

    def normalize_fields
        %i[address city state zip country].each do |attr|
            self[attr] = self[attr].to_s.strip.squeeze(" ")
        end
        self.state = state.upcase if state.present?
        self.country = country.to_s.strip
    end

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

    def require_coordinates_after_geocoding
        if full_address.present? && (latitude.blank? || longitude.blank?)
        errors.add(:base, "Could not geocode the provided address. Please check the address details.")
    end
end
end