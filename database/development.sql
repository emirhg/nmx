CREATE OR REPLACE FUNCTION beforeInsertNotasNOM() RETURNS trigger AS $beforeInsertNotasNOM$
    DECLARE
      title text;
    BEGIN
        IF EXISTS (SELECT cod_nota,claveNOMNorm FROM notasNOM WHERE cod_nota = NEW.cod_nota AND claveNOMNorm = NEW.claveNOMNorm) THEN
          IF EXISTS (with words as (select distinct regexp_split_to_table(NEW.titulo, E'\\s+|\\-+|\\.+|,+|\\(|\\)|;|\\\\|"') as word) select word from words where word ~* '(^|\w)\?[?\-!.]') THEN
            RETURN NULL;
          ELSE
            UPDATE notasNOM SET titulo = NEW.titulo WHERE cod_nota = NEW.cod_nota AND claveNOMNorm = NEW.claveNOMNorm;
            RETURN NULL;
          END IF;
        END IF;
        RETURN NEW;
    END;
$beforeInsertNotasNOM$ LANGUAGE plpgsql;

CREATE TRIGGER beforeInsertNotasNOM BEFORE INSERT ON notasNom
    FOR EACH ROW EXECUTE PROCEDURE beforeInsertNotasNOM();
    
-- DETAIL:  Key (cod_nota, clavenom)=(4707233, NOM-A- 14-1984) already exists.

  WITH diario AS (select NEW.fecha,NEW.respuesta,NEW.servicio FROM dof as NEW),
  entries as (select fecha,servicio,unnestJSON(respuesta) from diario),
  diarioFull AS ( select distinct fecha,servicio,getClaveNOM(unnestjson),btrim(COALESCE((unnestjson->'titulo')::text,(unnestjson->'tituloDecreto')::text,'SIN TITULO'),'"') AS titulo, btrim(COALESCE((unnestjson->'id')::text,(unnestjson->'cod_nota')::text,'404'),'"') AS cod_nota from entries WHERE servicio = 'diarioFull'),
  detalleEdicion AS ( select distinct fecha,servicio,getClaveNOM(unnestjson),btrim(COALESCE((unnestjson->'titulo')::text,(unnestjson->'tituloDecreto')::text,'SIN TITULO'),'"') AS titulo, btrim(COALESCE((unnestjson->'id')::text,(unnestjson->'cod_nota')::text,'404'),'"') AS cod_nota from entries WHERE servicio = 'detalleEdicion'),
  uniqueEntries AS (SELECT * FROM diarioFull UNION SELECT * FROM detalleEdicion WHERE cod_nota not in (SELECT DISTINCT cod_nota from diarioFull)),
  firstNote AS (SELECT cod_nota,min(fecha) as fecha FROM uniqueEntries group by cod_nota),
  insertValue as (SELECT fecha,cod_nota::int,getclavenom as claveNOM,normalizaClaveNOM(getclavenom) as claveNOMNormalizada,titulo,
  'http://diariooficial.gob.mx/nota_detalle.php?codigo='||cod_nota||'&fecha='||CASE WHEN length((extract(day from fecha))::text)=1 THEN '0' ELSE '' END || extract(day from fecha)||'/'||CASE WHEN length((extract(month from fecha))::text)=1 THEN '0' ELSE '' END || extract(month from fecha)||'/'||extract(year from fecha) AS urlnota
  FROM uniqueEntries NATURAL JOIN firstNote)
 
  INSERT INTO notasNom (select * from insertValue);


----------------------------------------------------------

--create temporary table knowledgebase2(primera text, fecha date, cod_nota int, clavenom text, titulo text, clavenomnorm text, etiqueta text, urlnota text);
TRUNCATE knowledgebase;
\copy knowledgebase from 'data/knowledgebase.csv' WITH CSV HEADER;

--update knowledgebase set etiqueta = 'Proyecto Modificación' where etiqueta = 'PROY Modificación';
update notasnom set etiqueta = 'Proyecto Modificación' where etiqueta = 'PROY Modificación';

--update knowledgebase set etiqueta = 'Respuestas a Comentarios' where etiqueta = 'Respuestas';
update notasnom set etiqueta = 'Respuestas a Comentarios' where etiqueta = 'Respuestas';

