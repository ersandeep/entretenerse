#!/usr/bin/python
from collections import defaultdict
import copy
import datetime
import lxml.html
import os
import re
import sys
import threading
import urllib
import urlparse

ROOT = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(ROOT, '..'))
os.environ["DJANGO_SETTINGS_MODULE"] = "settings"

import spyder
from worker_pool import Pool

from orm.models import TvShow


links_path = u'//form[@name="fpaginado"]/span/following-sibling::a/@href'

event_id_path = u'//div[@id="ficha"]/h1/text()'
event_info_root = u'//div[@id="resultado"]'
event_synopsis_url = u'.//h2/a[1]/@href'
event_synopsis_path = u'//div[@id="ficha"]/p[1]/text()'

date_format = '%Y/%m/%d'

def get_links(doc, xpath):
    raw_links = doc.xpath(xpath)
    links = []
    split_result = urlparse.urlsplit(doc.base_url)
    query_dict = urlparse.parse_qs(split_result.query)

    for rl in raw_links:
        page_number = int(re.search(r'\d+', rl).group()) - 1#url param is zero-based
        query_dict['o'] = page_number#'o' is the offset param, i.e. the page number
        new_query = urllib.unquote(urllib.urlencode(query_dict, True))
        links.append(urlparse.urlunsplit(split_result._replace(query=new_query)))
    
    return links
    

fields = {'show_name':(u'.//h2/a/text()', lambda n:n[0].split(' - ', 1)[1].strip().replace(u'_', u'-')),
          'channel_name':u'.//p/span[@class="tah11bordo"]/text()',
          'channels':u'.//p/span[@class="tah11rosa"]/b/text()',
          'horario':(u'.//h2/a/text()', lambda n:n[0].split(' - ')[0].strip()),
          'genero':u'.//h2/text()',
          }

events = defaultdict(list)
events_synopses = {}
local_mutex = threading.Lock()
db_mutex = threading.Lock()


def get_details(worker, doc, match, item):
    split_result = urlparse.urlsplit(doc.base_url)
    query_dict = urlparse.parse_qs(split_result.query)
    this_date = datetime.datetime.strptime(query_dict['fe'][0], date_format)
    
    for e in doc.xpath(event_info_root):
        event_id = fields['show_name'][1](e.xpath(fields['show_name'][0]))
        event = {}
        for key,path in fields.items():
            try:
                path,func = path
            except ValueError:
                func = lambda nodes: ', '.join([t.strip() for t in nodes if t.strip()])
            nodes = e.xpath(path)
            if nodes:
                value = func(nodes)
                if not value:
                    continue
                event[key] = value
        
        event['date'] = this_date
        
        with local_mutex:
            events[event_id].append(event)
            these_events = copy.deepcopy(events) if len(events) >= 100 else {}
            if these_events:
                events.clear()

        url = str(e.xpath(event_synopsis_url)[0])
        worker.add_to_queue({'depth':item['depth'] + 1, 'referrer':doc.base_url, 'url':url,})
            
        if these_events:
            with db_mutex:
                save_to_db(these_events)
        
        
def get_synopsis(worker, doc, match, item):
    event_id = doc.xpath(event_id_path)[0].strip()
    
    synopsis = doc.xpath(event_synopsis_path)[0].strip()

    with local_mutex:
        events_synopses[event_id] = synopsis
    

valid_urls = [(re.compile(r'^http://www\.terra\.com\.ar/programaciontv/busqueda\.shtml.*$'), get_details),
              (re.compile(r'^http://www\.terra\.com\.ar/programaciontv/ficha\.pl\?id=.*$'), get_synopsis),]


def save_to_db(these_events):
    for event_id,occurrences in these_events.items():
        for event_info in occurrences:
            TvShow.objects.create(**event_info)
            
def save_synopses():
    for event_id, synopsis in events_synopses.items():
        TvShow.objects.filter(show_name=event_id).update(sinopsis=synopsis)

if __name__ == '__main__':
    extra_kargs = {'links_path':links_path, 'crawled':set(), 'maxdepth':None, 'valid_urls':valid_urls, 'link_getter':get_links,}
    pool = Pool(30, spyder.dispatcher, timeout=4, extra_kargs=extra_kargs)
    for day in range(7):
        this_date = datetime.date.today() + datetime.timedelta(days=day)
        url = this_date.strftime('http://www.terra.com.ar/programaciontv/busqueda.shtml?fe=%Y/%m/%d&o=0')
        pool.add_to_queue({'depth':0, 'referrer':None, 'url':url,})
    start = datetime.datetime.now()
    TvShow.objects.all().delete()
    pool.start()
    save_to_db(events)
    save_synopses()
    end = datetime.datetime.now()
    print 'took', end - start, 'to crawl and save to db.'
