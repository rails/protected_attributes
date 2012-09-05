class Subscriber < ActiveRecord::Base
  self.primary_key = 'nick'
  has_many :subscriptions
  has_many :books, :through => :subscriptions
end
