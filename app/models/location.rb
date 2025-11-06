# frozen_string_literal: true

class Location < ApplicationRecord
  belongs_to :user
  has_many :reviews, dependent: :destroy
  has_and_belongs_to_many :features, join_table: :locations_features
  has_many_attached :pictures, dependent: :destroy

  include PgSearch::Model
  pg_search_scope :search_locations,
    against: [:name, :address, :city, :zip],
    using: {
      tsearch: { prefix: true },
    }

  before_validation :normalize_fields
  before_validation :clear_coords_if_address_changed
  before_validation :geocode_safely, if: -> { address_fields_changed? || latitude.blank? || longitude.blank? }
  validate :zip_code_format_valid
  validate :coordinates_required_if_address_changed, if: :address_fields_changed?


  # Let geocoded_by handle the geocoding automatically
  geocoded_by :full_address
  #after_validation :geocode, if: ->(obj) { obj.address_changed? || obj.city_changed? || obj.state_changed? || obj.zip_changed? || obj.country_changed? }
  #after_validation :geocode_safely, if: :address_fields_changed?


  validates :name, :address, :city, :state, :zip, :country, presence: true
  validates :address, uniqueness: {
    scope: [:city, :state, :zip, :country],
    case_sensitive: false,
    message: "has already been taken for this city, state, zip, and country",
  }

  validate :coordinates_required_if_address_changed, if: :address_fields_changed?

  def full_address
    [address, city, state, zip, country].compact_blank.join(", ")
  end

  def pictures_as_thumbnails
    pictures.map do |picture|
      picture.variant(resize_to_limit: [nil, 300], saver: { quality: 100 }).processed
    end
  end

  def address_fields_changed?
    will_save_change_to_address? ||
      will_save_change_to_city?   ||
      will_save_change_to_state?  ||
      will_save_change_to_zip?    ||
      will_save_change_to_country?
  end

  private

  def normalize_fields
    [:address, :city, :state, :zip, :country].each do |attr|
      self[attr] = self[attr].to_s.strip.squeeze(" ")
    end
    self.state = state.upcase if state.present?
    self.country = country.to_s.strip

    # us zips to digits or digits dash
    if country == "United States" && zip.present?
      self.zip = zip.gsub(/[^0-9\-]/, "")
    end
  end

  def zip_code_format_valid
    return if zip.blank?
    return unless country == "United States"
    unless /\A\d{5}(-\d{4})?\z/.match?(zip)
      errors.add(:zip, "must be in the format 12345 or 12345-6789 for United States")
    end
  end

  def require_coordinates_after_geocoding
    if full_address.present? && (latitude.blank? || longitude.blank?)
      errors.add(:base, "Could not geocode the provided address. Please check the address details.")
    end
  end

  def clear_coords_if_address_changed
    return unless address_fields_changed?
    
    self.latitude = nil
    self.longitude = nil
  end

  def geocode_safely
    # Call Geocoder directly so we can inspect postal_code
    result = Geocoder.search(full_address).first
    return unless result

    detected_zip = (result.postal_code || "").to_s
    # Normalize to 5 digits for US comparisons
    if country == "United States"
      provided = zip.to_s.gsub(/\D/, "")[0,5]
      detected = detected_zip.gsub(/\D/, "")[0,5]

      if provided.blank? || detected.blank? || provided != detected
        # Don’t set coords; fail validation later
        errors.add(:zip, "zip code does not match the address (found #{detected_zip.presence || 'unknown'})")
        return
      end
    end

    # ZIP matches (or non-US), accept the coordinates
    self.latitude  = result.latitude
    self.longitude = result.longitude
  rescue OpenSSL::SSL::SSLError, Geocoder::Error => e
    Rails.logger.warn("Geocode error, will invalidate save if coords blank: #{e.message}")
    # leave coords nil; your validation will block save
  end

  def coordinates_required_if_address_changed
    if latitude.blank? || longitude.blank?
      errors.add(:base, "Address could not be located. Please enter a valid address.")
    end
  end
end
