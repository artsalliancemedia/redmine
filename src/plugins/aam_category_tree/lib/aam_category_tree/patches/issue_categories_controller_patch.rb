require File.dirname(__FILE__) + '/../../../app/views/helpers/aam_category_tree/issue_category_helper.rb'

module AamCategoryTree
	module Patches
		module IssueCategoriesControllerPatch
			def self.included(base) # :nodoc:
				base.extend(ClassMethods)
				base.send(:include, InstanceMethods)

				base.class_eval do
					unloadable
					alias_method_chain :new, :id_param
					helper AamCategoryTree::IssueCategoryHelper
				end
			end

			module ClassMethods
			end

			module InstanceMethods
				
				def new_with_id_param
					@parent_category = IssueCategory.find(params[:id]) if params[:id]
					new_without_id_param
				end
				
			  def move_category
			    categoryId = params[:id]
			    direction = params[:direction]
			    
          category = IssueCategory.find(categoryId)
          
          if !category.id
            flash[:notice] = l(:issue_category_not_found)
            redirect_to :controller => 'projects', :action => 'settings', :tab => 'categories', :id => @project
          end
          
          case direction
          when "top"
            raise "Only root level categories can move to the top" if !category.root?
            raise "Selected category has no siblings above it" if !category.left_sibling
            
            category.move_to_left_of category.siblings.first
          when "up"
            raise "Selected category has no siblings above it" if !category.left_sibling
            
            category.move_left
          when "down"
            raise "Selected category has no siblings below it" if !category.right_sibling
            
            category.move_right
          when "bottom"
            raise "Only root level categories can move to the bottom" if !category.root?
            raise "Selected category has no siblings below it" if !category.right_sibling
            
            category.move_to_right_of category.siblings.last
          else
            raise "Unknown direction or direction not provided"
          end
          
          flash[:notice] = l(:issue_category_successful_move)
          redirect_to :controller => 'projects', :action => 'settings', :tab => 'categories', :id => @project
        end
			end
		end
	end
end
