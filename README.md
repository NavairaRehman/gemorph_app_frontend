# GeMorph Flutter Frontend

This repository contains the Flutter client. The FastAPI service is maintained and deployed separately in `gemorph_app_backend`.

> ⚠️ Intended for **law enforcement and forensic agencies** in sensitive cases such as murder, rape, and unidentified remains.

---

## 🧠 Features

- 🔬 **DNA-to-Face Prediction**  
  Generates a realistic 3D facial mesh using a Conditional Autoencoder trained on genetic features.

- 🎨 **Pigmentation Trait Prediction**  
  Predicts **eye**, **hair**, and **skin** color using XGBoost models trained on large-scale genomic data.

- 📄 **Automatic Report Generation**  
  Outputs a detailed **PDF report** containing predicted traits and face visuals.

- 🛠 **Fully Offline Execution**  
  No internet connection or external API calls. All models and logic run locally on-device.

- 🖥 **Cross-Platform Frontend**  
  Built with Flutter — simple UI for uploading DNA, tracking progress, and downloading reports.

---

## Project Structure

```

├── lib/                      # Flutter UI (Upload, Progress, Report screens)
├── assets/                   # PDF templates, icons, etc.
└── ...

```

---

## 🚀 Quick Start (Windows)

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A reachable deployment of the FastAPI backend

---

### 💻 Run the Flutter App (Windows)

```bash
flutter pub get
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:8000
```

For a deployed backend, replace the value with its HTTPS URL at build time, for example:

```bash
flutter build web --dart-define=API_BASE_URL=https://api.example.com
```

---

## 🧬 Model Details

### 🎭 Conditional Autoencoder (Face Prediction)

* Inputs:

  * Mean cluster face (3D vertices)
  * DNA embedding (e.g., 1326 SNP features)
* Outputs:

  * 3D mesh of predicted face (3000 vertices)

### 🎨 XGBoost Classifiers (Trait Prediction)

* Inputs:

  * DNA feature vector (preprocessed)
* Outputs:

  * Trait class + confidence (for eye/hair/skin)

---

## 🧪 Tests

Run Flutter tests:

```bash
flutter test
```

---

## 📜 License

This repository is part of a research and development initiative. For licensing and forensic deployment, please contact the [GeMorph team](mailto:gemorphdev@gmail.com).

---

## 👥 Contributors

* Ahsan Ullah Tanweer – Founder & Developer
* Navaira Rehman - Founder & Developer

---

## 🌐 Learn More

> Visit [GeMorph.com](https://gemorph.com) or follow our updates on LinkedIn, GitHub, and Instagram.
