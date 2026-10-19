<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BananaGrading extends Model
{
    use HasFactory;

    protected $table = 'banana_gradings';
    protected $primaryKey = 'id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'user_id',
        'grade',
        'confidence',
        'image_path',
        'graded_at',
    ];

    protected function casts(): array
    {
        return [
            'confidence' => 'double',
            'graded_at' => 'datetime',
        ];
    }

    // Accessor otomatis untuk menghasilkan URL gambar lengkap saat diakses Flutter
    protected $appends = ['image_url'];

    public function getImageUrlAttribute(): string
    {
        return asset('storage/' . $this->image_path);
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}