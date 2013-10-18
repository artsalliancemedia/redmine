#Producer Sync Plugin

Synchronises ticket data with Producer (by exposing a Rake task). Only fields required by Producer are sent.
The UUIDs of deleted tickets are also sent, so Producer can delete them at their end

##Setup

Ticket statuses should be set in the UI under admin->ticket statuses. 
This is to map the localised issue status string to a Producer-friendly ticket status

URL and Producer login details can be changed in the Lifeguard UI under admin->plugins

##Running

run `rake lifeguard:producer_push`

For extra debug logging, run `rake lifeguard:producer_push[true]`

Only tasks added or modified since the last run will be synced




