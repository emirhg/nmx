#!/bin/bash
./src/identifyNOMpublication.py -c3,5 -H -f "fecha|date,cod_nota|id,claveNOM,claveNOMNormalizada,titulo|tituloDecreto"  data/publicacionesDOF-1990.csv > data/publicacionesNOMs-1990.csv

psql -c "\copy notas from PROGRAM  './src/identifyNOMpublication.py -c3,5 -H -f \"fecha|date,cod_nota|id,claveNOM,claveNOMNormalizada,titulo|tituloDecreto,url\"  data/publicacionesDOF-1990.csv' WITH CSV header ESCAPE '\"' QUOTE '\"';" catalogonoms


psql -c "\COPY (select * FROM (SELECT DISTINCT fecha,claveNOMnorm, cod_nota, (string_to_array(titulo, ' '))[1] as primeraPalabra,titulo,url from notas) sub ORDER BY (regexp_matches(claveNOMnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2],(regexp_matches(claveNOMnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[1],(regexp_matches(claveNOMnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[3], fecha) TO STDOUT WITH CSV HEADER;" catalogonoms > data/nomsDB-betha.csv


#csvquery data/publicacionesNOMs-1990.csv data/economiaNOMS.csv data/clavesRenombradas.csv -q"select 'NOMs faltantes' as 'Descripción', count( distinct clave_NOM) AS 'total' from csv2 where clave_NOM not in (SELECT distinct IFNULL(claveNOMActualizada,claveNOMNormalizada) from csv LEFT JOIN csv3 ON claveNOMNormalizada=claveNOMObsoleta  UNION SELECT distinct claveNOM from csv) UNION SELECT 'Registros identificados', count(*) from csv UNION SELECT 'Claves NOMs', count(distinct claveNOMNormalizada) from csv"

#csvquery data/publicacionesNOMs-1990.csv data/economiaNOMS.csv data/clavesRenombradas.csv -q'select distinct clave_NOM from csv2 where clave_NOM not in (SELECT distinct IFNULL(claveNOMActualizada,claveNOMNormalizada) from csv LEFT JOIN csv3 ON claveNOMNormalizada=claveNOMObsoleta  UNION SELECT distinct claveNOM from csv)'

#csvquery data/publicacionesNOMs-1990.csv -q "SELECT fecha, titulo,cod_nota, claveNOMNormalizada, claveNOM, 'http://diariooficial.gob.mx/nota_detalle.php?codigo='||cod_nota||'&fecha='|| fecha AS url FROM csv ORDER BY claveNOMNormalizada DESC, fecha ASC" > data/nomsDB-alpha.csv
