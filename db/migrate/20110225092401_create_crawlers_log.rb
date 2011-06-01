class CreateCrawlersLog < ActiveRecord::Migration
  def self.up
    create_table :crawlers_log do |t|
      t.column :crawler_id, :integer, :null => false
      t.column :status,     :string
      t.column :url,        :string,  :null => false, :limit => 2048
      t.column :pull_data,  :text
      t.column :push_data,  :text

      t.timestamps
    end
  end

  def self.down
    drop_table :crawlers_log
  end
end
