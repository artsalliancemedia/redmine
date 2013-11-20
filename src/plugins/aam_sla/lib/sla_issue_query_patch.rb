require_dependency 'issue_query'

module SlaIssueQueryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      base.add_available_column(QueryColumn.new(:sla_status))

      alias_method_chain :available_filters, :sla

      # Used to override the SQL generated for the issue filter field.
      def sql_for_sla_status_field(field, operator, value)
        value = value.kind_of?(Array) ? value : [value]
        
        clause_breach = "(#{Issue.table_name}.due_date IS NOT NULL AND (" +
             "(#{Issue.table_name}.closed_on IS NOT NULL AND #{Issue.table_name}.closed_on > #{Issue.table_name}.due_date)" +
             "OR (#{Issue.table_name}.closed_on IS NULL AND '#{DateTime.now.to_s}' > #{Issue.table_name}.due_date)) )"

        clause_nrbreach = "(#{Issue.table_name}.closed_on IS NULL AND '#{DateTime.now.to_s}' > #{Issue.table_name}.near_breach_date)"

        clause_paused = "(#{Issue.table_name}.is_paused)"

        clauses = []
        value.each do |val|
          case val.to_sym
          # Sadly have to mirror sla_based functions found in the issue_patch file.
          when :breach
            clauses << clause_breach
          when :near_breach
            clauses << "(NOT #{clause_breach} AND #{clause_nrbreach})"
          when :paused
            clauses << clause_paused
          when :ok
            clauses << "(NOT #{clause_breach} AND NOT #{clause_paused} AND NOT #{clause_nrbreach})"
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
          :values => [[l(:ok), :ok], [l(:paused), :paused], [l(:breach), :breach], [l(:near_breach), :near_breach]]
        }
      }

      return @available_filters.merge(filters)
    end
  end
end
