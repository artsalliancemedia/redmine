class CircuitGroup < ActiveRecord::Base
  default_scope order('name ASC')

  has_and_belongs_to_many :cinemas, :uniq => true

  has_many :screens, through: :cinema
  has_many :devices, through: :cinema

  validates_presence_of :name

  def to_s
    name
  end

end