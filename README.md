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

