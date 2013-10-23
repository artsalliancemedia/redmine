## 0.9.1

* Working periods bug fixes and refinements.
* Raising new issues in Redmine from alerts created in Producer.

## 0.9.0

* AAM Theme
* Lifeguard(Producer) Intergration
  * Pulls in complexes, screens and devices from Lifeguard (Producer) and stores them locally in the Redmine database.
  * Able to assign tickets to a complex, screen and/or device.
  * Pushes ticket summary data to Lifeguard (Producer) for display in the reporting UI.
* SLA Plugin
  * Set number of seconds an issue is due after it is created, per priority level.
  * Able to pause the clock on an issue to prevent overrunning if information is not forthcoming from the client.
  * Define the working period of a week, this interacts with the due date of tickets to ensure the time remaining is when NOC users are in the office.
* Knowledge Base Plugin
  * Repurposes the built in forums module, adding tagging and a refined UI by default.
  * Articles are assign manufacturer, model, software and firmware versions.
  * Knowledge base articles can be made from issues, the issue description and any associated device information are included.
  * Includes two way links between knowledge base articles and issues.
  * As new issues are created the knowledge base and existing issues are searched to aid the location of existing solutions to faults.
* Dynamic Issue Categorisation Plugin
  * Hierarchically nested categorisation of issues, eases issue creation.
* UI Cleanup
  * Hide multi project UI as much as possible.
  * Streamline ticket creation/updating process to avoid confusing, legacy aspects of Redmine.
  * Script the default lifeguard installation of Redmine as much as possible so we don't have to remember it's quirks as much in future.
* Installation Process
  * Pulled in correct redmine and gem dependency versions into repository.
  * Created deployment scripts for the build process. Spits out a .tar.gz file.
  * Defines thin as the clustering server of choice, thin config file included in source control.
* Documentation
  * Added installation, customisation and production debugging guides.