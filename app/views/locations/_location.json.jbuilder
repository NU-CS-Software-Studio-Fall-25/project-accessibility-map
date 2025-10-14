# frozen_string_literal: true

json.extract!(location, :id, :name, :address, :city, :state, :zip, :country, :latitude, :longitude, :created_at, :updated_at)
json.tooltip(tooltip_link_to(location))
