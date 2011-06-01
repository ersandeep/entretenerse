require 'mechanize' 
class CrawlerLog < ActiveRecord::Base
  belongs_to :crawler
  belongs_to :parent
  has_many   :children, :class_name => 'CrawlerLog', :foreign_key => :parent_id, :autosave => true
  serialize  :config
  serialize  :pull_data, Array
  serialize  :push_data, Hash
  serialize  :result, Hash
  symbolize  :status, :in => [ :pull, :push, :done ]
  validates_presence_of :url
  validates_presence_of :crawler_id
  validates_presence_of :status

  def pull
    browser = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end
    browser.get(url) do |page|
      # Save the entire page to content field
      self.content=page.parser.to_s
      self.pull_data = []
      config[:group] = '/' unless config[:group]
      page.search(config[:group]).each do |group|
        data = {}
        data[:links] = group.search(config[:links]).map { |link| link["href"] } if config[:links]
        if config[:event_title]
          title = group.search(config[:event_title]).first
          data[:event_title] = title.inner_text.normalize if title && title.inner_text
        end
        if config[:event_description]
          desc = group.search(config[:event_description]).first
          data[:event_description] = desc.inner_text.normalize if desc && desc.inner_text
          data[:event_text] = data[:event_description]
        end
        if config[:event_image_url]
          image = group.search(config[:event_image_url]).first
          data[:event_image_url] = image["src"] if image
        end
        if config[:place_name]
          place_name = group.search(config[:place_name]).first
          data[:place_name] = place_name.inner_text.normalize if place_name && place_name.inner_text
        end
        if config[:place_address]
          place_address = group.search(config[:place_address]).first
          data[:place_address] = place_address.inner_text.normalize if place_address && place_address.inner_text
        end
        if config[:place_town]
          place_town = group.search(config[:place_town]).first
          data[:place_town] = place_town.inner_text.normalize if place_town && place_town.inner_text
        end
        if config[:place_state]
          place_state = group.search(config[:place_state]).first
          data[:place_state] = place_state.inner_text.normalize if place_state && place_state.inner_text
        end
        if config[:place_country]
          place_country = group.search(config[:place_country]).first
          data[:place_country] = place_country.inner_text.normalize if place_country && place_country.inner_text
        end
        if config[:place_phone]
          place_phone = group.search(config[:place_phone]).first
          data[:place_phone] = place_phone.inner_text.normalize if place_phone && place_phone.inner_text
        end
        if config[:time]
          data[:time] = []
          group.search(config[:time]).each do |time|
            data[:time] << time.inner_text.normalize if time && time.inner_text
          end
        end
        if config[:category]
          data[:category] = []
          group.search(config[:category]).each do |category|
            data[:category] << category.inner_text.normalize if category && category.inner_text
          end
        end
        self.pull_data << data
      end
      # Add separate groups for paging links
      if config[:pages]
        data = {}
        data[:pages] = page.search(config[:pages]).map { |link| link["href"] }
        self.pull_data << data
      end
      self.status = :push
      save!
    end
  rescue Exception => e
    self.result ||= {}
    self.result[:message] = e.message
    self.status = :error
    self.save
  end

  def push
    self.pull_data.each do |group|
      group = (self.push_data || {}).merge(group)
      pages = create_pages(group)
      links = create_links(group)

      place = create_place(group)
      place.save

      event = create_event(group)
      event.image_url = make_absolute(event.image_url, self.crawler.url) if event && event.image_url
      event.save

      categories = create_categories(group)
      categories.compact! if categories
      times = expand_times(group)
      unless times.blank?
        times.flatten.each do |time|
          occurrence = create_occurrence(event, time)
          pl = occurrence.places.select { |p| p.id == place.id }
          if pl.blank?
            occurrence.places << place
            occurrence.place_id = place.id
          end
          if categories and !categories.blank?
            categories.each do |category|
              ex = occurrence.labels.select { |label| label.id == category.id }
              occurrence.labels << category if ex.blank?
            end
          end
          occurrence.save
          self.result ||= {}
          self.result[:occurrences] ||= []
          self.result[:occurrences] << occurrence
        end
      end
    end
    self.status = :done
    save!
  #rescue Exception => e
  #  self.result ||= {}
  #  self.result[:message] = e.message
  #  self.status = :error
  #  self.save(false)
  end

  def make_absolute(href, root)
    uri = URI.parse(href)
    uri = URI.parse(root).merge(href) if uri.relative?
    uri.to_s
  end

  def create_pages(group)
    (group[:pages] || []).compact.collect do |page_link|
      begin
        self.children.build({
          :crawler => self.crawler,
          :url => make_absolute(page_link, crawler.url),
          :status => :pull,
          :crawler_id => 1,
          :config => self.config.to_options,
          :push_data => self.push_data
        })
      rescue URI::InvalidURIError => e
      end
    end
  end

  def create_links(group)
    (group[:links] || []).compact.collect do |follow_link|
      begin
        self.children.build({
          :crawler => self.crawler,
          :url => make_absolute(follow_link, crawler.url),
          :status => :pull,
          :crawler_id => 1,
          :config => self.config[:config].to_options,
          :push_data => group.reject { |key, value| key == :links || key == :pages }
        })
      rescue URI::InvalidURIError => e
      end
    end
  end

  def create_place(group)
    params = {}
    group.each do |key, value|
      next unless key.to_s.start_with?('place_')
      params[key.to_s.gsub('place_', '').to_sym] = value
    end
    places = Place.where params
    places.blank? ? Place.new(params) : places.first
  end

  def create_event(group)
    params = {}
    group.each do |key, value|
      next unless key.to_s.start_with?('event_')
      params[key.to_s.gsub('event_', '').to_sym] = value
    end
    params[:category_id] = crawler.category_id
    events = Event.where(:title => params[:title], :category_id => params[:category_id])
    event = events.blank? ? Event.new(params) : events.first
    event.attributes = params
    event
  end

  def create_occurrence(event, time)
    params = { :event_id => event.id, :date => time }
    occurrences = Occurrence.where params
    occurrences.blank? ? Occurrence.new(params.merge(:hour => time)) : occurrences.first
  end

  def expand_times(group)
    return if !group[:time] || group[:time].blank?
    time = group[:time].first
    # Expand each portion at least for the current week
    start = (self.crawler.start_at || Time.now.end_of_week) - 1.week  #next_week
    time.split(' ').collect do |portion|
      hour_minutes = Time.parse(portion)
      7.times.collect do |index|
        occ_time = Time.zone.local(start.year, start.month, start.day, hour_minutes.hour, hour_minutes.min)
        occ_time + index.days
      end
    end
  rescue ArgumentError
  end

  def create_categories(group)
    categories = group[:category]
    return unless categories
    categories = categories.first
    index = categories.index(':')
    if index && index > 0
      parent_category_name = categories[0...index].normalize
      categories = categories[index + 1..-1].normalize
    end
    # Find parent category first
    top_category = Attribute.find_by_value_and_parent_id(Category.find(crawler.category_id).name, nil)
    throw "Not found category with name #{top_category}" unless top_category
    unless parent_category_name.blank?
      parent_category = top_category.children.find_by_name(parent_category_name)
      parent_category ||= top_category.children.create({
        :name => parent_category_name.strip,
        :value => parent_category_name.strip,
        :top_parent_id => top_category.id
      })
    else
      parent_category = top_category
    end
    categories.split(',').collect do |category|
      category = category.normalize
      parent_category.children.find_by_value(category) || parent_category.children.create({
        :name => category,
        :value => category,
        :top_parent_id => top_category.id
      })
    end
  end

  def load_config
    self.config = YAML.load(File.open("#{Rails.root}/config/crawlers/cinesargentinos.yml")).to_options
  end
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: crawler_logs
#
#  id         :integer(4)      not null, primary key
#  crawler_id :integer(4)      not null
#  status     :string(255)
#  url        :string(2048)    not null
#  pull_data  :text
#  push_data  :text
#  created_at :datetime
#  updated_at :datetime
#  content    :text
#  config     :text
#  parent_id  :integer(4)
#  result     :text
