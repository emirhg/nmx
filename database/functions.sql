-- Usuarios
CREATE USER admin_catalogonoms WITH PASSWORD 'password.complicada';
CREATE USER usuario_catalogonom WITH PASSWORD 'password';

-- Creación de la Base de datos
CREATE DATABASE catalogonoms OWNER admin_catalogonoms;

-- Extensiones requeridas
CREATE EXTENSION plpython3u;
CREATE EXTENSION fuzzystrmatch;

-- Conexión a la Base
\C catalogonoms;

-- Esquema de la Base
CREATE TABLE dof (fecha date, url text, respuesta json, servicio text);
CREATE TABLE notasNOM (fecha date, cod_nota int, claveNOM text, claveNOMNorm text, titulo text, etiqueta text, urlnota text, revisionHumana bool, PRIMARY KEY (cod_nota,claveNOMNorm));
CREATE TABLE clavesRenombradas (claveNOMActualizada text, claveNOMObsoleta text);

ALTER TABLE dof OWNER TO admin_catalogonoms;
ALTER TABLE notasNOM OWNER TO admin_catalogonoms;
ALTER TABLE clavesRenombradas OWNER TO admin_catalogonoms;

-- Tablas auxiliares
CREATE TABLE sp_lemario(word text primary key);
\COPY sp_lemario FROM './data/lemario-general-del-espanol.txt' WITH CSV;


-- Permisos de usuario
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usuario_catalogonom

-- Inicialización parcial de datos
\COPY clavesRenombradas FROM './data/clavesRenombradas.csv' WITH CSV HEADER;

-- Funciones de aplicación

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
  uniqueEntries AS (SELECT * FROM diarioFull UNION SELECT * FROM detalleEdicion WHERE cod_nota not in (SELECT DISTINCT cod_nota from diarioFull)),
  firstNote AS (SELECT cod_nota,min(fecha) as fecha FROM uniqueEntries group by cod_nota),
  insertValue as (SELECT fecha,cod_nota::int,getclavenom as claveNOM,normalizaClaveNOM(getclavenom) as claveNOMNormalizada,titulo,
  'http://diariooficial.gob.mx/nota_detalle.php?codigo='||cod_nota||'&fecha='||CASE WHEN length((extract(day from fecha))::text)=1 THEN '0' ELSE '' END || extract(day from fecha)||'/'||CASE WHEN length((extract(month from fecha))::text)=1 THEN '0' ELSE '' END || extract(month from fecha)||'/'||extract(year from fecha) AS urlnota
  FROM uniqueEntries NATURAL JOIN firstNote)
 
  INSERT INTO notasNom (select * from insertValue);
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER insertNOMData AFTER INSERT ON dof
    FOR EACH ROW EXECUTE PROCEDURE insertNOMData();
    
--- Elimina evita la inserción de duplicados y en caso de que exista un mejor registro actualiza el título para evitar errores de codificación

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
      claveCorregida = claveCorregida.replace("nicos- NOM","NOM").replace("electrónicos- NOM","NOM").replace("\\fNOM","NOM").replace('.)','')
      claveCorregida = re.sub('^[^\d]+$','',claveCorregida)

      if (len(claveCorregida)>0):
        result.append(claveCorregida)
            
  return (result)
$$ LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION normalizaClaveNOM(claveNOM text)
  RETURNS text
AS $$
  import re, logging
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

  claveNOMRenombrada = plpy.execute("SELECT claveNOMActualizada from clavesRenombradas where claveNOMObsoleta = '" + claveNOMNormalizada + "'",1)

  if claveNOMRenombrada.nrows() > 0:
    try:
      claveNOMNormalizada = claveNOMRenombrada[0]['claveNOMActualizada']
    except Exception as inst:
      logging.error(inst);
  
  return claveNOMNormalizada
$$ LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION getPartialSentence(word text, sentence text)
  RETURNS TEXT
AS $$
  import re
  regexpr = '.*?\(?((?:\([^\)]+|[^\(]+|(\.\s+|^).*\(.*\)[^\)]+))' + word
  result = re.search(regexpr, sentence, re.IGNORECASE)
  return result.group(0) if result != None else None;
$$ LANGUAGE plpython3u;

