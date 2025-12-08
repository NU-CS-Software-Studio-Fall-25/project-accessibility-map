# frozen_string_literal: true

class Location < ApplicationRecord
  belongs_to :user
  has_many :reviews, dependent: :destroy
  has_and_belongs_to_many :features, join_table: :locations_features
  has_and_belongs_to_many :favorited_by_users, class_name: "User", join_table: "favorites"
  has_many_attached :pictures, dependent: :destroy

  include PgSearch::Model
  pg_search_scope :search_locations,
    against: [:name, :address, :city, :zip],
    using: {
      tsearch: { prefix: true },
    }

  before_validation :normalize_fields
  validate :zip_code_format_valid

  validates :name, :address, :city, :state, :zip, :country, presence: true
  validates :address, uniqueness: {
    scope: [:city, :state, :zip, :country],
    case_sensitive: false,
    message: "is already in use",
  }

  # Ensure coordinates are present when address fields are set
  validate :coordinates_present_if_address_changed, on: :update
  validates :name, length: { maximum: 60 }

  validate :name_is_clean
  validate :address_fields_are_clean
  validate :alt_texts_are_clean

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

  def name_is_clean
    return if name.blank?

    if Obscenity.profane?(name)
      errors.add(:name, "contains inappropriate language")
    end
  end

  def address_fields_are_clean
    [:address, :city, :state, :country].each do |field|
      value = self[field]
      next if value.blank?

      if Obscenity.profane?(value)
        errors.add(field, "contains inappropriate language")
      end
    end
  end

  def alt_texts_are_clean
    return unless pictures.attached?

    pictures.each do |pic|
      alt = pic.blob.metadata["alt_text"]

      next if alt.blank?

      # character limit
      if alt.length > 120
        errors.add(:base, "Alt text for an image is too long (maximum is 120 characters).")
      end

      # profanity check
      if Obscenity.profane?(alt)
        errors.add(:base, "Alt text contains inappropriate language: '#{alt}'")
      end
    end
  end

  def coordinates_present_if_address_changed
    return unless persisted? # Only for updates

    address_changed = will_save_change_to_address? ||
      will_save_change_to_city? ||
      will_save_change_to_state? ||
      will_save_change_to_zip? ||
      will_save_change_to_country?

    if address_changed && (latitude.blank? || longitude.blank?)
      errors.add(:base, "Address could not be located. Please enter a valid address.")
    end
  end
end
