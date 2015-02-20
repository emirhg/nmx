CREATE EXTENSION plpython3u;

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
  BEGIN
  
  RETURN QUERY SELECT DISTINCT 'http://diariooficial.gob.mx/BB_DetalleEdicion.php?cod_diario='||trim(both '"' from (json_array_elements(diario->'ejemplares')->'id')::text);
  END
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION getDOFTable(fecha date)
  RETURNS TABLE (fechaConsultada date, urlWS text, respuesta json, servicio text)
AS $$
  DECLARE
    diarioFull json;
    diarioFullUrl text;
  BEGIN
  DROP TABLE IF EXISTS detalleEdicionUrl;
  SELECT getDiarioFullUrl(fecha) INTO diarioFullUrl;
  SELECT getDataFromURL(diarioFullUrl) INTO diarioFull;
  CREATE TEMPORARY TABLE detalleEdicionUrl (url text);
  INSERT INTO detalleEdicionUrl SELECT getDetalleEdicionUrl(diarioFull);
  
  RETURN QUERY SELECT foo.fecha, foo.url,foo.respuesta::json,foo.servicio FROM (
    SELECT fecha as fecha, diarioFullUrl as url, diarioFull::text as respuesta, 'diarioFull' as servicio UNION
    SELECT fecha, url, getDataFromURL(url)::text, 'detalleEdicion' FROM detalleEdicionUrl) AS foo;

  END
$$ LANGUAGE plpgsql;