-- Requires NLTK http://www.nltk.org/
CREATE OR REPLACE FUNCTION classifyNOM(clavenom text, titulo text)
  RETURNS TEXT
AS $$
  import nltk
  import re
  import html.parser
  import json
  
  def nom_features(clavenom,titulo):
    featureset = {}
    titulo = titulo.replace("'","\\'")
    queryresult = plpy.execute("select lower(entity2char(getpartialSentence('"+clavenom+"',E'"+titulo+"'))) as context",1);

    if queryresult.nrows() >0:
      context = queryresult[0]['context'].strip() if queryresult[0]['context'] != None else ''
      context = re.sub(clavenom + '.*$','',context, re.IGNORECASE)

    for word in context.split(' '):
      if word in featureset.keys():
        featureset[word] = featureset[word]+1;
      else:
        featureset[word] = 1;

    featureset['context'] = context;
    featureset['firstword'] = context.split(' ')[0]
    featureset['lastword'] = context.split(' ')[-1]
    featureset['countwords'] = len(context.split(' '))
    return featureset if len(context)>0 else ''

  featuresets = []
  knowledgeTable = plpy.execute("SELECT relname FROM pg_class WHERE relname='featuresets';")
  if (knowledgeTable.nrows()==0):
    plpy.execute('CREATE TEMPORARY TABLE featuresets(features text, etiqueta text)');
  
    knowledgeBase = plpy.execute('SELECT clavenom, titulo, etiqueta FROM notasnom WHERE etiqueta IS NOT NULL;')
    
    for value in knowledgeBase:
      features = nom_features(value['clavenom'], value['titulo'])
      featuresets.append((features, value['etiqueta']));
      plpy.execute('INSERT INTO featuresets VALUES (\''+ json.dumps(features) + '\',\'' + value['etiqueta']+'\')')
  else:
    knowledgeBase = plpy.execute('SELECT features, etiqueta FROM featuresets;')
    for value in knowledgeBase:
      featuresets.append((json.loads(value['features']), value['etiqueta']));
      
  train_set = featuresets
  classifier = nltk.NaiveBayesClassifier.train(train_set)

  titulounescape =  html.parser.HTMLParser().unescape(titulo)
  nom_featuresRes = nom_features(clavenom,titulounescape)
  return classifier.classify(nom_featuresRes) if len(nom_featuresRes)>0 else None
  
$$ LANGUAGE plpython3u;



--- HTML Entity replacement ---
--- Source: http://stackoverflow.com/questions/14961992/postgresql-replace-html-entities-function ---

