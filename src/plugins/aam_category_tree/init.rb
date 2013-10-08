require 'redmine'

Redmine::Plugin.register :aam_category_tree do
	name 'AAM Issue Category Tree'
	author 'Arts Alliance Media'
	description 'Adds ability for arbitrary nesting of categories so issues can be categorised more usefully and completely.
		Based on "Redmine Category Tree" by Brett Patterson'
	version '0.0.1'
	author_url 'http://artsalliancemedia.com'
	
	permission :move_category, :issue_categories => :move_category

	requires_redmine :version_or_higher => '2.0.3'
end

require 'aam_category_tree/hooks/aam_category_tree_hooks'

ActionDispatch::Callbacks.to_prepare do
	require_dependency 'issue_category'
	unless IssueCategory.included_modules.include?(AamCategoryTree::Patches::IssueCategoryPatch)
		IssueCategory.send(:include, AamCategoryTree::Patches::IssueCategoryPatch)
	end

	require_dependency 'issues_controller'
	unless IssuesController.included_modules.include?(AamCategoryTree::Patches::IssuesControllerPatch)
		IssuesController.send(:include, AamCategoryTree::Patches::IssuesControllerPatch)
	end

	require_dependency 'issue_categories_controller'
	unless IssueCategoriesController.included_modules.include?(AamCategoryTree::Patches::IssueCategoriesControllerPatch)
		IssueCategoriesController.send(:include, AamCategoryTree::Patches::IssueCategoriesControllerPatch)
	end

	require_dependency 'project'
	unless Project.included_modules.include?(AamCategoryTree::Patches::ProjectPatch)
		Project.send(:include, AamCategoryTree::Patches::ProjectPatch)
	end
	
	require_dependency 'reports_controller'
  unless ReportsController.included_modules.include?(AamCategoryTree::Patches::ReportsControllerPatch)
    ReportsController.send(:include, AamCategoryTree::Patches::ReportsControllerPatch)
  end

	require_dependency 'queries_helper'
	unless QueriesHelper.included_modules.include?(AamCategoryTree::Patches::QueriesHelperPatch)
		QueriesHelper.send(:include, AamCategoryTree::Patches::QueriesHelperPatch)
	end

	require_dependency 'issues_helper'
	unless IssuesHelper.included_modules.include?(AamCategoryTree::Patches::IssuesHelperPatch)
		IssuesHelper.send(:include, AamCategoryTree::Patches::IssuesHelperPatch)
	end
end
