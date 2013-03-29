class CohortsController < ApplicationController
  def create
    cohort = Cohort.new
    cohort.name = params[:name]
    cohort.definition = params[:definition]
    cohort.start_date = params[:start_date]
    cohort.status = 1
    cohort.save
    redirect_to segments_path
  end
end