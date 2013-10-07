require_dependency 'enumerations_controller'

module EnumerationsControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    EnumerationsController.class_eval do
      after_filter :sla_seconds, :only => [:create, :update]
    end
  end

  module InstanceMethods
    def sla_seconds
      # Only save the seconds if we have a valid enumeration!
      return if not @enumeration.id or params[:seconds].nil?

      sla_priority = @enumeration.sla_priority || SlaPriority.new(:issue_priority_id => @enumeration.id)
      sla_priority.seconds = params[:seconds]
      sla_priority.save
    end
  end
end
