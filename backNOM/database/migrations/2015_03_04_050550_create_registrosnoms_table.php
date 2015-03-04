<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateRegistrosnomsTable extends Migration {

	/**
	 * Run the migrations.
	 *
	 * @return void
	 */
	public function up()
	{
		Schema::dropIfExists('registronoms');
		
		Schema::create('registronoms', function(Blueprint $table)
		{
			$table->increments('id');
			$table->bigInteger('nom_id');
			$table->string('nexo');
			$table->date('fecha_publicacion');
			$table->text('calve_dof');
			$table->text('link');
			$table->text('linkPDF');
			$table->timestamps();
		});
	}

	/**
	 * Reverse the migrations.
	 *
	 * @return void
	 */
	public function down()
	{
		Schema::drop('registronoms');
	}

}
