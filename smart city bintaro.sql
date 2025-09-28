DROP DATABASE IF EXISTS smart_city_bintaro;
CREATE DATABASE smart_city_bintaro;
USE smart_city_bintaro;
-- Tabel PENGGUNA
CREATE TABLE pengguna (
    kode_pengguna INT PRIMARY KEY AUTO_INCREMENT,
    nama_pengguna VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nomor_hp VARCHAR(20),
    jenis_akun ENUM('WARGA', 'PETUGAS', 'ADMIN', 'MANAGER') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel KATEGORI
CREATE TABLE kategori (
    kode_kategori INT PRIMARY KEY AUTO_INCREMENT,
    nama_kategori VARCHAR(100) NOT NULL UNIQUE,
    deskripsi TEXT
);
-- Tabel ADUAN
CREATE TABLE aduan (
    kode_aduan INT PRIMARY KEY AUTO_INCREMENT,
    kode_pengguna INT NOT NULL,
    kode_kategori INT NOT NULL,
    judul_aduan VARCHAR(200) NOT NULL,
    deskripsi TEXT NOT NULL,
    lokasi VARCHAR(255),
    tanggal_submit TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('BARU', 'DITERIMA', 'DIPROSES', 'SELESAI', 'DITOLAK') DEFAULT 'BARU',
    FOREIGN KEY (kode_pengguna) REFERENCES pengguna(kode_pengguna),
    FOREIGN KEY (kode_kategori) REFERENCES kategori(kode_kategori)
);
-- Tabel RIWAYAT_STATUS
CREATE TABLE riwayat_status (
    id_riwayat INT PRIMARY KEY AUTO_INCREMENT,
    kode_aduan INT NOT NULL,
    status_lama VARCHAR(50),
    status_baru VARCHAR(50) NOT NULL,
    tanggal_perubahan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    keterangan TEXT,
    FOREIGN KEY (kode_aduan) REFERENCES aduan(kode_aduan)
);
-- Tabel KOMENTAR
CREATE TABLE komentar (
    id_komentar INT PRIMARY KEY AUTO_INCREMENT,
    kode_aduan INT NOT NULL,
    kode_pengguna INT NOT NULL,
    isi_komentar TEXT NOT NULL,
    tanggal_komentar TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kode_aduan) REFERENCES aduan(kode_aduan),
    FOREIGN KEY (kode_pengguna) REFERENCES pengguna(kode_pengguna)
);
-- Tabel LAMPIRAN (untuk foto/video)
CREATE TABLE lampiran (
    id_lampiran INT PRIMARY KEY AUTO_INCREMENT,
    kode_aduan INT NOT NULL,
    nama_file VARCHAR(255) NOT NULL,
    path_file VARCHAR(500) NOT NULL,
    tipe_file VARCHAR(50) NOT NULL, -- 'image/jpeg', 'video/mp4', dll
    ukuran_file INT, -- dalam KB
    uploaded_by INT NOT NULL,
    tanggal_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kode_aduan) REFERENCES aduan(kode_aduan),
    FOREIGN KEY (uploaded_by) REFERENCES pengguna(kode_pengguna)
);
-- Insert kategori
INSERT INTO kategori (nama_kategori, deskripsi) VALUES
('SAMPAH', 'Aduan terkait kebersihan dan pengelolaan sampah'),
('JALAN_RUSAK', 'Kerusakan jalan, lubang, atau infrastruktur jalan'),
('KEAMANAN', 'Masalah keamanan lingkungan dan kriminalitas'),
('TRANSPORTASI', 'Masalah transportasi umum dan lalu lintas'),
('LAMPU_JALAN', 'Kerusakan atau matinya lampu penerangan jalan'),
('LAINNYA', 'Kategori lain yang tidak masuk kategori di atas');


-- Insert pengguna contoh
INSERT INTO pengguna (nama_pengguna, email, password, nomor_hp, jenis_akun) VALUES
('warga1', 'warga1@bintaro.com', 'password123', '081234567890', 'WARGA'),
('petugas1', 'petugas1@bintaro.com', 'password123', '081234567891', 'PETUGAS'),
('admin1', 'admin1@bintaro.com', 'password123', '081234567892', 'ADMIN'),
('manager1', 'manager1@bintaro.com', 'password123', '081234567893', 'MANAGER');

