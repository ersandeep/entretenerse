require 'rails/test_helper'

class AttributeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: attributes
#
#  id                :integer(4)      not null, primary key
#  name              :string(50)      not null
#  parent_id         :integer(4)
#  value             :string(50)      not null
#  icon              :string(50)
#  order             :integer(4)
#  count             :integer(4)
#  events_count      :integer(4)
#  occurrences_count :integer(4)
#  on_home_page      :boolean(1)      not null, default(TRUE)
#  top_parent_id     :integer(4)