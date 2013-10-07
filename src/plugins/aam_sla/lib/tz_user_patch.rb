require_dependency 'user'

module TzUserPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
		
		base.class_eval do
			unloadable
			alias_method_chain :time_zone, :better_time_zone
		end
  end

  module InstanceMethods
    def time_zone_with_better_time_zone
			#Don't bother calling original method - we want to override it.
			#Force the User.time_zone method to return something non-nil
			# by using the default system time zone if the user has not set theirs
			@time_zone = ActiveSupport::TimeZone[self.pref.time_zone || Time.zone.name]
		end
  end
end
