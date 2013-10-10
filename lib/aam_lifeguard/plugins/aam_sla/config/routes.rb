resources :working_periods

match '/issues/:id/toggle_pause', to: 'issues#toggle_pause', as: 'issue_toggle_pause'
