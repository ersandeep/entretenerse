require 'rails/test_helper'

class SponsorTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: sponsors
#
#  id         :integer(4)      not null, primary key
#  name       :string(50)      not null
#  credit     :float           not null
#  telephone  :string(50)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  user_id    :integer(4)      not null
#  url        :string(100)
#  email      :string(100)