require 'rails/test_helper'

class EventTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: events
#
#  id          :integer(4)      not null, primary key
#  title       :string(128)     not null
#  description :text            not null, default("")
#  text        :text(2147483647
#  thumbnail   :string(200)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  sponsor_id  :integer(4)
#  price       :float
#  image_url   :string(200)
#  web         :string(200)
#  duration    :integer(4)
#  category_id :integer(4)
#  rating      :float           not null, default(0.0)
#  rated_count :integer(4)      not null, default(0)