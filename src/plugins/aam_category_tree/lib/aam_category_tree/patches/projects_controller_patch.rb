require File.dirname(__FILE__) + '/../../../app/views/helpers/aam_category_tree/issue_category_helper.rb'

module AamCategoryTree
	module Patches
		module ProjectsControllerPatch
			def self.included(base) # :nodoc:
				base.extend(ClassMethods)
				base.send(:include, InstanceMethods)

				base.class_eval do
					unloadable

					helper AamCategoryTree::IssueCategoryHelper
				end
			end

			module ClassMethods
			end

			module InstanceMethods
			end
		end
	end
end
