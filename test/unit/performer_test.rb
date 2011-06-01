require 'rails/test_helper'

class PerformerTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
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