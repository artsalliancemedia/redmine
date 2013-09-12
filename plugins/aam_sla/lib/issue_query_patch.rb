require_dependency 'issue_query'

module IssueQueryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      base.add_available_column(QueryColumn.new(:sla_status))

      alias_method_chain :available_filters, :sla

      # Used to override the SQL generated for the issue filter field.
      def sql_for_sla_status_field(field, operator, value)
        # op = operator == "!" ? 'NOT' : ''
        # "(#{Issue.table_name}.cinema_id #{op} IN (SELECT DISTINCT cinemas_circuit_groups.cinema_id FROM cinemas_circuit_groups " +
        #   "WHERE cinemas_circuit_groups.circuit_group_id IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")))"
        "1=1"
      end
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
