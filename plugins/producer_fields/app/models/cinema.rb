class Cinema < ActiveRecord::Base

  has_and_belongs_to_many :circuit_group, :uniq => true
  belongs_to :issue

  has_many :screens
  has_many :devices, through: :screen
  has_many :devices, :as => :deviceable

  validates_presence_of :name

  def common_identifier
    "#{name}"
  end
  
  def to_s
    name
  end

end