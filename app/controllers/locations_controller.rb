# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

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
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to(@location, notice: "Location was successfully created.") }
        format.json { render(:show, status: :created, location: @location) }
      else
        format.html { render(:new, status: :unprocessable_entity) }
        format.json { render(json: @location.errors, status: :unprocessable_entity) }
      end
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
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
      format.html { redirect_to(locations_path, notice: "Location was successfully destroyed.", status: :see_other) }
      format.json { head(:no_content) }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_location
    @location = Location.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def location_params
    params.expect(location: [:name, :address, :city, :state, :zip, :country, :latitude, :longitude])
  end
end