create table character_entity(
    name text primary key,
    ch char(1) unique
);
insert into character_entity (ch, name) values
    (E'\u00C6','AElig'),(E'\u00C1','Aacute'),(E'\u00C2','Acirc'),(E'\u00C0','Agrave'),(E'\u0391','Alpha'),(E'\u00C5','Aring'),(E'\u00C3','Atilde'),(E'\u00C4','Auml'),(E'\u0392','Beta'),(E'\u00C7','Ccedil'),
    (E'\u03A7','Chi'),(E'\u2021','Dagger'),(E'\u0394','Delta'),(E'\u00D0','ETH'),(E'\u00C9','Eacute'),(E'\u00CA','Ecirc'),(E'\u00C8','Egrave'),(E'\u0395','Epsilon'),(E'\u0397','Eta'),(E'\u00CB','Euml'),
    (E'\u0393','Gamma'),(E'\u00CD','Iacute'),(E'\u00CE','Icirc'),(E'\u00CC','Igrave'),(E'\u0399','Iota'),(E'\u00CF','Iuml'),(E'\u039A','Kappa'),(E'\u039B','Lambda'),(E'\u039C','Mu'),(E'\u00D1','Ntilde'),
    (E'\u039D','Nu'),(E'\u0152','OElig'),(E'\u00D3','Oacute'),(E'\u00D4','Ocirc'),(E'\u00D2','Ograve'),(E'\u03A9','Omega'),(E'\u039F','Omicron'),(E'\u00D8','Oslash'),(E'\u00D5','Otilde'),(E'\u00D6','Ouml'),
    (E'\u03A6','Phi'),(E'\u03A0','Pi'),(E'\u2033','Prime'),(E'\u03A8','Psi'),(E'\u03A1','Rho'),(E'\u0160','Scaron'),(E'\u03A3','Sigma'),(E'\u00DE','THORN'),(E'\u03A4','Tau'),(E'\u0398','Theta'),
    (E'\u00DA','Uacute'),(E'\u00DB','Ucirc'),(E'\u00D9','Ugrave'),(E'\u03A5','Upsilon'),(E'\u00DC','Uuml'),(E'\u039E','Xi'),(E'\u00DD','Yacute'),(E'\u0178','Yuml'),(E'\u0396','Zeta'),(E'\u00E1','aacute'),
    (E'\u00E2','acirc'),(E'\u00B4','acute'),(E'\u00E6','aelig'),(E'\u00E0','agrave'),(E'\u2135','alefsym'),(E'\u03B1','alpha'),(E'\u0026','amp'),(E'\u2227','and'),(E'\u2220','ang'),(E'\u00E5','aring'),
    (E'\u2248','asymp'),(E'\u00E3','atilde'),(E'\u00E4','auml'),(E'\u201E','bdquo'),(E'\u03B2','beta'),(E'\u00A6','brvbar'),(E'\u2022','bull'),(E'\u2229','cap'),(E'\u00E7','ccedil'),(E'\u00B8','cedil'),
    (E'\u00A2','cent'),(E'\u03C7','chi'),(E'\u02C6','circ'),(E'\u2663','clubs'),(E'\u2245','cong'),(E'\u00A9','copy'),(E'\u21B5','crarr'),(E'\u222A','cup'),(E'\u00A4','curren'),(E'\u21D3','dArr'),
    (E'\u2020','dagger'),(E'\u2193','darr'),(E'\u00B0','deg'),(E'\u03B4','delta'),(E'\u2666','diams'),(E'\u00F7','divide'),(E'\u00E9','eacute'),(E'\u00EA','ecirc'),(E'\u00E8','egrave'),(E'\u2205','empty'),
    (E'\u2003','emsp'),(E'\u2002','ensp'),(E'\u03B5','epsilon'),(E'\u2261','equiv'),(E'\u03B7','eta'),(E'\u00F0','eth'),(E'\u00EB','euml'),(E'\u20AC','euro'),(E'\u2203','exist'),(E'\u0192','fnof'),
    (E'\u2200','forall'),(E'\u00BD','frac12'),(E'\u00BC','frac14'),(E'\u00BE','frac34'),(E'\u2044','frasl'),(E'\u03B3','gamma'),(E'\u2265','ge'),(E'\u003E','gt'),(E'\u21D4','hArr'),(E'\u2194','harr'),
    (E'\u2665','hearts'),(E'\u2026','hellip'),(E'\u00ED','iacute'),(E'\u00EE','icirc'),(E'\u00A1','iexcl'),(E'\u00EC','igrave'),(E'\u2111','image'),(E'\u221E','infin'),(E'\u222B','int'),(E'\u03B9','iota'),
    (E'\u00BF','iquest'),(E'\u2208','isin'),(E'\u00EF','iuml'),(E'\u03BA','kappa'),(E'\u21D0','lArr'),(E'\u03BB','lambda'),(E'\u2329','lang'),(E'\u00AB','laquo'),(E'\u2190','larr'),(E'\u2308','lceil'),
    (E'\u201C','ldquo'),(E'\u2264','le'),(E'\u230A','lfloor'),(E'\u2217','lowast'),(E'\u25CA','loz'),(E'\u200E','lrm'),(E'\u2039','lsaquo'),(E'\u2018','lsquo'),(E'\u003C','lt'),(E'\u00AF','macr'),
    (E'\u2014','mdash'),(E'\u00B5','micro'),(E'\u00B7','middot'),(E'\u2212','minus'),(E'\u03BC','mu'),(E'\u2207','nabla'),(E'\u00A0','nbsp'),(E'\u2013','ndash'),(E'\u2260','ne'),(E'\u220B','ni'),
    (E'\u00AC','not'),(E'\u2209','notin'),(E'\u2284','nsub'),(E'\u00F1','ntilde'),(E'\u03BD','nu'),(E'\u00F3','oacute'),(E'\u00F4','ocirc'),(E'\u0153','oelig'),(E'\u00F2','ograve'),(E'\u203E','oline'),
    (E'\u03C9','omega'),(E'\u03BF','omicron'),(E'\u2295','oplus'),(E'\u2228','or'),(E'\u00AA','ordf'),(E'\u00BA','ordm'),(E'\u00F8','oslash'),(E'\u00F5','otilde'),(E'\u2297','otimes'),(E'\u00F6','ouml'),
    (E'\u00B6','para'),(E'\u2202','part'),(E'\u2030','permil'),(E'\u22A5','perp'),(E'\u03C6','phi'),(E'\u03C0','pi'),(E'\u03D6','piv'),(E'\u00B1','plusmn'),(E'\u00A3','pound'),(E'\u2032','prime'),
    (E'\u220F','prod'),(E'\u221D','prop'),(E'\u03C8','psi'),(E'\u0022','quot'),(E'\u21D2','rArr'),(E'\u221A','radic'),(E'\u232A','rang'),(E'\u00BB','raquo'),(E'\u2192','rarr'),(E'\u2309','rceil'),
    (E'\u201D','rdquo'),(E'\u211C','real'),(E'\u00AE','reg'),(E'\u230B','rfloor'),(E'\u03C1','rho'),(E'\u200F','rlm'),(E'\u203A','rsaquo'),(E'\u2019','rsquo'),(E'\u201A','sbquo'),(E'\u0161','scaron'),
    (E'\u22C5','sdot'),(E'\u00A7','sect'),(E'\u00AD','shy'),(E'\u03C3','sigma'),(E'\u03C2','sigmaf'),(E'\u223C','sim'),(E'\u2660','spades'),(E'\u2282','sub'),(E'\u2286','sube'),(E'\u2211','sum'),
    (E'\u2283','sup'),(E'\u00B9','sup1'),(E'\u00B2','sup2'),(E'\u00B3','sup3'),(E'\u2287','supe'),(E'\u00DF','szlig'),(E'\u03C4','tau'),(E'\u2234','there4'),(E'\u03B8','theta'),(E'\u03D1','thetasym'),
    (E'\u2009','thinsp'),(E'\u00FE','thorn'),(E'\u02DC','tilde'),(E'\u00D7','times'),(E'\u2122','trade'),(E'\u21D1','uArr'),(E'\u00FA','uacute'),(E'\u2191','uarr'),(E'\u00FB','ucirc'),(E'\u00F9','ugrave'),
    (E'\u00A8','uml'),(E'\u03D2','upsih'),(E'\u03C5','upsilon'),(E'\u00FC','uuml'),(E'\u2118','weierp'),(E'\u03BE','xi'),(E'\u00FD','yacute'),(E'\u00A5','yen'),(E'\u00FF','yuml'),(E'\u03B6','zeta'),
    (E'\u200D','zwj'),(E'\u200C','zwnj')
