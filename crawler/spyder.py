import lxml.html
import random
import re
import sys
import urllib2
import urlparse

from workers import get_doc


def get_url_handler(url, valid_urls):
    """
        url: string
        valid_urls: [(compiled_regex, function), (compiled_regex, function), (compiled_regex, function), etc...]
    """
    for pattern, function in valid_urls:
        match = pattern.match(url)
        if match:
            return match, function
    return False, None

def dispatcher(worker, item, links_path, crawled, maxdepth, valid_urls, link_getter=lambda doc, links_path: doc.xpath(links_path)):
    """
        worker: threading.Thread
        item: {'url':url, 'referrer':some_url or None, 'depth':int}
        links_path: an xpath to look for links that matches the 'href' attribute
        crawled: a set where the crawled urls are added
        maxdepth: int
        valid_urls: [(compiled_regex, function), (compiled_regex, function), etc...], function signature is function(worker, doc, regexmatch, item)
    """
    url = item['url']
    referrer = item['referrer']
    depth = item['depth']
    
    with worker.pool.mutex:
        if url in crawled:
            return
        crawled.add(url)
    
    try:
        doc = get_doc(url)
    except urllib2.HTTPError, e:
        print '*' * 30
        print 'Error when fetching url: %s' % url
        print 'Error was: %s' % e
        if e.code == 500:
            if item.setdefault('retries', 0) < 100:
                print 'Putting url back in queue, tried %s times.' % (item['retries'] + 1)
                with worker.pool.mutex:
                    crawled.discard(url)
                item['retries'] += 1
                worker.add_to_queue(item)
            else:
                print 'Url %s failed after %s attempts... discarding.' % (url, item['retries'] + 1)
        print '*' * 30
        return
    except urllib2.URLError, e:
        print '*' * 30
        print 'Error when fetching url: %s' % url
        print 'Error was: %s' % e
        print '*' * 30
        return
    
    links = link_getter(doc, links_path)
    for path in links:
        new_url = urlparse.urljoin(url, path)
        valid, _ = get_url_handler(new_url, valid_urls)
        with worker.pool.mutex:
            if (new_url in crawled) or not valid or (maxdepth and (depth >= maxdepth)):
                continue
        worker.add_to_queue({'depth':depth + 1, 'referrer':url, 'url':new_url,})
    
    match, handler = get_url_handler(url, valid_urls)
    if match and handler:
        handler(worker, doc, match, item)

