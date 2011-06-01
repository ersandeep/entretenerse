class ChangeSponsorIdEvents < ActiveRecord::Migration
  def self.up
    change_column :events, :sponsor_id, :integer, :null => true
  end

  def self.down
    change_column :events, :sponsor_id, :integer, :null => false
  end
end
