class OccurrenceDto < Struct.new(:place, :place_dir, :hours); end

class EventController < ApplicationController
  before_filter :set_locale

  def view
    @occurrence = Occurrence.find(params[:id])
    render :layout => request.xhr? ? false : 'index'
  end

  def rate
    event = Event.find(params[:id])
    event.rate params[:event][:rating].to_i
    event.save
    if request.xhr?
      render :json => { :avg => event.rating, :count => event.rated_count }.to_json
    else
      redirect_to :back
    end
  end

  def detail
    @from = params["from"]
    @useragent = request.user_agent
    #robot_key = /googlebot/
    robot_key = /firefox/
    if (@useragent.downcase =~ robot_key && @from == "static")
      aux =params["id"]
      params[:show_event_id] = aux
      logger.info "Redirecting to Home Page"
      redirect_to :controller=>'/',:action => 'index', :show_event_id=>aux
    else
      @id =  params["id"].to_i
      @occurrence_id = params["occurrence_id"].to_i
      @event = Event.find(@id,
        :include => [:labels, :category, :comments, :occurrences, :places])

      h = {}
      @event.labels.each do |l|
        v = h[l.name.urlize]
        if ( v == nil)
          h[l.name.urlize] = l.value.urlize
        else
          h[l.name.urlize] += "-" + l.value.urlize
        end
      end

      @labels = ""
    
      h.keys.each do |k|
        @labels += "&" + k + "=" + h[k]
      end
    
      @occurrences = []
      @event.occurrences.each do |oc|
      
      oc_dto = nil;
      @occurrences.each do |o|
        if ( o.place == oc.place.name)
          oc_dto = o
        end
      end

      if ( oc_dto == nil)
        oc_dto = OccurrenceDto.new
        oc_dto.place = oc.place.name
        if (oc.place.address && oc.place.town && oc.place.state)
          oc_dto.place_dir = oc.place.address+", "+oc.place.town+", "+oc.place.state
        end
        @occurrences << oc_dto
      end

      if ( oc.id == @occurrence_id)
        @occurrence = oc_dto
      end
      if (oc_dto != nil && oc_dto.hours == nil)
        oc_dto.hours = oc.to_s 
      else
        oc_dto.hours+= ", " + oc.to_s
      end
    end
    
    @occurrences.delete(@occurrence)
    logger.info "Cantidad de Salas " + @occurrences.length.to_s
    if @from == nil || @from == "static"
      render :html=>@atts,:template => "event/detail.rhtml", :layout => false
    else
      render :html=>@atts,:template => "event/innerdetail.rhtml", :layout => false
    end
    end
  end
end
