# frozen_string_literal: true

module LocationsHelper
  def tooltip_link_to(location)
    full_address = "#{location.address}, #{location.city}, #{location.state} #{location.zip}"
    link_to(full_address, location_path(location), target: "_blank")
  end
end
