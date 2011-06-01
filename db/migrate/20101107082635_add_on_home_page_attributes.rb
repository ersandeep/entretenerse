class AddOnHomePageAttributes < ActiveRecord::Migration
  def self.up
    add_column :attributes, :on_home_page, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :attributes, :on_home_page
  end
end
