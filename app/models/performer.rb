class Performer < ActiveRecord::Base
  has_many :performances
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: performers
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string(50)      not null, default(" ")