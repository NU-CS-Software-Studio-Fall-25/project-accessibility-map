# frozen_string_literal: true

class ReviewsController < ApplicationController
  # Run auth check before every action except what should remain public  
  allow_unauthenticated_access only: [:index, :show]
  
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
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_review
    @review = Review.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def review_params
    params.expect(review: [:body])
  end

  def authorize_user!
    unless @review.user == current_user
      redirect_to @location, alert: "You are not authorized to perform this action."
    end
  end
end
