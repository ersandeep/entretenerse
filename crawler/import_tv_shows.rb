require 'common'
require_tree "models"


@days= {'lun'=>1,'mar'=>2,'mie'=>3,'mié'=>3,'jue'=>4,'vie'=>5,'sá'=>6,'sab '=>6,'dom'=>0}

@operadores= {'TLC'=>'Telecentro','CV'=>'Cablevisión','MC'=>'Multicanal','DTV'=>'DirectTV'}

def parse_occurrence(str, place, event)
  o = nil
  puts "Buscando Ocurrencias en " + str
  @days.keys.each do |k|
    if ( str.include? k)
      o = Occurrence.find_or_create_by_place_id_and_event_id_and_dayOfWeek_and_repeat_and_hour(place.id, event.id, @days[k], 'S', Time.parse(str.match(/[0123456789]+:[0123456789]+/).to_s))
    end
  end
  if ( o == nil)
    puts "No se encontro ningun horario para " + str
  end
end

def add_performer(rol, performers,event)
  
  rol = rol.gsub(" y ",",")
  directores = performers
  
  if ( directores == nil )
    puts "Esta peli no tiene " + rol
  else
    dirs = directores.split(",")
    dirs.each do |director|
      i = 0  
      director = director.strip
      pd = Performer.find(:first,:conditions=>["name = ?",director])
      if pd == nil
        pd = Performer.new
        pd.name = director
        pd.save
      end
      i+=1
      if ( !event.performers.exists?(pd) )
        perf = Performance.new
        perf.performer = pd
        perf.rol = rol
        perf.order = i
        perf.event = event
        perf.save
      end
    end    
  end
end


def import_shows(movs)
  
  sponsor = Sponsor.find(:first,:conditions=>["name = ?","Nektra"])
  if ( sponsor == nil )
    raise "No se encuentra el Sponsor por Defecto 'Nektra'" 
  end

  cat = Category.find(:first, :conditions=> { :name => "TV"})
  
  movs.each do |m|
    begin
      event = Event.find(:first,:conditions =>["title = ? AND category_id = ? ", m.show_name.strip, cat.id])
      if ( event == nil ) 
        puts "Importing " + m.show_name
        event = Event.new
        event.title = m.show_name.strip
        event.text = m.sinopsis
        event.category_id = cat.id
        if ( event.text == nil ) 
          event.text = "Sin Sinopsis"
        end
        event.sponsor = sponsor
        event.save
      end
    
      if ( m.genero != nil )
        find_or_add_attributes(event, m.genero.split("-"), 'Rubro TV', 'Otros', 'TV', 'Rubros TV')
      end

      if ( m.channels != nil )
        #Me fijo si el canal esta en los operadores, sino lo agrego
        channels = m.channels.slice(2,m.channels.length).gsub(/\d/, '').gsub(/ /, '').split('/')
        channels.each do |c|
          operador_name = @operadores.key?(c)? @operadores.values_at(c) : 'Otros'
          operador = Attribute.find(:first,:conditions=>["attributes.name = ? and attributes.value = ? AND parents_attributes.name = ? AND parents_attributes.value = ?", operador_name, operador_name, 'Operador TV', operador_name], :include => [:parent])
          add_attributes(event, [operador], true)
        end
      end

      event.save

    rescue Exception => e
      puts e
      puts "Error al guardar evento "
    end
  end
end

def import_channels(shows)
  
  cat = Category.find(:first, :conditions=> { :name => "TV"})
  
  shows.each do |show|
    
    if ( show.channel_name == nil)
      return
    end
    puts "Canal: " + show.channel_name.strip
    
    place = Place.find(:first,:conditions=>["name = ?", show.channel_name.strip])
    if ( place == nil )
      place = Place.new
      place.name = show.channel_name.strip
      address = show.channels
      place.lat = 0
      place.long = 0
      place.save
    end
    
    name = show.show_name.strip
    
    event = Event.find(:first,:conditions =>["title = ? AND category_id = ?", name, cat.id])
    if ( event != nil)
      dt = Time.zone.parse('%s %s' % [show.date, show.horario.match(/[0123456789]+:[0123456789]+/).to_s])
      o = Occurrence.find_or_create_by_place_id_and_event_id_and_date_and_repeat_and_hour(place.id, event.id, dt.to_date, 'N', dt)  
      find_or_add_attributes(o, place.name, 'Canal TV', 'Variedades', 'TV', 'Canales TV')
    else
      puts "Show Not Found: " + name
    end
  end    
end


begin
  shows = TvShow.find(:all)
  
  old_occurrences = Occurrence.find(:all, :joins => {:event => [:category]}, :select => '`occurrences`.`id`',
                                    :conditions => Occurrence.merge_conditions({:event => {:categories => {:name => "TV"}}},
                                                                               ['`occurrences`.`date` < ?', Time.zone.today]))
  
  Occurrence.destroy(old_occurrences)
  
  import_shows(shows)
  import_channels(shows)
rescue Exception => e
  puts e.message
  puts e.backtrace
end  

