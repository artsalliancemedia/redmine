class SearchMessagesController < ApplicationController
  unloadable

  def index
  
    @query = params[:query] || ""   
    @query.strip!

    logger.debug "Got request for [#{@query}]"
    logger.debug "Did you mean settings: #{Setting.plugin_aam_redmine_didyoumean_qa.to_json}"

    all_words = true # if true, returns records that contain all the words specified in the input query

    # extract tokens from the query
    # eg. hello "bye bye" => ["hello", "bye bye"]
    @tokens = @query.scan(%r{((\s|^)"[\s\w]+"(\s|$)|\S+)}).collect {|m| m.first.gsub(%r{(^\s*"\s*|\s*"\s*$)}, '')}
    
    min_length = Setting.plugin_aam_redmine_didyoumean_qa['min_word_length'].to_i
    @tokens = @tokens.uniq.select {|w| w.length >= min_length }

    if !@tokens.empty?
      # no more than 5 tokens to search for
      # this is probably too strict, in this use case
      @tokens.slice! 5..-1 if @tokens.size > 5

      if all_words
        separator = ' AND '
      else
        separator = ' OR '
      end

      @tokens.map! {|cur| '%' + cur +'%'}

      conditions = (['lower(subject) like lower(?)'] * @tokens.length).join(separator)
      variables = @tokens

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
      else
        logger.warn "Unrecognized option for project filter: [#{Setting.plugin_aam_redmine_didyoumean_qa['project_filter']}], skipping"
      end

      if project_tree
        # check permissions
        scope = project_tree.select {|p| User.current.allowed_to?(:view_messages, p)}
        logger.debug "Set project filter to #{scope}"
        conditions += " AND project_id in (?)"
        variables << scope
      end

      limit = Setting.plugin_aam_redmine_didyoumean_qa['limit']
      limit = 5 if limit.nil? or limit.empty?

      @messages = Message.visible.find(:all, :conditions => [conditions, *variables], :limit => limit)
      @count = Message.visible.count(:all, :conditions => [conditions, *variables])

      logger.debug "#{@count} results found, returning the first #{@messages.length}"

      # order by decreasing creation time. Some relevance sort would be a lot more appropriate here
      @messages = @messages.sort {|a,b| b.id <=> a.id}

    else
      @query = ""
      @count = 0
      @messages = []
    end

    render :json => { :total => @count, :messages => @messages.map{|i| 
      { #make a deep copy, otherwise rails3 makes weird stuff nesting the issue as mapping.
      :id => i.id,
      :subject => i.subject,
      :board_id => i.board.id,
      :board_name => i.board.name,
      :project_name => i.project.name
      }
    }}
  end
end
