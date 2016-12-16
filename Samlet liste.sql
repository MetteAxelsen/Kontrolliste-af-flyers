SELECT diary.[ClientNo], 
       diary.PolicyNo, 
       Diary.DiaryCode, 
       Diary.Description, 
       Diary.VersionNo     AS PoliceVersion, 
       Diary.DiaryYear     AS Policeoprettet�r, 
       [Diary].DiaryMonth  AS PoliceoprettetM�ned, 
       Diary.DiaryDay      AS PoliceoprettetDag, 
       diary.[CrtedBy]     AS Policeopretter, 
       Skader.VersionNo    AS SkadeVersion, 
       Skader.CreatedYear  AS Skadeudbetalings�r, 
       Skader.CreatedMonth AS Skadeudbetalingsm�ned, 
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
				   /*Her indstilles den seneste m�neds skadesudbetalinger*/
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
                  --and Diary.CrtedBy = skader.CrtedBy  -- Denne klausul bruges, n�r samme medarbejder skal v�re p� begge begivenheder
                  AND Diary.VersionNo <= Skader.VersionNo 
WHERE  ( Diary.DiaryCode = 605 -- Police dannet 
          OR Diary.DiaryCode = 560 --  
          OR ( Diary.DiaryCode = 600 
               AND Diary.Description = 'Police i kraft' ) 
          -- Kode 600 bruges ogs� til fakturaer 
          OR Diary.DiaryCode = 500 
          OR Diary.DiaryCode = 570 
          OR Diary.DiaryCode = 580 
          OR Diary.DiaryCode = 620 ) 
       AND diarymonth in (month(dateadd(m,-1,(SYSDATETIME()))), month(dateadd(m,-2,(SYSDATETIME()))), MONTH(sysdatetime())) /*Ikke relevant, blot 6 m�neder f�r dags dato*/
       AND diaryyear = 2016  /*Skal tilpasses ved �rskifte - b�r kunne laves automatisk */
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