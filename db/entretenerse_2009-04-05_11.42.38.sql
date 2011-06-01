-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.1.32


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema entretenerse
--

CREATE DATABASE IF NOT EXISTS entretenerse;
USE entretenerse;

--
-- Definition of table `entretenerse`.`accounts`
--

DROP TABLE IF EXISTS `entretenerse`.`accounts`;
CREATE TABLE  `entretenerse`.`accounts` (
  `id` int(11) NOT NULL,
  `date` datetime NOT NULL,
  `amount` double NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `sponsor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_campaign_fk` (`campaign_id`),
  KEY `account_sponsor_kf` (`sponsor_id`),
  CONSTRAINT `account_campaign_fk` FOREIGN KEY (`campaign_id`) REFERENCES `campaign_types` (`id`),
  CONSTRAINT `account_sponsor_kf` FOREIGN KEY (`sponsor_id`) REFERENCES `sponsors` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;

--
-- Dumping data for table `entretenerse`.`accounts`
--

/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
LOCK TABLES `accounts` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`attributes`
--

DROP TABLE IF EXISTS `entretenerse`.`attributes`;
CREATE TABLE  `entretenerse`.`attributes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `value` varchar(50) NOT NULL,
  `icon` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `attribute_attribute_fk` (`parent_id`),
  CONSTRAINT `attribute_attribute_fk` FOREIGN KEY (`parent_id`) REFERENCES `attributes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`attributes`
--

/*!40000 ALTER TABLE `attributes` DISABLE KEYS */;
LOCK TABLES `attributes` WRITE;
INSERT INTO `entretenerse`.`attributes` VALUES  (1,'rubro',NULL,'Teatro',NULL),
 (2,'rubro',NULL,'Cine',NULL),
 (3,'rubro',NULL,'Deportes',NULL);
UNLOCK TABLES;
/*!40000 ALTER TABLE `attributes` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`calendar`
--

DROP TABLE IF EXISTS `entretenerse`.`calendar`;
CREATE TABLE  `entretenerse`.`calendar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `month` int(11) NOT NULL,
  `day` int(11) NOT NULL,
  `status` char(1) NOT NULL,
  `reaseon` varchar(400) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entretenerse`.`calendar`
--

/*!40000 ALTER TABLE `calendar` DISABLE KEYS */;
LOCK TABLES `calendar` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `calendar` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`calendars`
--

DROP TABLE IF EXISTS `entretenerse`.`calendars`;
CREATE TABLE  `entretenerse`.`calendars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `month` int(11) NOT NULL,
  `day` int(11) NOT NULL,
  `status` char(1) NOT NULL,
  `reaseon` varchar(400) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entretenerse`.`calendars`
--

/*!40000 ALTER TABLE `calendars` DISABLE KEYS */;
LOCK TABLES `calendars` WRITE;
INSERT INTO `entretenerse`.`calendars` VALUES  (1,8,1,'F','Cumpleanios de Charly');
UNLOCK TABLES;
/*!40000 ALTER TABLE `calendars` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`campaign`
--

DROP TABLE IF EXISTS `entretenerse`.`campaign`;
CREATE TABLE  `entretenerse`.`campaign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `campaign_type_id` int(11) NOT NULL DEFAULT '0',
  `sponsor_id` int(11) NOT NULL DEFAULT '0',
  `status` char(1) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `campaign_campaign_type_fk` FOREIGN KEY (`campaign_type_id`) REFERENCES `campaign_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `campaign_sponsor_fk` FOREIGN KEY (`sponsor_id`) REFERENCES `sponsors` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entretenerse`.`campaign`
--

/*!40000 ALTER TABLE `campaign` DISABLE KEYS */;
LOCK TABLES `campaign` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `campaign` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`campaign_type`
--

DROP TABLE IF EXISTS `entretenerse`.`campaign_type`;
CREATE TABLE  `entretenerse`.`campaign_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `type` varchar(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`campaign_type`
--

/*!40000 ALTER TABLE `campaign_type` DISABLE KEYS */;
LOCK TABLES `campaign_type` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `campaign_type` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`campaign_types`
--

DROP TABLE IF EXISTS `entretenerse`.`campaign_types`;
CREATE TABLE  `entretenerse`.`campaign_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `ctype` varchar(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`campaign_types`
--

/*!40000 ALTER TABLE `campaign_types` DISABLE KEYS */;
LOCK TABLES `campaign_types` WRITE;
INSERT INTO `entretenerse`.`campaign_types` VALUES  (1,'Resaltado Simple','R'),
 (2,'Resaltado Grande','R'),
 (8,'8','8');
UNLOCK TABLES;
/*!40000 ALTER TABLE `campaign_types` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`event_attribute`
--

DROP TABLE IF EXISTS `entretenerse`.`event_attribute`;
CREATE TABLE  `entretenerse`.`event_attribute` (
  `event_id` int(11) NOT NULL,
  `attribute_id` int(11) NOT NULL,
  PRIMARY KEY (`attribute_id`,`event_id`),
  KEY `event_attribute_event_fk` (`event_id`),
  CONSTRAINT `event_attribute_attribute_fk` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `event_attribute_event_fk` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entretenerse`.`event_attribute`
--

/*!40000 ALTER TABLE `event_attribute` DISABLE KEYS */;
LOCK TABLES `event_attribute` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `event_attribute` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`event_campaign`
--

DROP TABLE IF EXISTS `entretenerse`.`event_campaign`;
CREATE TABLE  `entretenerse`.`event_campaign` (
  `campaign_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  PRIMARY KEY (`event_id`,`campaign_id`),
  KEY `event_campaign_campaign_fk` (`campaign_id`),
  CONSTRAINT `event_campaign_campaign_fk` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `event_campaign_event_fk` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entretenerse`.`event_campaign`
--

/*!40000 ALTER TABLE `event_campaign` DISABLE KEYS */;
LOCK TABLES `event_campaign` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `event_campaign` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`event_performer`
--

DROP TABLE IF EXISTS `entretenerse`.`event_performer`;
CREATE TABLE  `entretenerse`.`event_performer` (
  `event_id` int(11) NOT NULL,
  `performer_id` int(11) NOT NULL,
  `rol` varchar(45) DEFAULT NULL,
  `order` int(11) DEFAULT NULL,
  PRIMARY KEY (`event_id`,`performer_id`),
  KEY `event_performer_performer_fk` (`performer_id`),
  CONSTRAINT `event_performer_event_fk` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`),
  CONSTRAINT `event_performer_performer_fk` FOREIGN KEY (`performer_id`) REFERENCES `performers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`event_performer`
--

/*!40000 ALTER TABLE `event_performer` DISABLE KEYS */;
LOCK TABLES `event_performer` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `event_performer` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`event_place`
--

DROP TABLE IF EXISTS `entretenerse`.`event_place`;
CREATE TABLE  `entretenerse`.`event_place` (
  `place_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  PRIMARY KEY (`place_id`,`event_id`) ,
  KEY `event_place_event_fk` (`event_id`),
  CONSTRAINT `event_place_event_fk` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`),
  CONSTRAINT `event_place_place_fk` FOREIGN KEY (`place_id`) REFERENCES `places` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`event_place`
--

/*!40000 ALTER TABLE `event_place` DISABLE KEYS */;
LOCK TABLES `event_place` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `event_place` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`event_tag`
--

DROP TABLE IF EXISTS `entretenerse`.`event_tag`;
CREATE TABLE  `entretenerse`.`event_tag` (
  `event_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`tag_id`,`event_id`),
  KEY `event_tag_event_fk` (`event_id`),
  CONSTRAINT `event_tag_event_fk` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `even_tag_tag_fk` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entretenerse`.`event_tag`
--

/*!40000 ALTER TABLE `event_tag` DISABLE KEYS */;
LOCK TABLES `event_tag` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `event_tag` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`event_target`
--

DROP TABLE IF EXISTS `entretenerse`.`event_target`;
CREATE TABLE  `entretenerse`.`event_target` (
  `event_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `order` int(11) DEFAULT NULL,
  PRIMARY KEY (`event_id`,`target_id`),
  KEY `event_target_target_fk` (`target_id`),
  CONSTRAINT `event_target_event_fk` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `event_target_target_fk` FOREIGN KEY (`target_id`) REFERENCES `targets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entretenerse`.`event_target`
--

/*!40000 ALTER TABLE `event_target` DISABLE KEYS */;
LOCK TABLES `event_target` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `event_target` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`events`
--

DROP TABLE IF EXISTS `entretenerse`.`events`;
CREATE TABLE  `entretenerse`.`events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `text` longtext NOT NULL,
  `thumbnail` blob,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sponsor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `event_sponsor_fk` (`sponsor_id`),
  CONSTRAINT `event_sponsor_fk` FOREIGN KEY (`sponsor_id`) REFERENCES `sponsors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`events`
--

/*!40000 ALTER TABLE `events` DISABLE KEYS */;
LOCK TABLES `events` WRITE;
INSERT INTO `entretenerse`.`events` VALUES  (1,'Darth  Vader III contra Obi Wan','nada','Eso',NULL,'2009-03-11 03:13:20','2009-03-11 03:13:20',1);
UNLOCK TABLES;
/*!40000 ALTER TABLE `events` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`events_pepe`
--

DROP TABLE IF EXISTS `entretenerse`.`events_pepe`;
CREATE TABLE  `entretenerse`.`events_pepe` (
  `id` int(11) NOT NULL,
  `text` text,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `newindex` (`text`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entretenerse`.`events_pepe`
--

/*!40000 ALTER TABLE `events_pepe` DISABLE KEYS */;
LOCK TABLES `events_pepe` WRITE;
INSERT INTO `entretenerse`.`events_pepe` VALUES  (0,'laro que las Madres y las Abuelas estaban ahí, dueñas por derecho propio de la escena. Cada vez más pequeñas en su físico, con las sandalias tan habituadas a fatigar las calles sin violencia ni agresiones, ganándose un aplauso pleno, sostenido, emocionado.\n\nLos de 60, 50 años, los argentinos que la pasaron mal años ha, discurrieron otra vez sobre el espacio público de una ciudad calma, en la que refrescó un poquito, como para aliviar la tenida.\n\nEl documento leído desde el palco remoza los reclamos que llevan décadas. Podría hacerse una semblanza de la más noble militancia de la historia argentina repasando cómo fueron variando esas consignas. La “aparición con vida” de las Madres pioneras y corajudas, el “castigo a los culpables”, los repudios a la obediencia debida, el punto final y los indultos, la exigencia de nulidades se sucedieron en el tiempo. Ahora se agregan los pedidos por Jorge Julio López y las críticas por las demoras de los juicios a los genocidas.\n\nEs un tramo de más de un cuarto de siglo de funcionamiento institucional: las defecciones de los gobiernos populares, sus destellos de compromiso, los grandes momentos de los procesos a las Juntas y los producidos desde hace pocos años, la tenacidad de un sector creciente de la sociedad civil, con su vanguardia imbatible, los organismos de derechos humanos.\n\n- - -\n\nLa Plaza de Mayo está colmada, desde el palco hacia Bolívar. Se está terminando de leer el documento, el cronista descorre la Avenida de Mayo, ya pasadas las cinco de la tarde. Las columnas siguen viniéndose en sinfín, abigarradas hasta la avenida 9 de Julio, un poco más separadas hasta Rodríguez Peña. Hay algunas por Diagonal Norte, no tantas. Amén de la Plaza, hay más de once cuadras de multitud, alrededor de 40.000 metros cuadrados ocupados por manifestantes.\n\nEche usted su cuenta de la asistencia, lector, desconfíe de los canales de noticias y los on line de los grandes medios, que ayer mezquinaron cobertura. Días atrás transmitieron en cadena la raleada movida contra la inseguridad y los discursos proselitistas de un rabino en campaña y un sacerdote católico que rezumaba odio.\n\n- - -\n\nVolvamos a la calle, es más grato. Un repaso a ojo registra columnas variopintas, que suman al planteo colectivo signos identitarios. La agenda de las dictaduras es plana, no sólo se reprime la disidencia política, sino todas las formas de libertad o de diversidad.\n\nEn democracia, las demandas se multiplican y sofistican. Jamás serán saciadas del todo, pero la ampliación de sus márgenes es un dato insoslayable que a veces nos perdemos de ver. Grupos feministas que promueven el fin de la violencia familiar. Bolivianos orgullosos, tocando instrumentos de su terruño, con la bandera multicolor y pancartas con la figura de Evo Morales. Un grupo que, al modo de los descamisados que asumían con orgullo el mote desdeñoso de las minorías que los despreciaban, transforma la discriminación en bandera burlona. “Los putos peronistas” se la bancan como tales, y ya que están, se enumeran como “travas, tortas” y otras gracias.\n\nCentros de estudiantes secundarios y universitarios suman sus cánticos y sus internas, que también las hay. Hugo Yasky y Martín Sabbatella marchan juntos, como por las calles de la provincia, sueltos de aparatos, cómodos entre la multitud. Marta Maffei, que supo encabezar hechos de masas y de honrosas luchas gremiales, también anda por ahí, es una más entre los que siempre pusieron el cuerpo.\n\n- - -\n\nLa política dice presente desde el kirchnerismo a su izquierda. La entente pro campo no aporta presencias, está en otra. Muchos nombres de los ’70 acompañan a Evita y Guevara: desde Cacho el Kadre hasta Santucho.\n\nLos jóvenes de La Cámpora mixturan la evocación del efímero presidente de la primavera con un issue de coyuntura flamante “una ley de medios para la democracia”.\n\nLibres del Sur, con una columna más que nutrida, cuestiona a Carrió, a Macri, De Narváez y Solá, pero pone por delante su distanciamiento con el kirchnerismo y un motivo. “Rico no es derechos humanos”, proclama, irrefutable, una bandera que marca el camino de su gente.\n\n- - -\n\nLa multiplicidad de partidos de izquierda comulga con el reclamo general, pero le agrega su posición crítica frente al gobierno nacional. Son miles de manifestantes, nutridos con panfletos y publicaciones. Se ubican al final, en un abanico de siglas que describe su saga. Las consignas contra el Gobierno son severas.\n\nLuis Zamora camina con un par de compañeros por la vereda, sin columna ni pancartas.\n\n- - -\n\nCarta Abierta, que tuvo su bautismo de masas en el día previo al voto no positivo, es uno entre los nuevos colectivos que se agregan a una honrosa tradición. Las Asambleas barriales, que dieron color y número a tantos encuentros desde 2002, son difíciles de encontrar.\n\nMucha gente por la libre, parejas, pequeños grupos que eventualmente alivian el cansancio en las veredas de algún café. Bebés que miran azorados, en los hombros de sus padres o sus abuelos.\n\nA ojímetro, la clase media hegemoniza la concurrencia, la base social humilde de los movimientos sociales es minoría.\n\n- - -\n\nHay que tener 25 años para haber pasado toda la vida en democracia. Los de treinta recibieron toda su educación formal sin el cepo feroz del autoritarismo. Sería una audacia justipreciar cuántos de los manifestantes a Plaza de Mayo tenían esas edades, pero es seguro que eran muchos, acaso más de la mitad. La mayoría no son ya víctimas ni deudos: los pibes de HIJOS andan por arriba de 30, por lo general. Jóvenes de nuevas camadas, con sus propias experiencias, sin la vivencia personal de la dictadura, con la libertad mamada desde la cuna, dijeron presente, testimoniando que las grandes causas no tienen dueños, ni personales ni generacionales.\n\n- - -\n\nAyer mismo, a las siete de la tarde, para el on line de La Nación la noticia principal era la caída del gobierno checoslovaco. Wall Street la segunda, en la lógica de la edición la marcha era la décima o menos. Recién a las 19.30 la marcha gana posiciones en la edición de Internet del diario de los Mitre. Muy otro trato que los cortes de ruta de centenares de productores o que la convocatoria módica de Susana, Bergman y Marcó.\n\nLos instigadores, cómplices y luego encubridores del terrorismo de Estado siguen fieles a sí mismos, en su afán ocultador. Con todo, la tribuna de doctrina habla de “dictadura”. Es un avance, el tono de los tiempos mueve hasta a los más remisos: hasta hace un par de años el manual de estilo no escrito pero imperativo del medio vetaba esa expresión. Era “gobierno de facto” y el terrorismo de Estado “lucha antisubversiva”. Esa segunda supresión sigue vigente, casi todas las veces. Ese es el estilo de la “prensa independiente”.\n\nFue una fiesta de la democracia y la memoria. Organizaciones no gubernamentales, ciudadanos sueltos, partidos políticos del oficialismo y de la oposición, cooperando en aras de su insigne denominador común y dando rienda suelta a sus enormes divergencias.\n\nUsted, lector consecuente de este diario, inmune a la feroz manipulación predominante, seguramente lo palpó. Por si no estuvo, sepa que fue un actazo, en el que vibró una sociedad plural, dividida, herida, movilizada, viva al fin.'),
 (2,'El clima mediático creado a partir del protagonismo que se da a los reclamos por la inseguridad y al conflicto con los productores rurales quiere sugerir una especie de cansancio de la sociedad con el tema de los derechos humanos. Muchos de los actores en esas dos cuestiones no han ocultado su antipatía por los juicios a los represores, e incluso algunos han defendido a los genocidas. Sin embargo, y a contrapelo de ese clima preponderante en los medios, si se suman los participantes en los dos actos que se realizaron ayer en Plaza de Mayo por el aniversario del golpe del ’76, más el festival musical del lunes frente a los Tribunales y todos los actos que se hicieron en las principales ciudades del país, podría decirse que la convocatoria popular para esta fecha crece, en vez de achicarse, a medida que pasa el tiempo.\n\n- - -\n\nPara la misma hora que comenzaban a concentrarse las columnas de la marcha convocada por los organismos de derechos humanos se conocía el fallo de la Corte Suprema avalando la condena a Miguel Etchecolatz, el ex jefe de la Bonaerense durante la dictadura. Esa condena incluye la figura de genocidio y la advertencia de que los que cometieron delitos de lesa humanidad deben cumplir sus penas en cárcel común, independientemente de su edad. Algunos de estos puntos formaban parte de los reclamos más importantes sobre derechos humanos planteados en las dos marchas de ayer.\n\n- - -\n\nLas dos marchas fueron bastante heterogéneas. En la primera, convocada por los organismos de derechos humanos, junto con muchas personas que no llegaron encolumnadas, coincidían sectores kirchneristas como el Frente Transversal, de Edgardo de Petri; el Movimiento Evita, de Emilio Pérsico, o La Cámpora, de Juan Cabandié, con sectores críticos no opositores, como Encuentro, de Martín Sabbatella; la CTA, que marchó con Hugo Yasky y Víctor De Gennaro, y el Movimiento Libres del Sur, el Partido Comunista y el Partido Humanista; y otros abiertamente opositores al Gobierno, como Proyecto Sur, de Pino Solanas. Hubo dos agrupamientos que llevaron las banderas rojas del Partido Socialista, el más numeroso, encabezado por Oscar González y Ariel Basteiro, más próximo al kirchnerismo, y uno más reducido del socialismo de la Capital, de Roy Cortina, ubicado en la oposición. También marchó un pequeño grupo que llevaba un cartel que decía “Juventud Radical, somos el juicio a las Juntas”.\n\n- - -\n\nEn la cabeza de esta marcha estaban los dirigentes de los organismos de derechos humanos, Madres Línea Fundadora, Abuelas, Familiares, Hijos, Serpaj, CELS y APDH, entre otros. El diputado Juan Carlos Dante Gullo y la titular del Inadi, María José Lubertino, acompañaron a la columna de los organismos de derechos humanos. Otra de las columnas de esta marcha estaba encabezada por Jorge Ceballos, de Libres del Sur, Sabbatella y Yasky. Por lo menos los dos primeros están impulsando una lista independiente en el distrito bonaerense junto con el Partido de la Solidaridad, de Carlos Heller, que competirá con las del Frente para la Victoria.\n\n- - -\n\nEs común que en estos actos se sumen otras experiencias sociales, como los movimientos ecologistas, de los pueblos originarios o de género. Un grupo llevaba un cartel con el rostro de Eva Perón con una máscara antigás, que decía: “No al Ceamse en Ciudad Evita”. También hubo una nutrida agrupación de la Nación Diaguita, que desfiló con la bandera del arco iris haciendo sonar los erques y las cajas. En un corrillo discutían sobre cuál de los carteles exigía “más huevos” para llevarlo en la caminata. Algunos se inclinaban por el de la Juventud Radical, pero la mayoría votaba por un gran cartel que decía: “Putos peronistas, tortas y travestis del pueblo”.\n\n- - -\n\nLa confluencia de las dos marchas con poca diferencia de tiempo produjo algún desorden. En el primer acto, los organismos de derechos humanos terminaron de leer su documento cuando muchas columnas todavía no habían ingresado en la Plaza. Entonces subieron al estrado los animadores del acto siguiente, convocado por el Encuentro por la Memoria, Verdad y Justicia y partidos de izquierda, con lo que se mezclaron situaciones. Las columnas iban entrando y en vez de recibirlas, desde los parlantes les pedían que se retiraran. En ese momento recién estaban entrando las columnas de la corriente 26 de Julio, del peronismo revolucionario, las del PC, Libres del Sur y otras más que llegaban hasta la 9 de Julio.\n\n- - -\n\nA pesar de que los actos hayan sido por separado, se supone que las agrupaciones políticas que participaron en ambos coinciden en su repudio a la dictadura y en el reclamo por la vigencia de los derechos humanos. A pesar de los diferentes círculos comunes de los concurrentes a cada acto, también coinciden en la dificultad para traducir esos niveles de identidad en expresiones políticas confluyentes. Pese a su capacidad de movilización, siguen siendo pequeños partidos o agrupamientos que, con pocas excepciones, no alcanzan a lograr representaciones políticas legislativas o electorales importantes. Solamente alcanzan fuerza para promover sus planteos cuando logran coincidencias como la de los actos de ayer.\n\n- - -\n\nEn la cabecera de la segunda marcha estuvieron Adriana Calvo, de la Asociación de ex Detenidos-Desaparecidos, y Adolfo Pérez Esquivel. El dirigente del Serpaj fue el único que estuvo en la cabeza de las dos marchas. El grupo de Proyecto Sur también fue el único que participó en los dos actos. En esa cabecera también estuvieron dirigentes de los partidos de izquierda, de la FUBA y de decenas de comisiones de derechos humanos de barrios y centros estudiantiles que integran el Encuentro Memoria, Verdad y Justicia.\n\n- - -\n\nPara estos partidos de izquierda –PO, MAS, MST, PCR, PTS y otros–, que tras las grandes movilizaciones del 2002 y 2003 quedaron al margen del escenario político ocupado por la confrontación entre el oficialismo y la oposición, el acto por el 24 de marzo constituye la oportunidad de mostrar su fuerza de movilización y llevaron columnas nutridas, aunque menos que en los actos del 2002 y 2003.\n\n- - -\n\nEn este espectro, la coincidencia mayor es que todos son opositores al Gobierno, que se llevó el protagonismo central en las consignas de los manifestantes. En la mayoría de los casos las consignas no diferencian al Gobierno de la oposición de derecha y los engloban como un solo cuerpo. Pese a ese pequeño detalle, la puja central del escenario político, entre el Gobierno y esa oposición, se filtra irremediablemente y les genera problemas, como sucedió con el lockout de los productores agropecuarios. Mientras que agrupaciones como el PO, el PTS o el MST lo analizaron como un conflicto interburgués y se corrieron a un costado, otras agrupaciones, como los trotskistas del MAS y los chinoístas del PCR, respaldaron en los hechos los reclamos más retrógrados de la Mesa de Enlace. Los chinoístas incluso sellaron una alianza con el ala más derechista de la Federación Agraria, expresada por Alfredo De Angelis. En una lógica de izquierdas y derechas, en la práctica se pusieron a la derecha del Gobierno.');
UNLOCK TABLES;
/*!40000 ALTER TABLE `events_pepe` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`occurrences`
--

DROP TABLE IF EXISTS `entretenerse`.`occurrences`;
CREATE TABLE  `entretenerse`.`occurrences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `dayOfWeek` int(11) DEFAULT NULL,
  `repeat` char(1) NOT NULL,
  `from` datetime DEFAULT NULL,
  `to` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `place_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ocurrence_place_fk` (`place_id`),
  KEY `ocurrence_event_fk` (`event_id`),
  CONSTRAINT `ocurrence_event_fk` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`),
  CONSTRAINT `ocurrence_place_fk` FOREIGN KEY (`place_id`) REFERENCES `places` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`occurrences`
--

/*!40000 ALTER TABLE `occurrences` DISABLE KEYS */;
LOCK TABLES `occurrences` WRITE;
INSERT INTO `entretenerse`.`occurrences` VALUES  (1,'2009-03-11 03:12:00',1,'1','2009-03-11 03:12:00','2009-03-11 03:12:00','2009-03-11 03:13:20','2009-03-11 03:13:20',1,1),
 (2,'2009-03-11 03:14:00',2,'3','2009-03-11 03:14:00','2009-03-11 03:14:00','2009-03-11 03:15:16','2009-03-11 03:15:16',5,1);
UNLOCK TABLES;
/*!40000 ALTER TABLE `occurrences` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`performers`
--

DROP TABLE IF EXISTS `entretenerse`.`performers`;
CREATE TABLE  `entretenerse`.`performers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`performers`
--

/*!40000 ALTER TABLE `performers` DISABLE KEYS */;
LOCK TABLES `performers` WRITE;
INSERT INTO `entretenerse`.`performers` VALUES  (1,'2009-03-10 21:16:41','2009-03-10 21:16:41','pepe'),
 (2,'2009-03-27 23:20:06','2009-03-27 23:20:06','Antonio Banderas');
UNLOCK TABLES;
/*!40000 ALTER TABLE `performers` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`places`
--

DROP TABLE IF EXISTS `entretenerse`.`places`;
CREATE TABLE  `entretenerse`.`places` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(50) DEFAULT NULL,
  `town` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `lat` double NOT NULL,
  `long` double NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`places`
--

/*!40000 ALTER TABLE `places` DISABLE KEYS */;
LOCK TABLES `places` WRITE;
INSERT INTO `entretenerse`.`places` VALUES  (1,'2009-03-10 22:11:04','2009-03-10 22:11:04','La Trastienda','Balcarce 143','San Telmo','Capital Federal','Argentina',34,43),
 (5,'2009-03-11 03:15:16','2009-03-11 03:15:16','Teatro Opera','Balcarce','Buenos Aires','Buenos Aires','Argentina',34,43);
UNLOCK TABLES;
/*!40000 ALTER TABLE `places` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`preferences`
--

DROP TABLE IF EXISTS `entretenerse`.`preferences`;
CREATE TABLE  `entretenerse`.`preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rank` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `attribute_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `preference_attribute_fk` (`attribute_id`),
  KEY `preference_user_fk` (`user_id`),
  CONSTRAINT `preference_attribute_fk` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`id`),
  CONSTRAINT `preference_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`preferences`
--

/*!40000 ALTER TABLE `preferences` DISABLE KEYS */;
LOCK TABLES `preferences` WRITE;
INSERT INTO `entretenerse`.`preferences` VALUES  (1,1,1,1);
UNLOCK TABLES;
/*!40000 ALTER TABLE `preferences` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`promotions`
--

DROP TABLE IF EXISTS `entretenerse`.`promotions`;
CREATE TABLE  `entretenerse`.`promotions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `promotion_event_fk` (`event_id`),
  KEY `promotion_campaign_fk` (`campaign_id`),
  CONSTRAINT `promotion_campaign_fk` FOREIGN KEY (`campaign_id`) REFERENCES `campaigns` (`id`),
  CONSTRAINT `promotion_event_fk` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`promotions`
--

/*!40000 ALTER TABLE `promotions` DISABLE KEYS */;
LOCK TABLES `promotions` WRITE;
INSERT INTO `entretenerse`.`promotions` VALUES  (1,1,1);
UNLOCK TABLES;
/*!40000 ALTER TABLE `promotions` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`sponsors`
--

DROP TABLE IF EXISTS `entretenerse`.`sponsors`;
CREATE TABLE  `entretenerse`.`sponsors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `credit` double NOT NULL,
  `telephone` varchar(50) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) NOT NULL,
  `url` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sponsor_user_fk` (`user_id`),
  CONSTRAINT `sponsor_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`sponsors`
--

/*!40000 ALTER TABLE `sponsors` DISABLE KEYS */;
LOCK TABLES `sponsors` WRITE;
INSERT INTO `entretenerse`.`sponsors` VALUES  (1,'Coca Cola',9,'42944533','2009-03-11 03:13:20','2009-03-11 03:13:20',1,NULL,NULL),
 (2,'h',0,'h','2009-03-28 00:59:15','2009-03-28 00:59:15',1,'h','h');
UNLOCK TABLES;
/*!40000 ALTER TABLE `sponsors` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`tags`
--

DROP TABLE IF EXISTS `entretenerse`.`tags`;
CREATE TABLE  `entretenerse`.`tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entretenerse`.`tags`
--

/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
LOCK TABLES `tags` WRITE;
INSERT INTO `entretenerse`.`tags` VALUES  (1,'Ciencia Ficcion');
UNLOCK TABLES;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`targets`
--

DROP TABLE IF EXISTS `entretenerse`.`targets`;
CREATE TABLE  `entretenerse`.`targets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`targets`
--

/*!40000 ALTER TABLE `targets` DISABLE KEYS */;
LOCK TABLES `targets` WRITE;
INSERT INTO `entretenerse`.`targets` VALUES  (1,'2009-03-10 21:20:57','2009-03-10 21:20:57','chicos'),
 (2,'2009-03-27 23:31:30','2009-03-27 23:31:30','adultos'),
 (3,'2009-03-27 23:31:39','2009-03-27 23:31:39','solos y solas');
UNLOCK TABLES;
/*!40000 ALTER TABLE `targets` ENABLE KEYS */;


--
-- Definition of table `entretenerse`.`users`
--

DROP TABLE IF EXISTS `entretenerse`.`users`;
CREATE TABLE  `entretenerse`.`users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `password` varchar(50) DEFAULT NULL,
  `firstName` varchar(50) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `clickpass` varchar(50) NOT NULL,
  `lastName` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entretenerse`.`users`
--

/*!40000 ALTER TABLE `users` DISABLE KEYS */;
LOCK TABLES `users` WRITE;
INSERT INTO `entretenerse`.`users` VALUES  (1,'clizarralde','oycobe','Carlos','charly.lizarralde@gmail.com','clizarralde','Lizarralde');
UNLOCK TABLES;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
