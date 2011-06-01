class RenameHomePageCrawlers < ActiveRecord::Migration
  def self.up
    rename_column :crawlers, :home_page, :url
  end

  def self.down
    rename_column :crawlers, :url, :home_page
  end
end
