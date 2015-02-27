-- Usuarios
CREATE USER admin_catalogonoms WITH PASSWORD 'password.complicada'
CREATE USER usuario_catalogonom WITH PASSWORD 'password'

-- Creación de la Base de datos
CREATE DATABASE catalogonoms OWNER admin_catalogonoms;

-- Connección a la Base
\C catalogonoms;

-- Esquema de la Base
CREATE TABLE dof (fecha date, url text, respuesta json, servicio text);
CREATE TABLE notasNOM (fecha date, cod_nota int, claveNOM text, claveNOMNorm text, titulo text, etiqueta text, url text);
ALTER TABLE dof OWNER TO admin_catalogonoms;
ALTER TABLE notasNOM OWNER TO admin_catalogonoms;

-- Permisos de usuario
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usuario_catalogonom

-- Extensiones requeridas
CREATE EXTENSION plpython3u;


-- Functiones de aplicación

CREATE OR REPLACE FUNCTION getDataFromURL (urlrequest text)
  RETURNS json
AS $$
  import urllib.request
  response = urllib.request.urlopen(urlrequest)
  content = response.read()
  return content.decode('utf8')
$$ LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION getDiarioFullUrl (fecha date)
  RETURNS text
AS $$
  BEGIN
  return 'http://diariooficial.gob.mx/WS_getDiarioFull.php?year='||extract(year from fecha)||'&month='||extract(month from fecha)||'&day='||extract(day from fecha);
  END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getDiarioFullUrl (fechaInicio date, fechaFin date)
  RETURNS table (url text)
AS $$
  BEGIN
  RETURN QUERY WITH fechas AS (SELECT * FROM generate_series(fechaInicio, fechaFin, '1 day'::interval) fecha) select getDiarioFullUrl(fecha::date) from fechas;
  END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION getDetalleEdicionUrl(codigo int)
  RETURNS text
AS $$
  BEGIN
  return 'http://diariooficial.gob.mx/BB_DetalleEdicion.php?cod_diario='||codigo;
  END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getDetalleEdicionUrl(diario json)
  RETURNS TABLE (detalleEdicionURL text)
AS $$
  DECLARE
    edicionID text[];
  BEGIN
    SELECT array(SELECT trim(both '"' from (json_array_elements(diario->'ejemplares')->'id')::text)) INTO edicionID;
    
    RETURN QUERY SELECT DISTINCT 'http://diariooficial.gob.mx/BB_DetalleEdicion.php?cod_diario='||unnest from unnest(edicionID) WHERE length(unnest)>0 and unnest!='null';
  END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getDOFTable(fechaInicio date,fechaFin date)
  RETURNS TABLE (fecha date, urlWS text, respuesta json, servicio text)
AS $$
  BEGIN
  RETURN QUERY WITH fechas AS (SELECT * FROM generate_series(fechaInicio, fechaFin, '1 day'::interval) fecha)
  select (getDOFTable(fechas.fecha::date)).* from fechas;
  END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION getDOFTable(fechaConsulta date)
  RETURNS TABLE (fecha date, urlWS text, respuesta json, servicio text)
AS $$
  DECLARE
    diarioFull json;
    diarioFullUrl text;
    detalleEdicionUrl text[];
  BEGIN
  SELECT getDiarioFullUrl(fechaConsulta) INTO diarioFullUrl;
  SELECT getDataFromURL(diarioFullUrl) INTO diarioFull;
  
  SELECT array(SELECT getDetalleEdicionUrl(diarioFull)) INTO detalleEdicionUrl;
  
  RETURN QUERY SELECT foo.fecha, foo.url,foo.respuesta::json,foo.servicio FROM (
    SELECT fechaConsulta as fecha, diarioFullUrl as url, diarioFull::text as respuesta, 'diarioFull' as servicio WHERE (select count(*) from json_array_elements(diarioFull->'ejemplares') as ejemplares WHERE (ejemplares->'id')::text != 'null')>0 UNION
    SELECT fechaConsulta as fecha, unnest, getDataFromURL(unnest)::text, 'detalleEdicion' FROM unnest(detalleEdicionUrl)) AS foo;
  END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION populateDOFTable(fechaInicio date,fechaFin date)
  RETURNS VOID
AS $$
  DECLARE r record;
  BEGIN
  FOR r IN SELECT fecha FROM generate_series(fechaInicio, fechaFin, '1 day'::interval) fecha
  LOOP
      PERFORM populateDOFTable(r.fecha::date);
  END LOOP;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION populateDOFTable(fecha date)
  RETURNS VOID
AS $$
  BEGIN
  INSERT INTO dof SELECT * FROM getDOFTable(fecha);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertNOMData() RETURNS trigger
