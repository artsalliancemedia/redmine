class DataModifier
  def run
    
    #Remove unwanted trackers created by /lib/redmine/default_data/loader.rb
    Tracker.destroy(1) if Tracker.exists?(1)
    Tracker.destroy(2) if Tracker.exists?(2)
    #Modify the support tracker to remove some of the default "Standard fields" (Admin->Trackers->Edit)
    if Tracker.exists?(3)
      t = Tracker.find(3)
      #Can't use the update method - this field is protected - so do manually.
      t.fields_bits = 204 #magic number representing the bit pattern to disable unwanted fields
      t.save
    end
    
    #Create the lifeguard project
    unique_project_identifier = "lifeguard"
    unless Project.find_by_identifier(unique_project_identifier)
      lifeguard = Project.new
      lifeguard.name = I18n.t(:lifeguard)
      lifeguard.is_public = false
      lifeguard.identifier = unique_project_identifier
      lifeguard.use_datetime_for_issues = true
      lifeguard.enabled_module_names = [:issue_tracking, :boards]
      lifeguard.save
      
      #create knowledge base categories? Names aren't important - easy to modify
      lifeguard.boards.create(name: "Software", description: "Anything software related")
      lifeguard.boards.create(name: "Hardware", description: "Anything hardware related")
      
      #TODO some more modifications as necessary
      
      puts "Project Lifeguard has been created"
    else
      puts "Project Lifeguard already exists"
    end

    # Modify global settings, they automatically write to the db on assignment. MAGIC!!!!
    Setting['ui_theme'] = 'AAM'
    Setting['app_title'] = 'Lifeguard'
    Setting['login_required'] = '1'
    Setting['autologin'] = '30'
    Setting['self_registration'] = '0'
    Setting['session_lifetime'] = '43200'
    Setting['unsubscribe'] = '0'
    Setting['default_projects_public'] = '0'
    Setting['cross_project_issue_relations'] = '0'
    Setting['issue_list_default_columns'] = ['status', 'priority', 'subject', 'assigned_to', 'updated_on', 'cinema', 'screen', 'start_date', 'due_date', 'sla_status']
    Setting['mail_from'] = 'lifeguard@artsalliancemedia.com'

    # Get rid of useless Enumerations
    DocumentCategory.destroy_all
    TimeEntryActivity.destroy_all

    # Set the default set of issue priorities.
    IssuePriority.destroy(5) if IssuePriority.exists?(5)
    (1..4).each do |n|
      ip = IssuePriority.find_by_position(n)
      ip.name = "P" + n.to_s
      ip.is_default = true if n == 3
      ip.save
    end

    # Clean up the issue statuses
    IssueStatus.destroy_all(:name => 'Feedback')

    open = IssueStatus.find_by_name('New')
    if open
      open.name = 'Open'
      open.save
    end

    raw_statuses = [{:name => 'Open', :raw => 'open'}, {:name => 'In Progress', :raw => 'in_progress'}, {:name => 'Resolved', :raw => 'resolved'}, {:name => 'Closed', :raw => 'closed'}, {:name => 'Rejected', :raw => 'rejected'}]
    raw_statuses.each do |raw_status|
      s = IssueStatus.find_by_name(raw_status[:name])
      if s
        s.name_raw = raw_status[:raw]
        s.save
      end
    end
  end
end