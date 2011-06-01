class Calendar < ActiveRecord::Base
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: calendars
#
#  id        :integer(4)      not null, primary key
#  date      :datetime        not null
#  dayOfWeek :integer(4)      not null
#  month     :integer(4)      not null
#  day       :integer(4)      not null
#  status    :string(1)       not null
#  reason    :string(400)