;


create or replace function entity2char(t text)
returns text as $body$
declare
    r record;
begin
    for r in
        select distinct ce.ch, ce.name
        from
            character_entity ce
            inner join (
                select name[1] "name"
                from regexp_matches(t, '&([A-Za-z]+?);', 'g') r(name)
            ) s on ce.name = s.name
    loop
        t := replace(t, '&' || r.name || ';', r.ch);
    end loop;

    for r in
        select distinct
            hex[1] hex,
            ('x' || repeat('0', 8 - length(hex[1])) || hex[1])::bit(32)::int codepoint
        from regexp_matches(t, '&#x([0-9a-f]{1,8}?);', 'gi') s(hex)
    loop
        t := regexp_replace(t, '&#x' || r.hex || ';', chr(r.codepoint), 'gi');
    end loop;

    for r in
        select distinct
            chr(codepoint[1]::int) ch,
            codepoint[1] codepoint
        from regexp_matches(t, '&#([0-9]{1,10}?);', 'g') s(codepoint)
    loop
        t := replace(t, '&#' || r.codepoint || ';', r.ch);
    end loop;

    return t;
end;
$body$
language plpgsql immutable;

--- Funciones auxiliares
CREATE OR REPLACE FUNCTION "titlecase" (
  "v_inputstring" varchar
)
RETURNS varchar AS
$body$
/*
select * from Format_TitleCase('MR DOG BREATH');
select * from Format_TitleCase('each word, mcclure of this string:shall be
transformed');
select * from Format_TitleCase(' EACH WORD HERE SHALL BE TRANSFORMED	TOO
incl. mcdonald o''neil o''malley mcdervet');
select * from Format_TitleCase('mcclure and others');
select * from Format_TitleCase('J & B ART');
select * from Format_TitleCase('J&B ART');
select * from Format_TitleCase('J&B ART J & B ART this''s art''s house''s
problem''s 0''shay o''should work''s EACH WORD HERE SHALL BE TRANSFORMED
TOO incl. mcdonald o''neil o''malley mcdervet');
*/

