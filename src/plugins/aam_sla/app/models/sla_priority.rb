class SlaPriority < ActiveRecord::Base

  belongs_to :enumeration
  validates :seconds, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :near_breach_seconds, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }
  validates_presence_of :near_breach_seconds

  def common_identifier
    "#{seconds}"
  end
  
  def to_s
    seconds
  end

end