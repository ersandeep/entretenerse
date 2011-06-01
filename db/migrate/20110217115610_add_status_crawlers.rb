class AddStatusCrawlers < ActiveRecord::Migration
  def self.up
    add_column :crawlers, :status, :string
  end

  def self.down
    remove_column :crawlers, :status
  end
end
