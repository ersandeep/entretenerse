#Creo la tabla de busqueda
DROP TABLE IF EXISTS `entretenerse`.`occurrence_searches`;
CREATE TABLE occurrence_searches (occurrence_id INT(11) UNSIGNED NOT NULL PRIMARY KEY, search_text LONGTEXT,
	FULLTEXT (search_text)) ENGINE = MyISAM DEFAULT CHARSET=utf8;
	
#Trigger que llenara la tabla de busqueda
DELIMITER //
CREATE TRIGGER occurrences_fulltext_trigger AFTER INSERT ON occurrences
FOR EACH ROW BEGIN
  INSERT INTO occurrence_searches
   (SELECT NEW.id occurrence_id, CONCAt(e.title, ' ', e.description, ' ', e.text, ' ', p.name) search_text
   FROM events e, places p WHERE e.id = NEW.event_id AND p.id = NEW.place_id);
END; //

#Insert de los datos viejos en la tabla de busqueda
INSERT INTO occurrence_searches (SELECT o.id occurrence_id, CONCAT(e.title, ' ', e.description, ' ', e.text, ' ', p.name) search_text 
	FROM occurrences o, events e, places p WHERE o.event_id = e.id AND o.place_id = p.id);
	
	
	