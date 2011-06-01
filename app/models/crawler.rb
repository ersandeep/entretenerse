class Crawler < ActiveRecord::Base
  has_many :log_entries, :class_name => 'CrawlerLog', :dependent => :destroy
  serialize :config
  validates_presence_of :name
  validates_presence_of :url

  def config_import=(string)
    self.config = YAML.load(string)
  end

  def config_import
    self.config.to_yaml unless self.config.blank?
  end

  def active?
    status == 'active'
  end

  def self.start
    Crawler.all.each { |crawler| crawler.start }
  end

  def stopped?
    self.log_entries.exists?(:status => :stopped)
  end

  # Starts crawling data with the crawler
  def start
    self.running = true
    # Reschedule started at to week forward
    self.start_at = self.start_at + 1.week if self.start_at && self.start_at < Time.now
    self.save!
    stopped_entries = self.log_entries.find_all_by_status(:stopped)
    if stopped_entries && stopped_entries.length > 0
      stopped_entries.each { |entry| entry.update_attribute(:status, :pull) }
    else
      self.log_entries.create({ :url => url, :status => :pull, :config => config.to_options }) # Puller will do the rest
    end
  end

  def stop
    self.running = false
    ActiveRecord::Base.connection.execute("update crawler_logs set status = 'stopped' where crawler_id = #{self.id} and status != 'done';")
    self.save!
  end

  def reset
    self.stop
    ActiveRecord::Base.connection.execute("delete from crawler_logs where crawler_id = #{self.id}")
  end

  # Pulls the data from the web for all configured crawlers in the database
  def self.pull(params={})
    Crawler.find(:all, :limit => params[:limit] ? params[:limit] : nil ).each do |crawler|
      crawler.pull(params)
    end
  end

  # Pushes data collected by 'pull' method for all configured crawlers to database
  def self.push(params={})
    Crawler.find(:all, :limit => params[:limit] ? params[:limit] : nil ).each do |crawler|
      crawler.push(params)
    end
  end

  # Pulls the data from the web
  def pull(params={})
    self.log_entries.where(:status => :pull).each do |entry|
      entry.pull
      sleep(params[:sleep]) if params[:sleep]
    end
  end

  # Pushes data collected with 'pull' method to the database
  def push(params={})
    log_entries.where(:status => :push).each do |entry|
      entry.push
      sleep(params[:sleep]) if params[:sleep]
    end
  end
end


# == Schema Info
# Schema version: 20110328181217
#
# Table name: crawlers
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)     not null
#  url         :string(255)     not null
#  created_at  :datetime
#  updated_at  :datetime
#  status      :string(255)
#  running     :boolean(1)
#  config      :text
#  category_id :integer(4)      not null
#  started_at  :datetime
