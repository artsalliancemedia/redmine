#Suggest doing this as a rake with other data population, like
# /lib/redmine/default_data/loader.rb
class AmendTrackers < ActiveRecord::Migration

  def self.up
#		Tracker.destroy_all :name => "Bug"
#		Tracker.destroy_all :name => "Feature"
  end

  def self.down

#		Tracker.create!(:name => l(:default_tracker_bug),     :is_in_chlog => true,  :is_in_roadmap => false, :position => 1)
#		Tracker.create!(:name => l(:default_tracker_feature), :is_in_chlog => true,  :is_in_roadmap => true,  :position => 2)
#		Tracker.create!(:name => l(:default_tracker_support), :is_in_chlog => false, :is_in_roadmap => false, :position => 3)
  end
end
