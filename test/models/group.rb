class Group < ActiveRecord::Base
  self.mass_assignment_sanitizer = :strict

  has_many :memberships, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :pirate
end
