class DemographicsController < ApplicationController
  def update
    demographic = Demographic.find(params[:id])
    demographic.status = params[:status]
    respond_to do |format|
      if demographic.update_attributes(params[:demographic])
        if demographic.status.to_i == 0
          format.html { redirect_to(segments_path) }
        else
          format.html { redirect_to(edit_segment_path(demographic), :notice => "Updated at #{Time.now.to_s}.") }
          format.xml  { head :ok }
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => demographic.errors, :status => :unprocessable_entity }
      end
    end
  end
end