AS $$
BEGIN
  WITH diario AS (select NEW.fecha,NEW.respuesta,NEW.servicio),
  entries as (select fecha,servicio,unnestJSON(respuesta) from diario),
  diarioFull AS ( select distinct fecha,servicio,getClaveNOM(unnestjson),btrim(COALESCE((unnestjson->'titulo')::text,(unnestjson->'tituloDecreto')::text,'SIN TITULO'),'"') AS titulo, btrim(COALESCE((unnestjson->'id')::text,(unnestjson->'cod_nota')::text,'404'),'"') AS cod_nota from entries WHERE servicio = 'diarioFull'),
  detalleEdicion AS ( select distinct fecha,servicio,getClaveNOM(unnestjson),btrim(COALESCE((unnestjson->'titulo')::text,(unnestjson->'tituloDecreto')::text,'SIN TITULO'),'"') AS titulo, btrim(COALESCE((unnestjson->'id')::text,(unnestjson->'cod_nota')::text,'404'),'"') AS cod_nota from entries WHERE servicio = 'detalleEdicion'),
  uniqueEntries AS (SELECT * FROM diarioFull UNION SELECT * FROM detalleEdicion WHERE cod_nota not in (SELECT DISTINCT cod_nota from diarioFull))
  INSERT INTO notasnom(fecha, cod_nota,clavenom,clavenomnorm,titulo) SELECT fecha,cod_nota::int,getclavenom as claveNOM,normalizaClaveNOM(getclavenom) as claveNOMNormalizada,titulo FROM uniqueEntries order by (regexp_matches(normalizaClaveNOM(getclavenom),'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2],(regexp_matches(normalizaClaveNOM(getclavenom),'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[1],(regexp_matches(normalizaClaveNOM(getclavenom),'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[3];
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER insertNOMData AFTER INSERT ON dof
    FOR EACH ROW EXECUTE PROCEDURE insertNOMData();
    

CREATE OR REPLACE FUNCTION unnestJSON(jsonstring json)
  RETURNS TABLE ( unnestJSON json)
AS $$
  import collections, json

  jsondata = json.JSONDecoder(object_pairs_hook=collections.OrderedDict).decode((str(jsonstring)))
  
  def unnestedArray(jsonObject):
      result = []
      result.append({});
      idx=0
      if (isinstance(jsonObject,list)):
          jsonObj = enumerate(jsonObject);
      else:
          jsonObj = jsonObject;
      if (type(jsonObj) is enumerate or type(jsonObj) is dict or type(jsonObj) is collections.OrderedDict):
          for key in jsonObj:
              if type(key) is tuple:
                  key = key[0]
              response = unnestedArray(jsonObject[key])
              if (isinstance(response,str)):
                  auxResponse = response
                  result[idx].update({key: auxResponse});

                  for key3,value in enumerate(result):
                      if (len(result[key3].keys() - [key]) == len(result[key3].keys())):
                          result[idx].update({key: auxResponse})            
              else:
                  for key2,value in enumerate(response):
                      d = result[idx].copy();
                      d.update(value)
                  
                      if (len(result[idx].keys() - value.keys()) == len(result[idx].keys())):
                          result[idx].update(value)
                      else:
                          result.append(result[idx].copy())
                          result[idx+1].update(value)
                          idx = idx +1;
      else:
          result = str(jsonObject);

      return (result)
      
  result = unnestedArray(jsondata)

  for key,value in enumerate(result):
    result[key] = json.dumps(value)
    
  return (result)
$$ LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION getClaveNOM(notajson json)
  RETURNS TABLE ( claveNOM text)
AS $$
  import json,re,html.parser
  result = []
  
  contentLine = html.parser.HTMLParser().unescape(notajson);    
  regexpr = '((?:norma\s+oficial\s+mexicana\s*(?:espec.{1,2}fica\s*)?(?:de\s+emergencia,?\s*(?:denominada\s*)?)?(?:\(?\s*emergente\s*\)?\s*)?(?:\(?\s*con\s+\car.{1,2}cter\s+(?:de\s+emergencia|emergente)\s*\)?\s*,?\s*)?(?:\s*n.{1,2}mero\s*)?(?:\s*\-\s*)?\s)|(?P<prefijo>(?<=[^\w])(\w+\s*[\-\/]\s*)*?NOM(?:[-.\/]|\s+[^a-z])+))(?P<clave>(?:(?:NOM-?)?[^;"]+?)(?:\s*(?:(?=[,.]\s|[;"]|[^\d\-\/]\s[^\d])|\d{4}|\d(?=\s+[^\d]+[\s,;:]))))';

  matches = re.findall(regexpr, contentLine, re.IGNORECASE)
  result = [];
  
  for match in matches:
      claveCorregida = match[1] + match[-1]
      claveCorregida = claveCorregida.replace("nicos- NOM","NOM").replace("\\fNOM","NOM")
      claveCorregida = re.sub('^[^\d]+$','',claveCorregida)

      if (len(claveCorregida)>0):
        result.append(claveCorregida)
            
  return (result)
$$ LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION normalizaClaveNOM(claveNOM text)
  RETURNS text
AS $$
  import re
  global clavenom
  clavenom = clavenom.upper();
  clavenom = re.sub('\s*/\s*','/',clavenom)
  clavenom = re.sub('[\-\s,]+','-',clavenom)

  if (clavenom[0].isnumeric()):
      clavenom = 'NOM-'+clavenom;
  claveSplited = clavenom.split("-");

  if(len(claveSplited)>=2 and  claveSplited[1].isnumeric()):
      while len(claveSplited[1]) < 3:
          claveSplited[1] = '0' + claveSplited[1];
  elif(len(claveSplited)>=3 and claveSplited[2].isnumeric()):
      while len(claveSplited[2]) < 3:
          claveSplited[2] = '0' + claveSplited[2];
  if(claveSplited[-1].isnumeric() and len(claveSplited[-1])==2):
      if (int(claveSplited[-1])>20):
          claveSplited[-1] = '19' + claveSplited[-1];
      else:
          claveSplited[-1] = '20' + claveSplited[-1];
  
  claveNOMNormalizada = '-'.join(claveSplited);
  return claveNOMNormalizada
$$ LANGUAGE plpython3u;

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
