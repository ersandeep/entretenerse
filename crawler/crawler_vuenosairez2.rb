require 'rubygems'
require 'hawler'
require 'hawleroptions'
require 'hpricot'
require 'open-uri'
require 'active_record'
require 'extend_string'
require 'iconv'
require 'common'
require 'htmlentities'
require 'sanitize'

def buscar_entre(text,desde,hasta)
  idesde = text.rindex(desde)
  if idesde==nil
    return ""
  end
  ihasta = text.rindex(hasta)
  if ( ihasta == nil)
    return ""
  end
  return text[(idesde+desde.length)..ihasta].strip
end

def grep (suri)

    p "GREAT! This url IS  a Music Show. " + suri 
    
    f = open(suri)
    doc = Hpricot(Iconv.conv("utf-8", "iso-8859-1", f.read) )
          
  begin
    coder = HTMLEntities.new

    musicshow = MusicShow.new
    title = doc.search("//h1[@class*='titulos margin0']").inner_text
    title = title.strip.gsub(/[\n\t]/,'')
    musicshow.title = title
    musicshow.description = Sanitize.clean(coder.decode(doc.search("//h2[@class='copetes margin_btn']").inner_html.strip.gsub(/[\n\t\r]/,' ').gsub('  ',' ')))
    images = doc.search("//img[@alt='"+title+"']")
    if (images.length > 0)
      musicshow.image_url = "http://www.vuenosairez.com/"+images[0].get_attribute("src").sub("../","")
    end
    lugar = doc.search("//div[@class*='margin_btm']/h2[@class*='trebuchet margin0']/a").inner_text.strip
    if (lugar.length == 0)
      raise "El recital no tiene lugar"
    end
    musicshow.lugar = lugar + '-' + doc.search("//div[@class*='margin_btm']/h5[@class*='trebuchet margin0']").first.children.collect{|e| e.inner_text.strip}.select{|e| e.length > 0}.join(',')
    
    data = doc.at("//ul#ficha_tecnica").search("li")
    if (data.length > 2)
      musicshow.precio = data[2].children.select{|e| e.text?}.first.inner_text
    end
    if (data.length > 0)
      musicshow.date = data[0].children.select{|e| e.elem?}.collect{|e| e.inner_text.strip}.select{|e| e.length > 0}.join(' ')
    end
    
    fecha = doc.search("//div#main_ros/div/h5[@class*='trebuchet margin0']")[0].children.select{|e| e.text?}.collect{|e| e.inner_text.strip}.select{|e| e.length > 0}
    musicshow.date = fecha.first + ' ' +musicshow.date
    musicshow.horario = fecha.last
    #musicshow.artists = buscar_entre(data,"Artistas:","Videos relacionados:")
    #puts data
    musicshow.save
    
    puts "Saved " + musicshow.title
    
  rescue Exception=>e
    puts e
    puts "Error saving " + suri
  end
  
end

def page_link(number)
  "http://www.vuenosairez.com/V2_1/resultados-agenda.php?pag="+number.to_s+"&tipoBusq=3&cat=5"
end

#grep("http://www.vuenosairez.com/V2_1/evento.php?&idEvento=47298&fechaEvento=2455231")
#grep("D:/Users/Nico/Desktop/evento.php.htm")

MusicShow.delete_all

page = 0;
total = 0;
while ( page >= 0)
  page+=1
  url = page_link(page)
  puts "Chequeando " + url

  begin
    f = open(url)
    doc = Hpricot(Iconv.conv("utf-8", "iso-8859-1", f.read) )

    if (page == 1)
      total = doc.search("//div/div/div/div[text()*='Se encontraron']")[0].children.select{|e| e.text?}.join.strip.gsub(/[^\d]/,'').to_i
      puts 'Hay '+total.to_s+' recitales'
    end
  
    matches = doc.search("//a[@href*='evento.php?&idEvento']")
  
    if ! matches.empty?
  
      matches.each do |v|
        total -= 1;

        grep("http://www.vuenosairez.com/V2_1/"+v.get_attribute("href"))

       end   

       puts "Falta recorrer un total de " + total.to_s
       if (total <= 0)
         page = -1
       end
     else
      puts "No hay resultados para la pagina " + page.to_s
      page = -1
     end
  rescue Exception => e
    puts e
    puts "Error al procesar "+page.to_s
    #puts e.backtrace
  end
end