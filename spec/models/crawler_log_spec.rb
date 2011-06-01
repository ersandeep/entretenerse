require 'spec_helper'

describe CrawlerLog do
  describe "Validations" do
    before :each do
      @log_entry = CrawlerLog.new(
        :url => 'page_url',
        :crawler_id => 1,
        :status => :pull
      )
    end
    it "should be valid with url, crawler id and status specified" do
      @log_entry.should be_valid
    end
    it "should not be valid without url" do
      @log_entry.url = nil
      @log_entry.should_not be_valid
    end
    it "should not be valid without crawler id specified" do
      @log_entry.crawler_id = nil
      @log_entry.should_not be_valid
    end
    it "should not be valid without status specified" do
      @log_entry.status = nil
      @log_entry.should_not be_valid
    end
  end

  describe 'Pulling' do
    before :each do
      @params = {
        :url => "file://#{Rails.root}/spec/fixtures/pull-scraping.html",
        :status => :pull,
        :config => {},
        :crawler_id => 1,
        :crawler => Crawler.new(
          :name => "Cinema in Buenos Aires",
          :url => "http://www.cinesargentinos.com.ar/horarios",
          :config => {})
      }
    end
    it "should save the page content into the log entry itself" do
      log_entry = CrawlerLog.new @params
      log_entry.should_receive(:save!)
      log_entry.pull
      file = File.open(log_entry.url.gsub('file://', ''), 'rb')
      log_entry.content.gsub(' ', '').should == file.read.gsub(' ', '')
    end
    it "should change status of the log entry to 'push' once finished" do
      log_entry = CrawlerLog.new @params
      log_entry.should_receive(:save!)
      log_entry.pull
      log_entry.status.should == :push
    end
    describe "Scraping" do
      it "should contain at least one group even if group selector is not specified" do
        log_entry = CrawlerLog.new @params
        log_entry.pull
        log_entry.pull_data.should be_instance_of(Array)
        log_entry.pull_data.should_not be_blank
      end
      it "should find groups" do
        log_entry = CrawlerLog.new @params.merge :config => { :group => '//div[@class="group"]' }
        log_entry.pull
        log_entry.pull_data.should be_instance_of(Array)
        log_entry.pull_data.should_not be_blank
      end
      it "should find paging links" do
        log_entry = CrawlerLog.new @params.merge :config => { :pages => '//div[@class="paging"]/a' }
        log_entry.pull
        log_entry.pull_data.should be_any { |pull_data| !pull_data[:pages].blank? }
      end
      it "should find follow links within groups" do
        log_entry = CrawlerLog.new @params.merge :config => {
          :links => '//a',
          :group => '//div[@class="group"]'
        }
        log_entry.pull
        log_entry.pull_data.should be_any { |pull_data| !pull_data[:links].blank? }
      end
      describe "find event data" do
        it "should find event title" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :event_title => '//a',
            :group => '//div[@class="group"]'
          }
          log_entry.pull
          log_entry.pull_data.should be_any { |pull_data| !pull_data[:event_title].blank? }
        end
        it "should find event description" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :event_description => '/',
            :group => '//div[@class="group"]'
          }
          log_entry.pull
          log_entry.pull_data.should be_any { |pull_data| !pull_data[:event_description].blank? }
        end
        it "should find event image" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :event_image_url => '//img',
            :group => '//div[@class="group"]'
          }
          log_entry.pull
          log_entry.pull_data.should be_any { |pull_data| !pull_data[:event_image_url].blank? }
        end
      end
      describe "find the place data" do
        it "should find name" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :place_name => '//div[@class="place"]',
            :group => '//div[@class="group"]'
          }
          log_entry.pull
          log_entry.pull_data.should be_any { |pull_data| !pull_data[:place_name].blank? }
        end
        it "should find address" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :place_address => '//div[@class="place"]/div[@class="address"]',
            :group => '//div[@class="group"]'
          }
          log_entry.pull
          log_entry.pull_data.should be_any { |pull_data| !pull_data[:place_address].blank? }
        end
        it "should find town" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :place_town => '//div[@class="place"]/div[@class="town"]',
            :group => '//div[@class="group"]'
          }
          log_entry.pull
          log_entry.pull_data.should be_any { |pull_data| !pull_data[:place_town].blank? }
        end
        it "should find state" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :place_state => '//div[@class="place"]/div[@class="state"]',
            :group => '//div[@class="group"]'
          }
          log_entry.pull
          log_entry.pull_data.should be_any { |pull_data| !pull_data[:place_state].blank? }
        end
        it "should find country" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :place_country => '//div[@class="place"]/div[@class="country"]',
            :group => '//div[@class="group"]'
          }
          log_entry.pull
          log_entry.pull_data.should be_any { |pull_data| !pull_data[:place_country].blank? }
        end
        it "should find phone" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :place_phone => '//div[@class="place"]/div[@class="phone"]',
            :group => '//div[@class="group"]'
          }
          log_entry.pull
          log_entry.pull_data.should be_any { |pull_data| !pull_data[:place_phone].blank? }
        end
      end
      describe "find the occurrences data" do
        it "should find occurrences time" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :time => '//div[@class="time"]',
            :group => '//div[@class="group"]'
          }
          log_entry.pull
          log_entry.pull_data.each { |pull_data| pull_data[:time].should_not be_blank }
        end
        it "should find occurrences categories" do
          log_entry = CrawlerLog.new @params.merge :config => {
            :group => '//div[@class="group"]',
            :category => 'div[@class="category"]'
          }
          log_entry.pull
          log_entry.pull_data.each { |pull_data| pull_data[:category].should_not be_blank }
        end
      end
    end
  end

  describe 'Pushing' do
    before :each do
      @params = {
        :url => "file://#{Rails.root}/spec/fixtures/pull-scraping.html",
        :status => :push,
        :crawler_id => 1,
        :config => {},
        :pull_data => [{}],
        :crawler => Crawler.new(
          :id => 1,
          :name => "Cinema in Buenos Aires",
          :url => "http://www.cinesargentinos.com.ar/horarios"),
        :push_data => {
          :place_name => 'Place Name',
          :place_address => 'Place Address',
          :place_phone => '123-456-789',
          :event_title => 'Event Title',
          :event_description => 'This is event description',
          :event_thumbnail => '/thumbnail',
          :event_image_url => '/image_url',
          :occurrence_date => '1.02.04'
        }
      }
    end
    it 'should change status to "done" once finished' do
      log_entry = CrawlerLog.new @params
      log_entry.should_receive(:save!)
      log_entry.push
      log_entry.status.should == :done
    end
    describe 'Page Links' do
      before :each do
        @log_entry = CrawlerLog.new @params.merge(
          :pull_data => [{ :pages => ['/link1', '/link2', '/link3', '/link4'] }]
        )
      end
      it 'should be recreated with page links urls' do
        @log_entry.push
        @log_entry.children.map(&:url).each_with_index do |url, index|
          url.should include(@log_entry.pull_data.first[:pages][index])
        end
      end
      it 'should generate absolute urls' do
        @log_entry.push
        @log_entry.children.map(&:url).each { |url| url.should match('^http://www.cinesargentinos.com.ar') }
      end
      it 'should be expanded with pull status' do
        @log_entry.push
        @log_entry.children.should be_all { |entry| entry.status == :pull }
      end
      it 'should have the same config' do
        @log_entry.push
        @log_entry.children.should be_all { |entry| entry.config == @log_entry.config }
      end
      it 'should have the same push data' do
        @log_entry.push
        @log_entry.children.should be_all { |entry| entry.push_data == @log_entry.push_data }
      end
    end
    describe 'Follow Links' do
      before :each do
        @log_entry = CrawlerLog.new @params.merge(
          :pull_data => [
            { :links => ['/link1', '/link2', '/link3', '/link4'], :event_description => 'description', :place_name => 'New York', :place_phone => '123-456-789' },
            { :links => ['/link5', '/link6', '/link7', '/link8'], :event_description => 'description of second group', :place_name => 'New York Second', :place_phone => '321-654-987' }
          ],
          :push_data => { :place_name => 'Old New Place', :time => 'some time' },
          :config => { :group => '', :links => '', :config => { 'group' => '//div[@class="doesnotmatter"]', 'links' => '//a' } }
        )
        @log_entry.save!
      end
      it 'should be recreated with links url' do
        @log_entry.push
        @log_entry.children.map(&:url).each_with_index do |url, index|
          url.should include(@log_entry.pull_data.collect{|data| data[:links]}.flatten.compact()[index])
        end
      end
      it 'should be expanded with pull status' do
        @log_entry.push
        @log_entry.children.should be_all { |entry| entry.status == :pull }
      end
      it 'should generate absolute urls' do
        @log_entry.push
        @log_entry.children.map(&:url).each { |url| url.should match('^http://www.cinesargentinos.com.ar') }
      end
      describe "Config" do
        it 'should clone corresponding level of the original config' do
          @log_entry.push
          @log_entry.children.should be_all { |entry| entry.config == @log_entry.config[:config].to_options }
        end
      end
      describe 'Push Data' do
        it "should contain copy of original entry's push data merged with pull data related to the group where the link were found" do
          @log_entry.push
          @log_entry.children.each do |entry|
            group = @log_entry.pull_data.select do |pull_data|  # Search for link
              pull_data[:links] && pull_data[:links].include?(URI.parse(entry.url).path)
            end
            entry.push_data.should == @log_entry.push_data.merge(group.first).reject { |key, value| key == :links || key == :pages }
          end
        end
        it 'should not contain links' do
          @log_entry.push
          @log_entry.children.each do |entry|
            entry.push_data.should_not have_key(:links)
          end
        end
        it 'should not contain paging values' do
          @log_entry.pull_data[0][:pages] = ['/paging', '/paging']
          @log_entry.push
          @log_entry.children.each do |entry|
            entry.push_data.should_not have_key(:pages)
          end
        end
      end
    end
    describe 'Place' do
      before :each do
        @log_entry = CrawlerLog.new @params
        @place_hash = {
          :name => @log_entry.push_data[:place_name],
          :address => @log_entry.push_data[:place_address],
          :phone => @log_entry.push_data[:place_phone]
        }
      end
      describe 'should be constructed from keys starting from place_' do
        it 'should find identical place if name, address, town, state, country and phone are the same' do
          place = Place.new @place_hash
          place.should_receive(:save)
          Place.should_receive(:where).with(hash_including(@place_hash)).and_return([place])
          place.stub!(:new_record?).and_return(false)
          @log_entry.push
        end
        it 'should save new place if there is no identical place' do
          place = Place.new @place_hash
          place.should_receive(:save)
          Place.should_receive(:where).with(hash_including(@place_hash)).and_return([])
          Place.should_receive(:new).with(hash_including(@place_hash)).and_return(place)
          place.stub!(:new_record?).and_return(false)
          @log_entry.push
        end
      end
    end
    describe 'Event' do
      before :each do
        @log_entry = CrawlerLog.new @params
        @event_hash = {
          :title => @log_entry.push_data[:event_title],
          :description => @log_entry.push_data[:event_description],
          :image_url => @log_entry.push_data[:event_image_url]
        }
      end
      describe 'should be constructed from keys starting from event_' do
        it 'and should find identical event if title, description and image_url are the same' do
          event = Event.new @event_hash
          event.stub!(:new_record?).and_return(false)
          event.should_receive(:save)
          Event.should_receive(:where).with(hash_including(@event_hash)).and_return([event])
          @log_entry.push
        end
        it 'and should save new event if there is no identical event' do
          event = Event.new @event_hash
          event.should_receive(:save)
          Event.should_receive(:where).with(hash_including(@event_hash)).and_return([])
          Event.should_receive(:new).with(hash_including(@event_hash)).and_return(event)
          event.stub!(:new_record?).and_return(false)
          @log_entry.push
        end
      end
    end
    describe 'Occurrence' do
      before :each do
        @log_entry = CrawlerLog.new @params
        @occurrence_hash = {
          :date => @log_entry.push_data[:occurrence_date]
        }
      end
      describe 'should be constructed from keys starting from occurrence_' do
        it 'should find identical occurrence if date, place_id and event_id are the same' do
          occurrence = Occurrence.new @occurrence_hash
          occurrence.should_receive(:save)
          Occurrence.should_receive(:where).with(hash_including(@occurrence_hash)).and_return([occurrence])
          @log_entry.push
        end
        it 'should save new event if there is no identical occurrence' do
          occurrence = Occurrence.new @occurrence_hash
          occurrence.should_receive(:save)
          Occurrence.should_receive(:where).with(hash_including(@occurrence_hash)).and_return([])
          Occurrence.should_receive(:new).with(hash_including(@occurrence_hash)).and_return(occurrence)
          @log_entry.push
        end
      end
    end
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