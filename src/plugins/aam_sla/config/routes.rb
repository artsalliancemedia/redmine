resources :working_periods

match '/issues/:id/toggle_pause', to: 'issues#toggle_pause', as: 'issue_toggle_pause'
match '/issues/:id/pauses', to: 'pauses#show', as: 'issue_pauses'
