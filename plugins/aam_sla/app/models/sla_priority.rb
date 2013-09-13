class SlaPriority < ActiveRecord::Base

  belongs_to :enumeration
  validates_presence_of :seconds

  def common_identifier
    "#{seconds}"
  end
  
  def to_s
    seconds
  end

end