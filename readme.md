#  UniVibe

**UniVibe** is a mental wellness & fitness mobile app that helps users stay healthy and connected. Users can log exercises, earn coins, grow plants in a virtual garden, and engage in a vibrant forum called **FitHub**.

This app was built as part of the **NUS Orbital 2025** programme (Apollo 11 level)

---

##  Tech Stack

| Layer      | Technology         |
|------------|--------------------|
| Frontend   | Flutter            |
| Backend    | Flask (Python)     |
| Database   | MySQL              |
| Hosting    | Localhost for demo |

---

## Features

- 👤 **User Authentication** — Register / Login
- 🏃‍♂️ **Activity Logging** — Track exercises and earn coins
- 🌿 **Virtual Garden** — Spend coins to grow plants
- 🗣️ **FitHub Forum** — Create posts, comment, like
- 👥 **Connections** — View, follow/unfollow friends
- 🧑‍🎨 **Avatars** — Choose virtual characters to represent yourself

---

## 🧩 Folder Structure
<pre> ``` univibe/ ├── backend/ │ ├── app/ │ │ ├── __init__.py │ │ ├── auth.py │ │ ├── fithub.py │ │ └── db.py │ ├── run.py │ └── requirements.txt │ ├── frontend/ │ ├── lib/ │ │ ├── pages/ │ │ ├── widgets/ │ │ └── global.dart │ ├── assets/ │ └── pubspec.yaml │ ├── database/ │ └── univibe_db.sql │ └── README.md ``` </pre>


---

## Installation Guide

### Backend Setup

1. Install Python (>=3.10) and MySQL
2. Create MySQL DB called `univibe`
3. Import schema:
   ```bash
   mysql -u root -p < database/univibe_db.sql
4. Go to backend/, set up virtual environment:
   ```bash
   python -m venv venv 
   source venv/bin/activate
   pip install -r requirements.txt
5. Start server:
   ```bash
   python3 run.py

### Frontend Setup

1. Install Flutter
2. Navigate to /frontend
   ```bash
   flutter pub get
3. Make sure getBaseUrl() in API files is correct:
   <pre>String getBaseUrl() { if (Platform.isAndroid) return 'http://10.0.2.2:5000'; return 'http://127.0.0.1:5000'; }</pre>
4. Run
   ```bash
   flutter run





