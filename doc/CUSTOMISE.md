# Customisation

This covers the common features that should be changed to deploy Redmine to an external client.

## First Configuration Musts

A few tasks that should be done shortly after the installation is complete.

### Adding the Lifeguard Project

* Login > Administration > Projects

For a default installation there will be nothing in the database beyond the inital static data. We need to add a project first, Lifeguard is intended to only be used by a single project at a time. As a part of creating the new project you'll want to restrict the modules on display, we only use the "Issues" and "Forums" modules so please switch off the remainder.

### Changing the language

* Login > Administration > Settings > Display Tab > **Default language**
* Login > My Account > **Language**

### Changing Issue Priorities/Statuses/Categories

* Login > Administration > Enumerations
* Login > Administration > **Issue Statuses**
* Login > Settings (next to the Knowledge Base) > Issue Categories

### Changing Default Filter Columns

* Login > Administration > Settings > Issue Tracking Tab

### Updating Plugin Configurations

* Login > Administration > Plugins

Click through to the configure for each plugin in turn and make sure the settings are as expected.


## Security and Workflow

### Modifying Users/Groups

* Login > Administration > Users
* Login > Administration > Groups

For example, a user could be "Mike Wojtus" and be placed the "NOC" group.

At present per exhibitor or cinema users are not advised because we cannot partition the ticket data appropriately unfortunately.

### Permissions and Roles

* Login > Administration > Roles and Permissions
* Login > Settings (next to the Knowledge Base) > Members
* Login > Administration > Users or Groups > `<select a user or group>` > Projects Tab

Roles are given permissions and are assigned to users on a per project basis in Redmine. (In Lifeguard we should only ever have one project, so this distinction is slightly confusing). For example:

* A 1st Line NOC Engineer role might have the following permissions: Raise/Update/Resolve Tickets, Add/Update Knowledge Base Articles (plus many more). Whereas a NOC Lead might also include the ability to Close or Delete tickets.
* For the NOC group, go to the Projects Tab. There should be the "Lifeguard" project and then the "1st Line NOC Engineer" and "NOC Lead" roles, by choosing the role "1st Line NOC Engineer" for the "NOC" group it means that any user in the "NOC" group will be given the "1st Line NOC Engineer" permissions set.

This system is very flexible albeit quite confusing, this is mainly because there is the extra dimension we don't need (i.e. multiple projects).

### Workflow Alterations

* Login > Administration > Workflow

Redmine has a powerful issue workflow whereby transitions between issue states can be controlled by user role. In addition to controlling which state a role can transition an issue to, the workflow also has the ability to dynamically enforce different validation criteria at each stage. For example:

* A 1st Line NOC Engineer can transition to resolved and must set the resolution code at this point.
* They cannot however transition to the closed state, this must be transitioned by a NOC Lead who can review the ticket for quality at that opportunity.
* Once the ticket is in a closed state the fields become read-only and only an admin can change the values.

# Useful

A few tips that will hopefully prove useful in the future.

## Custom Fields

Use these with caution, they're not as useful as you'd hope if you're trying to integrate with them programatically, mainly because of localisation issues. Easier to just add the column to the table in question via a plugin if you need it in a report or do something other than just very simple CRUD with it.