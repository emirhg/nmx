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

Route::get('noms', function () {

	if (Input::get('tamPagina') && Input::get('pagina')) {
		return json_encode(DB::select(DB::raw("
			WITH nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
			notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN notasnom)
			SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo from vigencianoms NATURAL LEFT JOIN notasnomrecientes;
			")));
	} else {
		return json_encode(DB::select(DB::raw("
			WITH nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
			notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN notasnom)
			SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo from vigencianoms NATURAL LEFT JOIN notasnomrecientes ;
			")));
	}


});
Route::get('noms/{clave} ', function ($clave) {
	$clave = urldecode($clave);

	$historial = DB::select(DB::raw("
		WITH nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
		notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN notasnom)

		SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo from vigencianoms NATURAL LEFT JOIN notasnomrecientes where clavenomnorm like :clavenomnorm;
		"), array('clavenomnorm' => '%' . substr($clave, 3, -4) . '%'));
/*

		$ramayProducto = DB::select(DB::raw("
		Select rama, producto from vigencianoms where clavenomnorm like :clavenomnorm limit 1;
		"), array('clavenomnorm' => '%' . substr($clave, 3, -4) . '%'));

		$result = new stdClass;
		foreach ($ramayProducto as $row){
			$result->rama = $row->rama;
			$result->producto = $row->producto;
		}

		$result->historial = $historial;
		*/

		return json_encode($historial);

})->where('clave', '(.*)');

Route::get('nom/{clave}', function ($clave) {
	$clave = urldecode($clave);

	$historial = DB::select(DB::raw("SELECT  fecha,cod_nota, clavenomnorm, etiqueta, entity2char(titulo), urlnota AS url
FROM notasnom where clavenomnorm like :clavenomnorm ORDER BY fecha ASC;"),
		array('clavenomnorm' => '%' . substr($clave, 3, -4) . '%'));

		$ramayProducto = DB::select(DB::raw("
		Select rama, producto from vigencianoms where clavenomnorm like :clavenomnorm limit 1;
		"), array('clavenomnorm' => '%' . substr($clave, 3, -4) . '%'));

		$result = new stdClass;
		foreach ($ramayProducto as $row){
			$result->rama = $row->rama;
			$result->producto = $row->producto;
		}

		$result->historial = $historial;

		$comite = DB::select(DB::raw("SELECT  secretaria, nombre_secretaria, comite, descripcion_comite from comite WHERE :clavenomnorm like ('%'||comite||'%')ORDER BY secretaria, comite ASC;"),
		array('clavenomnorm' => '%' . substr($clave, 3, -4) . '%'));

		$result->comite = $comite;


		return json_encode($result);


})->where('clave', '(.*)');

/** Consultas relacionadas a la dependencia **/

Route::get('dependencia/{dependencia?}', function ($dependencia = null) {
	if ($dependencia == null) {
		$sqlQuery = "SELECT DISTINCT secretaria AS dependencia from comite";
	} else {
		$sqlQuery = "WITH detalleDependencia AS (SELECT secretaria AS dependencia, nombre_secretaria as nombre_dependencia, comite, descripcion_comite, reseña_comite from comite WHERE lower(secretaria)=lower('$dependencia')),

		nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
		notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN notasnom),

		nomsDetalle AS (SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comites, titulo from vigencianoms NATURAL LEFT JOIN notasnomrecientes),

		nomsPorComite AS (SELECT UNNEST(string_to_array(comites, '/')) comite, clavenomnorm FROM nomsDetalle),

		nomsDeLaDependencia AS (SELECT * FROM nomsPorComite NATURAL JOIN detalleDependencia)

		SELECT dependencia, nombre_dependencia, comite, descripcion_comite, reseña_comite, '['||string_agg('{\"clavenomnorm\":\"'||clavenomnorm||'\"'
		|| ',\"fecha\":\"'||fecha||'\"'
		|| ',\"comite\":\"'||comite||'\"'
		|| ',\"titulo\":\"'||titulo||'\"'
		, '},')||'}]' as normas FROM nomsDeLaDependencia Natural JOIN nomsDetalle GROUP BY dependencia, nombre_dependencia, comite, descripcion_comite, reseña_comite";

	}
	$result = DB::select(DB::raw($sqlQuery));
	foreach ($result as $row) {
		if (property_exists($row, 'normas')) {
			$row->normas = json_decode($row->normas);
		}
	}
	return json_encode($result);
});

Route::get('producto/{producto?}', function ($producto = null) {

	if ($producto == null) {
		$sqlQuery = 'WITH productos AS (select DISTINCT unnest(producto::text[]) as "producto" from vigencianoms ORDER BY producto)
		SELECT array_to_json(array_agg(producto)) as producto from productos';
	} else {
		$producto = urldecode($producto);
		$sqlQuery = "WITH nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
			notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN notasnom),
			detalleNOM AS (SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo from vigencianoms NATURAL LEFT JOIN notasnomrecientes)

			select clavenomnorm, titulo, estatus, array_to_json(producto::text[]) producto, array_to_json(rama::text[]) rama, comite from vigencianoms NATURAL JOIN detalleNOM WHERE (lower(producto))::text[] @> ARRAY[lower('$producto')] ORDER BY clavenomnorm";
	}

	$result = DB::select(DB::raw($sqlQuery));
	foreach ($result as $row) {
		if (property_exists($row, 'producto')) {
			$row->producto = json_decode($row->producto);
		}

		if (property_exists($row, 'rama')) {
			$row->rama = json_decode($row->rama);
		}
	}

	return json_encode($result);
});

Route::get('rama/{rama?}', function ($rama = null) {
	if ($rama == null) {
		$sqlQuery = "WITH ramas AS (select DISTINCT unnest(rama::text[]) as rama from vigencianoms ORDER BY rama)
		SELECT array_to_json(array_agg(rama)) as rama from ramas";
	} else {
		$rama = urldecode($rama);
		$sqlQuery = "WITH nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
			notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN notasnom),
			detalleNOM AS (SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo from vigencianoms NATURAL LEFT JOIN notasnomrecientes)
			select clavenomnorm,titulo,  estatus, array_to_json(producto::text[]) producto, array_to_json(rama::text[]) rama, comite from vigencianoms NATURAL JOIN detalleNOM WHERE (lower(rama)::text[]) @> ARRAY[lower('$rama')] ORDER BY clavenomnorm";
	}

	$result = DB::select(DB::raw($sqlQuery));
	foreach ($result as $row) {
		if (property_exists($row, 'producto')) {
			$row->producto = json_decode($row->producto);
		}

		if (property_exists($row, 'rama')) {
			$row->rama = json_decode($row->rama);
		}
	}

	return json_encode($result);
});
