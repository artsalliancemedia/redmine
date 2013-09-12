require_dependency 'issue'

module IssuePatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    Issue.class_eval do
      before_save :sla_service
    end
  end

  module InstanceMethods
    def sla_service
      return if priority.nil?

      if priority.sla_priority.nil?
        self.due_date = nil
      else
        self.due_date = start_date + priority.sla_priority.seconds
      end
    end

    def in_breach?
      breach = not closed_on.nil? and closed_on > due_date
      breach ||= DateTime.now > due_date

      breach
    end

    def sla_status
      return if start_date.nil? or due_date.nil?

      # @todo: Add in paused status for ticket stops.
      if self.in_breach?
        l(:breach)
      end
    end
  end
end
