<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateOrganizaciones extends Migration {

	/**
	 * Run the migrations.
	 *
	 * @return void
	 */
	public function up()
	{
		Schema::dropIfExists('dependencias');
		
		Schema::create('dependencias', function(Blueprint $table)
		{
			$table->increments('id');
			$table->string('siglas',30);
			$table->string('nombre');
			$table->string('sitio_oficial');
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
		Schema::dropIfExists('dependencias');
	}

}
