# Gemorph DNA to Face

Live application: [frontend-gemorph-43343.web.app](https://frontend-gemorph-43343.web.app/)

Use the live link to test the deployed frontend. The backend and machine-learning model are hosted separately in the cloud because of their compute requirements and intellectual-property constraints. This repository contains the Flutter frontend code and does not include the backend or model files.

GeMorph was originally designed for on-premise deployment in forensic environments. DNA data is highly sensitive and should not be uploaded to a public repository or exposed through a public demonstration system. Production use should run within an appropriately controlled environment, with approved access controls and data-handling procedures.

## What This Repository Contains

- Flutter user interface for DNA upload, processing status, reports, and generated face results.
- Static assets and platform project files for Flutter.

## Requirements

- Flutter SDK with Dart 3 or later.
- Access to a running GeMorph FastAPI backend.
- A supported Flutter target such as Chrome, Windows, macOS, or Linux.

## Run Locally

1. Open a terminal in this repository:

   ```bash
   cd /path/to/gemorph_app_frontend
   ```

2. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. Start the application with the backend URL. For the deployed backend:

   ```bash
   flutter run -d chrome \
     --dart-define=API_BASE_URL=https://fastapi-backend-226835992406.us-central1.run.app
   ```

   For a local backend, replace the URL with `http://localhost:8000`.

4. Select a DNA input file in the application and wait for processing to finish.

The API endpoint is defined in `lib/config/app_config.dart`. The `API_BASE_URL` Dart define takes precedence over its default value.

## Build For Web

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://fastapi-backend-226835992406.us-central1.run.app
```

The output is written to `build/web`.

## Local Sample Inputs

Sample genotype files can be kept locally in:

```text
/Users/navairarehman/Desktop/Input sample csvs
```

The provided input CSVs in that folder are available for testing the application. Select one when running the frontend locally or use one through the live application. These files are intentionally not included in this public frontend repository because they contain genomic data and identifiable sample information. Use them only in an authorized local or private testing environment. The backend accepts CSV, VCF, and TXT inputs with `# rsid` and `genotype` columns.

## Tests

```bash
flutter test
flutter analyze
```
