class Membership < ActiveRecord::Base
  self.mass_assignment_sanitizer = :strict

  belongs_to :group
  belongs_to :pirate

  attr_accessible []
end
