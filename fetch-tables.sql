DROP PROCEDURE IF EXISTS `fetchTables`;
DELIMITER $$
CREATE PROCEDURE `fetchTables`(IN pDatabase VARCHAR(255))
BEGIN 

	DECLARE v_finished INTEGER DEFAULT 0;
    DECLARE vTableName VARCHAR(255);
    DECLARE vText MEDIUMTEXT DEFAULT '';
    DECLARE vCode MEDIUMTEXT DEFAULT '';
	DECLARE vCursor CURSOR FOR (SELECT table_name FROM information_schema.tables WHERE table_schema = pDatabase);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    
	OPEN vCursor;
	get_code: 
		LOOP FETCH vCursor INTO vTableName;
	  
		IF v_finished = 1 THEN LEAVE get_code;
		END IF;
		select  CONCAT(vText, genEntities(vTableName, pDatabase),'\n') INTO vText;
        
	END LOOP get_code;
    CLOSE vCursor;
    
    SET v_finished = 0;
	OPEN vCursor;
	get_code: 
		LOOP FETCH vCursor INTO vTableName;
	  
		IF v_finished = 1 THEN LEAVE get_code;
		END IF;
		select  CONCAT(vText, genRelations(vTableName, pDatabase),'\n') INTO vText;
        
	END LOOP get_code;
    CLOSE vCursor;
    
    SELECT vText;
END;
