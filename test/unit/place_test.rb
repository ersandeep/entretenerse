require 'rails/test_helper'

class PlaceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: places
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  name       :string(50)      not null
#  address    :string(50)
#  town       :string(50)
#  state      :string(50)
#  country    :string(50)
#  phone      :string(128)