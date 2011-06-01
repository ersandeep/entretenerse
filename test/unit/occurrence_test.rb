require 'rails/test_helper'

class OccurrenceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: occurrences
#
#  id         :integer(4)      not null, primary key
#  date       :datetime
#  dayOfWeek  :integer(4)
#  from       :datetime
#  to         :datetime
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  place_id   :integer(4)      not null
#  event_id   :integer(4)      not null
#  hour       :time