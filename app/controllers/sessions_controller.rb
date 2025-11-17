# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to(new_session_url, alert: "Try again later.") }

  def new
  end

  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password)))
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
