module AamCategoryTree
	module Hooks
		class AamCategoryTreeHooks < Redmine::Hook::ViewListener
			
			render_on :view_issues_form_details_top, :partial => 'edit_category_hook'
			
			def view_layouts_base_html_head(context = {})
				css = stylesheet_link_tag 'aam_category_tree.css', :plugin => 'aam_category_tree'

				css
			end
		end
	end
end
