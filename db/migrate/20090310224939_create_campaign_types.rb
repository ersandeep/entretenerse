class CreateCampaignTypes < ActiveRecord::Migration
  def self.up
    create_table :campaign_types do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :campaign_types
  end
end
