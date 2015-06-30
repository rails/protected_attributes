class Keyboard < ActiveRecord::Base
  attr_accessible(nil)

  self.primary_key = 'key_number'
end
