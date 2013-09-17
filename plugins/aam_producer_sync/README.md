#Producer Sync Plugin

Synchronises ticket data with Producer (by exposing a Rake task). Only fields required by Producer are sent.

##Setup

Must edit the redmine core for it to work:

In app->views->issue_statuses->_form.html.erb, change line 11 from
`<%= call_hook(:view_issue_statuses_form, :issue_status => @issue_status ) %>`
to
`<%= call_hook(:view_issue_statuses_form, { :issue_status => @issue_status, :form => f } ) %>`

Ticket statuses should be set in the UI under admin->ticket statuses. 
This is to map the localised issue status string to a Producer-friendly ticket status

URL and Producer login details can be changed in the Lifeguard UI under admin->plugins

##Running

run `rake lifeguard:producer_push`

Only tasks added or modified since the last run will be synched.




