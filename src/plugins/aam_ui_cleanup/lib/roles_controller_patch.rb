require_dependency 'roles_controller'

module RolesControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable

      alias_method_chain :permissions, :uicleanup
    end
  end

  module InstanceMethods

    def permissions_with_uicleanup
      permissions_without_uicleanup

      unneeded_modules = ["files", "wiki", "time_tracking", "repository", "calendar", "gantt", "documents", "news"]
      @permissions.select! {|p| !unneeded_modules.include?(p.project_module.to_s) }

      unneeded_perms = ["add_project", "edit_project", "close_project", "select_project_modules", "manage_members", "manage_modules", "manage_versions", "add_subprojects", "move_category", "vote_messages", "set_issues_private", "set_own_issues_private", "manage_issue_relations", "manage_subtasks", "view_private_notes", "set_notes_private", "manage_public_queries", "move_issues"]
      @permissions.select! {|p| !unneeded_perms.include?(p.name.to_s) }
    end
  end
end
