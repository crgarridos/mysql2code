mysql2code
===

MySql procedures to generate classes or code automatically based on schema structure
> base on this https://gist.github.com/crgarridos/f5765b19bb8690ba7d18

These scripts work on mysql enviroment, then that means you should have priviliged access to create and execute function/procedures. 

### How to use
As previous requirement all scripts shall be runned to create functions.
Then the use is just the call to the main function that generate the code as a string in a only-one-column.
```sql
CALL fetchTables('from-this-database');
```
where `from-this-database` is the database from you want to generate classes' code

### TODO
* The actual script generate only code for greendao, please modify the fetchtables method to include `genProperties`functiion which do generate c++ class' code 

    ```sql
    SELECT genProperties('table','database');
    ```
* rename types in utils-cript.sql file to make them compatible with c++ types
* There is some code to generate classes' relations, this lines are contained in [gen-properties.sql] and you should do a second request with the lines commented in the code below:
    ```sql
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
    ```
    Then this mean you have to uncomment these lines and ceate another cursor for add this propertis with classes types.
