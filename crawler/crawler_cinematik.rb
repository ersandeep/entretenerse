require 'rubygems'
require 'hawler'
require 'hawleroptions'
require 'hpricot'
require 'active_record'
require 'extend_string'
require 'iconv'
require 'open-uri'
require 'common'

require 'common'

def grep (uri, referer, response)
  line = 0
  suri = uri.to_s 
  
  movie_title = nil
  
  if ( suri.match("http://www.cinemaki.com.ar/.+/p/[0123456789]+")!=nil)
    suri = suri.sub(/(.+)\/p\/(\d+)/, '\1/mi/\2')    
    p "GREAT! This url IS  a movie: " + suri 
    
    unless (response.nil?)
      
      #doc = Hpricot(response.body)
      doc = Hpricot(open(suri))
      
      matches = doc.search("//table[@class='desc']/tbody/td")
      rows = doc.search("//table[@class='desc']/tbody/th")
      
      if ! matches.empty?
        
        movie = Movie.new
        movie_title = doc.search("//h2[@class='movie_info']").inner_text
        #i = Iconv.new('MACROMAN//IGNORE//TRANSLIT',"UTF-8")
        #s = i.iconv(s)
        movie.title = movie_title.strip
        puts "   Movie Title " + movie.title
        matches.each do |v|
          
          row = rows[matches.index(v)].inner_text
          if ( row.include? "Original" ) 
            movie.titulo_original = v.inner_text.strip
          end
          if ( row.include? "o de lanzamiento" ) 
            movie.anio_lanzamiento = v.inner_text.strip
          end
          if ( row.include? "Duraci" ) 
            movie.duracion = v.inner_text.strip
          end
          if ( row.include? "Director" ) 
            movie.director = v.inner_text.strip
          end
          if ( row.include? "nero" ) 
            genero = v.inner_text.strip;
            movie.genero = genero == "Documentario"? "Documental" : genero
          end
          if ( row.include? "Sinopsis" ) 
            movie.sinopsis = v.inner_text.strip
          end
          if ( row.include? "Web" ) 
            movie.web = v.inner_text.strip
          end
          if ( row.include? "Protagonistas" ) 
            movie.protagonistas = v.inner_text.strip
          end
        end
        movie.image_link = doc.search("//div[@class='col col_picture']/img").first.get_attribute("src")
        
        puts "   Buscando Horarios" 
        suri = suri.sub(/(.+)\/mi\/(\d+)/, '\1/ms/\2')
        puts "        "+suri
        doc = Hpricot(open(suri))
        
        shows_count = 0;
        
        movie_title = doc.search("//div[@class='movie_header']/h1").inner_text

        matches = doc.search("//table[@class='theater_show']")
        matches.each do |m|
          td = 0
          m_tds = m.search("/td")
          while (td < m_tds.length)
            show = MovieShow.new
            show.movie = movie_title
            show.sala = m_tds[td].search("/a").inner_text.strip
            show.horarios = m_tds[td+1].inner_text.strip
            show.save
            
            shows_count += 1
            
            td += 4
          end
          
        end
        puts "      Shows para peli "+ shows_count.to_s

        if (shows_count > 0 && !Movie.exists?(:title => movie.title))
          puts "   Saving " + movie.title
          movie.save
        end
        
      else
        puts "   Movie Data Not Found!"
      end
      
    end
  else
    p "This url is not a movie: " + suri 
  end
end

#args =  ["","http://www.cinemaki.com.ar/832,Angeles-y-Demonios","-r 3 -v "]

args =  ["","http://www.cinemaki.com.ar/cartelera","-r 3 -v "]
options = HawlerOptions.parse(args, "Usage: #{File.basename $0} [pattern] [uri] [options]")

#  puts options.help
puts "Crawling started...."

if (args.empty?)
  puts options.help
else
  #Borro los datos viejoss
  MovieShow.delete_all
  Movie.delete_all
  @match = args.shift
  args.each do |site|
    crawler = Hawler.new(site, method(:grep))
    options.each_pair do |o,v|
      crawler.send("#{o}=",v)
    end
    crawler.start
  end
end
