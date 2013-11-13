get 'resolution_trees/drop_downs/:id', :to => 'resolution_trees#drop_downs_for_tree'
resources :projects do
  resources :issue_resolutions
end
