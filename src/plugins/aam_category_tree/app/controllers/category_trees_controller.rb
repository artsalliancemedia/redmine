class CategoryTreesController < ApplicationController
	def drop_downs_for_tree
		@category = IssueCategory.find(params[:id]) if params[:id].to_i > 0
		render layout: false
	end
end