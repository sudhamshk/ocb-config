set character_set_client = 'utf8';
update patient_identifier_type set format = "^(CHK|CP)[0-9]+$" where name = "Identifiant de patient";

