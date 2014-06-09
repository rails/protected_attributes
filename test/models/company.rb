class AbstractCompany < ActiveRecord::Base
  self.abstract_class = true
end

class Company < AbstractCompany
  attr_protected :rating
end

class Firm < Company
end

class Corporation < Company
  attr_accessible :type, :name, :description
end

class SpecialCorporation < Corporation
end
