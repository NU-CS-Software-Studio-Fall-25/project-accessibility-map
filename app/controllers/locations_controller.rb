# frozen_string_literal: true

class LocationsController < ApplicationController
  # Run auth check before every action except what should remain public
  allow_unauthenticated_access only: [:index, :show]

  before_action :set_location, only: [:show, :edit, :update, :destroy, :delete_picture]
  before_action :authorize_user!, only: [:edit, :update, :destroy, :delete_picture]

  # GET /locations or /locations.json
  def index
    @locations = if params[:query].present?
      Location.search_locations(params[:query])
    else
      Location.all
    end
  end

  # GET /locations/1 or /locations/1.json
  def show
    @location = Location.find(params[:id])
    @reviews = @location.reviews.order(created_at: :desc)
    @review = @location.reviews.build
  end

  # GET /locations/new
  def new
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations or /locations.json
  def create
    @location = current_user.locations.build(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to(@location, notice: "Location was successfully created.", status: :see_other) }
        format.json { render(:show, status: :created, location: @location) }
      else
        format.html { render(:new, status: :unprocessable_entity) }
        format.json { render(json: @location.errors, status: :unprocessable_entity) }
      end
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    if params[:location][:pictures].present?
      @location.pictures.attach(params[:location][:pictures])
    end

    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to(@location, notice: "Location was successfully updated.", status: :see_other) }
        format.json { render(:show, status: :ok, location: @location) }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
        format.json { render(json: @location.errors, status: :unprocessable_entity) }
      end
    end
  end

  # DELETE /locations/1 or /locations/1.json
  def destroy
    @location.destroy!

    respond_to do |format|
      format.html { redirect_to(locations_path, notice: "Location was successfully deleted.", status: :see_other) }
      format.json { head(:no_content) }
    end
  end

  # DELETE /locations/1/delete_picture
  def delete_picture
    picture = @location.pictures.find(params[:picture_id])

    if picture.purge
      redirect_back(fallback_location: edit_location_path(@location), notice: "Image deleted successfully.")
    else
      redirect_back(fallback_location: edit_location_path(@location), alert: "Failed to delete image.")
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_location
    @location = Location.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def location_params
    params.expect(location: [:name, :address, :city, :state, :zip, :country, :latitude, :longitude, feature_ids: []])
  end

  def authorize_user!
    unless @location.user == current_user
      redirect_to(@location, alert: "You are not authorized to perform this action")
    end
  end
end
