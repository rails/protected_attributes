class AbstractCompany < ActiveRecord::Base
  self.abstract_class = true
end

class Company < AbstractCompany
  attr_protected :rating
  self.sequence_name = :companies_nonstd_seq

  validates_presence_of :name

  has_one :dummy_account, :foreign_key => "firm_id", :class_name => "Account"
  has_many :contracts
  has_many :developers, :through => :contracts

  def arbitrary_method
    "I am Jack's profound disappointment"
  end

  private

  def private_method
    "I am Jack's innermost fears and aspirations"
  end
end

class Firm < Company
  ActiveSupport::Deprecation.silence do
    has_many :clients, -> { order "id" }, :dependent => :destroy, :counter_sql =>
        "SELECT COUNT(*) FROM companies WHERE firm_id = 1 " +
        "AND (#{QUOTED_TYPE} = 'Client' OR #{QUOTED_TYPE} = 'SpecialClient' OR #{QUOTED_TYPE} = 'VerySpecialClient' )",
        :before_remove => :log_before_remove,
        :after_remove  => :log_after_remove
  end
  has_many :unsorted_clients, :class_name => "Client"
  has_many :unsorted_clients_with_symbol, :class_name => :Client
  has_many :clients_sorted_desc, -> { order "id DESC" }, :class_name => "Client"
  has_many :clients_of_firm, -> { order "id" }, :foreign_key => "client_of", :class_name => "Client"
  has_many :clients_ordered_by_name, -> { order "name" }, :class_name => "Client"
  has_many :unvalidated_clients_of_firm, :foreign_key => "client_of", :class_name => "Client", :validate => false
  has_many :dependent_clients_of_firm, -> { order "id" }, :foreign_key => "client_of", :class_name => "Client", :dependent => :destroy
  has_many :exclusively_dependent_clients_of_firm, -> { order "id" }, :foreign_key => "client_of", :class_name => "Client", :dependent => :delete_all
  has_many :limited_clients, -> { limit 1 }, :class_name => "Client"
  has_many :clients_with_interpolated_conditions, ->(firm) { where "rating > #{firm.rating}" }, :class_name => "Client"
  has_many :clients_like_ms, -> { where("name = 'Microsoft'").order("id") }, :class_name => "Client"
  has_many :clients_like_ms_with_hash_conditions, -> { where(:name => 'Microsoft').order("id") }, :class_name => "Client"
  ActiveSupport::Deprecation.silence do
    has_many :clients_using_sql, :class_name => "Client", :finder_sql => proc { "SELECT * FROM companies WHERE client_of = #{id}" }
    has_many :clients_using_counter_sql, :class_name => "Client",
             :finder_sql  => proc { "SELECT * FROM companies WHERE client_of = #{id} " },
             :counter_sql => proc { "SELECT COUNT(*) FROM companies WHERE client_of = #{id}" }
    has_many :clients_using_zero_counter_sql, :class_name => "Client",
             :finder_sql  => proc { "SELECT * FROM companies WHERE client_of = #{id}" },
             :counter_sql => proc { "SELECT 0 FROM companies WHERE client_of = #{id}" }
    has_many :no_clients_using_counter_sql, :class_name => "Client",
             :finder_sql  => 'SELECT * FROM companies WHERE client_of = 1000',
             :counter_sql => 'SELECT COUNT(*) FROM companies WHERE client_of = 1000'
    has_many :clients_using_finder_sql, :class_name => "Client", :finder_sql => 'SELECT * FROM companies WHERE 1=1'
  end
  has_many :plain_clients, :class_name => 'Client'
  has_many :readonly_clients, -> { readonly }, :class_name => 'Client'
  has_many :clients_using_primary_key, :class_name => 'Client',
           :primary_key => 'name', :foreign_key => 'firm_name'
  has_many :clients_using_primary_key_with_delete_all, :class_name => 'Client',
           :primary_key => 'name', :foreign_key => 'firm_name', :dependent => :delete_all
  has_many :clients_grouped_by_firm_id, -> { group("firm_id").select("firm_id") }, :class_name => "Client"
  has_many :clients_grouped_by_name, -> { group("name").select("name") }, :class_name => "Client"

  has_one :account, :foreign_key => "firm_id", :dependent => :destroy, :validate => true
  has_one :unvalidated_account, :foreign_key => "firm_id", :class_name => 'Account', :validate => false
  has_one :account_with_select, -> { select("id, firm_id") }, :foreign_key => "firm_id", :class_name=>'Account'
  has_one :readonly_account, -> { readonly }, :foreign_key => "firm_id", :class_name => "Account"
  # added order by id as in fixtures there are two accounts for Rails Core
  # Oracle tests were failing because of that as the second fixture was selected
  has_one :account_using_primary_key, -> { order('id') }, :primary_key => "firm_id", :class_name => "Account"
  has_one :account_using_foreign_and_primary_keys, :foreign_key => "firm_name", :primary_key => "name", :class_name => "Account"
  has_one :deletable_account, :foreign_key => "firm_id", :class_name => "Account", :dependent => :delete

  has_one :account_limit_500_with_hash_conditions, -> { where :credit_limit => 500 }, :foreign_key => "firm_id", :class_name => "Account"

  has_one :unautosaved_account, :foreign_key => "firm_id", :class_name => 'Account', :autosave => false
  has_many :accounts
  has_many :unautosaved_accounts, :foreign_key => "firm_id", :class_name => 'Account', :autosave => false

  has_many :association_with_references, -> { references(:foo) }, :class_name => 'Client'

  def log
    @log ||= []
  end

  private
    def log_before_remove(record)
      log << "before_remove#{record.id}"
    end

    def log_after_remove(record)
      log << "after_remove#{record.id}"
    end
end

class Corporation < Company
  attr_accessible :type, :name, :description
end

class SpecialCorporation < Corporation
end
