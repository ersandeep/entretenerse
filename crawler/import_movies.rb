require 'common'

# Usage
require_tree "models"

def import_movies(movs)

  sponsor = Sponsor.find(:first,:conditions=>["name = ?","Nektra"])
  if ( sponsor == nil )
    raise "No se encuentra el Sponsor por Defecto 'Nektra'" 
  end

  cat = Category.find(:first, :conditions=> { :name => "Cine"})

  movs.each do |m|
    event = Event.find(:first,:conditions =>["title = ? AND category_id = ?", m.title.strip, cat.id])
    if ( event == nil ) 
      puts "Importing " + m.title
      event = Event.new
      event.title = m.title.strip
      event.text = m.sinopsis
      event.thumbnail = m.image_link
      event.web = m.web
      event.duration = m.duracion
      event.category_id = cat.id;
      if ( event.text == nil ) 
        event.text = "Sin Sinopsis"
      end
      event.sponsor = sponsor
      event.save

      grab_picture(event, m.image_link)
    end

    if ( m.genero != nil )
      find_or_add_attributes(event, m.genero.split(","), 'Género', 'Otros', 'Cine', 'Géneros')
      event.save
    end
    
    directores = m.director
    
    if ( directores != nil )
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
          perf.rol = "Director"
          perf.order = i
          perf.event = event
          perf.save
        end
      end  
    end
    
    directores = m.protagonistas
    
    if ( directores != nil )
      dirs = directores.split(",")
      i = 0
      dirs.each do |director|
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
          perf.rol = "Actor"
          perf.order = i
          perf.event = event
          perf.save
        end
      end  
    end  
  end #each
end  

def import_salas(shows)

  cat = Category.find(:first, :conditions=> { :name => "Cine"})

  shows.each do |show|
    place = Place.find(:first,:conditions=>["name = ?",show.sala])
    if ( place == nil )
        place = Place.new
        place.name = show.sala
        place.lat = 0
        place.long = 0
        place.save
    end
    
    name = show.movie.sub(/\(\d{4}\)/,"").strip
    event = Event.find(:first,:conditions =>["title = ? AND category_id = ?", name, cat.id])
    if ( event != nil)
      showdate, showtimes = show.horarios.split('-')
      hors = showtimes.split(",")
      showdate = showdate.split('/').reverse.join('-')
      puts "Importing showtimes for " + name + " at " + show.sala + " on " + showdate
      hors.each do |h|
        begin
          h = h.upcase.sub("3D","").sub("SUB","").sub("ES","").strip
          dt = Time.zone.parse('%s %s' % [showdate, h])
          o = Occurrence.find_or_create_by_place_id_and_event_id_and_repeat_and_hour_and_date(place.id, event.id, 'S', dt, dt.to_date)
          find_or_add_attributes(o, [show.sala], 'Sala', 'Otros', 'Cine', 'Salas')
          find_or_add_attributes(o, ((place.town)? place.town : 'No Disponible'), 'Barrio', 'Otros', 'Cine', 'Barrios') #agrego el barrio
        rescue Exception => e
          puts h
          puts e.message
          puts e
          raise e
        end
      end
    else
      puts "Movie Not Found: " + name
    end
  end
end

begin
  shows = MovieShow.find(:all)
  movs = Movie.find(:all)
  
  old_occurrences = Occurrence.find(:all, :joins => {:event => [:category]}, :select => '`occurrences`.`id`',
                                    :conditions => Occurrence.merge_conditions({:event => {:categories => {:name => "Cine"}}},
                                                                               ['`occurrences`.`date` < ?', Time.zone.today]))
  
  Occurrence.destroy(old_occurrences)
  
  import_movies(movs)
  import_salas(shows)
rescue Exception => e
  puts e.message
  puts e.backtrace
end
