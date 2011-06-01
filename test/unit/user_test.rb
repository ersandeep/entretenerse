require 'rails/test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: users
#
#  id        :integer(4)      not null, primary key
#  name      :string(50)      not null
#  password  :string(50)
#  firstName :string(50)
#  email     :string(50)
#  clickpass :string(50)      not null
#  lastName  :string(50)
#  admin     :boolean(1)      not null