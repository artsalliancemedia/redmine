require_dependency 'message'

module KbMessagePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
			#need to specify join table due to inverse lexical ordering of class names, see
			#http://guides.rubyonrails.org/association_basics.html#creating-join-tables-for-has-and-belongs-to-many-associations
			has_and_belongs_to_many :issues, :join_table => "#{table_name_prefix}messages_issues#{table_name_suffix}"
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
	
end