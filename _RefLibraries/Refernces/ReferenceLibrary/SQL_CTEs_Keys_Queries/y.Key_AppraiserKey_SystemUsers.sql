-- !preview conn=conn



Select Distinct
TRIM(UserLogin) AS [User_Initials],
TRIM(FirstName) AS [User_First],
TRIM(LastName) AS [User_Last],
TRIM(EmailAddr) AS [User_Email],
Id,
TranId,
UserLogin

From UserProfile
--Where UserLogin = 'KMM'