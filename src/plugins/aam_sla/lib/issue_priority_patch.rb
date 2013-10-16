require_dependency 'issue_priority'

module IssuePriorityPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    IssuePriority.class_eval do
      default_scope :include => :sla_priority
      has_one :sla_priority # Give us a way of reference the priority if we already have the enumeration.
      before_save :notify_change
    end
  end

  module InstanceMethods
		def notify_change
			save_path = Rails.root.join('plugins', 'aam_sla', 'assets', "changetime.stor").to_s
			file = open(save_path, 'w')
			file.write Time.now.to_s
			file.close
		end
  end
end
