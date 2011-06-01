class MovePlaces < ActiveRecord::Migration
  def self.up
    execute('insert into occurrences_places (place_id, occurrence_id) ' +
      'select place_id, id from occurrences;')
  end

  def self.down
    execute('update occurrences set place_id = ' +
      '(select place_id from occurrences_places where occurrences_places.occurrence_id = occurrences.id);')
  end
end
