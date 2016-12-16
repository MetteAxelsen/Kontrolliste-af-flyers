SELECT diary.[ClientNo], 
       diary.PolicyNo, 
       Diary.DiaryCode, 
       Diary.Description, 
       Diary.VersionNo     AS PoliceVersion, 
       Diary.DiaryYear     AS PoliceoprettetÅr, 
       [Diary].DiaryMonth  AS PoliceoprettetMåned, 
       Diary.DiaryDay      AS PoliceoprettetDag, 
       diary.[CrtedBy]     AS Policeopretter, 
       Skader.VersionNo    AS SkadeVersion, 
       Skader.CreatedYear  AS Skadeudbetalingsår, 
       Skader.CreatedMonth AS Skadeudbetalingsmåned, 
       Skader.CreatedDay   AS Skadeudbetalingsdag, 
       skader.CrtedBy      AS Skadeudbetaler ,
	   skader.claimnumber as Skadenummer
FROM   [NiceDataBICube].[dbo].[diary] 
       INNER JOIN (SELECT [ClientNo], 
                          [PolicyNo], 
                          [VersionNo], 
                          [DiaryCode], 
                          [ClaimNumber], 
                          [Description], 
                          [CreatedYear], 
                          [CreatedMonth], 
                          [CreatedDay], 
                          [CreatedTime], 
                          [CrtedBy] 
                   FROM   [NiceDataBICube].[dbo].[Diary] 
                   WHERE  DiaryCode = 3
				   /*Her indstilles den seneste måneds skadesudbetalinger*/
				   ) AS Skader 
               ON diary.PolicyNo = skader.PolicyNo 
                  AND Datefromparts(skader.CreatedYear, skader.CreatedMonth, 
                      skader.CreatedDay) > 
                      Datefromparts(diary.DiaryYear, Diary.DiaryMonth, 
                      Diary.DiaryDay) 
                  AND Dateadd(m, 2, Datefromparts(diary.DiaryYear, 
                                    Diary.DiaryMonth, 
                                    Diary.DiaryDay)) 
                      >= Datefromparts(skader.CreatedYear, skader.CreatedMonth, 
                         skader.CreatedDay) 
                  --and Diary.CrtedBy = skader.CrtedBy  -- Denne klausul bruges, når samme medarbejder skal være på begge begivenheder
                  AND Diary.VersionNo <= Skader.VersionNo 
WHERE  ( Diary.DiaryCode = 605 -- Police dannet 
          OR Diary.DiaryCode = 560 --  
          OR ( Diary.DiaryCode = 600 
               AND Diary.Description = 'Police i kraft' ) 
          -- Kode 600 bruges også til fakturaer 
          OR Diary.DiaryCode = 500 
          OR Diary.DiaryCode = 570 
          OR Diary.DiaryCode = 580 
          OR Diary.DiaryCode = 620 ) 
       AND diarymonth in (month(dateadd(m,-1,(SYSDATETIME()))), month(dateadd(m,-2,(SYSDATETIME()))), MONTH(sysdatetime())) /*Ikke relevant, blot 6 måneder før dags dato*/
       AND diaryyear = 2016  /*Skal tilpasses ved årskifte - bør kunne laves automatisk */
	   and Diary.CrtedBy not like 'AUTO'
GROUP  BY diary.[ClientNo], 
          diary.policyno, 
          Diary.DiaryCode, 
          Diary.VersionNo, 
          Diary.DiaryYear, 
          [Diary].DiaryMonth, 
          Diary.DiaryDay, 
          diary.[CrtedBy], 
          Skader.VersionNo, 
          Skader.CreatedYear, 
          Skader.CreatedMonth, 
          Skader.CreatedDay, 
          skader.CrtedBy, 
          Diary.Description ,
		  skader.claimnumber
ORDER  BY Diary.ClientNo 