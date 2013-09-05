require_dependency "heart/application_controller"

module Heart
  class AnnotationsController < ApplicationController
    
    def create
      fulldate = Time.at((params[:fulldate].to_i / 1000)+32400) #flot stores dates in UTC format, so have to add 9 hours to the time to get correct date
      annotation = Heart::Annotation.where(:fulldate => fulldate).first || Heart::Annotation.new(:fulldate => fulldate)
      annotation.note = params[:note]
      annotation.dashboard_id = params[:dashboard_id]
      annotation.save!
      @annotations = Heart::Annotation.visible(:from => Date.parse(params[:date_from]), :to => Date.parse(params[:date_to]))
    end

    def description
      annotation_hash = {:fulldate => '2999-12-31', :dashboard_id => params[:dashboard_id], :note => params[:note]}
      @annotation = Heart::Annotation.where(annotation_hash).first || Heart::Annotation.new(annotation_hash)
      @annotation.save!
    end
    
  end
end
