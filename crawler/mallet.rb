require 'rubygems'
require 'cgi'
require 'open-uri'
require 'hpricot'
require 'active_record'
require 'lingua/stemmer'

 ActiveRecord::Base.establish_connection(  
 :adapter => "mysql",  
 :host => "localhost",  
 :database => "7p-ops" ,
 :encoding=> "utf8"
 )  

class User < ActiveRecord::Base  
end 


class Opinion < ActiveRecord::Base  
end 

class Context < ActiveRecord::Base  
  belongs_to :opinion
end

@ic = Iconv.new('UTF-8', 'ISO-8859-1')

def remove_accents(str)
    accents = { ['á','à','â','ä','ã','Ã','Ä','Â','À'] => 'a',
  ['é','è','ê','ë','Ë','É','È','Ê'] => 'e',
  ['í','ì','î','ï','I','Î','Ì'] => 'i',
  ['ó','ò','ô','ö','õ','Õ','Ö','Ô','Ò'] => 'o',
  ['œ'] => 'oe',
  ['ß'] => 'ss',
  ['ú','ù','û','ü','U','Û','Ù'] => 'u'
  }
  
accents.each do |ac,rep|
  ac.each do |s|
    str.gsub!(s, rep)
  end
end
#str.gsub!(/[^a-zA-Z_\- ]/," ")
#str = " " + str.split.join(" ")
#str.gsub!(/ (.)/) { $1.upcase }

return str
end 

@white_list = ["gorila", "montonero","facho","negro"]

@stop_words = ["y","que","de","el","la","los","se","fue","le","comentario","sido","reportado",
"por","si","lo","a","ahora","ah","al","te","ok","van","q","vez","da", "hay",
"es","no","son","ha","va","nos","han","mis","ya","era","pero","como","sin","yo","ja","jaja",
"del","con","las","en","sus","un","una","e","su","mi","de","o","http","me","porque","quien","usuario","moderador",
"sino","para","otra","hasta","cosa","tal","vaya","ser","etc","ni","otro","lado","saludos","tu","digo","les","todo","sobre","ellos","esta","esa","he","p","jiji","ji",
"soy","tienen","vos","desde","asi","pd","estan","esto","mismo","segun","este","ante","uno","dos","diez"]

@stop_chars = [",",".","?","!","\"",":","-","_","'","¿","¡","(",")","\n","\r","<",">","/","*",";"]

@stemmer = Lingua::Stemmer.new(:language=>"es")
def pre_process(text, stem=true)
  #text = Iconv.conv("utf-8", "iso-8859-1", text)
  @stop_chars.each do |s|
    text = text.delete(s)
  end
  
  #mark_points
  #spelling
  #accents
  #stopwords
  #stem
  
  #downcase
  text = text.downcase  
  text2 = ""
  text.split(" ").each do |word|
    w = word#remove_accents(word)
    if  w.include?("pol")
      puts w
    end
      if (! @stop_words.include? w) && ( ! word.match("[0123456789]+")  )  && word.length > 4 && word.length < 15
        if ( stem )
          if (! @white_list.include? w )
            w = @stemmer.stem(w)
          end
        end
        text2 += " " + w+ " "
      end
  end
  return text2
end


#@stop_words = []
stem = true
ctx = Context.find(:all)

File.open('zurdosyfachos.txt', 'w') do |f2|  
  ctx.each do |c|
    ptext = pre_process(c.text,stem)  
    if ptext.length > 20 && ptext.split(" ").length > 15
      s = c.opinion_id.to_s + " " + c.klass + " " + ptext
      f2.puts s
      #puts s
    end
  end
 end  
puts "Fin Generacion de Archivo"

