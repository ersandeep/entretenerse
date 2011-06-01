namespace :prep do
  desc 'Expose reoccurring events, correct occurrences dates'
  task :do => :environment do
    Occurrence.correct_dates
    #Occurrence.expose
    Occurrence.correct_categories
    Event.correct_images
  end

  task :expose => :environment do
    #Occurrence.correct_category
    Occurrence.expose
  end

  task :unexpose => :environment do
    Occurrence.expose :revert => true
  end

  desc 'Fixes event data in order to show it simplier and faster. Should run once a day.'
  task :correct_dates => :environment do
    #Attribute.recount # Recount categories
    # Expose week-day-only repeating events (like Teatro)
    Occurrence.correct_dates
  end

  task :correct_categories => :environment do
    Occurrence.correct_categories
  end

  task :remove_duplicates => :environment do
    Occurrence.delete_duplicates
  end

  task :images => :environment do
    Event.correct_images
  end
end
