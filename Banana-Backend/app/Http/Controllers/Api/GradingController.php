<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BananaGrading;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class GradingController extends Controller
{
    /**
     * GET /api/gradings
     * Menampilkan seluruh riwayat grading yang tersimpan di server
     */
    public function index(Request $request)
    {
        $query = BananaGrading::query()->orderBy('graded_at', 'desc');

        // Filter berdasarkan user jika sedang login
        if (auth('sanctum')->check()) {
            $query->where('user_id', auth('sanctum')->id());
        }

        // Filter berdasarkan kategori Grade (opsional: ?grade=Grade A)
        if ($request->filled('grade') && $request->grade !== 'Semua') {
            $query->where('grade', $request->grade);
        }

        return response()->json([
            'status' => 'success',
            'data' => $query->get(),
        ]);
    }

    /**
     * GET /api/gradings/{id}
     * Menampilkan detail 1 riwayat grading
     */
    public function show(string $id)
    {
        $grading = BananaGrading::find($id);

        if (!$grading) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data riwayat tidak ditemukan di server.',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $grading,
        ]);
    }

    /**
     * DELETE /api/gradings/{id}
     * Menghapus 1 riwayat grading beserta file gambarnya di server
     */
    public function destroy(string $id)
    {
        $grading = BananaGrading::find($id);

        if (!$grading) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data riwayat tidak ditemukan.',
            ], 404);
        }

        if ($grading->image_path && Storage::disk('public')->exists($grading->image_path)) {
            Storage::disk('public')->delete($grading->image_path);
        }

        $grading->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Riwayat grading berhasil dihapus dari server.',
        ]);
    }

    /**
     * DELETE /api/gradings
     * Menghapus seluruh riwayat grading milik pengguna di server
     */
    public function clearAll()
    {
        $query = BananaGrading::query();

        if (auth('sanctum')->check()) {
            $query->where('user_id', auth('sanctum')->id());
        }

        $items = $query->get();
        foreach ($items as $item) {
            if ($item->image_path && Storage::disk('public')->exists($item->image_path)) {
                Storage::disk('public')->delete($item->image_path);
            }
            $item->delete();
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Seluruh riwayat grading berhasil dihapus dari server.',
        ]);
    }
}