use tryba;
DROP FUNCTION IF EXISTS genProperties;
DELIMITER 
CREATE FUNCTION genProperties(pTableName VARCHAR(255), pDatabase VARCHAR(255))
RETURNS TEXT
BEGIN

DECLARE vFinished INTEGER DEFAULT 0;

-- for properties fetch
DECLARE v_name VARCHAR(1024);
DECLARE v_type VARCHAR(1024);
DECLARE v_is_null VARCHAR(1024);
DECLARE v_extra VARCHAR(1024);
DECLARE v_key VARCHAR(1024);

DECLARE vPropCursor CURSOR FOR 
SELECT 
	COLUMN_NAME c,
	JTYPE(DATA_TYPE) AS ctype,
	IS_NULLABLE cnull, 
    EXTRA cextra, 
    COLUMN_KEY ckey
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_name = pTableName AND TABLE_SCHEMA = pDatabase;
-- TODO use the rest of sql to generate object references
-- AND COLUMN_NAME NOT IN
	-- (SELECT K.COLUMN_NAME c -- avoid fk attributes
		--   FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE K
		  -- WHERE K.TABLE_NAME = pTableName AND K.REFERENCED_TABLE_NAME IS NOT NULL);
  
DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;

	SET @class = UC_DELIMETER(pTableName, '_', TRUE,TRUE);-- LCASE(pTableName);
    SET @var = DECAPITALIZE(@class);

	SET @prop = 'private:\n';
	SET @prop = CONCAT('\t', @prop, @class,'(){};\n');-- default constructor
	SET @prop = CONCAT('\t', @prop, 'friend class odb::access;\n\n');
	SET @prop = CONCAT('\t', @prop, '#pragma db id auto\n');
	SET @prop = CONCAT('\t', @prop, 'unsigned long id_;\n');


    SET vFinished = 0;
	SET @meth = 'public:\n';
	SET @meth = CONCAT('\t', @meth, JGetter('id_', 'int'));
	SET @meth = CONCAT('\t', @meth, JSetter('id_', 'int', true));
    
    OPEN vPropCursor;
	get_prop: 
		LOOP FETCH vPropCursor INTO v_name, v_type, v_is_null, v_extra, v_key;
	  
		IF vFinished = 1 THEN 
			LEAVE get_prop; 
        END IF;
        IF v_name != 'id' THEN
			SET @prop = CONCAT('\t', @prop, v_type,' ', v_name,';');
            IF v_is_null != 'YES' THEN
				SET @prop = CONCAT(@prop,'//not null');
			END IF;
			SET @prop = CONCAT(@prop, '\n');
	SET @meth = CONCAT('\t', @meth, JGetter(v_name, v_type));
	SET @meth = CONCAT('\t', @meth, JSetter(v_name, v_type, true));
		END IF;
	  
	END LOOP get_prop;
	CLOSE vPropCursor;
    
	RETURN CONCAT('class ', @class, '{\n', @prop, @meth, '}');
END;