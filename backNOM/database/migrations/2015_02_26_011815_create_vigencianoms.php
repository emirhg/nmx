<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateVigencianoms extends Migration {

	/**
	 * Run the migrations.
	 *
	 * @return void
	 */
	public function up()
	{
		/*Schema::create('vigencianoms', function(Blueprint $table)
		{
			$table->increments('id');
			$table->text('clavenom');
			$table->string('estado',20);
			$table->timestamps();
		});*/
}

	/**
	 * Reverse the migrations.
	 *
	 * @return void
	 */
	public function down()
	{
		Schema::dropIfExists('vigencianoms');
	}

}
