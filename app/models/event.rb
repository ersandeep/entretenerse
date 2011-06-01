class Event < ActiveRecord::Base
  acts_as_commentable

  has_many :occurrences
  belongs_to :sponsor
  has_many :performances
  belongs_to :category, :class_name => 'Attribute'
  has_many :places , :through => :occurrences
  has_many :campaigns, :through => :promotions
  has_many :performers , :through => :performances
  has_and_belongs_to_many :labels, :class_name => "Attribute" , :join_table=> "events_attributes"

  validates_presence_of :title, :description, :category_id

  def to_param
    "#{id}-#{title.to_url}"
  end

  def rate(rating)
    if rating >= 1 and rating <= 5
      self.rating = ((((self.rating || 0) * self.rated_count + rating).to_f / (self.rated_count + 1)) * 10).round.to_f / 10
      self.rated_count += 1
    end
    self.rating
  end

  def rating_int
    rating.round
  end

  def self.correct_images
    # Check thrumbnails for empty images and remove them
    Dir.glob('public/thumbnails/*.jpg').each do |filename|
      unless File.size?(filename)
        event = Event.find_by_image_url filename[7..-1]
        if event
          event.image_url = nil
          event.save
        end
        File.delete filename
      end
    end
  end
end

class Performance < ActiveRecord::Base
  belongs_to :event
  belongs_to :performer
end



# == Schema Info
# Schema version: 20110328181217
#
# Table name: events
#
#  id          :integer(4)      not null, primary key
#  title       :string(128)     not null
#  description :text            not null, default("")
#  text        :text(2147483647
#  thumbnail   :string(200)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  sponsor_id  :integer(4)
#  price       :float
#  image_url   :string(200)
#  web         :string(200)
#  duration    :integer(4)
#  category_id :integer(4)
#  rating      :float           not null, default(0.0)
#  rated_count :integer(4)      not null, default(0)