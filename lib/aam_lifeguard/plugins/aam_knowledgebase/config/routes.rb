# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :questions do
  collection do
    get :autocomplete_for_topic
    get :topics
  end
  member do
    get :vote
  end
end

match "issues/:issue_id/move_to_forum/:board_id" => "questions#convert_issue"

match "devices_for_autocomplete/manufacturer/:manufacturer", :to => "questions#device_models", :via => :get
match "devices_for_autocomplete/manufacturer", :to => "questions#device_models", :via => :get

match "devices_for_autocomplete/model/:model", :to => "questions#device_model_info", :via => :get
match "devices_for_autocomplete/model", :to => "questions#device_model_info", :via => :get
