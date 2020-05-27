class VideosController < ApplicationController
  def index
    videos = Video.all.as_json(only: [:id, :title, :release_date, :available_inventory])
    render json: videos, status: :ok
  end

  def show
    video = Video.find_by(id: params[:id])

    if video
      render json: video.as_json(
        only: [:title, :overview, :release_date, :total_inventory, :available_inventory]
      )
      return
    else 
      render json: { ok: false, errors: ["Unable to find the video with id #{params[:id]}"] }, status: :not_found
      return
    end
  end
end
