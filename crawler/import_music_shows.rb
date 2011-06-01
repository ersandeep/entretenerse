require 'common'


@months= {'Enero'=>'01','Febrero'=>'02','Marzo'=>'03','Abril'=>'04','Mayo'=>'05','Junio'=>'06',
          'Julio'=>'07','Agosto'=>'08','Septiembre'=>'09','Octubre'=>'10','Noviembre'=>'11','Diciembre'=>'12'}

def parse_occurrence(fecha, horario, place, event)
  o = nil

  @months.each_pair {|key, value| 
    fecha = fecha.gsub(" de #{key} de ","-#{value}-")
    horario = horario.gsub(" de #{key} de ","-#{value}-")
    horario = horario.gsub(/[0-9]+\-[0-9]+\-[0-9]+/,"")
  }

  #fecha = fecha.gsub(" de Julio de ","-07-")
  #fecha = fecha.gsub(" de Agosto de ","-08-")
  
  puts "Buscando Ocurrencias en :" + fecha
  
  puts "FECHAS : " + fecha.scan(/[0-9]+\-[0-9]+\-[0-9]+/).length.to_s
  matches = fecha.scan(/[0-9]+\-[0-9]+\-[0-9]+/)
  if ( matches != nil)
    matches.each do |m|
      horario = horario.match(/[0123456789]+:*[0123456789]*/).to_s
      if (horario.length == 2)
        horario += ":00"
      end
      if (horario != nil && horario.length > 0)
        dt = Time.zone.parse(m.to_s.split('-').reverse.join('-'))
        if (horario.slice(0,2) == "24")
          horario = horario.gsub("24:","00:")
          dt += 1.day
        end
        t = horario.split(':').map { |p| p.to_i }
        dt += t[0].hours + t[1].minutes
        puts 'E: ' + event.id.to_s + '   F y H: ' + dt.to_s
        o = Occurrence.find_or_create_by_place_id_and_event_id_and_date_and_repeat_and_hour(place.id, event.id, dt.to_date, 'N', dt)

        find_or_add_attributes(o, ((place.town)? place.town : 'No Disponible'), 'Barrio', 'Otros', 'Recitales', 'Barrios') #agrego el barrio
      end
    end
  end
end

def add_performer(rol, performers, event)
  
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
      perf = Performance.find_or_create_by_performer_id_and_rol_and_event_id(pd.id, rol, event.id)  
      perf.order = i
      perf.save
      #if ( !event.performers.exists?(pd) )
      #  perf = Performance.new
      #  perf.performer = pd
      #  perf.rol = rol
      #  perf.order = i
      #  perf.event = event
      #  perf.save
      #end
    end    
  end
  
end


def import_shows(movs)
  
  sponsor = Sponsor.find(:first,:conditions=>["name = ?","Nektra"])
  if ( sponsor == nil )
    raise "No se encuentra el Sponsor por Defecto 'Nektra'" 
  end
  
  cat = Category.find(:first, :conditions=> { :name => "Recitales"})
    
  movs.each do |m|
    puts "Crawleando " + m.title
    
    event = Event.find(:first,:conditions =>["title = ?  AND category_id = ?", m.title.strip, cat.id])
    if ( event == nil ) 
      event = Event.new
      event.title = m.title.strip
      event.text = m.description
      event.description = m.description
      event.category_id = cat.id
      event.thumbnail = m.image_url
      if ( event.text == nil ) 
        event.text = "Sin Sinopsis"
      end
      event.sponsor = sponsor
    
      event.save

      grab_picture(event, m.image_url)
    end
    
    if (m.artists != nil)
      m.artists.split(",").each do |a|
        add_performer("Artista",a.strip,event)
      end
    end
  
  end
end

def import_places(shows)
  
    cat = Category.find(:first, :conditions=> { :name => "Recitales"})
   
   shows.each do |show|
    if not show.lugar
      next
    end
    lugar = show.lugar.split("-");
    if (lugar[0] == nil)
      puts "que raro"
    end
    sala = lugar[0].strip
    puts "Sala: " + sala 
    place = Place.find(:first,:conditions=>["name = ?",sala])
    if ( place == nil )
      begin
        place = Place.new
        place.name = sala
        if (lugar.length > 1)
          dir = lugar[1].split(",");
          if (dir.length > 0)
            place.address = dir[0].strip
          end
          if (dir.length > 1)
            place.town = dir[1].strip
          end
          if (dir.length > 2)
            place.state = dir[2].strip
          end
          if (dir.length > 3)
            place.country = dir[3].strip
          end
          if (dir.length > 4)
            place.phone = dir[4].strip
          end
        end
        place.lat = 0
        place.long = 0
        place.save
      rescue Exception => e
        puts e.message
        puts "Can't create place for " + sala
      end
    end
    
    name = show.title.strip
    occur = 0;
    begin
        event = Event.find(:first,:conditions =>["title = ?  AND category_id = ?", name, cat.id])
        if ( event != nil)
          if ! event.places.exists?(place) 
            occur = parse_occurrence(show.date, show.horario, place, event)
          end
        else
          puts "Music Show Not Found: " + name
        end
      
    rescue Exception => e
      puts e.message
    end  
  end    
end


begin
  shows = MusicShow.find(:all)
  
  old_occurrences = Occurrence.find(:all, :joins => {:event => [:category]}, :select => '`occurrences`.`id`',
                                    :conditions => Occurrence.merge_conditions({:event => {:categories => {:name => "Recitales"}}},
                                                                               ['`occurrences`.`date` < ?', Time.zone.today]))
  
  Occurrence.destroy(old_occurrences)
  
  import_shows(shows)
  import_places(shows)
rescue Exception => e
  puts e.message
  puts e.backtrace
end  

