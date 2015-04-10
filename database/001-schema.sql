-- Esquema de la Base
CREATE TABLE dof (fecha date, url text, respuesta json, servicio text);
CREATE TABLE notasNOM (fecha date, cod_nota int, claveNOM text, claveNOMNorm text, titulo text, etiqueta text, urlnota text, revisionHumana bool, PRIMARY KEY (cod_nota,claveNOMNorm));
CREATE TABLE clavesRenombradas (claveNOMActualizada text, claveNOMObsoleta text, PRIMARY KEY (claveNOMActualizada,claveNOMObsoleta));
CREATE TABLE diccionario (wrong text PRIMARY KEY, good text);
CREATE TABLE vigencianoms (clavenomnorm text PRIMARY KEY, estatus text, producto text, rama text, created_at timestamp(0) without time zone, updated_at timestamp(0) without time zone);
CREATE TABLE comite(secretaria text, nombre_secretaria text,comite text, descripcion_comite text, reseña_comite text, PRIMARY KEY (secretaria,comite));


-- Tablas auxiliares
CREATE TABLE knowledgeBase(clavenomnorm text, etiqueta text, urlnota text);
CREATE TABLE sp_lemario(word text primary key);
