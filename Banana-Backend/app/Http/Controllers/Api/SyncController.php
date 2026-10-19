<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BananaGrading;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SyncController extends Controller
{
    /**
     * POST /api/sync
     * Menerima 1 item riwayat grading dari SQLite Flutter dan menyimpannya ke MySQL
     */
    public function sync(Request $request)
    {
        $request->validate([
            'local_id' => 'required|string|max:64',
            'grade' => 'required|string|max:50',
            'confidence' => 'required|numeric',
            'created_at' => 'required|string',
            'image' => 'required|image|mimes:jpeg,png,jpg,webp|max:10240', // Maks 10MB
        ]);

        // Cek apakah data sudah pernah disinkronkan sebelumnya
        $existing = BananaGrading::find($request->local_id);
        if ($existing && $existing->image_path && Storage::disk('public')->exists($existing->image_path)) {
            Storage::disk('public')->delete($existing->image_path);
        }

        // Simpan foto pisang ke folder storage/app/public/gradings
        $storedPath = $request->file('image')->store('gradings', 'public');

        // Konversi format waktu ISO-8601 dari Flutter agar diterima oleh MySQL
        try {
            $gradedAt = Carbon::parse($request->created_at)->format('Y-m-d H:i:s');
        } catch (\Exception $e) {
            $gradedAt = now()->format('Y-m-d H:i:s');
        }

        // Ambil user_id jika pengguna mengirim Bearer Token Sanctum yang valid
        $userId = auth('sanctum')->id();

        $grading = BananaGrading::updateOrCreate(
            ['id' => $request->local_id],
            [
                'user_id' => $userId,
                'grade' => $request->grade,
                'confidence' => (float) $request->confidence,
                'image_path' => $storedPath,
                'graded_at' => $gradedAt,
            ]
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Data riwayat berhasil disinkronkan ke server.',
            'server_id' => $grading->id,
            'data' => $grading,
        ], 201);
    }
}