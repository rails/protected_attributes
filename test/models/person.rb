class LoosePerson < ActiveRecord::Base
  self.table_name = 'people'

  attr_protected :comments, :best_friend_id, :best_friend_of_id
  attr_protected :as => :admin

  has_one    :best_friend,    :class_name => 'LoosePerson', :foreign_key => :best_friend_id
  belongs_to :best_friend_of, :class_name => 'LoosePerson', :foreign_key => :best_friend_of_id
  has_many   :best_friends,   :class_name => 'LoosePerson', :foreign_key => :best_friend_id

  accepts_nested_attributes_for :best_friend, :best_friend_of, :best_friends
end

class TightPerson < ActiveRecord::Base
  self.table_name = 'people'

  attr_accessible :first_name, :gender
  attr_accessible :first_name, :gender, :comments, :as => :admin
  attr_accessible :best_friend_attributes, :best_friend_of_attributes, :best_friends_attributes
  attr_accessible :best_friend_attributes, :best_friend_of_attributes, :best_friends_attributes, :as => :admin

  has_one    :best_friend,    :class_name => 'TightPerson', :foreign_key => :best_friend_id
  belongs_to :best_friend_of, :class_name => 'TightPerson', :foreign_key => :best_friend_of_id
  has_many   :best_friends,   :class_name => 'TightPerson', :foreign_key => :best_friend_id

  accepts_nested_attributes_for :best_friend, :best_friend_of, :best_friends
end

class NestedPerson < ActiveRecord::Base
  self.table_name = 'people'

  attr_accessible :first_name, :best_friend_first_name, :best_friend_attributes
  attr_accessible :first_name, :gender, :comments, :as => :admin
  attr_accessible :best_friend_attributes, :best_friend_first_name, :as => :admin

  has_one :best_friend, :class_name => 'NestedPerson', :foreign_key => :best_friend_id
  accepts_nested_attributes_for :best_friend, :update_only => true, :reject_if => :all_blank

  def comments=(new_comments)
    raise RuntimeError
  end

  def best_friend_first_name=(new_name)
    assign_attributes({ :best_friend_attributes => { :first_name => new_name } })
  end
end
