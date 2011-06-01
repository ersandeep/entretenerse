require 'rubygems'
require 'hawler'
require 'hawleroptions'
require 'hpricot'
require 'open-uri'
require 'active_record'
require 'extend_string'
require 'iconv'
require 'common'

TvShow.delete_all

from = Time.new
days = 7
i = 0

while i < days
  date = from + i*60*60*24
  page = 0
  strdate = date.year.to_s + "%2F" + date.month.to_s + "%2F" + date.mday.to_s
  while ( page >= 0 )
    page+=1
    url = "http://www.terra.com.ar/programaciontv/busqueda.shtml?o=" + page.to_s + "&tb=m&ab=0&dia=0&mes=0&anio=0&fe=" + strdate+"&det=&gid=0&cid=0&hh=23%3A30&hd=00%3A00"
    puts "Chequeando " + url

    begin

      f = open(url)
      doc = Hpricot(Iconv.conv("utf-8", "iso-8859-1", f.read) )
  
    
      matches = doc.search("//div[@id='resultado']")
    
      if ! matches.empty?
    
        matches.each do |v|
        
          tvshow = TvShow.new
          tvshow.channel_name = v.search("//p/span[@class='tah11bordo']").inner_text
          tvshow.channels = v.search("//p/span[@class='tah11rosa']").inner_text
          aux = v.search("//h2").inner_text.split('-')
          tvshow.horario = aux[0]
          gen_idx = aux[1].index(/[\t\n]/)
          gen_idx = (gen_idx)? gen_idx-1 : aux[1].length
          tvshow.show_name = aux[1][0..gen_idx].strip
          url_ficha = v.search("//h2/a").first.get_attribute("href")
          f2 = open(url_ficha)
          doc2 = Hpricot(Iconv.conv("utf-8", "iso-8859-1", f2.read) )
          sinopsis = doc2.search("//div[@id='ficha']/p").first.inner_text.strip
          
          tvshow.sinopsis = sinopsis
          
          
          e = v.search("//h2")
          t = e.inner_text.strip
          gen_idx = t.rindex(/[\t\n]/)
          if (gen_idx)
            gen_idx = (gen_idx)? (gen_idx+1) : 0
            genero = t[gen_idx..t.length]
            tvshow.genero = genero
          end
          
          tvshow.date = date
           
          tvshow.save
          p "Saved " + tvshow.channel_name
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
  i+=1
end