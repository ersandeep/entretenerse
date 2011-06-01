require 'rails/test_helper'

class CampaignTypeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: campaign_types
#
#  id    :integer(4)      not null, primary key
#  name  :string(50)      not null
#  ctype :string(1)       not null