# frozen_string_literal: true

module LocationsHelper
  def tooltip_link_to(location)
    full_address = "#{location.address}, #{location.city}, #{location.state} #{location.zip}"

    content = <<~HTML
      <div style="text-align: left;">
        <div style="font-weight: bold; font-size: 1rem; margin-bottom: 4px;">#{location.name}</div>
        <div style="font-size: 0.875rem; margin-bottom: 8px;">#{full_address}</div>
        <a href="#{location_path(location)}" style="display: inline-block; background-color: #2563eb; color: white; padding: 4px 12px; border-radius: 16px; text-decoration: none; font-size: 0.875rem;">View Details</a>
      </div>
    HTML

    content.html_safe
  end
end
