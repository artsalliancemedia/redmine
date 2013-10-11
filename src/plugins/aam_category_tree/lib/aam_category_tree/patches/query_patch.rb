module AamCategoryTree
	module Patches
		module QueryPatch
			def self.included(base) # :nodoc:
				base.extend(ClassMethods)
				base.send(:include, InstanceMethods)

				base.class_eval do
					unloadable
					alias_method_chain :add_filter, :category
				end
			end

			module ClassMethods
			end

			module InstanceMethods
				def add_filter_with_category(field, operator, values=nil)
					if(field == 'category_id' && !values.nil? && values.is_a?(Array))
						#parent category is always top, so can simply access index 0
						values = IssueCategory.find(values[0].to_s)
																	.self_and_descendants
																	.collect { |cat| cat.id.to_s }
											
					end
					add_filter_without_category(field, operator, values)
				end
			end
		end
	end
end
