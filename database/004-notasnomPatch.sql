------------ Correcciones en claves nom (Intervención humana) -----
update notasnom set clavenomnorm = replace(clavenomnorm,'NOMEM', 'NOM-EM') where clavenomnorm like 'NOMEM%';

update notasnom set clavenom = 'NOM-023-   PESC-1996', clavenomnorm='NOM-023-PESC-1996' where clavenomnorm = 'NOM-023-';
update notasnom set clavenom = 'NOM-016-   PESC-1994', clavenomnorm='NOM-016-PESC-1994' where clavenomnorm = 'NOM-016-';
update notasnom set clavenom = 'NOM-055-1979', clavenomnorm='NOM-055-1979' where clavenomnorm = 'NO.NOM-055-1979';
update notasnom set clavenom = 'NOM-021-SSA2 - 1994', clavenomnorm = 'NOM-021-SSA2-1994' WHERE clavenomnorm='NOM-021-SSA2';
update notasnom set clavenom = 'NOM-038-SSA I-1993', clavenomnorm = 'NOM-038-SSA1-1993' WHERE clavenomnorm='NOM-038-SS';
update notasnom set clavenom = 'NOM - 115 - STPS - 1994', clavenomnorm = 'NOM-115-STPS-1994' WHERE clavenomnorm='NOM-115';
update notasnom set clavenom = 'NOM-243-   SSA1-2010', clavenomnorm = 'NOM-243-SSA1-2010' WHERE clavenomnorm='NOM-243-';
update notasnom set clavenom = 'NOM-039-SSA I-1993', clavenomnorm = 'NOM-039-SSA|-1993' WHERE clavenomnorm='NOM-039-SS';
update notasnom set clavenomnorm = 'NOM-AA-005-1980' WHERE clavenomnorm='NOM-AA-005-198O';

update notasnom set clavenomnorm = regexp_replace(clavenomnorm, '[LI](\d{3})','1\1') WHERE EXISTS (select regexp_matches(clavenomnorm,'[LI]\d{3}$'));

update notasnom set clavenom = 'NOM-Z-005-l985', clavenomnorm = 'NOM-Z-005-1985' WHERE clavenomnorm='NOM-Z-005-L985-DIBUJ';
update notasnom set clavenom = 'NOM-PA-CCAT-023 / 93', clavenomnorm = 'NOM-PA-CCAT-023/93' WHERE clavenomnorm='NOM-PA-CCAT-023';
update notasnom set clavenom = 'NOM-C-123. 1974', clavenomnorm = 'NOM-C-123-1974' WHERE clavenomnorm='NOM-C-123';
update notasnom set clavenom = 'NOM-F-365-S-198O', clavenomnorm = 'NOM-F-365-S-1980' WHERE clavenomnorm='NOM-F-365-S-198';


update vigencianoms set clavenomnorm = regexp_replace(clavenomnorm, '-(\d{2})-TUR', '-0\1-TUR') where clavenomnorm ~ '-\d{2}-TUR';
UPDATE vigencianoms SET clavenomnorm=regexp_replace(clavenomnorm, '([^\w])(FITO|ZOO|PESC)([^\w])', '\1SAG/\2\3') where clavenomnorm ~ '[^\w(SAG)/](FITO|ZOO|PESC)[^\w]';
UPDATE notasnom SET clavenomnorm=regexp_replace(clavenomnorm, '([^\w])(FITO|ZOO|PESC)([^\w])', '\1SAG/\2\3') where clavenomnorm ~ '[^\w(SAG)/](FITO|ZOO|PESC)[^\w]';
update notasnom set clavenomnorm= regexp_replace(clavenomnorm, '-CNA-', '-CONAGUA-') where clavenomnorm like '%-CNA%';




update notasnom set clavenom = 'NOM-024-SCFI-  \f1998', clavenomnorm = 'NOM-024-SCFI-1998' WHERE clavenomnorm='NOM-024-SCFI-';
update notasnom set clavenom = 'NOM-033-SCFI', clavenomnorm = 'NOM-033-SCFI-1994', etiqueta= 'Cancelación', revisionHumana=true WHERE clavenomnorm='NOM-033-SCF';
update notasnom set clavenom = 'PROY-NOM-015-CONAGUA-  \f2007', clavenomnorm = 'PROY-NOM-015-CONAGUA-2007' WHERE clavenomnorm='PROY-NOM-015-CONAGUA-';
update notasnom set clavenom = 'PROY-NOM-131-SSA1-  \f2011', clavenomnorm = 'PROY-NOM-131-SSA1-2011' WHERE clavenomnorm='PROY-NOM-131-SSA1-';
