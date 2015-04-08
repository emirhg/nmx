-- Prueba
WITH diario AS (select fecha,respuesta,servicio from getdoftable('1995-11-13')),
entries as (select fecha,servicio,unnestJSON(respuesta) from diario),
diarioFull AS ( select distinct fecha,servicio,getClaveNOM(unnestjson),btrim(COALESCE((unnestjson->'titulo')::text,(unnestjson->'tituloDecreto')::text,'SIN TITULO'),'"') AS titulo, btrim(COALESCE((unnestjson->'id')::text,(unnestjson->'cod_nota')::text,'404'),'"') AS cod_nota from entries WHERE servicio = 'diarioFull'),
detalleEdicion AS ( select distinct fecha,servicio,getClaveNOM(unnestjson),btrim(COALESCE((unnestjson->'titulo')::text,(unnestjson->'tituloDecreto')::text,'SIN TITULO'),'"') AS titulo, btrim(COALESCE((unnestjson->'id')::text,(unnestjson->'cod_nota')::text,'404'),'"') AS cod_nota from entries WHERE servicio = 'detalleEdicion'),
uniqueEntries AS (SELECT * FROM diarioFull UNION SELECT * FROM detalleEdicion WHERE cod_nota not in (SELECT DISTINCT cod_nota from diarioFull))
SELECT fecha,cod_nota,getclavenom as claveNOM,normalizaClaveNOM(getclavenom) as claveNOMNormalizada,titulo FROM uniqueEntries order by (regexp_matches(normalizaClaveNOM(getclavenom),'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2],(regexp_matches(normalizaClaveNOM(getclavenom),'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[1],(regexp_matches(normalizaClaveNOM(getclavenom),'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[3];

-- Pobla la tabla notasnom
WITH diario AS (select fecha,respuesta,servicio from dof),
entries as (select fecha,servicio,unnestJSON(respuesta) from diario),
diarioFull AS ( select distinct fecha,servicio,getClaveNOM(unnestjson),btrim(COALESCE((unnestjson->'titulo')::text,(unnestjson->'tituloDecreto')::text,'SIN TITULO'),'"') AS titulo, btrim(COALESCE((unnestjson->'id')::text,(unnestjson->'cod_nota')::text,'404'),'"') AS cod_nota from entries WHERE servicio = 'diarioFull'),
detalleEdicion AS ( select distinct fecha,servicio,getClaveNOM(unnestjson),btrim(COALESCE((unnestjson->'titulo')::text,(unnestjson->'tituloDecreto')::text,'SIN TITULO'),'"') AS titulo, btrim(COALESCE((unnestjson->'id')::text,(unnestjson->'cod_nota')::text,'404'),'"') AS cod_nota from entries WHERE servicio = 'detalleEdicion'),
uniqueEntries AS (SELECT * FROM diarioFull UNION SELECT * FROM detalleEdicion WHERE cod_nota not in (SELECT DISTINCT cod_nota from diarioFull))
INSERT INTO notasnom(fecha, cod_nota,clavenom,clavenomnorm,titulo) SELECT fecha,cod_nota::int,getclavenom as claveNOM,normalizaClaveNOM(getclavenom) as claveNOMNormalizada,titulo FROM uniqueEntries order by (regexp_matches(normalizaClaveNOM(getclavenom),'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2],(regexp_matches(normalizaClaveNOM(getclavenom),'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[1],(regexp_matches(normalizaClaveNOM(getclavenom),'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[3];


------- PRUEBA DE CONSULTA NOM

with mejornota AS (select cod_nota,clavenom,max(titulo) titulo from notasnom group by cod_nota,clavenom), mejornotaconfecha as (select min(fecha) AS fecha, cod_nota,clavenom,titulo from mejornota NATURAL JOIN notasnom GROUP BY cod_nota,clavenom,titulo), notasnomunique AS (SELECT * from notasnom NATURAL JOIN mejornotaconfecha)

------ Listado de normas vigentes

WITH nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM tmp_notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN tmp_notasnom)
SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo from notasnomrecientes JOIN vigencianoms on vigencianoms.clavenom=notasnomrecientes.clavenomnorm;





---- Diccionario
with words as (select distinct regexp_split_to_table(titulo, E'\\s+|\\-+|\\.+|,+|\\(|\\)|;|\\\\|"') as word,titulo  from notasnom) insert into dict select DISTINCT words.word, sp_lemario.word FROM words,(SELECT word from sp_lemario UNION SELECT titlecase(word) FROM sp_lemario) AS sp_lemario where words.word ~* '(^|\w)\?[?\-!.]' AND levenshtein_less_equal(regexp_replace(words.word,'\?|!',''),sp_lemario.word ,1,2,2,2)<=2  AND sp_lemario.word ~* '[ñáéíóúöü]' ORDER BY words.word, sp_lemario.word;


--- 8,999 palabras distintas
--- 11,824 Palabras mál codificadas
--- 1,022 Palabras únicas mal codificadas
--- 602 Palabras únicas corregidas
