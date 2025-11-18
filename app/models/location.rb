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
  validate :zip_code_format_valid

  validates :name, :address, :city, :state, :zip, :country, presence: true
  validates :address, uniqueness: {
    scope: [:city, :state, :zip, :country],
    case_sensitive: false,
    message: "has already been taken for this city, state, zip, and country",
  }

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
end
