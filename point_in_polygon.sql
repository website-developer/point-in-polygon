
DELIMITER //

DROP FUNCTION IF EXISTS point_in_polygon;
CREATE FUNCTION point_in_polygon(polygon POLYGON,point POINT) RETURNS INT(1) DETERMINISTIC
BEGIN
 DECLARE counter INT DEFAULT 0;
 DECLARE result INT(1) DEFAULT 0;
 DECLARE n INT DEFAULT 0;
 DECLARE str TEXT;
 DECLARE str2 TEXT;
 DECLARE pos INT;
 DECLARE coords VARCHAR(50);
 DECLARE coords_div_pos INT;
 DECLARE px DECIMAL(18,15);
 DECLARE py DECIMAL(18,15);
 DECLARE p1x DECIMAL(18,15);
 DECLARE p1y DECIMAL(18,15);
 DECLARE p2x DECIMAL(18,15);
 DECLARE p2y DECIMAL(18,15);
 DECLARE m DECIMAL(18,15);
 DECLARE i INT;
 DECLARE modulus INT;
 DECLARE xinters DECIMAL(18,15);
 SET coords = REPLACE(REPLACE(AsText(point),'POINT(',''),')','');
 SET coords_div_pos = INSTR(coords,' ');
 SET px = SUBSTRING(coords,1,coords_div_pos-1);
 SET py = SUBSTRING(coords,coords_div_pos+1);
 SET str = REPLACE(REPLACE(AsText(polygon),'POLYGON((',''),'))','');
 SET str2 = CONCAT(str,',');
 SET pos = INSTR(str,',');
 SET coords = SUBSTRING(str,1,pos-1);
 SET coords_div_pos = INSTR(coords,' ');
 SET p1x = SUBSTRING(coords,1,coords_div_pos-1);
 SET p1y = SUBSTRING(coords,coords_div_pos+1);
 WHILE pos>0 DO
  SET n = n + 1;
  SET str = SUBSTRING(str,pos+1);
  SET pos = INSTR(str,',');
 END WHILE;
 SET n = n + 1;
 SET i = 1;
 SET str = SUBSTRING(str2,INSTR(str2,',')+1);
 WHILE i<=n DO
  SET modulus = i % n;
  IF modulus=0 THEN
   SET str = str2;
  END IF;
  SET pos = INSTR(str,',');
  SET coords = SUBSTRING(str,1,pos-1);
  SET coords_div_pos = INSTR(coords,' ');
  SET p2x = SUBSTRING(coords,1,coords_div_pos-1);
  SET p2y = SUBSTRING(coords,coords_div_pos+1);
  IF px=p2x AND py=p2y THEN
   RETURN 1;
  END IF;
  SET str = SUBSTRING(str,pos+1);
  SET i = i + 1;
  IF p1y<p2y THEN
   SET m = p1y;
  ELSE
   SET m = p2y;
  END IF;
  IF py>m THEN
   IF p1y>p2y THEN
    SET m = p1y;
   ELSE
    SET m = p2y;
   END IF;
   IF py<=m THEN
    IF p1x>p2x THEN
     SET m = p1x;
    ELSE
     SET m = p2x;
    END IF;
    IF px<=m THEN
     IF p1y!=p2y THEN
      SET xinters = (py-p1y)*(p2x-p1x)/(p2y-p1y)+p1x;
     END IF;
     IF p1x=p2x OR px<=xinters THEN
      SET counter = counter + 1;
     END IF;
    END IF;
   END IF;
  END IF;
  SET p1x = p2x;
  SET p1y = p2y;
 END WHILE;
 IF counter%2!=0 THEN
  SET result = 1;
 END IF;
 RETURN result;
END;
//

DELIMITER ; 



-- usage example
SET @lat = 40.67; SET @lon = -73.94; /* latitude and longitude of New York City */
SET @point = GeomFromText(CONCAT('POINT(',@lat,' ',@lon,')'));
SELECT `id`,`name` FROM `us_states` WHERE MBRContains(`boundaries`,@point) AND point_in_polygon(`boundaries`,@point);
