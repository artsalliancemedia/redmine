class SearchMessagesController < ApplicationController
  unloadable

	#Searches articles and issues that may be relevant to an issue in the process of being created
	#The search method goes like this:
	#If device selected, only search for articles/issues with the same manufacturer and model,
	#	 and similar software & firmware version.
	#If (part) subject is known, extract tokens and use them to aid filtering by
	#  searching issue/article subjects, and article tags.
	#The tokens concept is less reliable due to possible unknown localisation factors, so is intended
	#  only as a secondary filtering action to limit a potentially large number of device-matched issues/articles.
  def index
		
		valid_query = false
		
		#First priority: search articles and issues based on the selected device, if any
		device = Device.find_by_id(params[:device_id])
		if device && device.manufacturer
			search_query_device = "manufacturer = ? AND model = ?"
			query_variables_device = [device.manufacturer, device.model]
			
			if !device.software_version.to_s.empty?
				search_query_device += " AND (software_version LIKE ? OR software_version = '' OR software_version IS NULL)"
				query_variables_device << fuzzy(device.software_version)
			end
			if !device.firmware_version.to_s.empty?
				search_query_device += " AND (firmware_version LIKE ? OR firmware_version = '' OR firmware_version IS NULL)"
				query_variables_device << fuzzy(device.firmware_version)
			end
			
			order_query_device = "software_version DESC, firmware_version DESC, model DESC"
			
			valid_query = true
		end
		
		#Second priority (for further filtering or if no device selected) is to search based on the typed subject
		@query = params[:query] || ""   
    @query.strip!

    # extract tokens from the query
    # eg. hello "bye bye" => ["hello", "bye bye"]
    @tokens = @query.scan(%r{((\s|^)"[\s\w]+"(\s|$)|\S+)}).collect {|m| m.first.gsub(%r{(^\s*"\s*|\s*"\s*$)}, '')}
    
    min_length = Setting.plugin_aam_redmine_didyoumean_qa['min_word_length'].to_i
    @tokens = @tokens.uniq.select {|w| w.length >= min_length }
		
		if !@tokens.empty?
			token_limit = 5 #let's say
      @tokens.slice! token_limit..-1 if @tokens.size > token_limit
		
			@tokens.map! {|cur| '%' + cur +'%'}
      query_variables_subject = @tokens
			
			#union or intersection search on the subject
			all_words = true
			separator = all_words ? ' AND ' : ' OR '			
      search_query_subjects = "(" + (['lower(subject) like lower(?)'] * @tokens.length).join(separator) + ")"
			
			#Tags are usually one word, so best to perform a union search
			search_query_tags = "(" + (['lower(tags.name) LIKE lower(?)'] * @tokens.length).join(" OR ") + ")"
			
			#For articles, search both tags and subject independently, i.e. union the result (don't require matches for both) 
			search_query_articles = "(" + search_query_subjects + " OR " + search_query_tags + ")"

			valid_query = true
    end
		
		if valid_query
			# pick the current project
      project = Project.find(params[:project_id]) unless params[:project_id].blank?
      
      case Setting.plugin_aam_redmine_didyoumean_qa['project_filter']
      when '2'
        project_tree = Project.all
      when '1'
        # search subprojects too
        project_tree = project ? (project.self_and_descendants.active) : nil
      when '0'
        project_tree = [project]
      end

      if project_tree
        # check permissions
        scope = project_tree.select {|p| User.current.allowed_to?(:view_messages, p)}
        search_query_project = "project_id in (?)"
        query_variables_project = [scope]
      end
			
			query_variables_issues = []
			issue_queries = []
			#Issue filtering based on settings
			if Setting.plugin_aam_redmine_didyoumean_qa['show_only_open'] == "1"
        valid_statuses = IssueStatus.all(:conditions => ["is_closed <> ?", true])
        issue_queries << "status_id in (?)"
        query_variables_issues << valid_statuses
      end
			# when editing an existing issue this will hold its id
      issue_id = params[:issue_id] unless params[:issue_id].blank?
      if !issue_id.nil?
        issue_queries << "issues.id != (?)"
        query_variables_issues << issue_id
      end
			search_query_issues = (issue_queries).join(" AND ") unless issue_queries.empty?
			
			#Finally, query
			limit = Setting.plugin_aam_redmine_didyoumean_qa['limit'].to_i
      limit = 1 if limit < 1
			
			base_search_query = [search_query_device, search_query_project]
			full_search_query_issues = (base_search_query + [search_query_issues, search_query_subjects]).compact.join(" AND ")
			full_search_query_articles = (base_search_query + [search_query_articles]).compact.join(" AND ")
			
			base_query_variables = (query_variables_device || []) + (query_variables_project || [])
			full_query_variables_issues = base_query_variables + (query_variables_issues || []) + (query_variables_subject || [])
			full_query_variables_articles = base_query_variables + ((query_variables_subject || []) * 2)
			
			@articles = Message.visible
				.joins("LEFT OUTER JOIN taggings ON taggings.taggable_id = messages.id AND taggings.taggable_type = 'Message'
								LEFT OUTER JOIN tags ON tags.id = taggings.tag_id")
				.where(full_search_query_articles, *full_query_variables_articles).order(order_query_device)
			@article_count = @articles.length
			@articles.slice!(limit..-1) if @article_count > limit

			@issues = Issue.visible
				.joins("LEFT OUTER JOIN devices on devices.id = issues.device_id")
				.where(full_search_query_issues, *full_query_variables_issues).order(order_query_device)
			@issue_count = @issues.length
			@issues.slice!(limit..-1) if @issue_count > limit
		
      # order by decreasing creation time. Some relevance sort would be a lot more appropriate here
#      @messages = @messages.sort {|a,b| b.id <=> a.id}

		else
			#prevent nil errors below
      @articles = []
      @issues = []
			@article_count = 0
			@issue_count = 0
		end
  
    render :json => {
			:articles => {
				:count => @article_count,
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
				:count => @issue_count,
				:list => @issues.map{|i| 
					{
						:id => i.id,
						:subject => i.subject,
						:status_name => i.status.name,
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
