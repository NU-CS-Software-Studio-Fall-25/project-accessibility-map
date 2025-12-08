# frozen_string_literal: true

class UsersController < ApplicationController
  allow_unauthenticated_access only: [:new, :create, :show]

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def profile
    @user = current_user
  end

  def update_profile
    @user = current_user

    # Handle profile photo upload
    if params[:user][:profile_photo].present?
      @user.profile_photo.attach(params[:user][:profile_photo])
      # Clear photo_url so the uploaded photo takes precedence
      @user.photo_url = nil
    end

    if @user.update(profile_params)
      redirect_to(profile_users_path, notice: "Profile updated successfully!")
    else
      render(:profile, status: :unprocessable_entity)
    end
  end

  def create
    # Check if a user with this email already exists
    existing_user = User.find_by(email_address: params[:user][:email_address]&.strip&.downcase)

    if existing_user && existing_user.provider.present?
      # User signed up with OAuth (Google), prompt them to use that method
      flash[:alert] = "An account with this email already exists. Please sign in with Google instead."
      redirect_to(new_session_path)
      return
    end

    @user = User.new(user_params)

    # Handle profile photo upload
    if params[:user][:profile_photo].present?
      @user.profile_photo.attach(params[:user][:profile_photo])
    end

    if @user.save
      redirect_to(new_session_path, notice: "Account created successfully! Please sign in.")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email_address, :password, :password_confirmation, :profile_photo)
  end

  def profile_params
    params.require(:user).permit(:username, :profile_photo)
  end
end
