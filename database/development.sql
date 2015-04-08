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
