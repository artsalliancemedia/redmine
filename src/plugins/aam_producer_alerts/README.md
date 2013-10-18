#Producer alert polling Plugin

Polls Producer alerts for new ticket-worthy alerts, and creates a stub ticket for them

##Setup

URL and Producer login details can be changed in the Redmine/Lifeguard UI under admin->plugins

##Running

run `rake lifeguard:producer_alerts`

For extra debug logging, run `rake lifeguard:producer_alerts[true]`

