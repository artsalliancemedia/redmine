class PausesController < ApplicationController
  before_filter :find_pause, :only => [:edit, :destroy]
  before_filter :find_issue, :only => [:show]

  def find_pause
    @pause = Pause.find(params[:id])
  end

  def create
    @pause = Pause.new(:issue_id => params[:issue_id], :start_date => DateTime.now)
  end

  def show
    @pauses = Pause.all.select{|p| p.issue_id == @issue.id}
  end
end