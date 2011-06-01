require 'rubygems'
require 'hawler'
require 'hawleroptions'
require 'hpricot'
require 'active_record'
require 'extend_string'
require 'iconv'

class TvShow < ActiveRecord::Base  
end  

 ActiveRecord::Base.establish_connection(  
 :adapter => "mysql",  
 :host => "localhost",  
 :database => "crawler"  
 )  

  def grep (uri, referer, response)
    line = 0
    suri =uri.to_s 
    if ( suri.match("http://www.terra.com.ar/programaciontv/busqueda.shtml\\?o=[0123456789]+&tb=m&ab=0&dia=0&mes=0&anio=0&fe=2009%2F04%2F14&det=&gid=0&cid=0&hh=23%3A30&hd=00%3A00")!=nil)
    
      p "GREAT! This url contains TV Shows! " + suri 
    
      unless (response.nil?)
        
        doc = Hpricot(response.body)
        
        
        matches = doc.search("//div[@id='resultado']")
        
        
        if ! matches.empty?
         
        
          matches.each do |v|
            
            tvshow = TvShow.new
            tvshow.name = v.search("//p/span[@class='tah11bordo']").inner_text
            tvshow.channels = v.search("//p/span[@class='tah11rosa']").inner_text
            aux = v.search("//h2").inner_text.split('-')
            tvshow.horario = aux[0]
            tvshow.description = aux[1]
             
            tvshow.save
            p "Saved " + tvshow.name
          
          end
        
          
          
          
        end
         
      end
    else
      p "This url does not contain TvShows..snif: " + suri 
    end

  end

  args =  ["","http://www.terra.com.ar/programaciontv/busqueda.shtml?o=0&tb=m&ab=0&dia=0&mes=0&anio=0&fe=2009%2F04%2F14&det=&gid=0&cid=0&hh=23%3A30&hd=00%3A00","-r 3 -v "]
  options = HawlerOptions.parse(args, "Usage: #{File.basename $0} [pattern] [uri] [options]")

  puts options.help
  puts "Crawling started...."

  if (args.empty?)
    puts options.help
  else
    @match = args.shift
    args.each do |site|
      crawler = Hawler.new(site, method(:grep))
      options.each_pair do |o,v|
        crawler.send("#{o}=",v)
      end
      crawler.start
    end
  end