DECLARE
   v_Index  INTEGER;
   v_Char  CHAR(1);
   v_OutputString  VARCHAR(4000);
   SWV_InputString VARCHAR(4000);

BEGIN
   SWV_InputString := v_InputString;
   SWV_InputString := LTRIM(RTRIM(SWV_InputString)); --cures problem where string starts with blank space
   v_OutputString := LOWER(SWV_InputString);
   v_Index := 1;
   v_OutputString := OVERLAY(v_OutputString placing
UPPER(SUBSTR(SWV_InputString,1,1)) from 1 for 1); -- replaces 1st char of Output with uppercase of 1st char from Input
   WHILE v_Index <= LENGTH(SWV_InputString) LOOP
      v_Char := SUBSTR(SWV_InputString,v_Index,1); -- gets loop's working character
      IF v_Char IN('m','M','
',';',':','!','?',',','.','_','-','/','&','''','(',CHR(9)) then
		 --END4
         IF v_Index+1 <= LENGTH(SWV_InputString) then
            IF v_Char = '''' AND UPPER(SUBSTR(SWV_InputString,v_Index+1,1))
<> 'S' AND SUBSTR(SWV_InputString,v_Index+2,1) <> REPEAT(' ',1) then  -- if the working char is an apost and the letter after that is not S
               v_OutputString := OVERLAY(v_OutputString placing
UPPER(SUBSTR(SWV_InputString,v_Index+1,1)) from v_Index+1 for 1);
            ELSE 
               IF v_Char = '&' then    -- if the working char is an &
                  IF(SUBSTR(SWV_InputString,v_Index+1,1)) = ' ' then
                     v_OutputString := OVERLAY(v_OutputString placing
UPPER(SUBSTR(SWV_InputString,v_Index+2,1)) from v_Index+2 for 1);
                  ELSE
                     v_OutputString := OVERLAY(v_OutputString placing
UPPER(SUBSTR(SWV_InputString,v_Index+1,1)) from v_Index+1 for 1);
                  END IF;
               ELSE
                  IF UPPER(v_Char) != 'M' AND
(SUBSTR(SWV_InputString,v_Index+1,1) <> REPEAT(' ',1) AND
SUBSTR(SWV_InputString,v_Index+2,1) <> REPEAT(' ',1)) then
                     v_OutputString := OVERLAY(v_OutputString placing
UPPER(SUBSTR(SWV_InputString,v_Index+1,1)) from v_Index+1 for 1);
                  END IF;
               END IF;
            END IF;

					-- special case for handling "Mc" as in McDonald
            IF UPPER(v_Char) = 'M' AND
UPPER(SUBSTR(SWV_InputString,v_Index+1,1)) = 'C' then
               v_OutputString := OVERLAY(v_OutputString placing
UPPER(SUBSTR(SWV_InputString,v_Index,1)) from v_Index for 1);
							--MAKES THE C LOWER CASE.
               v_OutputString := OVERLAY(v_OutputString placing
LOWER(SUBSTR(SWV_InputString,v_Index+1,1)) from v_Index+1 for 1);
							-- makes the letter after the C UPPER case
               v_OutputString := OVERLAY(v_OutputString placing
UPPER(SUBSTR(SWV_InputString,v_Index+2,1)) from v_Index+2 for 1);
							--WE TOOK CARE OF THE CHAR AFTER THE C (we handled 2 letters instead of only 1 as usual), SO WE NEED TO ADVANCE.
               v_Index := v_Index+1;
            END IF;
         END IF;
      END IF; --END3

      v_Index := v_Index+1;
   END LOOP; --END2

   RETURN coalesce(v_OutputString,'');
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

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
