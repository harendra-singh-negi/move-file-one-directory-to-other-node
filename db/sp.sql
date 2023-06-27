CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MoveActtechmentFile`()
BEGIN

DECLARE imoVal INT;
declare  counter, imo int ;
drop temporary table if exists attechmentTable;
create temporary table attechmentTable(
attachmentFile varchar(500),
imoNumber varchar(45)
);


 insert into attechmentTable SELECT attachmentFile, imoNumber
FROM (
SELECT ap.attachmentFile ,v.imoNumber  FROM commonattachment AS ap INNER JOIN mocgenerate AS m ON m.mocNo=ap.reportId INNER JOIN proposemoc AS pm ON pm.mocId=m.id INNER JOIN vessel AS v ON v.vuid=pm.vesselDepartment WHERE ap.moduleId=3 AND ap.moduleFormId=4 AND ap.formStageId IN (12,13,14,15,16,17,18)
UNION ALL
SELECT ap.attachmentFile ,v.imoNumber  FROM commonattachment AS ap INNER JOIN masterreviewgenerate AS rg ON rg.meetingNo=ap.reportId INNER JOIN masterreviewoverview AS ro ON ro.reviewId=rg.id INNER JOIN vessel AS v ON v.vuid=ro.vessel WHERE ap.moduleId=5 AND ap.moduleFormId=7 AND ap.formStageId IN (21,22,23,24,25) 
UNION ALL
SELECT p.attachmentFile ,v.imoNumber  FROM commonattachment AS p INNER JOIN safetymeetinggenerate AS sg ON sg.meetingNo=p.reportId INNER JOIN safetyoverview AS so ON so.safetyId=sg.id INNER JOIN vessel AS v ON v.vuid=so.vessel WHERE p.moduleId=1 AND p.moduleFormId=1 AND p.formStageId IN (1,2,3,4,5) 
UNION ALL
SELECT p.attachmentFile,v.imoNumber FROM commonattachment AS p INNER JOIN safetymeetinggenerateextra AS sg ON sg.meetingNo=p.reportId INNER JOIN safetyoverviewextra AS so ON so.safetyId=sg.id INNER JOIN vessel AS v ON v.vuid=so.vessel WHERE p.moduleId=1 AND p.moduleFormId=2 AND p.formStageId IN (6,7,8) 
UNION ALL
SELECT ca.attachmentFile ,v.imoNumber FROM commonattachment AS ca INNER JOIN fleetgenerate AS f ON f.meetingNo = ca.reportId INNER JOIN fleetnotificationsubmission AS fns ON fns.fleetnId = f.id  INNER JOIN vessel AS v ON v.id=fns.vesselId WHERE ca.moduleId = 12 AND ca.moduleFormId = 15 AND ca.formStageId IN (49,50,51)
UNION ALL
SELECT fvaa.attachmentFile ,v.imoNumber FROM fleetvesselactionattachment AS fvaa INNER JOIN fleetgenerate AS f ON f.id = fvaa.fleetgId INNER JOIN vessel AS v ON v.id=fvaa.vesselId WHERE fvaa.moduleId = 12 AND fvaa.moduleFormId = 16 AND fvaa.formStageId IN (52,53,54)
UNION ALL
SELECT ca.attachmentFile, v.imoNumber FROM commonattachment AS ca INNER JOIN lessonlearntgenerate AS llg ON llg.meetingNo = ca.reportId INNER JOIN lessonlearntsubmission AS lls ON lls.lessongId = llg.id  INNER JOIN vessel AS v ON v.id=lls.vesselId WHERE ca.moduleId = 13 AND ca.moduleFormId = 17 AND ca.formStageId IN (55,56,57)
UNION ALL
SELECT lvaa.attachmentFile,v.imoNumber FROM lessonvesselactionattachment AS lvaa  INNER JOIN vessel AS v ON v.id=lvaa.vesselId INNER JOIN lessonlearntgenerate AS llg ON llg.id = lvaa.lessongId  WHERE lvaa.moduleId = 13 AND lvaa.moduleFormId = 18 AND lvaa.formStageId IN (58,59,60) 
UNION ALL
SELECT cam.attachmentFile,v.imoNumber FROM commonattachment AS cam INNER JOIN nmnearmissgenerate AS ng ON ng.meetingNo = cam.reportId INNER JOIN nmnearmissreporting AS nr ON nr.nearmissId = ng.id INNER JOIN vessel AS v ON v.vuid = nr.vesselId WHERE cam.moduleId = 2 AND cam.moduleFormId = 3 AND cam.formStageId IN (9,10,11)
UNION ALL
SELECT ca.attachmentFile,v.imoNumber FROM commonattachment AS ca  INNER JOIN incidentgenerate AS ig ON ca.reportId = ig.incidentNo INNER JOIN incident AS i ON i.incidentNoId = ig.id INNER JOIN overview AS ov ON ov.incidentId = i.id INNER JOIN vessel AS v ON v.id=ov.vesselId WHERE ca.moduleId = 7 AND ca.moduleFormId = 9 AND ca.formStageId IN (29,30,31,32,33,34,35,36,37,38)
) AS combinedResults;
 

set counter =0;

   WHILE counter < (select count(DISTINCT imoNumber) from attechmentTable)  DO
       select DISTINCT imoNumber into imo from attechmentTable limit counter,1;
       insert into  attechmentTable (attachmentFile,imoNumber) (SELECT ca.attachmentFile,imo FROM commonattachment AS ca INNER JOIN commoncircularalert AS cr ON cr.id=ca.reportId WHERE ca.moduleId=4 AND ca.moduleFormId IN (5,6) AND ca.formStageId IN (19,20));
   set counter = counter+1;
  END WHILE;
   
  select * from attechmentTable;
   drop temporary table if exists attechmentTable;
END