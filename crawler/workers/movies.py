#!/usr/bin/python
from collections import defaultdict
import datetime
import os
import re
import string
import sys
import threading
import urllib2

from dateutil.rrule import DAILY, rrule, FR, SA, WE

ROOT = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(ROOT, '..'))
os.environ["DJANGO_SETTINGS_MODULE"] = "settings"

import spyder
from worker_pool import Pool
from workers import get_doc

from orm.models import Movie, MovieShow


image_map = dict((string.ascii_lowercase[i] * 2, str(i)) for i in range(10))
image_map.update({'%':',', 'kk':'lun', 'll':'mar', 'mm':'mie', 'nn':'jue', 'oo':'vie', 'pp':'sab', 'qq':'dom',
                  'rr':'Trasnoche', 'tt':'subtitulada', 'uu':'castellano', 'vv':' ',})
days = {image_map['oo']:FR, image_map['pp']:SA,}
next_wednesday = datetime.datetime.combine(rrule(DAILY, byweekday=WE, count=1)[0], datetime.time(23, 59))

time_regex = re.compile(r'\d{2}:\d{2}', flags=re.S)

# we don't need to look for links, we are already populating the queue on init
links_path = u'none'

event_id_path = u'//div[@id="contenido"]/h1/text()'

movie_fields = {'title':(event_id_path, lambda n:n[0].replace(u'_', u'-')),
                'titulo_original':u'//div[@id="contenido"]//b[contains(text(), "T\xedtulo original")]/../following-sibling::td/text()',
                'anio_lanzamiento':u'//div[@id="contenido"]//b[contains(text(), "Estreno")]/../following-sibling::td/text()',
                'duracion':(u'//div[@id="contenido"]//b[contains(text(), "Duraci\xf3n")]/../following-sibling::td/text()', lambda n:int(n[0].split()[0])),
                'director':(u'//div[@id="contenido"]//b[contains(text(), "Director")]/../following-sibling::td/text()', lambda n:n[0].replace(u'\xa0y\xa0', ', ')),
                'genero':u'//div[@id="contenido"]//b[contains(text(), "G\xe9nero")]/../following-sibling::td/text()',
                'sinopsis':u'//div[@id="contenido"]//div[@class="izquierda"]/following-sibling::p/text()',
                'web':u'//div[@id="contenido"]//b[contains(text(), "Trailer")]/../following-sibling::td/text()',
                'protagonistas':(u'//div[@id="contenido"]//b[contains(text(), "Actor")]/../following-sibling::td/text()', lambda n:n[0].replace(u'\xa0', ' ').replace(' y ', ', ')),
                'image_link':(u'//div[@id="contenido"]//div[@class="izquierda"]/img/@src', lambda n:urllib2.quote(urllib2.unquote(n[0].strip()), safe='/:'))
                }

showtime_date_path = u'//div[@id="showtimes"]//div[@class="right"]/text()'
movie_showtimes = u'//table[@class="theater_show"]//td[position()=1]//a | //table[@class="theater_show"]//td[position()=2]'

events = {}
event_showtimes = defaultdict(set)
local_mutex = threading.Lock()


def store_showtimes(movie_id, node):
    venue_name = node.xpath(u'./b/text()')[0].strip()
    raw_showtimes = node.xpath(u'./following-sibling::img[1]/@src')[0]
    for k,v in image_map.items():
        raw_showtimes = raw_showtimes.replace(k, v)
    
    showtimes = []
    for s in raw_showtimes.split('|'):
        for time_str in time_regex.findall(s):
            time = datetime.datetime.strptime(time_str, '%H:%M').time()
            byweekday = [(d.weekday + 1 if time <= datetime.time(23, 59, 59) else d)\
                         for k,d in days.items() if (image_map['rr'] in s) and (k in s)]
            
            with local_mutex:
                for sh in rrule(DAILY, byweekday=byweekday, byhour=time.hour, byminute=time.minute, bysecond=0, until=next_wednesday):
                    event_showtimes[movie_id].add((venue_name, sh.strftime('%Y/%m/%d-%H:%M'),))

def get_movie_details(worker, doc, match, item):
    doc.make_links_absolute()
    try:
        movie_id = doc.xpath(event_id_path)[0].strip()
    except IndexError:
        # some pages render without any content
        return
    for key, path in movie_fields.items():
        try:
            path,func = path
        except ValueError:
            func = lambda nodes: ', '.join([t.strip() for t in nodes if t.strip()])
        nodes = doc.xpath(path)
        if nodes:
            value = func(nodes)
            if not value:
                continue
            with local_mutex:
                d = {}
                events.setdefault(movie_id, d)[key] = value
    
    venues = doc.xpath(u'//div[@id="contenido"]//div[@class="acumulados cines"]//a[@title="Ver la ficha del cine"]')
    for venue in venues:
        store_showtimes(movie_id, venue)
                
def get_movie_showtimes(worker, doc, match, item):
    movie_id = doc.xpath(event_id_path)[0].strip()
    raw_showtime_date = ''.join(doc.xpath(showtime_date_path))
    showtime_date = re.search(r'[0-9]{2}/[0-9]{2}/[0-9]{4}', raw_showtime_date).group() if raw_showtime_date else ''
    showtimes = doc.xpath(movie_showtimes)
    showtime_pairs = [(showtimes[i],showtimes[i+1]) for i in range(len(showtimes))[::2]]
    with local_mutex:
        for place,times in showtime_pairs:
            event_showtimes[movie_id].add((place.text_content().strip(), u'%s-%s' % (showtime_date, times.text_content().strip())))

valid_urls = [(re.compile(r'http://www\.lanacion\.com\.ar/espectaculos/cartelera-cine/peliculaFicha\.asp\?pelicula=(\d+)$'), get_movie_details),]


def save_to_db():
    Movie.objects.all().delete()
    MovieShow.objects.all().delete()
    for event_info in events.values():
        Movie.objects.create(**event_info)
    
    for event_title,venue_showtimes in event_showtimes.items():
        for venue,showtime in venue_showtimes:
            MovieShow.objects.create(movie=event_title, sala=venue, horarios=showtime)

if __name__ == '__main__':
    pool = Pool(25, spyder.dispatcher, timeout=5, extra_kargs={'links_path':links_path, 'crawled':set(), 'maxdepth':None, 'valid_urls':valid_urls,})
    doc = get_doc('http://www.lanacion.com.ar/espectaculos/cartelera-cine/index.asp')
    for movie_id in doc.xpath(u'//div[@id="contenido"]//form//select[@name="pelicula"]/option/@value'):
        if movie_id.strip():
            pool.add_to_queue({'depth':0, 'referrer':None,
                               'url':'http://www.lanacion.com.ar/espectaculos/cartelera-cine/peliculaFicha.asp?pelicula=%s' % movie_id.strip(),})
    start = datetime.datetime.now()
    pool.start()
    save_to_db()
    end = datetime.datetime.now()
    print 'took', end - start, 'to crawl and save to db.'
