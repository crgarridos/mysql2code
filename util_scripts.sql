DROP FUNCTION IF EXISTS SPLIT_STR;
CREATE FUNCTION SPLIT_STR(x TEXT, delim TEXT, pos INT)
RETURNS TEXT
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),delim, '');
       
-- compte le nombre des ocurrences de v dans x
DROP FUNCTION IF EXISTS COUNT_STR;
CREATE FUNCTION COUNT_STR(x TEXT, v TEXT)
RETURNS INT
RETURN (LENGTH(x) - LENGTH(REPLACE(x, v, '')))/LENGTH(v);

-- SELECT COUNT_STR('aloaloaloaa','a')

DROP FUNCTION IF EXISTS DECAPITALIZE;
CREATE FUNCTION DECAPITALIZE(s VARCHAR(255)) RETURNS VARCHAR(255)
  RETURN CONCAT(LCASE(LEFT(s, 1)), SUBSTRING(s, 2));

DROP FUNCTION IF EXISTS UC_FIRST;
CREATE FUNCTION UC_FIRST(oldWord VARCHAR(255)) RETURNS VARCHAR(255)
  RETURN CONCAT(UCASE(SUBSTRING(oldWord, 1, 1)),SUBSTRING(oldWord, 2));

DROP FUNCTION IF EXISTS DEL_CHAR_AND_CAPITALIZE;
DELIMITER //
CREATE FUNCTION DEL_CHAR_AND_CAPITALIZE(x TEXT, v TEXT) RETURNS TEXT
BEGIN
	SET @x = 0;
    SET @c = COUNT_STR(x,v)+1;
    SET @s = '';
    REPEAT
		SET @x = @x + 1;
        SET @t = SPLIT_STR(x,v,@x);
        SET @s = CONCAT(@s,UC_FIRST(@t));
    UNTIL @x >= @c END REPEAT;
    RETURN @s;
END // DELIMITER ;

 
-- SELECT DEL_CHAR_AND_CAPITALIZE('', '_');

DROP FUNCTION IF EXISTS UC_DELIMETER;
DELIMITER //
CREATE FUNCTION UC_DELIMETER(oldName VARCHAR(255), delim VARCHAR(1), trimSpaces BOOL, replaceDelim BOOL) RETURNS VARCHAR(255)
BEGIN
  SET @oldString := oldName;
  SET @newString := "";
 
  tokenLoop: LOOP
    IF trimSpaces THEN SET @oldString := TRIM(BOTH " " FROM @oldString); END IF;
 
    SET @splitPoint := LOCATE(delim, @oldString);
 
    IF @splitPoint = 0 THEN
      SET @newString := CONCAT(@newString, UC_FIRST(@oldString));
      LEAVE tokenLoop;
    END IF;
 
    SET @newString := CONCAT(@newString, UC_FIRST(SUBSTRING(@oldString, 1, @splitPoint)));
    SET @oldString := SUBSTRING(@oldString, @splitPoint+1);
  END LOOP tokenLoop;
  
  IF replaceDelim THEN 
	RETURN REPLACE(@newString,delim,'');
  END IF;
  RETURN @newString;
END// DELIMITER ;


DROP FUNCTION IF EXISTS JTYPE;
DELIMITER //
CREATE FUNCTION JTYPE(pType TEXT) RETURNS TEXT
BEGIN
  RETURN (CASE pType 
				WHEN 'bigint' THEN 'Long'
				WHEN 'binary' THEN 'Byte[]'
				WHEN 'bit' THEN 'Boolean'
				WHEN 'char' THEN 'String'
				WHEN 'date' THEN 'Date'
				WHEN 'datetime' THEN 'Date'
				WHEN 'datetime2' THEN 'Date'
				WHEN 'decimal' THEN 'Double'
				WHEN 'double' THEN 'Double'
				WHEN 'float' THEN 'Float'
				WHEN 'image' THEN 'byte[]'
				WHEN 'int' THEN 'Int'
				WHEN 'longtext' THEN 'String'
				WHEN 'money' THEN 'Double'
				WHEN 'nchar' THEN 'String'
				WHEN 'ntext' THEN 'String'
				WHEN 'numeric' THEN 'Double'
				WHEN 'nvarchar' THEN 'String'
				WHEN 'real' THEN 'Double'
				WHEN 'smalldatetime' THEN 'Date'
				WHEN 'smallint' THEN 'Int'
				WHEN 'mediumint' THEN 'Int'
				WHEN 'smallmoney' THEN 'Double'
				WHEN 'text' THEN 'String'
				WHEN 'time' THEN 'Date'
				WHEN 'timestamp' THEN 'Date'
				WHEN 'tinyint' THEN 'Boolean'
				WHEN 'uniqueidentifier' THEN 'String'
				WHEN 'varbinary' THEN 'byte[]'
				WHEN 'VARCHAR' THEN 'String'
				WHEN 'year' THEN 'Int'
				ELSE 'UNKNOWN_' + pType 
		END);
END// DELIMITER ;

DROP FUNCTION IF EXISTS JVAR;
CREATE FUNCTION JVAR(tname TEXT) RETURNS TEXT
  RETURN DECAPITALIZE(JCLASS(tname));
  
  
DROP FUNCTION IF EXISTS JCLASS;
CREATE FUNCTION JCLASS(tname TEXT) RETURNS TEXT
  RETURN (DEL_CHAR_AND_CAPITALIZE(tname,'_'));
