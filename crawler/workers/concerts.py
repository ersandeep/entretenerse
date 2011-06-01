#!/usr/bin/python
import lxml.html
import os
import re
import sys
import threading
import urllib2

ROOT = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(ROOT, '..'))
os.environ["DJANGO_SETTINGS_MODULE"] = "settings"

import spyder
from worker_pool import Pool

from orm.models import MusicShow


links_path = u'//table[@id="resultados"]//a[contains(@href, "idEvento")]/@href'

event_id_path = u'//h1[contains(@class, "titulos margin0")]/text()'

def get_description(nodes):
    h2 = nodes[0]
    return lxml.html.tostring(h2, encoding=unicode, method='text').strip()

def get_lugar(nodes):
    nodes = [n.strip() for n in nodes if n.strip()]
    if not nodes:
        return u''
    return u'%s - %s' % (nodes[0], u', '.join(nodes[1:]))

def get_horario(nodes):
    time_str = ''.join(nodes).strip()
    times = re.findall(r'[0-9]+\.[0-9]+', time_str)
    if not times:
        return u''
    return times[0].replace('.', ':')

fields = {'title':(event_id_path, lambda n:n[0].replace(u'_', u'-')),
          'description':(u'//h2[@class="copetes margin_btn description"]', get_description),
          'image_url':(u'//div[@id="main_ros"]/img[@class="photo"]/@src', lambda n:urllib2.quote(urllib2.unquote(n[0].strip().encode('utf-8')), safe='/:')),
          'lugar':(u'(//div[@class="margin_btm"]//h2[@class="trebuchet margin0"]/a/span/text() |\
                      //div[@class="margin_btm"]//h5[@class="trebuchet margin0 adr"]//*/text() |\
                      //div[@class="margin_btm"]//h5[@class="trebuchet margin0 adr"]/text())', get_lugar),
          'date':u'//abbr[@class="dtstart"]/@title',
          'horario':(u'//abbr[@class="dtstart"]/../text()', get_horario),
          }

events = {}
local_mutex = threading.Lock()

def get_details(worker, doc, match, item):
    doc.make_links_absolute()
    event_id = ' '.join(doc.xpath(event_id_path)).strip()

    for key,path in fields.items():
        try:
            path,func = path
        except ValueError:
            func = None
        nodes = doc.xpath(path)
        if nodes:
            value = func(nodes) if func else ', '.join([t.strip() for t in nodes if t.strip()])
            if not value:
                continue
            with local_mutex:
                d = {}
                events.setdefault(event_id, d)[key] = value

valid_urls = [(re.compile(r'^http://www\.vuenosairez\.com/V2_1/evento\.php\?idEvento=[0-9]+&fechaEvento=[0-9]+$'),
               get_details),]


def save_to_db():
    MusicShow.objects.all().delete()
    for event_info in events.values():
        MusicShow.objects.create(**event_info)

if __name__ == '__main__':
    import datetime
    pool = Pool(25, spyder.dispatcher, timeout=20, extra_kargs={'links_path':links_path, 'crawled':set(), 'maxdepth':1, 'valid_urls':valid_urls,})
    pool.add_to_queue({'depth':0, 'referrer':None, 'url':'http://www.vuenosairez.com/V2_1/resultados-agenda.php?tipoBusq=27&cat=5',})
    start = datetime.datetime.now()
    pool.start()
    save_to_db()
    end = datetime.datetime.now()
    print 'took', end - start, 'to crawl and save to db.'
