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

  # Let geocoded_by handle the geocoding automatically
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj) { obj.address_changed? || obj.city_changed? || obj.state_changed? || obj.zip_changed? || obj.country_changed? }

  validates :name, :address, :city, :state, :zip, :country, presence: true
  validates :address, uniqueness: {
    scope: [:city, :state, :zip, :country],
    case_sensitive: false,
    message: "has already been taken for this city, state, zip, and country",
  }

  validate :require_coordinates_after_geocoding, on: :update

  def full_address
    [address, city, state, zip, country].compact_blank.join(", ")
  end

  def pictures_as_thumbnails
    pictures.map do |picture|
      picture.variant(resize_to_limit: [nil, 300], saver: { quality: 100 }).processed
    end
  end

  private

  def normalize_fields
    [:address, :city, :state, :zip, :country].each do |attr|
      self[attr] = self[attr].to_s.strip.squeeze(" ")
    end
    self.state = state.upcase if state.present?
    self.country = country.to_s.strip
  end

  def require_coordinates_after_geocoding
    if full_address.present? && (latitude.blank? || longitude.blank?)
      errors.add(:base, "Could not geocode the provided address. Please check the address details.")
    end
  end
end
