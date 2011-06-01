namespace :prep do
  desc 'Shifts occurrences dates a week forward'
  task :back_to_future => :environment do
    Occurrence.back_to_future
  end
end
