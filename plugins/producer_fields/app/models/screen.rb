class Screen < ActiveRecord::Base
  default_scope :include => :cinema, :order => :'cinemas.name, identifier'

  belongs_to :cinema
  belongs_to :issue
  has_many :devices, :as => :deviceable

  validates_presence_of :title
  validates_presence_of :identifier
  validates_presence_of :uuid

  def common_identifier
    "#{identifier} - #{cinema.name}"
  end

  def identifier_with_cinema
    "#{cinema.name} - #{identifier}"
  end

  def to_s
    identifier
  end

end