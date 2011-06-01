import os
import random
import sys
import urllib2

import lxml.html
from settings import user_agents

ROOT = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(ROOT, '..'))

os.environ["DJANGO_SETTINGS_MODULE"] = "settings"


def get_doc(url):
    request = urllib2.Request(url, headers={'user-agent':random.choice(user_agents)})
    html = urllib2.urlopen(request).read().strip()
    return lxml.html.fromstring(html, base_url=url)
