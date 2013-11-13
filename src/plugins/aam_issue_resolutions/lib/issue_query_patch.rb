require_dependency 'issue_query'

module IssueQueryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      base.add_available_column(QueryColumn.new(:resolution, :sortable => "#{IssueResolution.table_name}.name", :groupable => false))

      alias_method_chain :available_filters, :resolution_field
      alias_method_chain :issues, :resolution_field
    end
  end

  module InstanceMethods
    def available_filters_with_resolution_field
      @available_filters = available_filters_without_resolution_field

      # Double definition because I don't have time to work out how to import this properly from the helpers file, sorry!
      def issue_resolutions_options_for_select(issue_resolutions)
        options = []
        IssueResolution.resolution_tree(issue_resolutions) do |resolution, level|
          label = (level > 0 ? '     ' * 2 * level + '» ' : '').html_safe
          label << resolution.name
          options << [label, resolution.id.to_s] # Cast to string to stop type mismatches later on.
        end
        options
      end

      filters = {
        "resolution_id" => {
          :name => l(:field_resolution),
          :order => 18,
          :type => :list,
          :values => issue_resolutions_options_for_select(IssueResolution.all)
        }
      }

      return @available_filters.merge(filters)
    end

    def issues_with_resolution_field(options={})
      options[:include] = (options[:include] || []) + [:resolution]
      issues = issues_without_resolution_field(options)
    end
  end
end
