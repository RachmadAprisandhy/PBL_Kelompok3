<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('banana_gradings', function (Blueprint $table) {
           $table->string('id', 64)->primary();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('grade', 50); // 'Grade A', 'Grade B', 'Grade C'
            $table->double('confidence'); // 0.0 - 1.0
            $table->string('image_path'); // Path file di storage Laravel
            $table->timestamp('graded_at')->nullable(); // Waktu grading asli di perangkat
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('banana_gradings');
    }
};
