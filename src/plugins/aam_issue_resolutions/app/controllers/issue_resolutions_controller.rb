class IssueResolutionsController < ApplicationController
  unloadable

  #layout 'admin'

  helper :sort
  include SortHelper

  before_filter :find_project_by_project_id
  before_filter :find_issue_resolution, :only => [:edit, :update, :destroy]
  before_filter :require_admin

  def index
    @issue_resolutions = IssueResolution.all
  end

  def new
    @issue_resolution = @project.issue_resolutions.build
    @issue_resolution.safe_attributes = params[:issue_resolution]
  end
  
  def edit
  end

  def create
    @issue_resolution = @project.issue_resolutions.build
    @issue_resolution.safe_attributes = params[:issue_resolution]

    if @issue_resolution.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to_settings_in_projects
    else
      render :action => 'new'
    end
  end


  def update
    if request.put? and @issue_resolution.update_attributes(params[:issue_resolution])
      flash[:notice] = l(:notice_successful_update)
      redirect_to_settings_in_projects
    else
      render :action => 'edit'
    end
  end

  def destroy
    @issue_resolution.destroy
    redirect_to_settings_in_projects
  rescue
    flash[:error] =  l(:error_can_not_remove_issue_resolution)
    redirect_to_settings_in_projects
  end
  
  private

  def redirect_to_settings_in_projects
    redirect_to settings_project_path(@project, :tab => 'resolutions')
  end

  def issue_resolutions_destroy_confirmation_message
    message = l(:text_issue_resolutions_destroy_confirmation)
    message
  end
  
  def find_issue_resolution
    @issue_resolution = IssueResolution.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end