class Device < ActiveRecord::Base
  default_scope :joins => "
  LEFT OUTER JOIN \"screens\" ON \"devices\".\"deviceable_id\" = \"screens\".\"id\" AND \"devices\".\"deviceable_type\" = 'Screen'
  LEFT OUTER JOIN \"cinemas\" as \"cin\" ON \"screens\".\"cinema_id\" = \"cin\".\"id\"
  LEFT OUTER JOIN \"cinemas\" ON \"devices\".\"deviceable_id\" = \"cinemas\".\"id\" AND \"devices\".\"deviceable_type\" = 'Cinema'
  ", :order => :'cin.name, cinemas.name, screens.identifier'

  belongs_to :deviceable, polymorphic: true
  belongs_to :cinema
  belongs_to :issue

  validates_presence_of :uuid
  
  def to_s
    l(category)
  end

end
