class Battle < ActiveRecord::Base
  attr_accessible []
  belongs_to :team
  belongs_to :battle, :polymorphic => true
end
