SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Groups
CREATE TABLE [prd].[AAD_Groups]
(
	[hash] [varbinary](8000) NULL,
	[id] [nvarchar](50) NULL,
	[created_date_time] [datetime] NULL,
	[description] [nvarchar](500) NULL,
	[display_name] [nvarchar](500) NULL,
	[mail] [nvarchar](255) NULL,
	[mail_enabled] [bit] NULL,
	[renewed_date_time] [datetime] NULL,
	[security_enabled] [bit] NULL,
	[security_identifier] [nvarchar](75) NULL,
	[visibility] [nvarchar](50) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [hash] ),
	HEAP
)
GO

-- Members
CREATE TABLE [prd].[AAD_Members]
(
	[hash] [varbinary](8000) NULL,
	[id] [nvarchar](50) NULL,
	[mail] [nvarchar](255) NULL,
	[display_name] [nvarchar](255) NULL,
	[first_name] [nvarchar](255) NULL,
	[last_name] [nvarchar](255) NULL,
	[user_principal_name] [nvarchar](255) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [hash] ),
	HEAP
)
GO


-- GroupMembers
CREATE TABLE [prd].[AAD_GroupMembers]
(
	[hash] [varbinary](8000) NULL,
	[user_id] [nvarchar](50) NULL,
	[group_id] [nvarchar](50) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [hash] ),
	HEAP
)
GO
