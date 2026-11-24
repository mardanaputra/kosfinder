-- ==============================================================================
-- Migration: 001_init.sql
-- Proyek: KosFinder
-- Deskripsi: Inisialisasi tabel kos dan konfigurasi Row Level Security (RLS)
-- ==============================================================================

-- 1. Buat Tabel Kos
CREATE TABLE IF NOT EXISTS public.kos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    area TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('Putra', 'Putri', 'Campur')),
    price_per_month BIGINT NOT NULL CHECK (price_per_month > 0),
    available_rooms INT NOT NULL DEFAULT 0 CHECK (available_rooms >= 0),
    facilities TEXT[] NOT NULL DEFAULT '{}',
    contact_number TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indeks untuk optimalisasi pencarian dan filter
CREATE INDEX IF NOT EXISTS idx_kos_owner_id ON public.kos(owner_id);
CREATE INDEX IF NOT EXISTS idx_kos_area ON public.kos(area);
CREATE INDEX IF NOT EXISTS idx_kos_price ON public.kos(price_per_month);
CREATE INDEX IF NOT EXISTS idx_kos_type ON public.kos(type);

-- 2. Aktifkan Row Level Security (RLS)
ALTER TABLE public.kos ENABLE ROW LEVEL SECURITY;

-- 3. Kebijakan Row Level Security (RLS)

-- A. SELECT: Publik (siapa pun, termasuk guest/anon) dapat membaca semua data kos
CREATE POLICY "Publik dapat melihat semua data kos"
ON public.kos
FOR SELECT
USING (true);

-- B. INSERT: Hanya user yang terotentikasi (login) yang dapat menambahkan kos miliknya
CREATE POLICY "Pemilik dapat menambah kos miliknya"
ON public.kos
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = owner_id);

-- C. UPDATE: Hanya pemilik kos terkait yang dapat memperbarui datanya
CREATE POLICY "Pemilik hanya dapat mengubah kos miliknya"
ON public.kos
FOR UPDATE
TO authenticated
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);

-- D. DELETE: Hanya pemilik kos terkait yang dapat menghapus datanya secara permanen
CREATE POLICY "Pemilik hanya dapat menghapus kos miliknya"
ON public.kos
FOR DELETE
TO authenticated
USING (auth.uid() = owner_id);
