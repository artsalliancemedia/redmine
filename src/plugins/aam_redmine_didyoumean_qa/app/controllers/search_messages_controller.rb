class SearchMessagesController < ApplicationController
  unloadable

  def index
    limit = 5 # Number of rows returned, yay for consts!

    # Try to match to the category structure.

    issue_category = IssueCategory.find_by_id(params[:category_id])
    # Grab the issue category and all of it's children.
    def recurse(ic)
      return [] if !ic # Prevent against an invalid category

      children = IssueCategory.where('parent_id' => ic.id)
      ic_names = [{:id => ic.id, :name => ic.name}]
      children.each {|child_ic|
        ic_names.push(*recurse(child_ic)) # Push and flatten the list so we end up with a flat list of names.
      }

      return ic_names
    end

    child_categories = recurse(issue_category)
    query_kb = {:key => 'boards.name IN (?)', :vals => child_categories.map {|c| c[:name]}}

    # First deal with Knowledge Base articles.
    
    @articles = Message.visible.where(query_kb[:key], query_kb[:vals]).order('messages.updated_on DESC')
    @article_count = @articles.length
    @articles.slice!(limit..-1) if @article_count > limit

    # Issue specific stuff next.

    query_issues = {:key => ['category_id IN (?)'], :vals => [child_categories.map {|c| c[:id]}]}

    # when editing an existing issue this will hold its id
    issue_id = params[:issue_id] unless params[:issue_id].blank?
    if !issue_id.nil?
      query_issues[:key] << "issues.id != (?)"
      query_issues[:vals] << issue_id
    end

    @issues = Issue.visible.where(query_issues[:key].join(' AND '), *query_issues[:vals]).order('issues.updated_on DESC')
    @issue_count = @issues.length
    @issues.slice!(limit..-1) if @issue_count > limit


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
end
