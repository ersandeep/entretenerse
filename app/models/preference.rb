class Preference < ActiveRecord::Base
  belongs_to :user
  belongs_to :attribute
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: preferences
#
#  id           :integer(4)      not null, primary key
#  rank         :integer(4)      not null
#  user_id      :integer(4)      not null
#  attribute_id :integer(4)      not null