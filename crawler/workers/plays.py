#!/usr/bin/python
import lxml.html
import os
import re
import string
import sys
import threading
import urllib2

ROOT = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(ROOT, '..'))
os.environ["DJANGO_SETTINGS_MODULE"] = "settings"

import spyder
from worker_pool import Pool

from orm.models import Theater


links_path = u'//div[@id="contenido"]//a/@href'

event_id_path = u'//div[@id="contenido"]/h1/text()'

image_map = dict((string.ascii_lowercase[i] * 2, str(i)) for i in range(10))
image_map.update({'vv':' ', 'kk':'lun', 'll':'mar', 'mm':'mie', 'nn':'jue', 'oo':'vie', 'pp':'sab', 'qq':'dom', '%' :',',})

horario_regex = re.compile(r'.+txt=[\n\t]*(.+)\$', flags=re.S)

def get_horarios(nodes):
    div = nodes[0]
    inner_html = lxml.html.tostring(div, method='xml').replace('<br />', '#')
    text = lxml.html.fromstring(inner_html).text_content().replace(u'\xa0', ' ')
    img_nodes = div.xpath(u'img/@src')
    img_src = img_nodes[0] if img_nodes else u''
    m = horario_regex.match(img_src)
    horario = m.groups()[0] if m else u''
    for k,v in image_map.items():
        horario = horario.replace(k,v)
    text += horario.strip()
    text = text.replace('[ver mapa]', '')
    text = text.replace('Horarios:', '')
    return text.strip()

fields = {'obra':(event_id_path, lambda n:n[0].replace(u'_', u'-')),
          'teatro':u'//div[@class="acumulados"]/b[1]/text()',
          'image_url':(u'//img[@class="focal"][1]/@src', lambda n:urllib2.quote(urllib2.unquote(n[0].strip()), safe='/:')),
          'horarios':(u'//div[@class="acumulados"][1]', get_horarios),
          'text':u'//div[@class="obra floatFix"]/p[1]/text()',
          'direccion':u'(//div[@class="franjaGris"] | //div[@class="franjaBlanca"])/div[@class="izquierda"]/b[contains(text(), "Direcci\xf3n:")]/../../text()',
          'actor':u'(//div[@class="franjaGris"] | //div[@class="franjaBlanca"])/div[@class="izquierda"]/b[contains(text(), "Actor:")]/../../text()',
          'genero':u'(//div[@class="franjaGris"] | //div[@class="franjaBlanca"])/div[@class="izquierda"]/b[contains(text(), "G\xe9nero:")]/../../text()',
          'dramaturgia':u'(//div[@class="franjaGris"] | //div[@class="franjaBlanca"])/div[@class="izquierda"]/b[contains(text(), "Dramaturgia:")]/../../text()',
          'vestuario':u'(//div[@class="franjaGris"] | //div[@class="franjaBlanca"])/div[@class="izquierda"]/b[contains(text(), "Vestuario:")]/../../text()',
          'autor':u'(//div[@class="franjaGris"] | //div[@class="franjaBlanca"])/div[@class="izquierda"]/b[contains(text(), "Autor:")]/../../text()',
          'coreografia':u'(//div[@class="franjaGris"] | //div[@class="franjaBlanca"])/div[@class="izquierda"]/b[contains(text(), "Core\xf3grafo:")]/../../text()',
          'iluminacion':u'(//div[@class="franjaGris"] | //div[@class="franjaBlanca"])/div[@class="izquierda"]/b[contains(text(), "Iluminaci\xf3n:")]/../../text()',
          'escenografia':u'(//div[@class="franjaGris"] | //div[@class="franjaBlanca"])/div[@class="izquierda"]/b[contains(text(), "Escenograf\xeda:")]/../../text()',
          }

events = {}
local_mutex = threading.Lock()

def get_details(worker, doc, match, item):
    doc.make_links_absolute()
    event_id = doc.xpath(event_id_path)[0].strip()

    for key,path in fields.items():
        try:
            path,func = path
        except ValueError:
            func = None
        nodes = doc.xpath(path)
        if nodes:
            value = func(nodes) if func else ', '.join([t.strip() for t in nodes if t.strip()])
            with local_mutex:
                d = {}
                events.setdefault(event_id, d)[key] = value

valid_urls = [(re.compile(r'http://www\.lanacion\.com\.ar/espectaculos/cartelera-teatro/obraFicha\.asp\?obra=[0-9]+&teatro_id=[0-9]+$'),
               get_details),]


def save_to_db():
    Theater.objects.all().delete()
    for event_info in events.values():
        Theater.objects.create(**event_info)

if __name__ == '__main__':
    import datetime
    pool = Pool(25, spyder.dispatcher, timeout=4, extra_kargs={'links_path':links_path, 'crawled':set(), 'maxdepth':1, 'valid_urls':valid_urls,})
    pool.add_to_queue({'depth':0, 'referrer':None, 'url':'http://www.lanacion.com.ar/espectaculos/cartelera-teatro/',})
    start = datetime.datetime.now()
    pool.start()
    save_to_db()
    end = datetime.datetime.now()
    print 'took', end - start, 'to crawl and save to db.'
