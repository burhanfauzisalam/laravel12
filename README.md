## Deploy ke Server (Docker + Traefik)

Panduan singkat untuk deploy pertama kali ke server (mis. Ubuntu + Docker + Traefik).

### 1. Persiapan di server

- Install Docker dan Docker Compose plugin.
- Pastikan user (mis. `ubuntu`) bisa menjalankan Docker (opsional tanpa `sudo`):
  - `sudo usermod -aG docker ubuntu` lalu logout/login, atau lanjut gunakan `sudo` seperti di workflow.
- Buat network Traefik yang dipakai `docker-compose.yml`:
  - `sudo docker network create web` (abaikan error jika sudah ada).
- Siapkan folder aplikasi:
  - `mkdir -p ~/Apps/laravel12`
  - `cd ~/Apps/laravel12`

### 2. Buat file `.env` di server

- Ambil contoh dari `.env.production.example` di repo ini, lalu isi sesuai environment production:
  - `APP_ENV=production`
  - `APP_URL` / `ASSET_URL` arahkan ke `https://server.burhanfs.my.id/laravel12`
  - Konfigurasi database:
    - `DB_CONNECTION=mysql`
    - `DB_HOST` = host/IP MySQL (boleh di luar Docker).
    - `DB_PORT` = port MySQL.
    - `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` sesuai server DB.
- Simpan sebagai `~/Apps/laravel12/.env`.
- Catatan:
  - Workflow deploy **tidak akan menghapus atau menimpa** file `.env` di server (rsync memakai `--exclude='.env'`).

### 3. Deploy manual pertama kali

Di server:

```bash
cd ~/Apps/laravel12
git clone https://github.com/burhanfauzisalam/laravel12.git .   # jika belum ada isi repo
sudo docker compose up -d --build
```

Jika tidak ada error di log container `laravel12`, aplikasi dapat diakses melalui Traefik di `https://server.burhanfs.my.id/laravel12`.

### 4. Setup CI/CD (GitHub Actions)

Repository ini sudah menyertakan:

- `./.github/workflows/ci.yml` – menjalankan test dan build front-end pada setiap push/pull request.
- `./.github/workflows/deploy.yml` – auto-deploy ke server pada setiap push ke branch `main`.

Langkah konfigurasi:

1. Di GitHub repo ini buka: `Settings` → `Secrets and variables` → `Actions`.
2. Tambahkan **Repository secrets** berikut:
   - `SSH_HOST` = host/IP server (mis. `ec2-...ap-southeast-1.compute.amazonaws.com`).
   - `SSH_USER` = user SSH (mis. `ubuntu`).
   - `SSH_PORT` = port SSH (`22` jika default).
   - `SSH_PRIVATE_KEY` = isi private key yang dipakai untuk SSH ke server (mulai `-----BEGIN` sampai `END PRIVATE KEY-----`).
3. Pastikan folder `~/Apps/laravel12` di server sudah ada dan berisi file `.env` seperti langkah di atas.

Setelah itu, setiap kali push ke branch `main`:

- GitHub Actions akan menjalankan CI (`ci.yml`).
- Workflow deploy akan:
  - Menyalin kode terbaru ke `~/Apps/laravel12` via `rsync` (tanpa menghapus `.env`).
  - Menjalankan `sudo docker compose up -d --build` di server.
  - Membersihkan image lama dengan `sudo docker image prune -f`.
