require_dependency 'issue_query'

module IssueQueryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      base.add_available_column(QueryColumn.new(:sla_status))

      alias_method_chain :available_filters, :sla
    end
  end

  module InstanceMethods
    def available_filters_with_sla
      @available_filters = available_filters_without_sla

      filters = {
        "sla_status" => {
          :name => l(:sla_status),
          :order => 16,
          :type => :list,
          :values => [[l(:ok), :ok], [l(:paused), :paused], [l(:breach), :breach]]
        }
      }

      return @available_filters.merge(filters)
    end
  end
end
