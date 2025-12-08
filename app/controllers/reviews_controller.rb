# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :set_location
  before_action :set_review, only: [:update, :destroy]
  before_action :authorize_user!, only: [:update, :destroy]

  # POST /reviews or /reviews.json
  def create
    @review = current_user.reviews.build(review_params.merge(location_id: @location.id))

    respond_to do |format|
      if @review.save
        format.html { redirect_to(@location, notice: "Review was successfully created.", status: :see_other) }
        format.json { render(:show, status: :created, location: @review) }
      else
        format.html do
          @reviews = @location.reviews.order(created_at: :desc)
          flash.now[:alert] = "Review could not be saved. #{@review.errors.full_messages.join(", ")}"
          render("locations/show", status: :unprocessable_entity)
        end
        format.json { render(json: @review.errors, status: :unprocessable_entity) }
      end
    end
  end

  # PATCH/PUT /reviews/1 or /reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to(@location, notice: "Review was successfully updated.", status: :see_other) }
        format.json { render(:show, status: :ok, location: @review) }
      else
        format.html do
          @reviews = @location.reviews.order(created_at: :desc)
          flash.now[:alert] = "Review could not be updated. #{@review.errors.full_messages.join(", ")}"
          render("locations/show", status: :unprocessable_entity)
        end
        format.json { render(json: @review.errors, status: :unprocessable_entity) }
      end
    end
  end

  # DELETE /reviews/1 or /reviews/1.json
  def destroy
    @review.destroy!

    respond_to do |format|
      format.html { redirect_to(@location, notice: "Review was successfully destroyed.", status: :see_other) }
      format.json { head(:no_content) }
    end
  end

  private

  def set_location
    @location = Location.find(params[:location_id])
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("REVIEWS_CONTROLLER: Location not found for ID #{params[:location_id]}. Error: #{e.message}")
    raise e
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_review
    @review = Review.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("REVIEWS_CONTROLLER: Review not found for ID #{params[:id]}. Error: #{e.message}")
    raise e
  end

  # Only allow a list of trusted parameters through.
  def review_params
    params.require(:review).permit(:body) # Use params.require(:review).permit(:body) - CORRECTED
  end

  def authorize_user!
    unless @review.user == current_user
      Rails.logger.warn("REVIEWS_CONTROLLER: Authorization failed for user #{current_user&.id} on review #{@review&.id}")
      redirect_to(@location, alert: "You are not authorized to perform this action.")
    end
  end
end
