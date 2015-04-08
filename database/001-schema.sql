-- Esquema de la Base
CREATE TABLE dof (fecha date, url text, respuesta json, servicio text);
CREATE TABLE notasNOM (fecha date, cod_nota int, claveNOM text, claveNOMNorm text, titulo text, etiqueta text, urlnota text, revisionHumana bool, PRIMARY KEY (cod_nota,claveNOMNorm));
CREATE TABLE clavesRenombradas (claveNOMActualizada text, claveNOMObsoleta text, PRIMARY KEY (claveNOMActualizada,claveNOMObsoleta));
CREATE TABLE vigencianoms (
    clavenomnorm text PRIMARY KEY,
    estatus text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


-- Tablas auxiliares
CREATE TABLE knowledgeBase(clavenomnorm text, etiqueta text, urlnota text);
CREATE TABLE sp_lemario(word text primary key);