--update knowledgebase set etiqueta = 'Proyecto NOM' where etiqueta = 'PROY NOM';
update notasnom set etiqueta = 'Proyecto NOM' where etiqueta = 'PROY NOM';

--UPDATE knowledgebase k SET etiqueta= k2.etiqueta from knowledgebase2 k2 WHERE k.clavenomnorm=k2.clavenomnorm AND k.urlnota=k2.urlnota AND k.etiqueta != k2.etiqueta;
UPDATE notasnom k SET etiqueta= k2.etiqueta from knowledgebase k2 WHERE k.clavenomnorm=k2.clavenomnorm AND k.urlnota=k2.urlnota AND k.etiqueta != k2.etiqueta;

-----------------------------------------------------------------------
---- Corrección ortográfica

select distinct ce.ch, ce.name
        from
            character_entity ce
            inner join (
                select name[1] "name"
                from notasnom, regexp_matches(titulo, '\?', 'g') r(name)
            ) s on ce.name = s.name;



WITH badencoding AS (select distinct name[2] "name", CASE WHEN regexp_replace(name[2],'(\?[?!\-])', ' ','g') = titlecase(regexp_replace(name[2],'(\?[?!\-])', ' ','g')) THEN true ELSE false END AS isTitlecase from notasnom, regexp_matches(titulo, '(^|\s)(\w*(\?[?!\-]\w*)+\w*)', 'g') r(name))
SELECT name, CASE WHEN isTitleCase THEN titlecase(word) ELSE word END "corrected" from badencoding,sp_lemario where word ~* ('^'||replace(replace(replace(replace(name,'?-', 'í'),'?-', 'á'),'??', '[ñáéíóúöü]'),'?', '[ñáéíóúöü]')||'$') ORDER BY name;


CREATE OR REPLACE FUNCTION fixBadEncoding(t text) RETURNS text AS
$$
  DECLARE r record;
BEGIN
  for r in
    SELECT distinct dic.wrong, dic.good FROM diccionario dic INNER JOIN (SELECT wrong[2] AS wrong FROM regexp_matches(t, '(^|\s)(\w*(\?.)\w*)', 'g') wrong) s ON s.wrong = dic.wrong
  loop
    t:= replace(t,r.wrong,r.good);
  end loop;
  RETURN t;
END$$ LANGUAGE plpgsql;

------------------------------------------------------------------------
----- Trigger before insert vigencianom -----------------

CREATE OR REPLACE FUNCTION beforeInsertVigenciaNOM() RETURNS TRIGGER AS $$
BEGIN

  IF NEW.producto IS NOT NULL THEN
      NEW.producto:= '{"'||replace(NEW.producto,'"','\"')||'"}';
  END IF;

  IF NEW.rama IS NOT NULL THEN
      NEW.rama:= '{"'||replace(NEW.rama,'"','\"')||'"}';
  END IF;

  IF EXISTS (SELECT clavenomnorm from vigenciaNOMs WHERE claveNOMNorm=NEW.claveNOMNorm) THEN
    NEW.updated_at:= NOW();
    UPDATE vigenciaNOMs set
      estatus = COALESCE(NEW.estatus,estatus),
      producto = (SELECT (ARRAY(SELECT DISTINCT UNNEST(array_cat(NEW.producto::text[], (COALESCE(producto, '{}'))::text[])) ORDER BY 1))::text),
      rama = (SELECT (ARRAY(SELECT DISTINCT UNNEST(array_cat(NEW.rama::text[], (COALESCE(rama, '{}'))::text[])) ORDER BY 1))::text),
      updated_at = NOW();
    RETURN NULL;
  END IF;
  NEW.created_at:= NOW();
  NEW.updated_at:= NOW();
  RETURN NEW;
END
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER beforeInsertVigenciaNOM BEFORE INSERT ON vigenciaNOMs
  FOR EACH ROW EXECUTE PROCEDURE beforeInsertVigenciaNOM();

\copy vigenciaNOMs(clavenomnorm,producto,rama) FROM STDIN
NOM-001-CONAGUA-2011 	Agua	Agua y suministro de gas por ductos
\.

NOM-001-CONAGUA-2011
