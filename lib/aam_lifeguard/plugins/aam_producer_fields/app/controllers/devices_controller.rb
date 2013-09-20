class DevicesController < ApplicationController
  unloadable

  layout 'admin'

  helper :sort
  include SortHelper

  before_filter :find_device, :only => [:edit, :update, :destroy]

  def index
    sort_init ['cinema_name', ['screen_identifier', 'desc']]
    sort_update 'category' => "devices.category",
                  'screen_identifier' => "screens.identifier",
                  'cinema_name' => "COALESCE(cin.name, cinemas.name)"
    @device_pages, @devices = paginate Device.unscoped.joins("LEFT OUTER JOIN \"screens\" ON \"devices\".\"deviceable_id\" = \"screens\".\"id\" AND \"devices\".\"deviceable_type\" = 'Screen'
    LEFT OUTER JOIN \"cinemas\" as \"cin\" ON \"screens\".\"cinema_id\" = \"cin\".\"id\"
    LEFT OUTER JOIN \"cinemas\" ON \"devices\".\"deviceable_id\" = \"cinemas\".\"id\" AND \"devices\".\"deviceable_type\" = 'Cinema'
    ").order(sort_clause), :per_page => 25
  end

  def new
    @device = Device.new
  end

  def edit
    @screens = Screen.find(:all)
  end

  def create
    @device = Device.new(params[:device])

    if request.post? && @device.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to devices_path
    else
      @devices = Device.all
      render :action => 'new'
    end
  end

  def update
    if request.put? and @device.update_attributes(params[:device])
      flash[:notice] = l(:notice_successful_update)
      redirect_to devices_path
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @device.destroy
    redirect_to devices_path
  rescue
    flash[:error] =  l(:error_can_not_remove_screen)
    redirect_to devices_path
  end
  
  private

  def devices_destroy_confirmation_message
    message = l(:text_devices_destroy_confirmation)
    message
  end

  def find_device
    @device = Device.unscoped.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
