## **CHANGE HISTORY** ##
- Built by AWin on 11.27.20
- Prepped for Git by AWin on 01.13.23

## **SUMMARY** ##
This is a script that is meant to specifically import groups and their associated group members from the Microsoft GRAPH API to an Azure Synapse SQL Dedicated pool.

## **NOTES** ##
By changing the class azuresql in config.py, this could be repointed any given SQL SOURCE
SQL Files are in Synapse SQL syntax.
Highly optimal model for complex Power BI RLS across multiple external sources.
Applicable for task scheduler.

## **SETUP** ##
0. Execute Setup.py to run the package_handler, which will install / ensure installation of the required packages.
1. Change the variables in config.py to point at the appropriate app registration for MSAL/Graph, along with SQL String variables in azuresql class.
2. Execute the SQL files in sql in the desired target sql resource.
3. Execute main.py

## **WARNING** ##
main.py could be a lot better, and some of the import logic could use more thought. So any feedback would be appreciated.
The SQL Data typing is not well formed in etl_schema_aad_table_creation.sql and prd_schema_aad_table_creation.sql.