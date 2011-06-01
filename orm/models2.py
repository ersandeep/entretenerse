from django.db import models


class User(models.Model):
    name = models.CharField(max_length=50)
    password = models.CharField(max_length=50, blank=True)
    firstname = models.CharField(max_length=50, db_column='firstName', blank=True) # Field name made lowercase.
    email = models.CharField(max_length=50, blank=True)
    clickpass = models.CharField(max_length=50)
    lastname = models.CharField(max_length=50, db_column='lastName', blank=True) # Field name made lowercase.

    class Meta:
        db_table = u'users'

class CampaignType(models.Model):
    name = models.CharField(max_length=50)
    type = models.CharField(max_length=1)

    class Meta:
        db_table = u'campaign_type'

class Sponsor(models.Model):
    name = models.CharField(max_length=50)
    credit = models.FloatField()
    telephone = models.CharField(max_length=50, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    user = models.ForeignKey(User)
    url = models.CharField(max_length=100, blank=True)
    email = models.CharField(max_length=100, blank=True)

    class Meta:
        db_table = u'sponsors'

class Account(models.Model):
    date = models.DateTimeField()
    amount = models.FloatField()
    campaign = models.ForeignKey(CampaignType)
    sponsor = models.ForeignKey(Sponsor)

    class Meta:
        db_table = u'accounts'

class Attribute(models.Model):
    name = models.CharField(max_length=50)
    parent = models.ForeignKey('self', null=True, blank=True)
    value = models.CharField(max_length=50)
    icon = models.CharField(max_length=50, blank=True)
    order = models.IntegerField(null=True, blank=True)

    class Meta:
        db_table = u'attributes'

class Calendar(models.Model):
    date = models.DateTimeField(unique=True)
    dayofweek = models.IntegerField(db_column='dayOfWeek') # Field name made lowercase.
    month = models.IntegerField()
    day = models.IntegerField()
    status = models.CharField(max_length=1)
    reason = models.TextField(max_length=400, blank=True)

    class Meta:
        db_table = u'calendars'

class Campaign(models.Model):
    start = models.DateTimeField(null=True, blank=True)
    end = models.DateTimeField(null=True, blank=True)
    campaign_type = models.ForeignKey(CampaignType)
    sponsor = models.ForeignKey(Sponsor)
    status = models.CharField(max_length=1)

    class Meta:
        db_table = u'campaigns'

class Category(models.Model):
    name = models.CharField(max_length=100, blank=True)
    attribute = models.ForeignKey(Attribute, null=True, blank=True)

    class Meta:
        db_table = u'categories'

class Comment(models.Model):
    title = models.CharField(max_length=45, blank=True)
    comment = models.TextField(max_length=200, blank=True)
    created_at = models.DateTimeField()
    user = models.ForeignKey(User)
    commentable_type = models.CharField(max_length=45)
    commentable_id = models.IntegerField()

    class Meta:
        db_table = u'comments'

class Tag(models.Model):
    name = models.CharField(max_length=45)

    class Meta:
        db_table = u'tags'

class Target(models.Model):
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    name = models.CharField(max_length=50)

    class Meta:
        db_table = u'targets'

class Place(models.Model):
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    name = models.CharField(max_length=50)
    address = models.CharField(max_length=50, blank=True)
    town = models.CharField(max_length=50, blank=True)
    state = models.CharField(max_length=50, blank=True)
    country = models.CharField(max_length=50, blank=True)
    lat = models.FloatField()
    long = models.FloatField()
    phone = models.CharField(max_length=128, blank=True)

    class Meta:
        db_table = u'places'

class Event(models.Model):
    title = models.CharField(max_length=128)
    description = models.TextField()
    text = models.TextField(blank=True)
    thumbnail = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    sponsor = models.ForeignKey(Sponsor)
    price = models.FloatField(null=True, blank=True)
    image_url = models.CharField(max_length=200, blank=True)
    web = models.CharField(max_length=200, blank=True)
    duration = models.IntegerField(null=True, blank=True)
    category_id = models.IntegerField(null=True, blank=True)

    class Meta:
        db_table = u'events'

class EventCampaign(models.Model):
    campaign = models.ForeignKey(Campaign)
    event = models.ForeignKey(Event)

    class Meta:
        db_table = u'event_campaign'

class EventPlace(models.Model):
    place = models.ForeignKey(Place)
    event = models.ForeignKey(Event)
    
    class Meta:
        db_table = u'event_place'

class EventSearches(models.Model):
    event_id = models.IntegerField(primary_key=True)
    text = models.TextField(blank=True)
    attributes = models.TextField(blank=True)
    places = models.TextField(blank=True)
    
    class Meta:
        db_table = u'event_searches'

class EventTag(models.Model):
    event = models.ForeignKey(Event)
    tag = models.ForeignKey(Tag)
    
    class Meta:
        db_table = u'event_tag'

class EventTarget(models.Model):
    event = models.ForeignKey(Event)
    target = models.ForeignKey(Target)
    order = models.IntegerField(null=True, blank=True)
    
    class Meta:
        db_table = u'event_target'

class EventsAttributes(models.Model):
    event = models.ForeignKey(Event)
    attribute = models.ForeignKey(Attribute)
    
    class Meta:
        db_table = u'events_attributes'

class OccurrenceSearches(models.Model):
    occurrence_id = models.IntegerField(primary_key=True)
    search_text = models.TextField(blank=True)

    class Meta:
        db_table = u'occurrence_searches'

class Occurrence(models.Model):
    date = models.DateTimeField(null=True, blank=True)
    dayofweek = models.IntegerField(null=True, db_column='dayOfWeek', blank=True) # Field name made lowercase.
    repeat = models.CharField(max_length=1)
    from_field = models.DateTimeField(null=True, db_column='from', blank=True) # Field renamed because it was a Python reserved word. Field name made lowercase.
    to = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    place = models.ForeignKey(Place)
    event = models.ForeignKey(Event)
    hour = models.TextField(blank=True) # This field type is a guess.

    class Meta:
        db_table = u'occurrences'

class OccurrenceAttribute(models.Model):
    occurrence = models.ForeignKey(Occurrence)
    attribute = models.ForeignKey(Attribute)
    
    class Meta:
        db_table = u'occurrences_attributes'

class Performer(models.Model):
    created_at = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField(null=True, blank=True)
    name = models.CharField(max_length=50)

    class Meta:
        db_table = u'performers'

class Performances(models.Model):
    event = models.ForeignKey(Event)
    performer = models.ForeignKey(Performer)
    rol = models.CharField(max_length=45, primary_key=True)
    order = models.IntegerField(null=True, blank=True)
    
    class Meta:
        db_table = u'performances'

class Preference(models.Model):
    rank = models.IntegerField()
    user = models.ForeignKey(User)
    attribute = models.ForeignKey(Attribute)

    class Meta:
        db_table = u'preferences'

class Promotion(models.Model):
    campaign = models.ForeignKey(Campaign)
    event = models.ForeignKey(Event)

    class Meta:
        db_table = u'promotions'
