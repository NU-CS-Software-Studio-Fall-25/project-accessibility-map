# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Ensure session is always resumed on every request
  before_action :resume_session # MOVE THIS LINE UP

  include Authentication # This registers before_action :require_authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  private

  def current_user
    Current.session&.user
  end
end
