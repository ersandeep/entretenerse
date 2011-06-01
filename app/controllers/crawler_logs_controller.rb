class CrawlerLogsController < ApplicationController

  def show
    @log_entry = CrawlerLog.find(params[:id])
    render :layout => !request.xhr?
  end

  def update
    @log_entry = CrawlerLog.find(params[:id])
    @log_entry.config = YAML.load(params[:crawler_log][:config]).to_options
    @log_entry.save
  rescue
      flash[:error] = "Crawler Log's configuration YAML was incorrect. Import failed."
  ensure
    redirect_to :action => :edit
  end

  def proceed
    @log_entry = CrawlerLog.find(params[:id])
    if @log_entry.status == :pull
      @log_entry.pull
    elsif @log_entry.status == :push
      @log_entry.push
    end
    redirect_to crawler_path(@log_entry.crawler, :page => params[:page])
  end

  def restart
    @log_entry = CrawlerLog.find(params[:id])
    @log_entry.status = :pull
    @log_entry.save
    redirect_to crawler_path(@log_entry.crawler)
  end

  def pull_data
    @log_entry = CrawlerLog.find(params[:id])
    render :layout => false
  end

  def push_data
    @log_entry = CrawlerLog.find(params[:id])
    render :layout => false
  end

end
