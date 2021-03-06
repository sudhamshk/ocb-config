SELECT to_char(B.sample_date,'DD/MM/YYYY')  AS "Date prélèvement",
       B.care_center_requesting AS "Provenance",
       B.Patient_Name AS "Nom",
       B.Patient_Identifier AS "ID",
       concat((current_Date-b.dob)/365 ,' ','ans' , ' ',((current_date-b.dob)%365)/30, ' ','Mois')as Age,
       B.sexe AS "Sexe",
       to_char(B.date_of_results,'DD/MM/YYYY') AS "Date resultats",
       sum(cast(B.Plaquettes AS NUMERIC)) AS "Pqt",
       sum(cast(B.Hemoglobine AS NUMERIC)) AS "Hb",
       sum(cast(B.Globules_Blancs AS NUMERIC)) AS "GB",
       sum(cast(B.FLLYM AS NUMERIC)) AS "FL-L%",
       sum(cast(B.FLNEUT AS NUMERIC)) AS "FL-N%",
       sum(cast(B.FLMXD AS NUMERIC)) AS "FL-MID%",
       max(COALESCE(B.Malaria)) AS "Palu",
       max(COALESCE(B.Syphilis)) AS "Siphilis",
       sum(cast(B.Hemoglobine_pr AS NUMERIC)) AS "Hb(Hemocue)",
       sum(cast(B.Glycame AS NUMERIC)) AS "Glycémie",
       sum(cast(B.Lactate AS NUMERIC)) AS "Lactate",
       sum(cast(B.potassium AS NUMERIC)) AS "K",
       sum(cast(B.sodium AS NUMERIC)) AS "Na",
       sum(cast(B.Chlore AS NUMERIC)) AS "Cl",
       sum(cast(B.GammaGT AS NUMERIC)) AS "Gamma GT(GGT)",
       sum(cast(B.Phosphatasealcaline AS NUMERIC)) AS "Phosphatase alchaline(Pal)",
       sum(cast(B.Bilirubine_totalE AS NUMERIC)) AS "Billi Total(BT)",
       sum(cast(B.BilirubinedirectE AS NUMERIC)) AS "Billi direct(BD)",
       sum(cast(B.Calcium AS NUMERIC)) AS "Calcium (Ca)",
       sum(cast(B.EID AS NUMERIC)) AS "EID/PCR"
