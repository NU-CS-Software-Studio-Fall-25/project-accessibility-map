# frozen_string_literal: true

class LocationsController < ApplicationController
  # Run auth check before every action except what should remain public
  allow_unauthenticated_access only: [:index, :show]

  before_action :set_location, only: [:show, :edit, :update, :destroy, :delete_picture, :favorite, :unfavorite]
  before_action :authorize_user!, only: [:edit, :update, :destroy, :delete_picture]

  # GET /locations or /locations.json
  def index
    # Ensure location params are always present for map centering
    # Redirect to same page with default location if not provided (HTML only)
    # For JSON requests, use defaults without redirecting
    unless params[:latitude].present? && params[:longitude].present?
      default_lat = 42.057853
      default_lng = -87.676143

      if request.format.html?
        # Redirect HTML requests to ensure map is centered from the start
        redirect_params = params.to_unsafe_h.merge(
          latitude: default_lat,
          longitude: default_lng
        ).except(:controller, :action, :format)

        redirect_to locations_path(redirect_params), allow_other_host: false
        return
      else
        # For JSON requests, set defaults without redirecting
        params[:latitude] = default_lat
        params[:longitude] = default_lng
      end
    end

    @locations = Location.paginate(page: params[:page], per_page: 10)

    # text search
    if params[:query].present?
      @locations = @locations.merge(Location.search_locations(params[:query]))
        .reorder(nil) # ← remove pg_search ORDER BY
    end

    # favorites filter
    if params[:favorites_only] == "1" && current_user
      favorite_ids = current_user.favorite_locations.pluck(:id)
      @locations = @locations.where(id: favorite_ids)
    end

    # feature filter
    if params[:feature_ids].present?
      feature_ids = params[:feature_ids].reject(&:blank?)

      @locations = @locations
        .joins(:features)
        .where(features: { id: feature_ids })
        .group("locations.id")
        .having("COUNT(DISTINCT features.id) = ?", feature_ids.count)
    end

    # Preload favorite location IDs for current user to avoid N+1 queries
    @favorite_location_ids = current_user&.favorite_locations&.pluck(:id)&.to_set || Set.new

    respond_to do |format|
      format.html
      format.json # This will automatically use index.json.jbuilder
    end
  end

  # GET /locations/1 or /locations/1.json
  def show
    @location = Location.find(params[:id])
    @reviews = @location.reviews.order(created_at: :desc)
    @review = @location.reviews.build
    @is_favorited = current_user&.favorite_locations&.include?(@location) || false

    respond_to do |format|
      format.html
      format.pdf do
        pdf = LocationPdf.new(@location, @reviews)
        send_data(
          pdf.render,
          filename: "location-#{@location.id}.pdf",
          type: "application/pdf",
          disposition: "inline",
        ) # or "attachment" to force download
      end
    end
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
    @location = current_user.locations.build(location_params_with_pictures)

    # Validate coordinates are present
    if @location.latitude.blank? || @location.longitude.blank?
      @location.errors.add(:base, "Address could not be located. Please enter a valid address.")
    end

    respond_to do |format|
      save_alt_texts
      if @location.errors.empty? && @location.save
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
    # Extract and attach new pictures separately
    new_pictures = params[:location]&.delete(:pictures)

    # Assign params to check for changes
    @location.assign_attributes(location_params)

    # Check if address fields changed and validate coordinates
    address_changed = @location.will_save_change_to_address? ||
      @location.will_save_change_to_city? ||
      @location.will_save_change_to_state? ||
      @location.will_save_change_to_zip? ||
      @location.will_save_change_to_country?

    if address_changed && (@location.latitude.blank? || @location.longitude.blank?)
      @location.errors.add(:base, "Address could not be located. Please enter a valid address.")
    end

    save_alt_texts

    respond_to do |format|
      if @location.errors.empty? && @location.save
        # Attach new pictures after update (this appends, not replaces)
        @location.pictures.attach(new_pictures) if new_pictures.present?

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

  # POST /locations/1/favorite
  def favorite
    unless current_user
      redirect_to(new_session_path, alert: "You must be logged in to favorite locations.")
      return
    end

    if current_user.favorite_locations.include?(@location)
      notice_message = "Location is already in your favorites."
    else
      current_user.favorite_locations << @location
      notice_message = "Location added to favorites."
    end

    respond_to do |format|
      format.html { redirect_back(fallback_location: @location, notice: notice_message) }
      format.json { head(:ok) }
    end
  end

  # DELETE /locations/1/unfavorite
  def unfavorite
    unless current_user
      redirect_to(new_session_path, alert: "You must be logged in to unfavorite locations.")
      return
    end

    if current_user.favorite_locations.include?(@location)
      current_user.favorite_locations.delete(@location)
      notice_message = "Location removed from favorites."
    else
      notice_message = "Location is not in your favorites."
    end

    respond_to do |format|
      format.html { redirect_back(fallback_location: @location, notice: notice_message) }
      format.json { head(:ok) }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_location
    @location = Location.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  # Note: Zip is now optional since it's not required for all countries
  def location_params
    params.expect(location: [:name, :address, :city, :state, :zip, :country, :latitude, :longitude, feature_ids: []])
  end

  # For create action: include pictures
  def location_params_with_pictures
    params.expect(location: [:name, :address, :city, :state, :zip, :country, :latitude, :longitude, feature_ids: [], pictures: []])
  end

  def authorize_user!
    unless @location.user == current_user
      redirect_to(@location, alert: "You are not authorized to perform this action")
    end
  end

  def save_alt_texts
    return unless params[:location] && params[:location][:alt_texts]

    params[:location][:alt_texts].each do |blob_id, alt_text|
      blob = ActiveStorage::Blob.find_by(id: blob_id)
      next unless blob.present?
      blob.metadata["alt_text"] = alt_text
      blob.save
    end
  end
end