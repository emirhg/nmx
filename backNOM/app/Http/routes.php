<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the controller to call when that URI is requested.
|
*/

Route::get('/', 'WelcomeController@index');

Route::get('home', 'HomeController@index');

Route::controllers([
	'auth' => 'Auth\AuthController',
	'password' => 'Auth\PasswordController',
	]);

Route::get('noms', function() {

	if(Input::get('tamPagina') && Input::get('pagina') ){
		return json_encode( DB::select(DB::raw("
			WITH nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
			notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN notasnom)
			SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo from vigencianoms NATURAL LEFT JOIN notasnomrecientes;
			")));
	}
	else{
		return json_encode( DB::select(DB::raw("
			WITH nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
			notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN notasnom)
			SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo from vigencianoms NATURAL LEFT JOIN notasnomrecientes ;
			")));
	}
	
});
Route::get('noms/{clave} ', function($clave) {


	return json_encode( DB::select(DB::raw("
		WITH nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
		notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN notasnom)

		SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo from vigencianoms NATURAL LEFT JOIN notasnomrecientes where clavenomnorm like :clavenomnorm;
		"),array('clavenomnorm'=> '%'. substr( $clave,3,-4).'%') ));
	

});

Route::get('nom/{clave}', function( $clave){
	return  json_encode	(DB::select(DB::raw( "SELECT  fecha,cod_nota, clavenomnorm, etiqueta, entity2char(titulo), urlnota AS url 
FROM notasnom where clavenomnorm like :clavenomnorm ORDER BY fecha ASC;"), 
	array('clavenomnorm'=> '%'. substr( $clave,3,-4).'%') ));

});

/** Consultas relacionadas a la dependencia **/

Route::get('dependencia/{dependencia?}', function($dependencia=null) {
	if ($dependencia == null){
		return json_encode( DB::select(DB::raw("SELECT DISTINCT secretaria AS dependencia from comite")));
	}
});


Route::get('producto/{producto?}', function($producto=null) {
	
	if ($producto == null){
		$sqlQuery = 'select DISTINCT unnest(producto::text[]) as "producto" from vigencianoms ORDER BY producto';
	}else {
		$producto = urldecode($producto);
		$sqlQuery = "select * from vigencianoms WHERE (lower(producto))::text[] @> ARRAY[lower('$producto')] ORDER BY clavenomnorm";
	}
	return json_encode( DB::select(DB::raw($sqlQuery)));
});

Route::get('rama/{rama?}', function($rama=null) {
	if ($rama == null){
		$sqlQuery = 'select DISTINCT unnest(rama::text[]) as "rama" from vigencianoms ORDER BY rama';
	}else {
		$rama = urldecode($rama);
		$sqlQuery = "select * from vigencianoms WHERE (lower(rama)::text[]) @> ARRAY[lower('$rama')] ORDER BY clavenomnorm";
	}
	return json_encode( DB::select(DB::raw($sqlQuery)));
});
