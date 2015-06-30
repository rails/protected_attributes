class Subscriber < ActiveRecord::Base
  attr_accessible(nil)

  self.primary_key = 'nick'
  has_many :subscriptions
  has_many :books, :through => :subscriptions
end
