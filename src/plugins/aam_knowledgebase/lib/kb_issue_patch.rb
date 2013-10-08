require_dependency 'issue'

module KbIssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
			has_and_belongs_to_many :messages, :join_table => "#{table_name_prefix}messages_issues#{table_name_suffix}"
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
	
end