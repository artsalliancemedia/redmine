class SearchMessagesController < ApplicationController
  unloadable

  def index
    # Try to match this to a device.
    device = Device.find_by_id(params[:device_id])
    query_device = {:key => '1=?', :vals => [1]}
    if false and device and device.manufacturer
        query_device[:key] = "manufacturer = ? AND model = ?"
        query_device[:vals] = [device.manufacturer, device.model]
        
        if !device.software_version.to_s.empty?
            query_device[:key] += " AND (software_version LIKE ? OR software_version = '' OR software_version IS NULL)"
            query_device[:vals] << fuzzy(device.software_version)
        end
        if !device.firmware_version.to_s.empty?
            query_device[:key] += " AND (firmware_version LIKE ? OR firmware_version = '' OR firmware_version IS NULL)"
            query_device[:vals] << fuzzy(device.firmware_version)
        end
    end

    # Try to match to the category structure.

    issue_category = IssueCategory.find_by_id(params[:category_id])
    # Grab the issue category and all of it's children.
    def recurse(ic)
      return if !ic # Prevent against an invalid category

      children = IssueCategory.where('parent_id' => ic.id)
      if children.length <= 0
        return [ic.name]
      end

      ic_names = []
      children.each {|child_ic|
        ic_names.push(*recurse(child_ic)) # Push and flatten the list so we end up with a flat list of names.
      }

      return ic_names
    end

    query_issue_category = {:key => 'boards.name IN (?)', :vals => [recurse(issue_category)]}

    limit = Setting.plugin_aam_redmine_didyoumean_qa['limit'].to_i
    limit = 1 if limit < 1
    
    # First deal with Knowledge Base articles.

    base_search_keys = [query_device[:key], query_issue_category[:key]]
    base_query_vals = query_device[:vals] + query_issue_category[:vals]
    
    @articles = Message.visible
        .where(base_search_keys.compact.join(" AND "), *base_query_vals)
    @article_count = @articles.length
    @articles.slice!(limit..-1) if @article_count > limit

    # Issue specific stuff next.
    # Commented out because only care about articles for this release.

    # @query = params[:query] || ""
    # @query.strip!

    # # extract tokens from the query
    # # eg. hello "bye bye" => ["hello", "bye bye"]
    # @tokens = @query.scan(%r{((\s|^)"[\s\w]+"(\s|$)|\S+)}).collect {|m| m.first.gsub(%r{(^\s*"\s*|\s*"\s*$)}, '')}
    
    # min_length = Setting.plugin_aam_redmine_didyoumean_qa['min_word_length'].to_i
    # @tokens = @tokens.uniq.select {|w| w.length >= min_length }

    # query_variables_subject = []
    # if !@tokens.empty?
    #   token_limit = 5 #let's say
    #   @tokens.slice! token_limit..-1 if @tokens.size > token_limit

    #   @tokens.map! {|cur| '%' + cur +'%'}
    #   query_variables_subject = @tokens

    #   #union or intersection search on the subject
    #   search_query_subjects = "(" + (['lower(subject) like lower(?)'] * @tokens.length).join(' OR ') + ")"
    # end

    # query_variables_issues = []
    # issue_queries = [search_query_subjects]
    # #Issue filtering based on settings
    # if Setting.plugin_aam_redmine_didyoumean_qa['show_only_open'] == "1"
    #   valid_statuses = IssueStatus.all(:conditions => ["is_closed <> ?", true])
    #   issue_queries << "status_id in (?)"
    #   query_variables_issues << valid_statuses
    # end
    
    # # when editing an existing issue this will hold its id
    # issue_id = params[:issue_id] unless params[:issue_id].blank?
    # if !issue_id.nil?
    #   issue_queries << "issues.id != (?)"
    #   query_variables_issues << issue_id
    # end

    # search_query_issues = (issue_queries).join(" AND ") unless issue_queries.empty?

    # full_search_query_issues = (base_search_query + [search_query_issues]).compact.join(" AND ")
    # full_query_variables_issues = base_query_variables + query_variables_issues + query_variables_subject

    # @issues = Issue.visible
    #     .joins("LEFT OUTER JOIN devices on devices.id = issues.device_id")
    #     .where(full_search_query_issues, *full_query_variables_issues)
    # @issue_count = @issues.length
    # @issues.slice!(limit..-1) if @issue_count > limit


    @articles = @articles || []
    @issues = @issues || []
  
    render :json => {
          :articles => {
              :count => @article_count || 0,
              :list => @articles.map{|a| 
                  { #make a deep copy, otherwise rails3 makes weird stuff nesting the issue as mapping.
                      :id => a.id,
                      :subject => a.subject,
                      :category => a.board.name,
                      :category_id => a.board.id
                  }
              }
          },
          :issues => {
              :count => @issue_count || 0,
              :list => @issues.map{|i| 
                  {
                      :id => i.id,
                      :subject => i.subject,
                      :category => i.category.name,
                      :category_id => i.category.id,
                      :status => i.status.name
                  }
              }
          }
    }
  end
    
  private
  
  #trim a version number so it can be matched approximately
  def fuzzy version_num
    #remove numbers after the last dot (least significant version substring)
    return version_num.nil? ? '' : version_num.split('.')[0..-2].join('.') + ".%"
  end
end
