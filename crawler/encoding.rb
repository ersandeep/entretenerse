require  'open-uri'
require  'chardet'

f = open("http://www.lanacion.com.ar/nota.asp?nota_id=1136032&pid=6597665&toi=6256")

chardet.detect(f.read)
print f.read