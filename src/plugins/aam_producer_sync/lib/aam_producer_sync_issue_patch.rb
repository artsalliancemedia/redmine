require_dependency 'issue'

module AamProducerSyncIssuePatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      after_destroy :save_deleted_uuid
    end
  end

  module InstanceMethods
    def save_deleted_uuid
			DeletedIssue.create(uuid: self.uuid, deleted_on: DateTime.now) if self.uuid
    end
  end
end