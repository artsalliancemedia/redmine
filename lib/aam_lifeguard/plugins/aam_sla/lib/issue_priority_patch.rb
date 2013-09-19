require_dependency 'issue_priority'

module IssuePriorityPatch
  def self.included(base)
    IssuePriority.class_eval do
      default_scope :include => :sla_priority
      has_one :sla_priority # Give us a way of reference the priority if we already have the enumeration.
    end
  end
end
