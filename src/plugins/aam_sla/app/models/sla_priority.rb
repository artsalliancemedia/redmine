class SlaPriority < ActiveRecord::Base

  belongs_to :enumeration
  validates_presence_of :seconds
  validates_presence_of :near_breach_seconds

  def common_identifier
    "#{seconds}"
  end
  
  def to_s
    seconds
  end

end