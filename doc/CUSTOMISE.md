# Customisation

A few tasks that should be done shortly after the installation is complete.

**Make sure you've run `rake lifeguard:data_modify` before proceeding! This will set up all the default lifeguard data.**

**Changing the language**

Language is auto detected from the user's browser, but if you want to explicitly override this then:

* Login > Administration > Settings > Display Tab > **Default language**
* Login > My Account > **Language**

**Setting the host name and port**

* Login > Administration > Settings > **Host name and port**

**Updating plugin configurations**

* Login > Administration > **Plugins**

Click through to the configure for each plugin in turn and make sure the settings are as expected.

**Changing the Working Times**

Each NOC is open for a set period each week, we take this into account by defining shift patterns. i.e. If a NOC is open 7am-11pm daily and a Priority 1 ticket is raised at 10:30pm. Priority 1 tickets have a 2 hour SLA, therefore instead of it breaching at 12:30am, it'll roll over and breach at 07:30am.

* Login > Administration > **Working Times**

**Changing the SLA Periods**

*SLA Seconds* are added to the Start Date of an issue to determine the due date. i.e. If the start date is 1/1/2013 12:30pm, it's a Priority 1 ticket therefore needs to be responded to within 2 hours (7200 seconds). Therefore the due date should be 1/1/2013 02:30pm.

* Login > Administration > **Issue Priorities** > Set the "SLA Seconds" field.

**Changing Knowledge Base Categories**

* Login > Administration > Projects > Lifeguard > **Knowledge Base Categories**

**Modifying Users/Groups**

* Login > Administration > **Users**
* Login > Administration > **Groups**

For example, a user could be "Mike Wojtus" and be placed the "NOC Engineers" group.

At present per exhibitor or cinema users are *not supported* because we cannot partition the ticket data appropriately unfortunately.

**Add a new permission role**

* Login > Administration > **Roles and Permissions**

Roles are global to the system and defines what permissions the user or group should recieve. For example:

* A "NOC Engineer" role might have the following permissions: Raise/Update/Resolve Tickets, Add/Update Knowledge Base Articles (plus many more). Whereas a "NOC Lead" role might also include the ability to Close or Delete tickets.

**Give user or group a role**

* Login > Administration > Users or Groups > `<select a user or group>` > **Projects Tab**

The final step is to link a user (or group) to the Lifeguard project, thus giving the user access to the issues/articles contained within.

* For the "NOC Engineers" group, go to the Projects Tab. There should be the "Lifeguard" project in the dropdown and then the "NOC Engineer" role just underneath, by choosing the role "NOC Engineer" for the "NOC Engineers" group it means that any user in that group will be given the "NOC Engineer" permission set for the lifeguard project.

This system is very flexible albeit quite confusing, this is mainly because Redmine supports settings a role for a user or a group per project and we only have one project (Lifeguard) so this extra dimension is unnecessary for us unfortunately.

**Workflow Alterations**

* Login > Administration > **Workflow**

Redmine has a powerful issue workflow whereby transitions between issue states can be controlled by user role. In addition to controlling which state a role can transition an issue to, the workflow also has the ability to dynamically enforce different validation criteria at each stage. For example:

* A 1st Line NOC Engineer can transition to resolved and must set the resolution code at this point.
* They cannot however transition to the closed state, this must be transitioned by a NOC Lead who can review the ticket for quality at that opportunity.
* Once the ticket is in a closed state the fields become read-only and only an admin can change the values because of localisation issues. Easier to just add the column to the table in question via a plugin if you need it in a report or do something other than just very simple CRUD with it.

## Already configured, but might need tweaking

**Changing Issue Priorities/Statuses/Resolutions/Categories**

* Login > Administration > **Issue Priorities**
* Login > Administration > **Issue Statuses**
* Login > Administration > Projects > Lifeguard > **Issue Categories Tab**
* Login > Administration > Projects > Lifeguard > **Issue Resolutions Tab**

**Changing Default Filter Columns**

* Login > Administration > Settings > **Issue Tracking Tab**