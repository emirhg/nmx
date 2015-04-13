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


 WITH claves as (select distinct regexp_replace(clavenomnorm, '(^((NOM|PROY|EM|MOD)-)+)?(.*?)((-?\d{4}|/\d{1,4}))?$', '\4') clave from notasnom WHERE extract (year from fecha)>=1990 order by clave)

 