-- Insert contoh aduan
INSERT INTO aduan (kode_pengguna, kode_kategori, judul_aduan, deskripsi, lokasi) VALUES
(1, 1, 'Sampah Menumpuk di Jalan', 'Sampah sudah 3 hari tidak diangkut di depan rumah saya', 'Jl. Bintaro Sektor 1 Blok A'),
(1, 2, 'Jalan Berlubang', 'Ada lubang besar di jalan yang membahayakan pengendara', 'Jl. Bintaro Utama Sektor 3');
-- Insert riwayat status
INSERT INTO riwayat_status (kode_aduan, status_baru, keterangan) VALUES
(1, 'BARU', 'Aduan baru dibuat oleh warga'),
(2, 'BARU', 'Aduan baru dibuat oleh warga');
-- Insert contoh komentar
INSERT INTO komentar (kode_aduan, kode_pengguna, isi_komentar) VALUES
(1, 3, 'Terima kasih atas laporannya, akan segera ditindaklanjuti'),
(2, 3, 'Tim kami akan segera meninjau lokasi yang dilaporkan');

-- Insert contoh lampiran foto
INSERT INTO lampiran (kode_aduan, nama_file, path_file, tipe_file, ukuran_file, uploaded_by) VALUES
(1, 'sampah_menumpuk_1.jpg', '/uploads/2024/sampah_menumpuk_1.jpg', 'image/jpeg', 1024, 1),
(1, 'sampah_menumpuk_2.jpg', '/uploads/2024/sampah_menumpuk_2.jpg', 'image/jpeg', 856, 1),
(2, 'jalan_berlubang.jpg', '/uploads/2024/jalan_berlubang.jpg', 'image/jpeg', 1456, 1),
(2, 'video_lubang_jalan.mp4', '/uploads/2024/video_lubang_jalan.mp4', 'video/mp4', 5120, 1);

-- CONTOH QUERY UNTUK TESTING
-- 1. Lihat semua aduan dengan detail lengkap + jumlah foto
SELECT 
    a.kode_aduan, 
    a.judul_aduan, 
    a.deskripsi,
    a.lokasi,
    a.status, 
    a.tanggal_submit,
    p.nama_pengguna as warga, 
    k.nama_kategori,
    COUNT(l.id_lampiran) as jumlah_foto
FROM aduan a 
JOIN pengguna p ON a.kode_pengguna = p.kode_pengguna 
JOIN kategori k ON a.kode_kategori = k.kode_kategori 
LEFT JOIN lampiran l ON a.kode_aduan = l.kode_aduan
GROUP BY a.kode_aduan
ORDER BY a.tanggal_submit DESC;
-- 2. Lihat foto/video dari suatu aduan
SELECT 
    l.nama_file,
    l.tipe_file,
    l.ukuran_file,
    l.tanggal_upload,
    p.nama_pengguna as uploader
FROM lampiran l
JOIN pengguna p ON l.uploaded_by = p.kode_pengguna
WHERE l.kode_aduan = 1;

-- 3. Lihat statistik aduan per kategori
SELECT 
    k.nama_kategori,
    COUNT(*) as total_aduan,
    COUNT(CASE WHEN a.status = 'SELESAI' THEN 1 END) as selesai,
    COUNT(CASE WHEN a.status = 'BARU' THEN 1 END) as baru,
    COUNT(CASE WHEN a.status = 'DIPROSES' THEN 1 END) as diproses,
    AVG(CASE WHEN l.id_lampiran IS NOT NULL THEN 1 ELSE 0 END) as rata_foto_per_aduan
FROM aduan a 
JOIN kategori k ON a.kode_kategori = k.kode_kategori 
LEFT JOIN lampiran l ON a.kode_aduan = l.kode_aduan
GROUP BY k.nama_kategori;

-- 4. Lihat riwayat status suatu aduan
SELECT 
    rs.kode_aduan,
    rs.status_lama,
    rs.status_baru,
    rs.tanggal_perubahan,
    rs.keterangan
FROM riwayat_status rs
WHERE rs.kode_aduan = 1
ORDER BY rs.tanggal_perubahan DESC;