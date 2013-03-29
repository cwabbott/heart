class AnnotationsController < ApplicationController
  before_filter :login_required

  def create
    annotation = Annotation.find_or_create_by_fulldate(:fulldate => Time.at((params[:fulldate].to_i / 1000)+32400))#flot stores dates in UTC format, so have to add 9 hours to the time to get correct date
    annotation.note = params[:note]
    annotation.dashboard_id = params[:dashboard_id]
    annotation.save!
    @annotations = Annotation.visible(:from => Date.parse(params[:date_from]), :to => Date.parse(params[:date_to]))
  end

  def description
    @annotation = Annotation.find_or_create_by_fulldate_and_note(:fulldate => '2999-12-31', :note => params[:note])#flot stores dates in UTC format, so have to add 9 hours to the time to get correct date
    @annotation.dashboard_id = params[:dashboard_id]
    @annotation.save!
  end
end