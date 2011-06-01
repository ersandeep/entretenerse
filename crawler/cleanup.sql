DELETE FROM occurrences_attributes;
DELETE FROM events_attributes;
DELETE FROM occurrence_searches;
DELETE FROM occurrences;
DELETE FROM performances;
DELETE FROM performers;
DELETE FROM event_searches;
DELETE FROM events;

#DELETE FROM places;
/*
UPDATE attributes SET parent_id = NULL;
DELETE FROM preferences;
DELETE FROM attributes WHERE name != 'rubro';
INSERT INTO attributes (name, parent_id, value) VALUES( 'Salas', 1, 'Salas') ;
INSERT INTO attributes (name, parent_id, value) VALUES( 'Generos', 1, 'Generos');
INSERT INTO attributes (name, parent_id, value) VALUES(  'Genero Teatral', 2, 'Genero Teatral');
INSERT INTO attributes (name, parent_id, value) VALUES(  'Rubros TV', 3, 'Rubros TV');
INSERT INTO attributes (name, parent_id, value) VALUES(  'Canales TV', 3, 'Canales TV');
*/