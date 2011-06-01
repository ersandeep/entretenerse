require 'net/http'

namespace :crawler do
  desc "Do all currently opened tasks from crawlers"
  task :crawl => :environment do
#    while CrawlerLog.count(:conditions => ['status = ? or status = ?', :pull, :push]) > 0
      Crawler.pull :sleep => 10, :limit => 5
      Crawler.push :sleep => 10, :limit => 5
#    end
  end

  desc "Loads default configs from config/crawlers/*.yml to database"
  task :load_config => :environment do
    Dir.glob("#{Rails.root}/config/crawlers/*.yml").each do |file|
      config = YAML.load(File.open(file))
      crawler = Crawler.find_by_name(config['name'].strip) || Crawler.new(config)
      crawler.attributes = config unless crawler.new_record?
      crawler.save
    end
  end

# /static/archivos/14557 |
#| /static/archivos/14264 
  desc "Loads images to local store"
  task :fetch_images => :environment do
    while !(events = Event.find(:all,
      :conditions => ["image_url not like ?", "/th%"],
      :limit => 10)).blank?
      events.each do |event|
        uri = URI.parse(event.image_url)
        Net::HTTP.start(uri.host) do |http|
          resp = http.get(uri.path)
          content_type = resp['content-type']
          image_type = content_type.split('/')[1] unless content_type.blank?
          puts image_type
          new_url = "/thumbnails/event_#{event.id}.#{image_type || 'jpeg'}"
          open("#{Rails.root}/public#{new_url}", 'wb' ) do |file|
            file.write(resp.body)
          end
          event.update_attribute('image_url', new_url)
        end
        sleep(10)
      end
    end
  end
end
