module AamCategoryTree
	module Patches
		module IssuesHelperPatch
			def self.included(base)
				base.extend(ClassMethods)
				base.send(:include, InstanceMethods)

				base.class_eval do
				  unloadable
				  include AamCategoryTree::IssueCategoryHelper
				end
			end

			module ClassMethods
			end

			module InstanceMethods
			end
		end
	end
end
