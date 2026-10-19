<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    /**
     * POST /api/register
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
        ]);

        $token = $user->createToken('bananagrade_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Pendaftaran akun berhasil',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
        ], 201);
    }

    /**
     * POST /api/login
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string',
            'password' => 'required|string',
        ]);

        // Mendukung login menggunakan email maupun nama pengguna
        $user = User::where('email', $request->email)
            ->orWhere('name', $request->email)
            ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email atau kata sandi salah.',
            ], 401);
        }

        $token = $user->createToken('bananagrade_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
        ], 200);
    }

    /**
     * POST /api/login/google
     */
    public function loginWithGoogle(Request $request)
    {
        $request->validate([
            'access_token' => 'required|string',
        ]);

        // Ambil profil pengguna dari Google OAuth2 UserInfo Endpoint
        $googleResponse = Http::withToken($request->access_token)
            ->get('https://www.googleapis.com/oauth2/v3/userinfo');

        if ($googleResponse->failed()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Token Google tidak valid atau sudah kedaluwarsa.',
            ], 401);
        }

        $googleUser = $googleResponse->json();
        $email = $googleUser['email'] ?? null;

        if (!$email) {
            return response()->json([
                'status' => 'error',
                'message' => 'Tidak dapat mengambil alamat email dari akun Google.',
            ], 422);
        }

        $user = User::updateOrCreate(
            ['email' => $email],
            [
                'name' => $googleUser['name'] ?? explode('@', $email)[0],
                'google_id' => $googleUser['sub'] ?? null,
                'password' => Hash::make(Str::random(24)),
            ]
        );

        $token = $user->createToken('bananagrade_google_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
        ], 200);
    }

    /**
     * GET /api/me
     */
    public function me(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'user' => $request->user(),
        ]);
    }

    /**
     * POST /api/logout
     */
    public function logout(Request $request)
    {
        if ($request->user() && $request->user()->currentAccessToken()) {
            $request->user()->currentAccessToken()->delete();
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Berhasil keluar dari akun.',
        ]);
    }
}