class CategoryTreesController < ApplicationController
	def drop_downs_for_tree
		@category = IssueCategory.find(params[:id]) if params[:id].to_i > 0
		@use_blank_for_root = !params[:no_blank]
		render layout: false
	end
end