require_dependency 'project'

module ProjectPatch
  def self.included(base)

    base.class_eval do
      unloadable

      has_many :issue_resolutions, :dependent => :delete_all, :order => "#{IssueResolution.table_name}.name"
    end
  end
end
