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
    Rails.logger.debug("AUTHENTICATION: authenticated? called")
    Current.session.present?
  end

  def require_authentication
    Rails.logger.debug("AUTHENTICATION: require_authentication called")
    authenticated? || request_authentication
  end

  def resume_session
    Rails.logger.debug("AUTHENTICATION: resume_session called")
    session_from_cookie = find_session_by_cookie
    Rails.logger.debug("AUTHENTICATION: session_from_cookie: #{session_from_cookie.inspect}")
    Current.session ||= session_from_cookie
    Rails.logger.debug("AUTHENTICATION: Current.session after assignment: #{Current.session.inspect}")
    Current.session
  end

  def find_session_by_cookie
    Rails.logger.debug("AUTHENTICATION: find_session_by_cookie called")
    cookie_session_id = cookies.signed[:session_id]
    Rails.logger.debug("AUTHENTICATION: cookies.signed[:session_id]: #{cookie_session_id.inspect}")
    if cookie_session_id
      session_record = Session.find_by(id: cookie_session_id)
      Rails.logger.debug("AUTHENTICATION: Session.find_by(id: #{cookie_session_id}) result: #{session_record.inspect}")
      session_record
    else
      Rails.logger.debug("AUTHENTICATION: No session_id in signed cookies.")
      nil
    end
  end

  def request_authentication
    Rails.logger.debug("AUTHENTICATION: request_authentication called")
    # CHANGE THIS LINE: Store return URL in a signed cookie instead of the disabled session hash
    cookies.signed[:return_to_after_authenticating] = request.url
    redirect_to(new_session_path)
  end

  def after_authentication_url
    # CHANGE THIS LINE: Retrieve from cookie and then delete the cookie
    url = cookies.signed[:return_to_after_authenticating]
    cookies.delete(:return_to_after_authenticating)
    url || root_url
  end

  def start_new_session_for(user)
    Rails.logger.debug("AUTHENTICATION: start_new_session_for called for user #{user.id}")
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session_record|
      Current.session = session_record
      cookies.signed.permanent[:session_id] = { value: session_record.id, httponly: true, same_site: :lax }
      Rails.logger.debug("AUTHENTICATION: New session created (ID: #{session_record.id}) and cookie set.")
    end
  end

  def terminate_session
    Rails.logger.debug("AUTHENTICATION: terminate_session called")
    Current.session&.destroy
    cookies.delete(:session_id)
    Rails.logger.debug("AUTHENTICATION: Session terminated and cookie deleted.")
  end
end