FROM
  (/*Pivoting the table row to column*/ SELECT Patient_Name,
                                               care_center_requesting,
                                               Patient_Identifier,
                                               sample_date,
                                               dob,
                                               sexe,
                                               date_of_results,
                                               month_of_results,
                                               COMMENT,
                                               CASE
                                                   WHEN tname ='Bilirubine totalE' THEN tvalue
                                               END AS Bilirubine_totalE,
                                               CASE
                                                   WHEN tname ='Plaquettes' THEN tvalue
                                               END AS Plaquettes,
                                               CASE
                                                   WHEN tname ='Hemoglobine' THEN tvalue
                                               END AS Hemoglobine,
                                               CASE
                                                   WHEN tname ='Hemoglobine*' THEN tvalue
                                               END AS Hemoglobine_pr,
                                               CASE
                                                   WHEN tname ='Globules Blancs' THEN tvalue
                                               END AS Globules_Blancs,
                                               CASE
                                                   WHEN tname ='FL - NEUT%' THEN tvalue
                                               END AS FLLYM,
                                               CASE
                                                   WHEN tname ='FL - NEUT%' THEN tvalue
                                               END AS FLNEUT,
                                               CASE
                                                   WHEN tname ='FL - MXD%' THEN tvalue
                                               END AS FLMXD,
                                               CASE
                                                   WHEN tname ='Malaria' THEN dvalue
                                               END AS Malaria,
                                               CASE
                                                   WHEN tname ='Syphilis' THEN dvalue
                                               END AS Syphilis,
                                               CASE
                                                   WHEN tname ='Glycémie' THEN tvalue
                                               END AS Glycame,
                                               CASE
                                                   WHEN tname ='Lactate' THEN tvalue
                                               END AS Lactate,
                                               CASE
                                                   WHEN tname ='potassium' THEN tvalue
                                               END AS potassium,
                                               CASE
                                                   WHEN tname ='sodium' THEN tvalue
                                               END AS sodium,
                                               CASE
                                                   WHEN tname ='Chlore' THEN tvalue
                                               END AS Chlore,
                                               CASE
                                                   WHEN tname ='Gamma GT' THEN tvalue
                                               END AS GammaGT,
                                               CASE
                                                   WHEN tname ='Phosphatase alcaline' THEN tvalue
                                               END AS Phosphatasealcaline,
                                               CASE
                                                   WHEN tname ='Bilirubine directE' THEN tvalue
                                               END AS BilirubinedirectE,
                                               CASE
                                                   WHEN tname ='Calcium' THEN tvalue
                                               END AS Calcium,
                                               CASE
                                                   WHEN tname ='EID (PCR)' THEN tvalue
                                               END AS EID
   FROM
     (/*Pivoting the table row to column*/ SELECT sample.collection_date AS sample_date,
                                                  ss.name AS care_center_requesting,
                                                  trim( concat( COALESCE(NULLIF(person.first_name, ''), ''), ' ', COALESCE(NULLIF(person.last_name, ''), '') ) ) AS Patient_Name,
                                                  pi.identity_data AS Patient_Identifier,
                                                  patient.birth_date :: DATE AS dob,
                                                  case when patient.gender = 'M' then 'H'
                                                       when patient.gender = 'F' then 'F'
                                                       when patient.gender = 'O' then 'A'
                                                  else
                                                      patient.gender END AS sexe,
                                                  t.name AS tname,
                                                  r.value AS tvalue,
                                                  trim( concat( COALESCE(NULLIF(d.dict_entry,''),''),' ')) AS dvalue,
                                                  sample.lastupdated :: DATE AS date_of_results,
                                                  to_char(to_timestamp(date_part('month', r.lastupdated) :: TEXT, 'MM'), 'Month') AS month_of_results,
                                                  a.comment
      FROM
      patient_identity pi
      INNER JOIN patient ON patient.id = pi.patient_id
      INNER JOIN person ON patient.person_id = person.id
      INNER JOIN sample_human ON patient.id = sample_human.patient_id
      INNER JOIN sample sample on sample_human.samp_id=sample.id
      INNER JOIN sample_source ss ON sample.sample_source_id = ss.id
      INNER JOIN sample_item item ON sample.id = item.samp_id
      INNER JOIN analysis a ON item.id = a.sampitem_id
      INNER JOIN RESULT r ON a.id = r.analysis_id
      INNER JOIN test t ON a.test_id = t.id AND
            t.name IN  ('Bilirubine totalE','Plaquettes','Hemoglobine','Hemoglobine*','Globules Blancs','FL - LYM%','FL - NEUT%','FL - MXD%','Malaria','Syphilis','Glycémie','Lactate','potassium','sodium','Chlore','Gamma GT','Phosphatase alcaline','Bilirubine totalE','Bilirubine directE','Calcium','EID (PCR)')
       LEFT JOIN dictionary d ON  r.result_type = 'D' and cast(d.id as Text) = r.value
       WHERE   a.status_id=6 /*Filtering the result which are validated*/
                       AND sample.accession_number IS NOT NULL
                       AND pi.identity_type_id = 2) AS A) AS B
                       WHERE date(B.date_of_results) BETWEEN  '#startDate#' and '#endDate#'
GROUP BY B.Patient_Name,
         B.sample_date,
         B.care_center_requesting,
         B.Patient_Identifier,
         B.dob,
         B.sexe,
         B.date_of_results,
         B.month_of_results
ORDER BY B.date_of_results,
         B.care_center_requesting,
         B.Patient_Name,
         B.dob,
         B.sexe ;
