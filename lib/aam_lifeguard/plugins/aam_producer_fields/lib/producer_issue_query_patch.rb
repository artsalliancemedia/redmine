require_dependency 'issue_query'

module ProducerIssueQueryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      base.add_available_column(QueryColumn.new(:cinema, :sortable => "#{Cinema.table_name}.name", :groupable => true))
      base.add_available_column(QueryColumn.new(:screen))
      base.add_available_column(QueryColumn.new(:device, :sortable => "#{Device.table_name}.category", :groupable => true))

      alias_method_chain :available_filters, :producer_fields
      alias_method_chain :issues, :producer_fields

      # Used to override the SQL generated for the issue filter field, required because we need to do a sub-query to the CinemaCircuitGroup table.
      def sql_for_circuit_group_id_field(field, operator, value)
        op = operator == "!" ? 'NOT' : ''
        "(#{Issue.table_name}.cinema_id #{op} IN (SELECT DISTINCT cinemas_circuit_groups.cinema_id FROM cinemas_circuit_groups " +
          "WHERE cinemas_circuit_groups.circuit_group_id IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")))"
      end
    end
  end

  module InstanceMethods
    def available_filters_with_producer_fields
      @available_filters = available_filters_without_producer_fields

      filters = {
        "cinema_id" => {
          :name => l(:cinema),
          :order => 14,
          :type => :list,
          :values => Cinema.order('name ASC').collect { |c| [c.name, c.id.to_s] }
        },
        "circuit_group_id" => {
          :name => l(:circuit_group),
          :order => 15,
          :type => :list,
          :values => CircuitGroup.order('name ASC').collect { |cg| [cg.name, cg.id.to_s] }
        }
      }

      return @available_filters.merge(filters)
    end

    def issues_with_producer_fields(options={})
      options[:include] = (options[:include] || []) + [:cinema, :device]
      issues = issues_without_producer_fields(options)
    end
  end
end
