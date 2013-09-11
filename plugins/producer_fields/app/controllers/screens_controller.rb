class ScreensController < ApplicationController
  unloadable

  layout 'admin'

  helper :sort
  include SortHelper

  before_filter :find_screen, :only => [:edit, :update, :destroy]

  def index
    sort_init ['cinemas.name', 'identifier']
    sort_update %w(identifier cinemas.name)
    @screen_pages, @screens = paginate Screen.unscoped.includes(:cinema).order(sort_clause), :per_page => 25
  end

  def new
    @screen = Screen.new
    @cinemas = Cinema.find(:all)
  end

  def get_devices
    devices = Screen.find_by_id(params[:id]).devices.select('devices.id as id, category').order('category')
    devices.each do |device|
      device.category = t(device.category) # Translate to local language.
    end

    render json: devices
  end

  def edit
    @cinemas = Cinema.find(:all)
  end

  def create
    @screen = Screen.new(params[:screen])

    if request.post? && @screen.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to screens_path
    else
      @screens = Screen.all
      render :action => 'new'
    end
  end

  def update
    if request.put? and @screen.update_attributes(params[:screen])
      flash[:notice] = l(:notice_successful_update)
      redirect_to screens_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @screen.destroy
    redirect_to screens_path
  rescue
    flash[:error] =  l(:error_can_not_remove_screen)
    redirect_to screens_path
  end

  private

  def screens_destroy_confirmation_message
    message = l(:text_screens_destroy_confirmation)
    message
  end

  def find_screen
    @screen = Screen.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
