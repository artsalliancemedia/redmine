class CategoryTreesController < ApplicationController
	def drop_downs_for_tree
		@category = IssueCategory.find(params[:id]) if params[:id].to_i > 0
		@use_blank_for_root = !params[:no_blank]
		@category_ignore = IssueCategory.find(params[:id_ignore]) if params[:id_ignore].to_i > 0
		render layout: false
	end
end