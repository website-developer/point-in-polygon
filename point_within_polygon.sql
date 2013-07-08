
DELIMITER //

DROP FUNCTION IF EXISTS point_within_polygon;
CREATE FUNCTION point_within_polygon(polygon POLYGON,point POINT) RETURNS INT(1) DETERMINISTIC
BEGIN
 DECLARE counter INT DEFAULT 0;
 DECLARE result INT(1) DEFAULT 0;
 DECLARE n INT DEFAULT 0;
 DECLARE points LINESTRING;
 DECLARE p POINT;
 DECLARE px DECIMAL(18,15);
 DECLARE py DECIMAL(18,15);
 DECLARE p1x DECIMAL(18,15);
 DECLARE p1y DECIMAL(18,15);
 DECLARE p2x DECIMAL(18,15);
 DECLARE p2y DECIMAL(18,15);
 DECLARE m DECIMAL(18,15);
 DECLARE i INT;
 DECLARE xinters DECIMAL(18,15);
 SET points = ExteriorRing(polygon);
 SET px = X(point);
 SET py = Y(point);
 SET p = PointN(points,1);
 SET p1x = X(p);
 SET p1y = Y(p);
 SET n = NumPoints(points);
 SET i = 1;
 WHILE i<=n DO
  SET p = PointN(points,i%n+1);
  SET p2x = X(p);
  SET p2y = Y(p);
  IF px=p2x AND py=p2y THEN
   RETURN 1;
  END IF;
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
SELECT `id`,`name` FROM `us_states` WHERE MBRContains(`boundaries`,@point) AND point_within_polygon(`boundaries`,@point);
