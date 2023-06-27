CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MoveActtechmentFile`(dynamicDbName varchar(45))
BEGIN

DECLARE imoVal INT;
declare  counter, imo int ;
drop temporary table if exists attechmentTable;
create temporary table attechmentTable(
attachmentFile varchar(500),
imoNumber varchar(45)
);

 SET @sql = CONCAT(
        'INSERT INTO attechmentTable SELECT ca.attachmentFile, imoNumber FROM `', dynamicDbName, '`.commonattachment AS ca ',
        'INNER JOIN `', dynamicDbName, '`.mocgenerate AS m ON m.mocNo=ca.reportId ',
        'INNER JOIN `', dynamicDbName, '`.proposemoc AS pm ON pm.mocId=m.id ',
        'INNER JOIN `', dynamicDbName, '`.vessel AS v ON v.vuid=pm.vesselDepartment ',
        'WHERE ca.moduleId=3 AND ca.moduleFormId=4 AND ca.formStageId IN (12,13,14,15,16,17,18) ',
        'UNION ALL ',
        'SELECT ap.attachmentFile, imoNumber FROM `', dynamicDbName, '`.commonattachment AS ap ',
        'INNER JOIN `', dynamicDbName, '`.masterreviewgenerate AS rg ON rg.meetingNo=ap.reportId ',
        'INNER JOIN `', dynamicDbName, '`.masterreviewoverview AS ro ON ro.reviewId=rg.id ',
        'INNER JOIN `', dynamicDbName, '`.vessel AS v ON v.vuid=ro.vessel ',
        'WHERE ap.moduleId=5 AND ap.moduleFormId=7 AND ap.formStageId IN (21,22,23,24,25) ',
        'UNION ALL ',
        'SELECT p.attachmentFile, imoNumber FROM `', dynamicDbName, '`.commonattachment AS p ',
        'INNER JOIN `', dynamicDbName, '`.safetymeetinggenerate AS sg ON sg.meetingNo=p.reportId ',
        'INNER JOIN `', dynamicDbName, '`.safetyoverview AS so ON so.safetyId=sg.id ',
        'INNER JOIN `', dynamicDbName, '`.vessel AS v ON v.vuid=so.vessel ',
        'WHERE p.moduleId=1 AND p.moduleFormId=1 AND p.formStageId IN (1,2,3,4,5) ',
        'UNION ALL ',
        'SELECT attachmentFile, imoNumber FROM `', dynamicDbName, '`.commonattachment AS p ',
        'INNER JOIN `', dynamicDbName, '`.safetymeetinggenerateextra AS sg ON sg.meetingNo=p.reportId ',
        'INNER JOIN `', dynamicDbName, '`.safetyoverviewextra AS so ON so.safetyId=sg.id ',
        'INNER JOIN `', dynamicDbName, '`.vessel AS v ON v.vuid=so.vessel ',
        'WHERE p.moduleId=1 AND p.moduleFormId=2 AND p.formStageId IN (6,7,8) ',
        'UNION ALL ',
        'SELECT attachmentFile, imoNumber FROM `', dynamicDbName, '`.commonattachment AS ca ',
        'INNER JOIN `', dynamicDbName, '`.fleetgenerate AS f ON f.meetingNo = ca.reportId ',
        'INNER JOIN `', dynamicDbName, '`.fleetnotificationsubmission AS fns ON fns.fleetnId = f.id ',
        'INNER JOIN `', dynamicDbName, '`.vessel AS v ON v.id=fns.vesselId ',
        'WHERE ca.moduleId=12 AND ca.moduleFormId=15 AND ca.formStageId IN (49,50,51) ',
        'UNION ALL ',
        'SELECT attachmentFile, imoNumber FROM `', dynamicDbName, '`.fleetvesselactionattachment AS fvaa ',
        'INNER JOIN `', dynamicDbName, '`.fleetgenerate AS f ON f.id = fvaa.fleetgId ',
        'INNER JOIN `', dynamicDbName, '`.vessel AS v ON v.id=fvaa.vesselId ',
        'WHERE fvaa.moduleId=12 AND fvaa.moduleFormId=16 AND fvaa.formStageId IN (52,53,54) ',
        'UNION ALL ',
        'SELECT attachmentFile, imoNumber FROM `', dynamicDbName, '`.commonattachment AS ca ',
        'INNER JOIN `', dynamicDbName, '`.lessonlearntgenerate AS llg ON llg.meetingNo = ca.reportId ',
        'INNER JOIN `', dynamicDbName, '`.lessonlearntsubmission AS lls ON lls.lessongId = llg.id ',
        'INNER JOIN `', dynamicDbName, '`.vessel AS v ON v.id=lls.vesselId ',
        'WHERE ca.moduleId=13 AND ca.moduleFormId=17 AND ca.formStageId IN (55,56,57) ',
        'UNION ALL ',
        'SELECT attachmentFile, imoNumber FROM `', dynamicDbName, '`.lessonvesselactionattachment AS lvaa ',
        'INNER JOIN `', dynamicDbName, '`.vessel AS v ON v.id=lvaa.vesselId ',
        'INNER JOIN `', dynamicDbName, '`.lessonlearntgenerate AS llg ON llg.id = lvaa.lessongId ',
        'WHERE lvaa.moduleId=13 AND lvaa.moduleFormId=18 AND lvaa.formStageId IN (58,59,60) ',
        'UNION ALL ',
        'SELECT attachmentFile, imoNumber FROM `', dynamicDbName, '`.commonattachment AS cam ',
        'INNER JOIN `', dynamicDbName, '`.nmnearmissgenerate AS ng ON ng.meetingNo = cam.reportId ',
        'INNER JOIN `', dynamicDbName, '`.nmnearmissreporting AS nr ON nr.nearmissId = ng.id ',
        'INNER JOIN `', dynamicDbName, '`.vessel AS v ON v.vuid = nr.vesselId ',
        'WHERE cam.moduleId=2 AND cam.moduleFormId=3 AND cam.formStageId IN (9,10,11) ',
        'UNION ALL ',
        'SELECT attachmentFile, imoNumber FROM `', dynamicDbName, '`.commonattachment AS ca ',
        'INNER JOIN `', dynamicDbName, '`.incidentgenerate AS ig ON ca.reportId = ig.incidentNo ',
        'INNER JOIN `', dynamicDbName, '`.incident AS i ON i.incidentNoId = ig.id ',
        'INNER JOIN `', dynamicDbName, '`.overview AS ov ON ov.incidentId = i.id ',
        'INNER JOIN `', dynamicDbName, '`.vessel AS v ON v.id=ov.vesselId ',
        'WHERE ca.moduleId=7 AND ca.moduleFormId=9 AND ca.formStageId IN (29,30,31,32,33,34,35,36,37,38)'
    );

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

set counter =0;

   WHILE counter < (select count(DISTINCT imoNumber) from attechmentTable)  DO
       select DISTINCT imoNumber into imo from attechmentTable limit counter,1;
      SET @insertQuery = CONCAT(
        'INSERT INTO attechmentTable (attachmentFile, imoNumber) ',
        'SELECT ca.attachmentFile, ', imo, ' FROM `', dynamicDbName, '`.commonattachment AS ca ',
        'INNER JOIN `', dynamicDbName, '`.commoncircularalert AS cr ON cr.id = ca.reportId ',
        'WHERE ca.moduleId = 4 AND ca.moduleFormId IN (5, 6) AND ca.formStageId IN (19, 20)'
    );
    PREPARE stmt FROM @insertQuery;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

     
     set counter = counter+1;
  END WHILE;
  
  
   
  select * from attechmentTable;
   drop temporary table if exists attechmentTable;
END