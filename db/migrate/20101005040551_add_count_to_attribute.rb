class AddCountToAttribute < ActiveRecord::Migration
  def self.up
    add_column :attributes, :count, :integer
  end

  def self.down
    remove_column :attributes, :count
  end
end
