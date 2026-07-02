# 📚 Digital Ebook Library

A full-stack ebook management app built with **Ruby on Rails 7** (API backend) and **Flutter 3** (mobile frontend) as part of the Sagar Fab International Full Stack Developer assignment.

---

## 🗂️ Project Overview

Users can upload, browse, search, read, download, and delete ebooks (PDF + EPUB) through a clean, bookshelf-inspired mobile interface.

---

## 🛠️ Tech Stack

| Layer     | Technology |
|-----------|-----------|
| Backend   | Ruby on Rails 7 (API mode), SQLite, Active Storage |
| Frontend  | Flutter 3, Riverpod, go_router, Dio, SfPdfViewer |
| Tests     | RSpec (backend), flutter_test + mocktail (frontend) |
| Storage   | Active Storage — local disk (dev), S3-compatible (prod) |

---

## ⚙️ Setup — Backend

### Prerequisites
- Ruby 3.3+ (`rbenv install 3.3.6`)
- Bundler (`gem install bundler`)
- ImageMagick (`sudo apt install imagemagick`)

```bash
cd backend
bundle install
rails db:create db:migrate
rails db:seed         # optional: loads 10 demo ebooks
rails s -p 3000
```

The API will be available at `http://localhost:3000`.

---

## 📱 Setup — Flutter

### Prerequisites
- Flutter 3.22+ (`flutter --version`)
- Android emulator or physical device

```bash
cd frontend
flutter pub get
flutter run
```

> **Note:** The app defaults to `http://10.0.2.2:3000` (Android emulator → localhost).  
> For a real device, update `lib/core/api/endpoints.dart` with your machine's local IP.

---

## 🧪 Running Tests

### Backend (RSpec)
```bash
cd backend
bundle exec rspec --format documentation
```

### Frontend (Flutter)
```bash
cd frontend
flutter test
```

---

## 📡 API Overview

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/api/ebooks` | List all ebooks. Supports `?q=`, `?sort=`, `?type=`, `?page=` |
| POST   | `/api/ebooks` | Upload ebook (multipart/form-data) |
| GET    | `/api/ebooks/:id` | Get ebook details |
| GET    | `/api/ebooks/:id/download` | Download ebook file |
| DELETE | `/api/ebooks/:id` | Delete ebook |
| GET    | `/api/ebooks/search?q=` | Search by title/author |

### Upload request format
```
Content-Type: multipart/form-data

ebook[title]       required
ebook[author]      optional
ebook[description] optional
ebook[file]        required (PDF or EPUB)
ebook[cover]       optional (image)
```

---

## ✨ Key Features

- **Bookshelf UI** — Books displayed as spines on wooden shelves (iOS-style)
- **PDF Cover Extraction** — Auto-generates cover thumbnail from first page
- **PDF In-App Reader** — Syncfusion viewer with page tracking + full-screen
- **Last Read Page** — Remembered per book via SharedPreferences
- **Debounced Search** — 300ms debounce with filter (All/PDF/EPUB) + sort chips
- **Upload Progress** — Real-time progress bar during file upload
- **Shimmer Loading** — Skeleton placeholders while data loads
- **Error States** — Full-page error widget with retry on every screen

---

## ⚠️ Known Limitations

- No user authentication (single-user app)
- EPUB reading is supported in-app via the `epub_view` package (downloads to a temp file then renders natively)
- Active Storage uses local disk — files are lost if the storage directory is deleted
- PDF cover extraction requires ImageMagick + Ghostscript installed on the server
- Upload file size is capped at **50 MB** on the Flutter side; the Rails backend also enforces this via Active Storage limits
- Pagination UI not yet implemented on the mobile side (loads first 20 results)

---

## 🤖 AI Tools Used

| Tool | Usage |
|------|-------|
| Antigravity (Claude Sonnet 4.6) | Architecture planning, all code scaffolding, test generation |
| Manual Review | All generated code reviewed for correctness, edge cases, and Rails/Flutter best practices |
| Debugged | Provider invalidation after delete, Active Storage signed URL generation, MiniMagick PDF extraction error handling |

**What I reviewed/improved:**
- Replaced auto-generated `@riverpod` annotations with explicit `StateNotifierProvider` for clearer state (upload, download, delete)
- Added `allow_blank: true` to `file_type` validation to prevent double errors on missing file
- Corrected `DeleteNotifier` to accept `WidgetRef` and call `ref.invalidate(ebooksProvider)` after deletion

---

## ✅ Manual Testing Checklist

- [x] Upload a PDF → appears in bookshelf
- [x] Upload an EPUB → appears in bookshelf
- [x] Upload with no title → validation error shown
- [x] Upload unsupported file → error shown
- [x] Upload file > 50 MB → "File too large" error shown immediately
- [x] Search by title → correct results
- [x] Search by author → correct results
- [x] Search with no match → empty state shown
- [x] Filter by PDF → only PDFs shown
- [x] Open and read a PDF in-app
- [x] Full-screen mode works in reader
- [x] Reopen reader → last page restored
- [x] Download an ebook → file saved locally
- [x] Delete an ebook → confirmation dialog shown
- [x] Confirm delete → removed from shelf
- [x] Cancel delete → item stays
- [x] Empty library → illustrated empty shelf shown
- [x] Server offline → error widget with retry shown
