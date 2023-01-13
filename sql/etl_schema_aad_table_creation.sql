SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [etl].[AAD_Groups]
(
	[id] [nvarchar](4000) NULL,
	[deletedDateTime] [nvarchar](4000) NULL,
	[classification] [nvarchar](4000) NULL,
	[createdDateTime] [nvarchar](4000) NULL,
	--[creationOptions] [nvarchar](4000) NULL,
	[description] [nvarchar](4000) NULL,
	[displayName] [nvarchar](4000) NULL,
	[expirationDateTime] [nvarchar](4000) NULL,
	--[groupTypes] [nvarchar](4000) NULL,
	[isAssignableToRole] [nvarchar](4000) NULL,
	[mail] [nvarchar](4000) NULL,
	[mailEnabled] [bit] NULL,
	[mailNickname] [nvarchar](4000) NULL,
	--[proxyAddresses] [nvarchar](4000) NULL,
	[renewedDateTime] [nvarchar](4000) NULL,
	--[resourceBehaviorOptions] [nvarchar](4000) NULL,
	--[resourceProvisioningOptions] [nvarchar](4000) NULL,
	[securityEnabled] [bit] NULL,
	[securityIdentifier] [nvarchar](4000) NULL,
	[visibility] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

CREATE TABLE etl.[AAD_GroupMembers] (
        [id] NVARCHAR(4000) NULL,
        [displayName] NVARCHAR(4000) NULL,
        [givenName] NVARCHAR(4000) NULL,
        [jobTitle] NVARCHAR(4000) NULL,
        [mail] NVARCHAR(4000) NULL,
        [surname] NVARCHAR(4000) NULL,
        [userPrincipalName] NVARCHAR(4000) NULL,
        [groupId] NVARCHAR(4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)