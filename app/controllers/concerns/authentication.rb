# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action(:require_authentication, **options)
    end
  end

  private

  def authenticated?
    Current.session.present?
  end

  def require_authentication
    authenticated? || request_authentication
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    cookie_session_id = cookies.signed[:session_id]
    Session.find_by(id: cookie_session_id) if cookie_session_id
  end

  def request_authentication
    # Store return URL in a signed cookie instead of the disabled session hash
    cookies.signed[:return_to_after_authenticating] = request.url
    redirect_to(new_session_path)
  end

  def after_authentication_url
    # Retrieve from cookie and then delete the cookie
    url = cookies.signed[:return_to_after_authenticating]
    cookies.delete(:return_to_after_authenticating)
    url || root_url
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session_record|
      Current.session = session_record
      cookies.signed.permanent[:session_id] = { value: session_record.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
  end
end
