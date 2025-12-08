# frozen_string_literal: true

# Represents an accessibility feature that can be associated with locations.
# Features are organized by categories (e.g., "Physical Accessibility", "Food & Diet").
class Feature < ApplicationRecord
  has_and_belongs_to_many :locations, join_table: :locations_features
end
