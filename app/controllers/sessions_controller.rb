# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to(new_session_url, alert: "Try again later.") }

  def new
  end

  def create
    if (auth_hash = request.env["omniauth.auth"])

      def generate_compliant_password
        lowercase = ("a".."z").to_a.sample
        uppercase = ("A".."Z").to_a.sample
        digit     = ("0".."9").to_a.sample
        special   = ["!", "@", "#", "$", "%", "^", "&", "*"].sample
        filler    = SecureRandom.alphanumeric(20) # fills the rest
        # Shuffle so required characters aren't predictable
        (lowercase + uppercase + digit + special + filler).chars.shuffle.join
      end

      # OmniAuth login
      # First, try to find user by provider/uid (existing OAuth user)
      user = User.find_by(provider: auth_hash.provider, uid: auth_hash.uid)

      # If not found, check if a user exists with this email (account merging)
      if user.nil?
        user = User.find_by(email_address: auth_hash.info.email)

        # If user exists with this email, link the OAuth credentials
        if user
          user.provider = auth_hash.provider
          user.uid = auth_hash.uid
          # Don't touch password - keep existing password for email/password login
          # Don't overwrite username/photo for existing accounts
          user.save!(validate: false) # Skip validations to avoid password issues
        else
          # New user - create from scratch
          user = User.new(
            provider: auth_hash.provider,
            uid: auth_hash.uid,
            email_address: auth_hash.info.email,
            password: generate_compliant_password,
            username: auth_hash.info.name || auth_hash.info.email.split("@").first,
            photo_url: auth_hash.info.image,
          )
          user.save!
        end
      else
        # Existing OAuth user - just update email
        user.email_address = auth_hash.info.email
        user.save!(validate: false)
      end

      start_new_session_for(user)
      redirect_to(after_authentication_url, notice: "Signed in successfully!")
    elsif (user = User.authenticate_by(params.permit(:email_address, :password)))
      # Existing password/email login
      start_new_session_for(user)
      redirect_to(after_authentication_url)
    else
      flash.now[:alert] = "Incorrect email or password."
      render(:new, status: :unprocessable_entity)
    end
  end

  def destroy
    terminate_session
    redirect_to(new_session_path)
  end
end
