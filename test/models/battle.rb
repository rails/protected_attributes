class Battle < ActiveRecord::Base
  attr_accessible []
  belongs_to :team
  belongs_to :battle, :polymorphic => true
end

class NestedBattle < ActiveRecord::Base
  self.table_name = "battles"

  belongs_to :team
  belongs_to :battle, :polymorphic => true

  accepts_nested_attributes_for :team
end
