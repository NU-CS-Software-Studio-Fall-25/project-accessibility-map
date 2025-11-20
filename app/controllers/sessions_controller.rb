# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to(new_session_url, alert: "Try again later.") }

  def new
  end

  def create
    if auth_hash = request.env["omniauth.auth"]

      def generate_compliant_password
        lowercase = ('a'..'z').to_a.sample
        uppercase = ('A'..'Z').to_a.sample
        digit     = ('0'..'9').to_a.sample
        special   = %w[! @ # $ % ^ & *].sample
        filler    = SecureRandom.alphanumeric(20)  # fills the rest
        # Shuffle so required characters aren't predictable
        (lowercase + uppercase + digit + special + filler).chars.shuffle.join
      end

      # OmniAuth login
      user = User.find_or_initialize_by(provider: auth_hash.provider, uid: auth_hash.uid)

      # Always update these fields when logging in from OmniAuth
      user.email_address = auth_hash.info.email
      user.password ||= generate_compliant_password # only assign if password missing

      user.save!  # raises validation errors if something is wrong

      start_new_session_for(user)
      redirect_to(after_authentication_url, notice: "Signed in successfully!")
    else
      # Existing password/email login
      if (user = User.authenticate_by(params.permit(:email_address, :password)))
        start_new_session_for(user)
        redirect_to(after_authentication_url)
      else
        flash.now[:alert] = "Incorrect email or password."
        render(:new, status: :unprocessable_entity)
      end
    end
  end

  def destroy
    terminate_session
    redirect_to(new_session_path)
  end
end
