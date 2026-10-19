<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\GradingController;
use App\Http\Controllers\Api\SyncController;
use App\Http\Middleware\ForceJsonResponse;

Route::middleware([ForceJsonResponse::class])->group(function () {

    // Endpoint Cek Status Koneksi Server dari Halaman Profil Flutter
    Route::get('/ping', function () {
        return response()->json([
            'status' => 'online',
            'app' => 'BananaGrade API',
            'timestamp' => now()->toIso8601String(),
        ]);
    });

    // 1. Autentikasi Publik
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/login/google', [AuthController::class, 'loginWithGoogle']);

    // 2. Sinkronisasi SQLite -> MySQL (Tetap bekerja baik saat Guest maupun Login)
    Route::post('/sync', [SyncController::class, 'sync']);

    // 3. Riwayat Grading (CRUD Server)
    Route::get('/gradings', [GradingController::class, 'index']);
    Route::get('/gradings/{id}', [GradingController::class, 'show']);
    Route::delete('/gradings/{id}', [GradingController::class, 'destroy']);
    Route::delete('/gradings', [GradingController::class, 'clearAll']);

    // 4. Endpoint Terproteksi Token Sanctum
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});