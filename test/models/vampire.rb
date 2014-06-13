class Vampire < ActiveRecord::Base
  has_many :battles, :as => :battle
  has_many :teams, :through => :battles
end
