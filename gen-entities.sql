DROP FUNCTION IF EXISTS genEntities;
DELIMITER 
CREATE FUNCTION genEntities(pTableName VARCHAR(255), pDatabase VARCHAR(255))
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
WHERE table_name = pTableName AND TABLE_SCHEMA = pDatabase
		AND COLUMN_NAME NOT IN
		(SELECT K.COLUMN_NAME c -- avoid fk attributes
		   FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE K
		  WHERE K.TABLE_NAME = pTableName AND K.REFERENCED_TABLE_NAME IS NOT NULL);
  
DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;

	SET @class = UC_DELIMETER(pTableName, '_', TRUE,TRUE);-- LCASE(pTableName);
    SET @var = DECAPITALIZE(@class);
	SET @entity = CONCAT('Entity ',@var,' = schema.addEntity("',@class,'DB");\n');
	SET @entity = CONCAT(@entity, @var, '.setTableName(DaoUtil.dbName("',@class,'"));\n');

	SET @prop = '';
	-- SET @prop = CONCAT(@prop, @var,'.implementsInterface("Parcelable");\n');
	-- SET @prop = CONCAT(@prop, @var,'.implementsSerializable();\n');
	SET @prop = CONCAT(@prop, @var,'.addIdProperty().autoincrement();\n');-- sqlite required
    SET vFinished = 0;
    
    OPEN vPropCursor;
	get_prop: 
		LOOP FETCH vPropCursor INTO v_name, v_type, v_is_null, v_extra, v_key;
	  
		IF vFinished = 1 THEN 
			LEAVE get_prop; 
        END IF;
        IF v_name != 'id' THEN
			SET @prop = CONCAT(@prop, @var,'.add', v_type,'Property("', v_name,'")');
			
            IF v_is_null != 'YES' THEN
				SET @prop = CONCAT(@prop,'.notNull()');
			END IF;
            
			SET @prop = CONCAT(@prop,';\n');
            -- SELECT @class;
		END IF;
	  
	END LOOP get_prop;
	CLOSE vPropCursor;
    
	RETURN concat(@entity,@prop);-- ,vRel);
END;