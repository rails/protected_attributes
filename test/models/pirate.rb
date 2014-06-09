class Pirate < ActiveRecord::Base
  self.mass_assignment_sanitizer = :strict

  has_many :memberships
end
