# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :set_location
  before_action :set_review, only: [:update, :destroy]
  before_action :authorize_user!, only: [:update, :destroy]

  # POST /reviews or /reviews.json
  def create
    Rails.logger.debug "REVIEWS_CONTROLLER: create action started."
    Rails.logger.debug "REVIEWS_CONTROLLER: @location ID: #{@location&.id.inspect}"
    Rails.logger.debug "REVIEWS_CONTROLLER: current_user ID: #{current_user&.id.inspect}"

    @review = current_user.reviews.build(review_params.merge(location_id: @location.id))

    respond_to do |format|
      if @review.save
        Rails.logger.debug "REVIEWS_CONTROLLER: Review saved successfully. Redirecting to #{@location.id}"
        format.html { redirect_to(@location, notice: "Review was successfully created.", status: :see_other) }
        format.json { render(:show, status: :created, location: @review) }
      else
        Rails.logger.debug "REVIEWS_CONTROLLER: Review failed to save. Errors: #{@review.errors.full_messages.inspect}"
        format.html do
          @reviews = @location.reviews.order(created_at: :desc)
          render("locations/show", status: :unprocessable_entity)
        end
        format.json { render(json: @review.errors, status: :unprocessable_entity) }
      end
    end
  end

  # PATCH/PUT /reviews/1 or /reviews/1.json
  def update
    Rails.logger.debug "REVIEWS_CONTROLLER: update action started for review ID: #{@review.id}"
    respond_to do |format|
      if @review.update(review_params)
        Rails.logger.debug "REVIEWS_CONTROLLER: Review updated successfully. Redirecting to #{@location.id}"
        format.html { redirect_to(@location, notice: "Review was successfully updated.", status: :see_other) }
        format.json { render(:show, status: :ok, location: @review) }
      else
        Rails.logger.debug "REVIEWS_CONTROLLER: Review failed to update. Errors: #{@review.errors.full_messages.inspect}"
        format.html do
          @reviews = @location.reviews.order(created_at: :desc)
          render("locations/show", status: :unprocessable_entity)
        end
        format.json { render(json: @review.errors, status: :unprocessable_entity) }
      end
    end
  end

  # DELETE /reviews/1 or /reviews/1.json
  def destroy
    Rails.logger.debug "REVIEWS_CONTROLLER: destroy action started for review ID: #{@review.id}"
    @review.destroy!
    Rails.logger.debug "REVIEWS_CONTROLLER: Review destroyed successfully. Redirecting to #{@location.id}"

    respond_to do |format|
      format.html { redirect_to(@location, notice: "Review was successfully destroyed.", status: :see_other) }
      format.json { head(:no_content) }
    end
  end

  private

  def set_location
    Rails.logger.debug "REVIEWS_CONTROLLER: set_location called. params[:location_id]: #{params[:location_id].inspect}"
    @location = Location.find(params[:location_id])
    Rails.logger.debug "REVIEWS_CONTROLLER: @location found: #{@location&.id.inspect}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "REVIEWS_CONTROLLER: Location not found for ID #{params[:location_id]}. Error: #{e.message}"
    raise e # Re-raise the error to confirm it's the source of the 404
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_review
    Rails.logger.debug "REVIEWS_CONTROLLER: set_review called. params[:id]: #{params[:id].inspect}"
    @review = Review.find(params[:id]) # Use params[:id] directly, not params.expect(:id) - CORRECTED
    Rails.logger.debug "REVIEWS_CONTROLLER: @review found: #{@review&.id.inspect}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "REVIEWS_CONTROLLER: Review not found for ID #{params[:id]}. Error: #{e.message}"
    raise e
  end

  # Only allow a list of trusted parameters through.
  def review_params
    params.require(:review).permit(:body) # Use params.require(:review).permit(:body) - CORRECTED
  end

  def authorize_user!
    Rails.logger.debug "REVIEWS_CONTROLLER: authorize_user! called for review ID: #{@review&.id}"
    unless @review.user == current_user
      Rails.logger.warn "REVIEWS_CONTROLLER: Authorization failed for user #{current_user&.id} on review #{@review&.id}"
      redirect_to @location, alert: "You are not authorized to perform this action."
    end
  end
end
