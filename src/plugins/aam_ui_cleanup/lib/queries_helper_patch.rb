require_dependency 'queries_helper'

module QueriesHelperPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable

      alias_method_chain :filters_options, :uicleanup
    end
  end

  module InstanceMethods

    def filters_options_with_uicleanup(opts)
      options = filters_options_without_uicleanup(opts)

      unneeded_fields = ["tracker_id","is_private","relates","duplicates","duplicated","blocks","blocked","precedes","follows","copied_to","copied_from"]
      options.select! {|o| !unneeded_fields.include?(o[1].to_s) }

      options
    end
  end
end
