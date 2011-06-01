class AddTopParentAttributes < ActiveRecord::Migration
  def self.up
    add_column :attributes, :top_parent_id, :integer

    Attribute.top_categories.each do |category|
      set_top_parent(category.children, category.id)
    end
  end

  def self.set_top_parent(categories, top_parent_id)
    categories.each do |category|
      category.update_attribute('top_parent_id', top_parent_id)
      set_top_parent(category.children, top_parent_id)
    end
  end

  def self.down
    remove_column :attributes, :top_parent_id
  end
end
