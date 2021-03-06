class RentalsController < ApplicationController
  before_action :require_customer
  before_action :require_video

  def create
    rental = Rental.new(customer_id: @customer.id, video_id: @video.id)

    if rental.video.available_inventory == 0
      render json: { errors: ["No available copies of the video available"] }, status: :bad_request
      return
    end

    if rental.save
      rental.customer.videos_checked_out_count += 1
      rental.customer.save
      rental.video.available_inventory -= 1
      rental.video.save
      
      render json: {
        customer_id: rental.customer_id,
        video_id: rental.video_id,
        due_date: rental.due_date,
        videos_checked_out_count: rental.customer.videos_checked_out_count,
        available_inventory: rental.video.available_inventory
      }, status: :ok

    else
      render json: {
          errors: rental.errors.messages
      }, status: :not_found
    end
  end

  def check_in
    rental = Rental.find_by(video_id: params[:video_id], customer_id: @customer.id)
    
    if rental
      rental.destroy
      rental.customer.videos_checked_out_count -= 1
      rental.customer.save
      rental.video.available_inventory += 1
      rental.video.save

      render json: {
        customer_id: rental.customer_id,
        video_id: rental.video_id,
        videos_checked_out_count: rental.customer.videos_checked_out_count,
        available_inventory: rental.video.available_inventory
      }, status: :ok

    else
      render json: {
        errors: ["No existing rental for this video and customer"]
    }, status: :not_found
    end
  end

  private

  def require_customer
    @customer = Customer.find_by(id: params[:customer_id])
    if @customer.nil?
      render json: { errors: ["Not Found"] }, status: :not_found
    end
  end

  def require_video
    @video = Video.find_by(id: params[:video_id])
    if @video.nil?
      render json: { errors: ["Not Found"] }, status: :not_found
    end
  end
end
