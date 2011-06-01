class Attribute < ActiveRecord::Base
  has_many :children, :foreign_key => :parent_id, :class_name => 'Attribute', :order => '`attributes`.`order`, `attributes`.`value` '
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Attribute'

  has_and_belongs_to_many :events, :class_name => "Event" , :join_table=> "events_attributes"
  has_and_belongs_to_many :occurrences, :class_name => "Occurrence" , :join_table=> "occurrences_attributes"

  scope :top_categories, :conditions => ['parent_id IS NULL']
  scope :with_occurrences, :conditions => ['occurrences_count > ?', 0]

  def to_param
    "#{id}-#{value.to_url}"
  end

  def leafs
    @leafs ||= []# self.children
  end

  def leafs=(attrs)
    @leafs = attrs
  end

  def self.find_with_counts(conditions)
    find(:all,
      :select => 'attributes.*, count(occurrences.id) as occurrences_count',
      :joins => :occurrences,
      :conditions => conditions,
      :group => 'attributes.id')
  end

  def on_home_page=(value)
    write_attribute(:on_home_page, value)
    # We need to update all children and their childrent with the value
    self.children.each do |child|
      child.on_home_page = value
      child.save!
    end
  end

  def to_s_long
    if ( self.parent == nil)
      return "Rubro >> " + self.value
    else
      return parent.to_s_long + " >> " + self.value
    end
  end

  def update_events_count
    children.each { |child| child.update_events_count }
    self.events_count = events.count + children.inject(0) { |sum, child| sum + child.events_count }
    save!
  end

  def update_occurrences_count(conditions)
    children.each { |child| child.update_occurrences_count(conditions) }
    self.occurrences_count = occurrences.count(conditions) + children.inject(0) { |sum, child| sum + child.occurrences_count }
    save!
  end

  def update_count(conditions)
    children.each { |child| child.update_count(conditions) }
    update_events_count
    update_occurrences_count(conditions)
    self.count = occurrences_count + events_count
    save!
  end

  # Updates occurrences and events count for each category on database for current date
  def self.recount
    categories = Attribute.find(:all, :conditions => ['parent_id is null'])
    categories.each { |category| category.update_count(:conditions => ['date >= ?', Date.current])}
  end

  def parent_chain
    self.parent_id.blank? ? [self] : [self, self.parent.parent_chain].flatten
  end
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: attributes
#
#  id                :integer(4)      not null, primary key
#  name              :string(50)      not null
#  parent_id         :integer(4)
#  value             :string(50)      not null
#  icon              :string(50)
#  order             :integer(4)
#  count             :integer(4)
#  events_count      :integer(4)
#  occurrences_count :integer(4)
#  on_home_page      :boolean(1)      not null, default(TRUE)
#  top_parent_id     :integer(4)