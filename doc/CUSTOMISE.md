# Customisation

This covers the common features that should be changed to deploy Redmine to an external client.

## First Configuration Musts

A few tasks that should be done shortly after the installation is complete.

### Adding the Lifeguard Project

Run `rake lifeguard:data_modify`

This adds the project and configures a few basic settings, as well as removing some unwanted redmine fluff from the db. Note well that Lifeguard is intended to only be used by a single project at a time.

### Changing the language

* Login > Administration > Settings > Display Tab > **Default language**
* Login > My Account > **Language**

### Changing Issue Priorities/Statuses/Categories

* Login > Administration > **Enumerations**
* Login > Administration > **Issue Statuses**
* Login > Administration > Projects > `<select a project>` > **Issue Categories Tab**

### Changing the SLA Periods

*SLA Seconds* are added to the Start Date of an issue to determine the due date. i.e. If the start date is 1/1/2013 12:30pm, it's a Priority 1 ticket therefore needs to be responded to within 2 hours (7200 seconds). Therefore the due date should be 1/1/2013 02:30pm.

* Login > Administration > **Enumerations** > Set the "SLA Seconds" field.

### Changing the Working Times

Each NOC is open for a set period each week, we take this into account by defining shift patterns. i.e. If a NOC is open 7am-11pm daily and a Priority 1 ticket is raised at 10:30pm. Priority 1 tickets have a 2 hour SLA, therefore instead of it breaching at 12:30am, it'll roll over and breach at 07:30am.

* Login > Administration > **Working Times**

### Changing Knowledge Base Categories

* Login > Administration > Projects > `<select a project>` > **Forums**

### Changing Default Filter Columns

* Login > Administration > Settings > **Issue Tracking Tab**

### Updating Plugin Configurations

* Login > Administration > **Plugins**

Click through to the configure for each plugin in turn and make sure the settings are as expected.


## Security and Workflow

### Modifying Users/Groups

* Login > Administration > **Users**
* Login > Administration > **Groups**

For example, a user could be "Mike Wojtus" and be placed the "NOC" group.

At present per exhibitor or cinema users are not advised because we cannot partition the ticket data appropriately unfortunately.

### Permissions and Roles

* Login > Administration > **Roles and Permissions**
* Login > Administration > Projects > `<select a project>` > **Members Tab**
* Login > Administration > Users or Groups > `<select a user or group>` > **Projects Tab**

Roles are given permissions and are assigned to users on a per project basis in Redmine. (In Lifeguard we should only ever have one project, so this distinction is slightly confusing). For example:

* A 1st Line NOC Engineer role might have the following permissions: Raise/Update/Resolve Tickets, Add/Update Knowledge Base Articles (plus many more). Whereas a NOC Lead might also include the ability to Close or Delete tickets.
* For the NOC group, go to the Projects Tab. There should be the "Lifeguard" project and then the "1st Line NOC Engineer" and "NOC Lead" roles, by choosing the role "1st Line NOC Engineer" for the "NOC" group it means that any user in the "NOC" group will be given the "1st Line NOC Engineer" permissions set.

This system is very flexible albeit quite confusing, this is mainly because Redmine supports settings a role for a user or a group per project, we only have one project (Lifeguard) so this extra dimension is unnecessary for us but it's a pain to remove so we've done our best to remove it.

### Workflow Alterations

* Login > Administration > **Workflow**

Redmine has a powerful issue workflow whereby transitions between issue states can be controlled by user role. In addition to controlling which state a role can transition an issue to, the workflow also has the ability to dynamically enforce different validation criteria at each stage. For example:

* A 1st Line NOC Engineer can transition to resolved and must set the resolution code at this point.
* They cannot however transition to the closed state, this must be transitioned by a NOC Lead who can review the ticket for quality at that opportunity.
* Once the ticket is in a closed state the fields become read-only and only an admin can change the values.

# Useful

A few tips that will hopefully prove useful in the future.

## Custom Fields

Use these with caution, they're not as useful as you'd hope if you're trying to integrate with them programatically, mainly because of localisation issues. Easier to just add the column to the table in question via a plugin if you need it in a report or do something other than just very simple CRUD with it.