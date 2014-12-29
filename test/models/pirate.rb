class Pirate < ActiveRecord::Base
  self.mass_assignment_sanitizer = :strict
  attr_accessible :name
  has_many :memberships
end
