require 'common'
require_tree "models"

ActiveRecord::Base.logger = Logger.new(STDOUT)

begin
  events = Event.find(:all, :conditions => 'thumbnail IS NOT NULL')
  for event in events
    begin
      grab_picture(event, event.thumbnail, false)
    rescue Interrupt
      raise
    rescue Exception => e
      puts e.message
    end
  end
end
