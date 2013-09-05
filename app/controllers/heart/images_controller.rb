require_dependency "heart/application_controller"

module Heart
  class ImagesController < ApplicationController
    def create
      image = Heart::Image.new
      image.dashboard_id = params[:dashboard_id]
      image.purpose = params[:purpose]
      image.dataurl = params[:dataurl]
      image.save
      render :json => { :result => 'success', :id => image.id }
    end

    def show
      image = Heart::Image.find(params[:id])
      send_data Base64.decode64(image.dataurl.split(",")[1]), :type => 'image/png', :disposition => 'inline'
    end
  end
end
