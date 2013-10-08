class WorkingPeriodsController < ApplicationController
  unloadable

  layout 'admin'

  before_filter :find_working_period, :only => [:edit, :update, :destroy]

  def index
    @adjusted_working_periods = []
    WorkingPeriod.all.each do |wp|
      adjusted_wps = wp.adjust_for_current_time_zone
      adjusted_wps.each do |adjusted_wp|
        @adjusted_working_periods.push([adjusted_wp,wp]) # Need to store original WorkingPeriod to get delete path
      end
    end
    @adjusted_working_periods = @adjusted_working_periods.sort_by{|wp| [wp[0].day, wp[0].start_time.hour, wp[0].start_time.min]}
  end

  def new
    @working_period = WorkingPeriod.new
  end

  def create
    @working_period = WorkingPeriod.new(params[:working_period])

    if(@working_period.start_time.blank?)
      raise l(:error_no_start_time)
    elsif(@working_period.end_time.blank?)
      raise l(:error_no_end_time)
    end
    
    if @working_period.time_zone.blank? # If combo box was left blank get user time zone
      if User.current.pref.time_zone.blank? # If user time zone not specified, use system time zone
        @working_period.time_zone = Time.zone.name
      else
        @working_period.time_zone = User.current.pref.time_zone
      end
    end
    if WorkingPeriod.count != 0 && (WorkingPeriod.first.time_zone != @working_period.time_zone)
      raise l(:error_invalid_time_zone)
    end

    if @working_period.start_time >= @working_period.end_time
      raise l(:error_duration_not_positive)
    end

    # Check for working period overlap
    WorkingPeriod.all.each do |wp|
      # Need to parse times using Time.at as dates will screw up comparisons
      wp1_start = Time.at(@working_period.start_time.hour * 60 * 60 + @working_period.start_time.min * 60 + @working_period.start_time.sec)
      wp1_end = Time.at(@working_period.end_time.hour * 60 * 60 + @working_period.end_time.min * 60 + @working_period.end_time.sec)
      wp2_start = Time.at(wp.start_time.hour * 60 * 60 + wp.start_time.min * 60 + wp.start_time.sec)
      wp2_end = Time.at(wp.end_time.hour * 60 * 60 + wp.end_time.min * 60 + wp.end_time.sec)
      if @working_period.day == wp.day &&
          (((wp1_start < wp2_end) && (wp1_start > wp2_start)) ||
           ((wp1_end < wp2_end) && (wp1_end > wp2_start)) ||
           (wp1_start == wp2_start) || (wp1_end == wp2_end))
        raise l(:error_working_period_overlap)
      end
    end

    if request.post? && @working_period.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to working_periods_path
    else
      @working_periods = WorkingPeriod.all
      render :action => 'new'
    end
    
  rescue Exception => e
    flash[:error] = e.message
    redirect_to :action => 'new'
  end

  def update
  end

  def destroy
    @working_period.destroy
    redirect_to working_periods_path
  rescue
    flash[:error] =  l(:error_can_not_remove_working_periods)
    redirect_to working_periods_path
  end

  private

  def find_working_period
    @working_period = WorkingPeriod.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
