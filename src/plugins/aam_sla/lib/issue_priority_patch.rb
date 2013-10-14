require_dependency 'issue_priority'

module IssuePriorityPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    
    IssuePriority.class_eval do
      default_scope :include => :sla_priority
      has_one :sla_priority # Give us a way of reference the priority if we already have the enumeration.
      before_save :update_issue_due_dates
    end
  end

  module InstanceMethods
    def update_issue_due_dates
      Issue.all.each do |issue|
        unless issue.status.is_closed
          issue.save_due_date
        end
      end
    end
  end
end
