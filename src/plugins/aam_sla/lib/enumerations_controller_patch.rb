require_dependency 'enumerations_controller'

module EnumerationsControllerPatch
  include SlaHelper
  
  def self.included(base)
    base.send(:include, InstanceMethods)

    EnumerationsController.class_eval do
		before_filter :sla_priority_grab, :only => [:new, :edit, :create, :update]
      after_filter :sla_seconds, :only => [:create, :update]
      after_filter :update_issue_due_dates, :only => [:create, :update, :index] # Bit of a bodge, as the updates redirect to the index page
    end
  end

  module InstanceMethods
    def sla_seconds
      # Only save the seconds if we have a valid enumeration!
      return if not @enumeration.id or params[:seconds].nil? or params[:near_breach_seconds].nil?
	  
		if params[:near_breach_seconds].to_i > params[:seconds].to_i
			flash.clear
			flash[:error] = l(:bad_near_breach_seconds_warning)
			return
		end
		
      sla_priority = @enumeration.sla_priority || SlaPriority.new(:issue_priority_id => @enumeration.id)
      sla_priority.seconds = params[:seconds]
      sla_priority.near_breach_seconds = params[:near_breach_seconds].to_i #use 0 instead of null
	  
		sla_priority.save
		#Need to be able to clear sla_seconds from an existing priority,
		# so must delete its associated sla_priorty record
		sla_priority.destroy if params[:seconds].blank? && @enumeration.sla_priority
    end
	
	def sla_priority_grab
		if @enumeration.type == 'IssuePriority'
			#Build an empty sla priority if making a new issue priority
			@enumeration.build_sla_priority unless @enumeration.sla_priority
		end
	end
  end
end
