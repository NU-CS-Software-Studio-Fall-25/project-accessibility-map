# frozen_string_literal: true

class Feature < ApplicationRecord
  has_and_belongs_to_many :locations, join_table: :locations_features
end
