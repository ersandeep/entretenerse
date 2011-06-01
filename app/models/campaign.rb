class Campaign < ActiveRecord::Base
  has_many :promotions
  has_many :events, :through =>:promotions
  belongs_to :campaign_type
  belongs_to :sponsor
end

class Promotion < ActiveRecord::Base
  belongs_to :event
  belongs_to :campaign
end





# == Schema Info
# Schema version: 20110328181217
#
# Table name: campaigns
#
#  id               :integer(4)      not null, primary key
#  start            :datetime
#  end              :datetime
#  campaign_type_id :integer(4)      not null, default(0)
#  sponsor_id       :integer(4)      not null, default(0)
#  status           :string(1)       not null