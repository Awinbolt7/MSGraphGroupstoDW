
CREATE PROC [dbo].[MERGE_AAD_GroupMembers] AS
BEGIN

	-- =============================================
	-- Author:      <Author, , AWin>
	-- Create Date: <Create Date, , 11.22.20>
	-- Description: <Description, , A Stored Procedure that Merges AAD Data. >
	-- Notes:
	-- <1, , Created >
	-- =============================================

	-- =============================================
	-- Notes
	-- =============================================
	-- =============================================

	--CTAS AAD_Members
	CREATE TABLE #AAD_Members
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		HEAP
	)
	AS
	SELECT DISTINCT
		HASHBYTES('SHA2_256',CAST(AGM.[id] AS NVARCHAR(50))) AS [hash],
		CAST(AGM.[id] AS NVARCHAR(50)) AS [id],
		CAST([mail] AS NVARCHAR(255)) AS [mail],
		CAST([displayName] AS NVARCHAR(255)) AS [display_name],
		CAST([givenName] AS NVARCHAR(255)) AS [first_name],
		CAST([surname] AS NVARCHAR(255)) AS [last_name],
		CAST([userPrincipalName] AS NVARCHAR(255)) AS [user_principal_name]
	FROM [etl].[AAD_GroupMembers] AGM

	--merge
	MERGE [prd].[AAD_Members] AS TARGET
	USING #AAD_Members AS SOURCE
	ON (TARGET.[hash] = SOURCE.[hash])

	WHEN MATCHED
		THEN 
			UPDATE SET
				TARGET.[id] = SOURCE.[id],
				TARGET.[mail] = SOURCE.[mail],
				TARGET.[display_name] = SOURCE.[display_name],
				TARGET.[first_name] = SOURCE.[first_name],
				TARGET.[last_name] = SOURCE.[last_name],
				TARGET.[user_principal_name] = SOURCE.[user_principal_name]
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT
			(
				[hash],
				[id],
				[mail],
				[display_name],
				[first_name],
				[last_name],
				[user_principal_name]
			)
			VALUES
			(
				SOURCE.[hash],
				SOURCE.[id],
				SOURCE.[mail],
				SOURCE.[display_name],
				SOURCE.[first_name],
				SOURCE.[last_name],
				SOURCE.[user_principal_name]
			)
	--runs in full batch
	WHEN NOT MATCHED BY SOURCE
		THEN
			DELETE;

	--cleanup
	DROP TABLE #AAD_Members;

	--CTAS AAD_GroupMembers
	CREATE TABLE #AAD_GroupMembers
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		HEAP
	)
	AS
	SELECT DISTINCT
		HASHBYTES('SHA2_256',CONCAT(CAST([id] AS NVARCHAR(50)),CAST([groupId] AS NVARCHAR(50)))) AS [hash],
		CAST([id] AS NVARCHAR(50)) AS [user_id],
		CAST([groupId] AS NVARCHAR(50)) AS [group_id]
	FROM [etl].[AAD_GroupMembers]

	--merge
	MERGE [prd].[AAD_GroupMembers] AS TARGET
	USING #AAD_GroupMembers AS SOURCE
	ON (TARGET.[hash] = SOURCE.[hash])

	WHEN MATCHED
		THEN 
			UPDATE SET
				TARGET.[user_id] = SOURCE.[user_id],
				TARGET.[group_id] = SOURCE.[group_id]
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT
			(
				[hash],
				[user_id],
				[group_id]
			)
			VALUES
			(
				SOURCE.[hash],
				SOURCE.[user_id],
				SOURCE.[group_id]
			)
	--runs in full batch
	WHEN NOT MATCHED BY SOURCE
		THEN
			DELETE;

	DROP TABLE #AAD_GroupMembers;

	--CTAS AAD_Groups
	CREATE TABLE #AAD_Groups
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		HEAP
	)
	AS
	SELECT
		HASHBYTES('SHA2_256',CAST(AG.[id] AS NVARCHAR(50))) AS [hash],
		CAST(AG.[id] AS NVARCHAR(50)) AS [id],
		CAST([createdDateTime] AS DATETIME) AS [created_date_time],
		CAST([description] AS NVARCHAR(500)) AS [description],
		CAST([displayName] AS NVARCHAR(500)) AS [display_name],
		CAST([mail] AS NVARCHAR(255)) AS [mail],
		[mailEnabled] AS [mail_enabled],
		CAST([renewedDateTime] AS DATETIME) AS [renewed_date_time],
		[securityEnabled] AS [security_enabled],
		CAST([securityIdentifier] AS NVARCHAR(75)) AS [security_identifier],
		CAST([visibility] AS NVARCHAR(50)) AS [visibility]
	FROM [etl].[AAD_Groups] AG

	--merge
	MERGE [prd].[AAD_Groups] AS TARGET
	USING #AAD_Groups AS SOURCE
	ON (TARGET.[hash] = SOURCE.[hash])

	WHEN MATCHED
		THEN 
			UPDATE SET
				TARGET.[id] = SOURCE.[id],
				TARGET.[created_date_time] = SOURCE.[created_date_time],
				TARGET.[description] = SOURCE.[description],
				TARGET.[display_name] = SOURCE.[display_name],
				TARGET.[mail] = SOURCE.[mail],
				TARGET.[mail_enabled] = SOURCE.[mail_enabled],
				TARGET.[renewed_date_time] = SOURCE.[renewed_date_time],
				TARGET.[security_enabled] = SOURCE.[security_enabled],
				TARGET.[security_identifier] = SOURCE.[security_identifier],
				TARGET.[visibility] = SOURCE.[visibility]
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT
			(
				[hash],
				[id],
				[created_date_time],
				[description],
				[display_name],
				[mail],
				[mail_enabled],
				[renewed_date_time],
				[security_enabled],
				[security_identifier],
				[visibility]
			)
			VALUES
			(
				SOURCE.[hash],
				SOURCE.[id],
				SOURCE.[created_date_time],
				SOURCE.[description],
				SOURCE.[display_name],
				SOURCE.[mail],
				SOURCE.[mail_enabled],
				SOURCE.[renewed_date_time],
				SOURCE.[security_enabled],
				SOURCE.[security_identifier],
				SOURCE.[visibility]
			)
	--runs in full batch
	WHEN NOT MATCHED BY SOURCE
		THEN
			DELETE;

	--cleanup
	DROP TABLE #AAD_Groups;

END