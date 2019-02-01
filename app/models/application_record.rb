class ApplicationRecord < ActiveRecord::Base
  include Loggable

  self.abstract_class = true
end
