require 'active_record'

ActiveSupport::Deprecation.silence do
  require 'active_record/test_case'
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do

  create_table :accounts, :force => true do |t|
    t.integer :firm_id
    t.string  :firm_name
    t.integer :credit_limit
  end


  create_table :companies, :force => true do |t|
    t.string  :type
    t.integer :firm_id
    t.string  :firm_name
    t.string  :name
    t.integer :client_of
    t.integer :rating, :default => 1
    t.integer :account_id
    t.string :description, :default => ""
  end

  add_index :companies, [:firm_id, :type, :rating], :name => "company_index"
  add_index :companies, [:firm_id, :type], :name => "company_partial_index", :where => "rating > 10"


  create_table :keyboards, :force => true, :id  => false do |t|
    t.primary_key :key_number
    t.string      :name
  end


  create_table :people, :force => true do |t|
    t.string     :first_name, :null => false
    t.references :primary_contact
    t.string     :gender, :limit => 1
    t.references :number1_fan
    t.integer    :lock_version, :null => false, :default => 0
    t.string     :comments
    t.integer    :followers_count, :default => 0
    t.references :best_friend
    t.references :best_friend_of
    t.timestamps
  end


  create_table :subscribers, :force => true, :id => false do |t|
    t.string :nick, :null => false
    t.string :name
  end
  add_index :subscribers, :nick, :unique => true


  create_table :tasks, :force => true do |t|
    t.datetime :starting
    t.datetime :ending
  end
end

QUOTED_TYPE = ActiveRecord::Base.connection.quote_column_name('type')
