class AddCategoryCrawler < ActiveRecord::Migration
  def self.up
    add_column :crawlers, :category_id, :integer, :null => false
  end

  def self.down
    remove_column :crawlers, :category_id
  end
end
