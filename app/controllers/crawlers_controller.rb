require 'open-uri'
require 'hpricot'

class CrawlersController < ApplicationController
  layout 'index'

  # GET /crawlers
  def index
    @crawlers = Crawler.all
    render :layout => !request.xhr?
  end

  # GET /crawlers/1
  def show
    @crawler = Crawler.find(params[:id])
    @log_entries = @crawler.log_entries.paginate :page => params[:page]
  end

  def proceed
    crawlers = Crawler.find(:all, :conditions => ["start_at < ?", Time.new])
    crawlers.each { |crawler| cralwer.start }
    pull_entry = CrawlerLog.find(:first, :conditions => ["status = ? and crawler_id = ?", :pull, params[:id]])
    pull_entry.pull if pull_entry
    push_entry = CrawlerLog.find(:first, :conditions => ["status = ? and crawler_id = ?", :push, params[:id]])
    push_entry.push if push_entry
    render :text => 'ok'
  end

  # GET /crawlers/new
  def new
    @crawler = Crawler.new
  end

  # GET /crawlers/1/edit
  def edit
    @crawler = Crawler.find(params[:id])
    render :layout => !request.xhr?
  end

  def configuration
    @crawler = Crawler.find(params[:id])
    render :text => '<pre>' + @crawler.config.to_yaml + '</pre>', :layout => !request.xhr?
  end

  def activate
    redirect_to crawlers_path and return unless request.post?
    crawler = Crawler.find(params[:id])
    crawler.status = 'active'
    crawler.save
    flash[:notice] = t('crawlers.index.activated', :name => crawler.name)
    redirect_to crawlers_path
  end

  def deactivate
    redirect_to crawlers_path and return unless request.post?
    crawler = Crawler.find(params[:id])
    crawler.status = 'inactive'
    crawler.save
    flash[:notice] = t('crawlers.index.deactivated', :name => crawler.name)
    redirect_to crawlers_path
  end

  def run
    redirect_to crawlers_path and return unless request.post?
    crawler = Crawler.find(params[:id])
    crawler.running = true
    crawler.save
    flash[:notice] = t('crawlers.index.started', :name => crawler.name)
    redirect_to crawlers_path
  end

  def proxy
    render :layout => false and return if params[:url].blank?
    url_param = params[:url]
    url_param = "http://#{url_param}" if url_param && !url_param.start_with?('http')
    url = URI.parse(url_param)
    domain = (url.scheme.blank? ? "http://" : "#{url.scheme}://") + url.host
    doc = Hpricot(open(url))
    doc.search('script').remove
    doc.search('link') do |stylesheet|
      stylesheet['href'] = domain + stylesheet['href']
    end
    doc.search('a') do |link|
      link['href'] = 'proxy?url=' + CGI::escape(domain + link['href']) unless link['href'].blank?
    end
    doc.search('img') do |image|
      image['src'] = domain + image['src']
    end
    render :text => doc.to_html
  end

  # POST /crawlers
  # POST /crawlers/new
  def create
    @crawler = Crawler.new(params[:crawler])
    if @crawler.save
      redirect_to(edit_crawler_path(@crawler), :notice => 'Crawler was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /crawlers/1
  def update
    @crawler = Crawler.find(params[:id])

    respond_to do |format|
      if @crawler.update_attributes(params[:crawler])
        format.html { redirect_to(@crawler, :notice => 'Crawler was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @crawler.errors, :status => :unprocessable_entity }
      end
    end
  end

  def import
    @crawler = Crawler.find(params[:id])
    @crawler.config = YAML.load(params[:crawler][:config]).to_options
    if @crawler.save!
      flash[:notice] = "Crawler configuration imported successfully"
    end
  rescue
      flash[:error] = "Crawler configuration YAML was incorrect. Import failed."
  ensure
    redirect_to :action => :edit
  end

  # DELETE /crawlers/1
  # DELETE /crawlers/1.xml
  def destroy
    @crawler = Crawler.find(params[:id])
    @crawler.destroy

    respond_to do |format|
      format.html { redirect_to(crawlers_url) }
      format.xml  { head :ok }
    end
  end

  def start
    @crawler = Crawler.find(params[:id])
    @crawler.start
    redirect_to crawler_path(@crawler)
  end

  def stop
    @crawler = Crawler.find(params[:id])
    @crawler.stop
    redirect_to crawler_path(@crawler)
  end

  def reset
    @crawler = Crawler.find(params[:id])
    @crawler.reset
    redirect_to crawler_path(@crawler)
  end
end
