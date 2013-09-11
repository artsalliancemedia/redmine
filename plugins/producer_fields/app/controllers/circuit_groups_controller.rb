class CircuitGroupsController < ApplicationController
  unloadable

  layout 'admin'

  helper :sort
  include SortHelper

  before_filter :find_circuit_group, :only => [:edit, :update, :destroy]

  def index
    sort_init 'name'
    sort_update %w(name)
    @circuit_group_pages, @circuit_groups = paginate CircuitGroup.unscoped.order(sort_clause), :per_page => 25
  end

  def new
    @circuit_group = CircuitGroup.new
  end

  def create
    @circuit_group = CircuitGroup.new(params[:circuit_group])

    if request.post? && @circuit_group.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to circuit_groups_path
    else
      render :action => 'new'
    end
  end

  def update
    if request.put? and @circuit_group.update_attributes(params[:circuit_group])
      flash[:notice] = l(:notice_successful_update)
      redirect_to circuit_groups_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @circuit_group.destroy
    redirect_to circuit_groups_path
  rescue
    flash[:error] =  l(:error_can_not_remove_circuit_group)
    redirect_to circuit_groups_path
  end
  
  private

  def circuit_groups_destroy_confirmation_message
    message = l(:text_circuit_groups_destroy_confirmation)
    message
  end
  
  def find_circuit_group
    @circuit_group = CircuitGroup.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
