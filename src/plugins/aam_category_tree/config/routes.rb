get 'issue_categories/:id/move/:direction', :to => 'issue_categories#move_category'
get 'category_trees/drop_downs/:id', :to => 'category_trees#drop_downs_for_tree'

get '/projects/:project_id/issue_categories/new_sub/:id', :to => 'issue_categories#new'

