class FrontendStaticController < ApplicationController

  def find_attributes()
    find_attributes_impl
    render :html=>@atts,:template => "event/static.rhtml", :layout => false
  end
  
 def find_attributes_impl()
    @att_name =  params["att_name"]
    if ( @att_name == nil)
      @att_name = "Rubro"
    end

    @attribute = Attribute.find(:first,:conditions=>["value = ?", @att_name])
    @top = @att_name
    if ( @attribute == nil)
      @atts =  Attribute.find(:all,:conditions=>["parent_id is null"])
    else
      logger.info("Finding attributes for " + @att_name)
      @atts =  Attribute.find(:all,:conditions=>["parent_id = ?", @attribute.id])
      @top = @attribute.to_s_long
    end
  end
  
  def find_eventos_semana()
    @event_scope = "Semana"
    find_attributes_impl
    @events = Event.find(:all, :include=>[:labels], :conditions=>["attributes.value = ?", @attribute.value])
    render :html=>@atts,:template => "event/static.rhtml", :layout => false
  end

  def find_eventos_hoy()
    @event_scope = "Hoy" 
    find_attributes_impl
    @events = Event.find(:all, :include=>[:labels], :conditions=>["attributes.value = ?", @attribute.value])
    logger.info("Found " + @events.length.to_s + " events.")
    render :html=>@atts,:template => "event/static.rhtml", :layout => false
  end
end
