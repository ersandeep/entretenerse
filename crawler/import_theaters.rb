require 'common'
require_tree "models"


@days= {'lun'=>1,'mar'=>2,'mie'=>3,'mié'=>3,'jue'=>4,'vie'=>5,'sá'=>6,'sab '=>6,'dom'=>0}

def parse_occurrence(str, place, event)
  o = nil
  puts "Buscando Ocurrencias en " + str
  @days.keys.each do |k|
    if ( str.include? k)
      # quiere decir que esta el horario
      o = Occurrence.find_or_create_by_place_id_and_event_id_and_dayOfWeek_and_repeat_and_hour(place.id, event.id, @days[k], 'S', Time.zone.parse(str.match(/[0123456789]+:[0123456789]+/).to_s))  

      find_or_add_attributes(o, ((place.town)? place.town : 'No Disponible'), 'Barrio', 'Otros', 'Teatro', 'Barrios') #agrego el barrio
    end
  end
  if ( o == nil)
    puts "No se encontro ningun horario para " + str
  end
end

def add_performer(rol, performers, event)
  
  rol = rol.gsub(" y ",",")
  directores = performers
  
  if ( directores == nil )
    puts "Esta obra no tiene " + rol
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
    end    
  end
  
end


def import_movies(movs)
  
  sponsor = Sponsor.find(:first,:conditions=>["name = ?","Nektra"])
  if ( sponsor == nil )
    raise "No se encuentra el Sponsor por Defecto 'Nektra'" 
  end
  
  cat = Category.find(:first, :conditions=> { :name => "Teatro"})
  movs.each do |m|
    begin
      event = Event.find(:first,:conditions =>["title = ? AND text = ? AND category_id = ?", m.obra.strip, m.text.strip, cat.id])
      if ( event == nil) 
        puts "Importing " + m.obra
        event = Event.new
        event.title = m.obra.strip
        event.text = m.text.strip
        event.category_id = cat.id
        event.thumbnail = m.image_url
        #event.web = m.web
        #event.duration = m.duracion
        if ( event.text == nil ) 
          event.text = "Sin Sinopsis"
        end
        event.sponsor = sponsor
        event.save
        
        grab_picture(event, m.image_url)
      end
      
      genero = m.genero.gsub(/\302\240/,'')
      if (genero.length == 0)
        genero = 'Sin Género'
      end
      find_or_add_attributes(event, genero.split(","), 'Género Teatral', 'Otros', 'Teatro', 'Género Teatral')

      event.save

      add_performer("Director",m.direccion,event)
      add_performer("Actor",m.actor,event)
      add_performer("Autor",m.autor,event)
      add_performer("Dramaturgia",m.dramaturgia,event)
      add_performer("Escenografia",m.escenografia,event)
      add_performer("Iluminacion",m.iluminacion,event)
      add_performer("Vestuario",m.vestuario,event)
      add_performer("Coreografia",m.coreografia,event)
    rescue Exception => e
      puts e.message
    end
  end
end

def import_salas(shows)
  
  shows.each do |show|
    hors = show.horarios.split("#")

    puts "Sala: " + show.teatro.strip
    place = Place.find(:first,:conditions=>["name = ?",show.teatro.strip])
    if ( place == nil )
      place = Place.new
      place.name = show.teatro.strip
      if ( hors[2].match("[0123456789]+-[0123456789]+"))
        place.phone = hors[2].strip
      end

      address = hors[1].split(" - ");
      place.address = address[0].strip;
      state = address[1].strip;
      if (state == 'Capital Federal')
        place.state = state;
      else
        place.town = state;
      end
      place.country = "Argentina"

      place.lat = 0
      place.long = 0
      place.save
    end
    
    name = show.obra.strip
    cat = Category.find(:first, :conditions=> { :name => "Teatro"})
    event = Event.find(:first,:conditions=>{ :title => name, :text => show.text.strip, :category_id => cat.id})
    if ( event != nil)
      
      if ! event.places.exists?(place)
        
        hs = []
        if ( hors[2].match("[0123456789]+-[0123456789]+"))
          hs = hors[3].split(",")
        else
          hs = hors[2].split(",")
      end
      
        
        hs.each do |h|
          parse_occurrence(h,place,event)
        end
        
      end
    else
      puts "Show Not Found: " + name
    end
  end    
end


begin
  shows = Theater.find(:all)
  
  old_occurrences = Occurrence.find(:all, :joins => {:event => [:category]}, :select => '`occurrences`.`id`',
                                    :conditions => Occurrence.merge_conditions({:event => {:categories => {:name => "Teatro"}}},
                                                                               ['`occurrences`.`date` < ?', Time.zone.today]))
  
  Occurrence.destroy(old_occurrences)
  
  import_movies(shows)
  import_salas(shows)
rescue Exception => e
  puts e.message
  puts e.backtrace
end  

