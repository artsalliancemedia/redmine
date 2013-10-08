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
        value = value.kind_of?(Array) ? value : [value]

        clauses = []
        value.each do |val|
          case val.to_sym
          # Sadly have to mirror in_breach, paused?, ok? functions found in the issue_patch file.
          when :ok
            clauses << "(#{Issue.table_name}.due_date IS NULL OR #{Issue.table_name}.due_date >= '#{DateTime.now.to_s}'" +
										"OR (#{Issue.table_name}.closed_on IS NOT NULL AND #{Issue.table_name}.closed_on <= #{Issue.table_name}.due_date))"
          when :paused
            clauses << "FALSE" #TODO - pause feature not yet implemented
          when :breach
            clause = "(#{Issue.table_name}.due_date IS NOT NULL AND (" +
										 "(#{Issue.table_name}.closed_on IS NOT NULL AND #{Issue.table_name}.closed_on > #{Issue.table_name}.due_date)" +
									 "OR (#{Issue.table_name}.closed_on IS NULL AND '#{DateTime.now.to_s}' > #{Issue.table_name}.due_date)) )"

            clauses << clause
          end
        end

				op = operator == "!" ? 'NOT ' : ''
        sql = op + "(" + clauses.join(" OR ") + ")"
        sql
      end
    end
  end

  module InstanceMethods
    def available_filters_with_sla
      @available_filters = available_filters_without_sla
			
			#Remove (unwanted) tracker filter from the list
			delete_available_filter "tracker_id"

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
