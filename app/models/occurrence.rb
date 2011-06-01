class Occurrence < ActiveRecord::Base
  belongs_to :event
  belongs_to :place
  has_and_belongs_to_many :places
  has_and_belongs_to_many :labels, :class_name => "Attribute" , :join_table=> "occurrences_attributes"

  default_scope :order => 'date, hour'
  attr_accessor :show_date_header, :show_time_header, :show_image, :show_char_header, :show_category_header

  validates_presence_of :place_id, :event_id

  MAX_COLUMN_WEIGHT = 400
  EVENT_WEIGHT = 49
  IMAGE_WEIGHT = 95
  HOURS_WEIGHT = 16
  DATE_WEIGHT  = 36

  def weight
    @weight = EVENT_WEIGHT
    @weight += IMAGE_WEIGHT if show_image
    @weight += DATE_WEIGHT if show_date_header or show_category_header
    @weight += HOURS_WEIGHT if show_time_header or show_char_header
    @weight
  end

  def self.date_range(date)
    case date
    when 'today' then [Time.zone.now.beginning_of_day, Time.zone.now.end_of_day]
    when 'tomorrow' then [Time.zone.now.tomorrow.beginning_of_day, Time.zone.now.tomorrow.end_of_day]
    when 'week' then [Time.zone.now.beginning_of_day, Time.zone.now.end_of_week.end_of_day]
    when 'weekend' then [[Time.zone.now.end_of_week.advance(:days => -1), Time.zone.now].max.beginning_of_day, Time.zone.now.end_of_week.end_of_day]
    when 'month' then [Time.zone.now.beginning_of_day, Time.zone.now.end_of_month]
    else [Time.zone.parse(date).beginning_of_day, Time.zone.parse(date).end_of_day]
    end
  end

  def self.date_conditions(date)
    return nil if date.blank?
    ['date >= ? and date < ?', *date_range(date)]
  rescue ArgumentError
    ['date = ?', Time.zone.today]
  end

  def self.time_conditions(time)
    return nil if time.blank? || !time.is_a?(String)
    time = (Time.zone.now - 2.hours).strftime('%H-24') if time == 'started'
    from, to = time.split('-').map do |hours|
      Time.zone.local(2000, 1, 1, hours.to_i, 0) rescue nil
    end
    if from.blank? && to.blank?
      nil
    elsif from.blank?
      ['hour <= ?', to - 1.second]
    elsif to.blank?
      ['hour >= ?', from]
    else
      ['hour >= ? and hour <= ?', from, to - 1.second]
    end
  end

  def self.category_conditions(category_id, home_page)
    return Occurrence.home_page_conditions(home_page) if category_id.to_i == 0
    category = Attribute.find(category_id.to_i)
    ['exists(select * from occurrences_attributes ' +
      'where occurrences_attributes.occurrence_id = occurrences.id ' +
      'and occurrences_attributes.attribute_id IN (' +
      [category.id, category.child_ids, category.children.collect { |child| child.child_ids }].flatten.join(',') +
      ') limit 1)']
  end

  def self.home_page_conditions(home_page)
    return nil unless home_page
    # Category not selected - filter occurrences by 'on_home_page' flag
    ['exists(select * from occurrences_attributes ' +
      'inner join attributes on attributes.id = occurrences_attributes.attribute_id ' +
      'where occurrences_attributes.occurrence_id = occurrences.id and attributes.on_home_page = 1 limit 1)']
  end

  def self.text_conditions(text)
    return nil if text.blank?
    #text = text.split.collect { |word| '+' + word }.join
    ["(exists (select events.* from events " +
      "where events.id = occurrences.event_id " +
        "and MATCH (`events`.`title`,`events`.`description`,`events`.`text`) AGAINST (? IN BOOLEAN MODE)) " +
      "or exists(" +
      "select * from places " +
      "where places.id = occurrences.place_id " +
        "and MATCH (`places`.`name`) AGAINST (? IN BOOLEAN MODE)) " +
      ")", text, text]
  end

  def self.conditions(options={})
    conditions = []
    conditions << Occurrence.category_conditions(options[:category], options[:home])
    conditions << Occurrence.date_conditions(options[:date])
    conditions << Occurrence.time_conditions(options[:hours])
    conditions << Occurrence.text_conditions(options[:text])
    conditions.compact!
    conditions = [conditions.map{|c| c[0]}.join(" AND "), *conditions.map{|c| c[1..-1]}].flatten
    conditions.length > 0 && conditions[0].blank? ? nil : conditions
  end

  def nearest_siblings
    self.event.occurrences.find(:all,
      :conditions => ["date = ? and hour >= ?", self.date, self.hour],
      :group => 'date, hour',
      :limit => 3)
  end

  def self.format(occurrences, options)
    Occurrence.set_promotions(occurrences, options[:view] == 'category')
    columns, current_column_weight = [], MAX_COLUMN_WEIGHT

    # Now we can calculate overal weight of the occurrence and add it to appropriate column
    occurrences.each do |occurrence|
      if options[:flat] || (current_column_weight + occurrence.weight) >  MAX_COLUMN_WEIGHT
        columns << []
        current_column_weight = 0
      end
      columns.last << occurrence
      current_column_weight += occurrence.weight
    end
    columns
  end

  # Decide, which of those should show an image(s), date and / or time header
  def self.set_promotions(occurrences, by_category)
    columns = []
    last_date, last_time, last_char, last_category = Date.new, Date.new.to_time, '0'.to_i, 0
    occurrences.each_with_index do |occurrence, index|
      if !occurrence.event.image_url.blank?
        occurrence.show_image = true
        last_image_index = index
      end
      if by_category
        if last_char < occurrence.event.title[0].to_i
          occurrence.show_char_header = true
          last_char = occurrence.event.title[0].to_i
        end
        if last_category < occurrence.event.category_id
          occurrence.show_category_header = true
          last_category = occurrence.event.category_id
        end
      else
        if last_date < occurrence.date.to_date
          occurrence.show_date_header = true
          last_date = occurrence.date.to_date
        end
        if last_time != occurrence.hour
          occurrence.show_time_header = true
          last_time = occurrence.hour
        end
      end
    end
  end

  def to_s
    return self.hour.strftime("%H:%M") if self.hour
    super
  end

  # Shifts dates a week forward on all occurrences
  def self.back_to_future
    ActiveRecord::Base.connection.execute(
      'update occurrences set date = ADDDATE(date, 7);');
  end

  # Correct dates, set date field to contain both date and hours of occurrence
  def self.correct_dates
    ActiveRecord::Base.connection.execute(
      'update occurrences set date = timestamp(date(date), time(hour)) where date is not null and hour is not null;');
  end

  # Expose week-day-only repeating events to the month ahead
  def self.expose(props = {})
    offset, limit, max_date = 0, 20, Date.today + 1.month
    while true
      occurrences = Occurrence.find(:all,
        :conditions => "date is null and dayOfWeek is not null",
        :order => 'dayOfWeek',
        :offset => offset,
        :limit => limit)

      break if occurrences.length == 0
      occurrences.each do |occurrence|
        if props[:revert]
          occurrence.unexpose
        else
          occurrence.expose_till max_date
        end
      end
      offset += occurrences.length
    end
  end

  def expose_till(max_date)
    latest, new_date = nil, Date.today
    # Select latest occurrence of the same event already exposed
    latest = Occurrence.find(:last,
      :conditions => ["event_id = ? and dayOfWeek = ? and hour = ? and date is not null", self.event_id, self.dayOfWeek, self.hour])
    while true
      new_date = (latest ? (latest.date + 1.week) : Time.now.getutc).beginning_of_week + self.dayOfWeek.days
      new_date = new_date.advance(:hours => self.hour.hour, :minutes => self.hour.min, :seconds => self.hour.sec)
      break if (new_date > max_date)
      latest = Occurrence.new
      attrs = self.attributes.merge(:date => new_date, :repeat => 'N', :id => nil)
      attrs.delete(:id)
      latest.attributes = attrs
      latest.labels = self.labels # Expose categories to the new occurrence
      latest.save!
    end
  end

  def unexpose
    ActiveRecord::Base.connection.execute(
      "delete from occurrences where event_id = #{self.event_id} and dayOfWeek = #{self.dayOfWeek} and hour = '#{self.hour.to_s(:db)}' and date is not null");
  end

  # This will reassign categories from appropriate events to its occurrences
  def self.correct_categories
    ActiveRecord::Base.connection.execute(
      ["insert into occurrences_attributes (occurrence_id, attribute_id)",
        "select occurrences.id, events_attributes.attribute_id",
        "from occurrences",
          "inner join events on events.id = occurrences.event_id",
          "inner join events_attributes on events_attributes.event_id = events.id",
        "where occurrences.id is not null",
          "and events.id is not null",
          "and events_attributes.attribute_id is not null",
          "and not exists (",
            "select *",
            "from occurrences_attributes",
            "where occurrences_attributes.attribute_id = events_attributes.attribute_id",
            "and occurrences_attributes.occurrence_id = occurrences.id",
          ");"].join(' '))
  end

  def self.delete_duplicates
    # Remove duplicates from occurrences
    ActiveRecord::Base.connection.execute(
      "delete from occurrences
        using occurrences, occurrences as duplicates
        where occurrences.ID > duplicates.ID
            and occurrences.date = duplicates.date
            and occurrences.event_id = duplicates.event_id")

    # Cleanup categories data
    ActiveRecord::Base.connection.execute(
      "delete from occurrences_attributes
        where not exists (select *
          from occurrences
          where occurrences.id = occurrences_attributes.occurrence_id)")
  end

end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: occurrences
#
#  id         :integer(4)      not null, primary key
#  date       :datetime
#  dayOfWeek  :integer(4)
#  from       :datetime
#  to         :datetime
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  place_id   :integer(4)      not null
#  event_id   :integer(4)      not null
#  hour       :time
