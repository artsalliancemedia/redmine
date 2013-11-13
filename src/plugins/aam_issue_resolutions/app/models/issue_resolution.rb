class IssueResolution < ActiveRecord::Base
  include Redmine::SafeAttributes
  belongs_to :project
  has_many :issues, :foreign_key => 'resolution_id', :dependent => :nullify
  acts_as_tree :dependent => :nullify
  acts_as_list :scope => '(project_id = #{project_id} AND parent_id #{parent_id ? "= #{parent_id}" : "IS NULL"})'
  acts_as_nested_set :order => "name", :dependent => :destroy, :scope => 'project_id'
  safe_attributes 'name', 'parent_id', 'move_to', 'selected'

  validates_presence_of :name

  def common_identifier
    "#{name}"
  end
  
  def to_s
    name
  end

  def valid_parents
    @valid_parents ||= project.issue_resolutions - self_and_descendants
  end

  def self.resolution_tree(resolutions, parent_id=nil, level=0)
    tree = []
    resolutions.select {|resolution| resolution.parent_id == parent_id}.sort_by(&:position).each do |resolution|
      tree << [resolution, level]
      tree += resolution_tree(resolutions, resolution.id, level+1)
    end
    if block_given?
      tree.each do |resolution, level|
        yield resolution, level
      end
    end
    tree
  end

end