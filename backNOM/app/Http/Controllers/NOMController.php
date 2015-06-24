<?php namespace App\Http\Controllers;

use App\Http\Requests;
use App\Http\Controllers\Controller;

use Illuminate\Http\Request;
use \Input;
use DB;

class NOM extends Controller {

	public function getNomsPublications(){
		if (Input::get('tamPagina') && Input::get('pagina')) {
			return json_encode(DB::select(DB::raw("
				WITH nomReciente AS (SELECT clavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY clavenomnorm),
				notasNOMRecientes AS (SELECT * from nomreciente NATURAL JOIN notasnom)
				SELECT fecha,clavenomnorm,trim(both '-' from (regexp_matches(vigencianoms.clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo from vigencianoms LEFT JOIN notasnomrecientes ON substring(vigencianoms.clavenomnorm from '-.*-') = substring(notasnomrecientes.clavenomnorm from '-.*-') WHERE estatus='Vigente';
				")));
		} else {
			return json_encode(DB::select(DB::raw("
				WITH nomReciente AS (SELECT trim(both '-' FROM substring(clavenomnorm from '-.*-')) subclavenomnorm, max(fecha) AS fecha FROM notasnom  WHERE etiqueta= 'NOM' GROUP BY trim(both '-' FROM substring(clavenomnorm from '-.*-'))),
notasNOMRecientes AS (SELECT DISTINCT notasnom.* from nomreciente JOIN notasnom ON clavenomnorm like '%'||subclavenomnorm ||'%' WHERE subclavenomnorm IS NOT NULL)
SELECT DISTINCT fecha,vigencianoms.clavenomnorm,trim(both '-' from (regexp_matches(vigencianoms.clavenomnorm,'NOM(?:[^a-z0-9])(\d[a-z0-9\/]*[^a-z0-9])?([a-z][a-z0-9\/]*(?:[^a-z0-9](?:[a-z][a-z0-9\/]*[^a-z0-9]?)?)?)?(\d[a-z0-9\/]*[^a-z0-9])?','gi'))[2]) as comite, titulo
FROM vigencianoms LEFT JOIN notasnomrecientes ON substring(vigencianoms.clavenomnorm from '-.*-') = substring(notasnomrecientes.clavenomnorm from '-.*-') WHERE  estatus='Vigente';
				")));
		}
	}
}
