require 'rubygems'
require 'hawler'
require 'hawleroptions'
require 'hpricot'
require 'active_record'
require 'extend_string'
require 'iconv'
require 'open-uri'
require 'common'
require 'htmlentities'
require 'sanitize'

@ic = Iconv.new('UTF-8', 'ISO-8859-1')

@hor_image_text= {'aa'=> '0','bb'=> '1','cc'=> '2','dd'=> '3','ee'=> '4','ff'=> '5','gg'=> '6','hh'=> '7','ii'=> '8','jj'=> '9','vv'=> ' ','kk'=> 'lun','ll'=> 'mar','mm'=> 'mie','nn'=> 'jue','oo'=> 'vie','pp'=> 'sab','qq'=> 'dom', '%' => ','}

def grep (uri, referer, response)
  line = 0
  suri =uri.to_s
  
      
  if ( suri.match("http://www.lanacion.com.ar/espectaculos/cartelera-teatro/obraFicha.asp\\?obra=[0123456789]+&teatro_id=[0123456789]+")!=nil)
    p "GREAT! This url IS  a Theater Perf. " + suri 
    
    unless (response.nil?)
      
      f = open(suri)
      doc = Hpricot(Iconv.conv("utf-8", "iso-8859-1", f.read) )
            
      
      matches1 = doc.search("//div[@class='franjaBlanca']")
      matches2 = doc.search("//div[@class='franjaGris']")
      
      matches = []
      matches = matches1.concat(matches2)
      
      
      if ! matches.empty?
        
        theater = Theater.new
        theater.obra = doc.search("//div[@id='contenido']/h1").inner_text
        theater.teatro = doc.search("//div[@class='acumulados']/b").first.inner_text
        image = doc.search("//img[@class='focal']").first
        theater.image_url = "http://www.lanacion.com.ar" + image.get_attribute("src") unless image.nil?
        text = Sanitize.clean(doc.search("//div[@class='acumulados']").first.inner_html.gsub(/[\n\t\r]/," ").gsub(/<br \/>/,"#"))
        hor_image = doc.search("//div[@class='acumulados']/img").first
        if (hor_image)
          hor_image = hor_image.get_attribute("src")
          hor_image = hor_image.slice(hor_image.index('txt=')+4,hor_image.index('&estilo')-hor_image.index('txt=')-4).gsub('&#xA;','').gsub('$','').strip;
          @hor_image_text.keys.each do |k|
            hor_image = hor_image.gsub(k, @hor_image_text[k])
          end
          text += hor_image.strip
        end
        puts "Antes: "+ text
        #text = text.gsub(theater.teatro,"")
        #text = text.gsub(/[\n\t\r]/," ")
        #text = text.gsub("[ver mapa]",";")
        text = text.gsub("[ver mapa]","")
        text = text.gsub("Horarios:","")

        theater.horarios = text
        
        theater.text = doc.search("//div[@class='obra floatFix']/p").first.inner_text
        
        matches.each do |m|
          ax = m.inner_text.split(":")
          puts "Evaluation " + m.inner_text
          if ( ax[0] != nil)
            
            if ( ax[0].include? "Direcci")
              theater.direccion = ax[1]
            end
            if ( ax[0].include? "Actor")
              theater.actor = ax[1]
            end
            if ( ax[0].include? "nero")
              theater.genero = ax[1].strip
            end
            if ( ax[0].include? "maturgia")
              theater.dramaturgia = ax[1]
            end
            if ( ax[0].include? "Vestu")
              theater.vestuario = ax[1]
            end
             if ( ax[0].include? "Autor")
              theater.autor = ax[1]
            end
             if ( ax[0].include? "Coreo")
              theater.coreografia = ax[1]
            end
             if ( ax[0].include? "Ilumi")
              theater.iluminacion = ax[1]
            end
             if ( ax[0].include? "Esceno")
              theater.escenografia = ax[1]
            end

          end #if
          
        end #each
        theater.save
      
        p "Saved " + theater.obra
      else
        p "This url is not a theater " + suri
      end #maches.empty
    end #unless
   end
end



#args =  ["","http://www.cinemaki.com.ar/cartelera","-r 3 -v "]
args =  ["","http://www.lanacion.com.ar/espectaculos/cartelera-teatro/","-r 1 -v "]
options = HawlerOptions.parse(args, "Usage: #{File.basename $0} [pattern] [uri] [options]")
puts "Crawling started...."

if (args.empty?)
puts options.help
else
  Theater.delete_all
@match = args.shift
args.each do |site|
  crawler = Hawler.new(site, method(:grep))
  options.each_pair do |o,v|
    crawler.send("#{o}=",v)
  end
  crawler.start
end
end
