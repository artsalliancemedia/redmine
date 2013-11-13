class ResolutionTreesController < ApplicationController
  def drop_downs_for_tree
    @issue_resolution = IssueResolution.find(params[:id]) if params[:id].to_i > 0
    @use_blank_for_root = !params[:no_blank]
    render layout: false
  end
end