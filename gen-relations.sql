DROP FUNCTION IF EXISTS genRelations;
DELIMITER $$
CREATE FUNCTION genRelations(pTableName VARCHAR(255), pDatabase VARCHAR(255))
RETURNS TEXT
BEGIN
DECLARE vFinished INTEGER DEFAULT 0;

-- for relations fetch
DECLARE v_prop TEXT;
DECLARE v_one TEXT;
DECLARE v_many TEXT;

DECLARE vRelCursor CURSOR FOR
(SELECT 
		CONCAT('Property ',JVAR(tref),'To',JCLASS(t),' = ',JVAR(t),'.add',
			(CASE ctype WHEN 'Int' THEN 'Long' ELSE ctype END)/* Id issue on mysql (Id as Long) */,'Property("',c,'")',
			(CASE cnull WHEN 'NO' THEN '.notNull()' ELSE '' END),'.getProperty();\n') as prop, 
		CONCAT(JVAR(t),'.addToOne(',JVAR(tref),',',JVAR(tref),'To',JCLASS(t),');\n') as toOne,
		CONCAT(JVAR(tref),'.addToMany(',JVAR(t),',',JVAR(tref),'To',JCLASS(t),');\n') as toMany
        -- ,tref, cref, t, c, ctype
	FROM ( SELECT 
				K.TABLE_NAME t, 
				K.COLUMN_NAME c, 
				K.REFERENCED_TABLE_NAME tref, 
				K.REFERENCED_COLUMN_NAME cref, 
				C.IS_NULLABLE cnull, 
				JTYPE(C.DATA_TYPE) ctype
				-- C.COLUMN_KEY, 
				-- C.EXTRA
			FROM 	
				INFORMATION_SCHEMA.KEY_COLUMN_USAGE K  
				INNER JOIN 
				INFORMATION_SCHEMA.COLUMNS C 
				ON K.TABLE_NAME = C.TABLE_NAME AND K.COLUMN_NAME = C.COLUMN_NAME 
			WHERE K.REFERENCED_TABLE_NAME = pTableName AND K.TABLE_SCHEMA = pDatabase) A
);
 
    
DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;

	SET @class = UC_DELIMETER(pTableName, '_', TRUE,TRUE);
    SET @var = DECAPITALIZE(@class);
    
	SET @relcode = CONCAT('\t/*********** Relations pour ', @class, ' table ***********/\n');
    SET vFinished = 0;
    
    OPEN vRelCursor;
	get_rel: LOOP FETCH vRelCursor INTO v_prop, v_one, v_many;
		IF vFinished = 1 THEN 
			LEAVE get_rel; 
        END IF;

		SET @relcode = CONCAT(@relcode, v_prop, v_one, v_many,'\n');
	  
	END LOOP get_rel;
	CLOSE vRelCursor;

	RETURN @relcode;
END;
