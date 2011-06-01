require 'spec_helper'

describe Crawler do
  before(:each) do
    @crawler = Crawler.new({
      :name => 'test',
      :url => 'home_page_url',
      :status => :active,
      :running => false,
      :config => { :groups => 'selector' },
      :log_entries => [CrawlerLog.new(:url => '/link', :status => :pull, :crawler_id => 1), CrawlerLog.new(:url => '/link', :status => :pull, :crawler_id => 1)]})
  end
  describe 'Startup' do
    it 'should set running flag' do
      @crawler.start
      @crawler.should be_running
    end
    it 'should create a pull log entry and copy config there if there is no stopped entries' do
      @crawler.log_entries.should_receive(:find_all_by_status).with(:stopped).and_return([])
      @crawler.log_entries.should_receive(:create).with hash_including(:url => 'home_page_url', :status => :pull, :config => @crawler.config)
      @crawler.start
    end
    it 'should pull all stopped entries' do
      stopped_entries = [CrawlerLog.new, CrawlerLog.new]
      @crawler.log_entries.should_receive(:find_all_by_status).with(:stopped).and_return(stopped_entries)
      stopped_entries.each { |entry| entry.should_receive(:update_attribute).with(:status, :pull) }
      @crawler.start
    end
  end
  describe 'Stopping' do
    it 'should clear running flag' do
      @crawler.running = true
      @crawler.should_receive(:save!)
      @crawler.stop
      @crawler.should_not be_running
    end
    it 'should set stopped status to all log entries' do
      @crawler.log_entries.each { |entry| entry.should_receive(:update_attribute).with(:status, :stopped) }
      @crawler.stop
    end
  end
  describe 'Reseting' do
    it 'should stop the crawler' do
      @crawler.should_receive(:stop)
      @crawler.reset
    end
    it 'should remove all log entries with stopped status' do
      stopped_entries = [CrawlerLog.new, CrawlerLog.new]
      @crawler.stub!(:stop)
      @crawler.log_entries.should_receive(:find_all_by_status).with(:stopped).and_return(stopped_entries)
      stopped_entries.each { |entry| entry.should_receive(:delete) }
      @crawler.reset
    end
  end
  describe 'Pulling' do
    it 'should do nothing if there is no pull entries' do
      @crawler.log_entries.should_receive(:where).with(hash_including(:status => :pull)).and_return([])
      @crawler.pull
    end
    it 'should pull all log entries with pull status' do
      pull_entry = CrawlerLog.new({:url => 'home_page_url', :status => :pull})
      pull_entry.should_receive(:pull)
      @crawler.log_entries.should_receive(:where).with(hash_including(:status => :pull)).and_return([pull_entry])
      @crawler.pull
    end
  end
  describe 'Pushing' do
    it 'should push all log entries with push status' do
      push_entry = CrawlerLog.new(:url => 'home_page_url', :status => :push)
      push_entry.should_receive(:push)
      @crawler.log_entries.should_receive(:where).with(hash_including(:status => :push)).and_return([push_entry])
      @crawler.push
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