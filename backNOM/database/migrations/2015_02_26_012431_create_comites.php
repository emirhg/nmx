<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateComites extends Migration {

	/**
	 * Run the migrations.
	 *
	 * @return void
	 */
	public function up()
	{
		Schema::dropIfExists('comites');

		Schema::create('comites', function(Blueprint $table)
		{
			$table->increments('id');
			$table->integer('dependencia_id');
			$table->string('siglas',20);
			$table->string('nombre');
			$table->string('sitio_oficial')->nullable();
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
		Schema::dropIfExists('comites');
	}

}
