class SlaPriority < ActiveRecord::Base

  belongs_to :enumeration
  validates :seconds, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }

  def common_identifier
    "#{seconds}"
  end
  
  def to_s
    seconds
  end

end