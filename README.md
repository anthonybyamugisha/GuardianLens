# GuardianLens

GuardianLens is an Android-based, AI-assisted child online-safety prototype. It periodically analyses visible screen content within selected applications and displays a warning when potentially inappropriate visual content is detected.

The system consists of:

- A GuardianLens parent application
- A GuardianLens child-agent application
- A shared Django REST backend
- Google Cloud Vision SafeSearch integration

## Project Components

### Parent Application

The parent application will allow a parent or guardian to:

- Register and manage an account
- Log in and recover a password
- Create and manage child profiles
- Pair a child device
- Select applications to monitor
- Configure moderation sensitivity
- View safety alerts and event history
- View the monitoring status of paired devices

### Child-Agent Application

The child agent will:

- Pair with a parent account
- Request the necessary Android permissions
- Detect when a monitored application is active
- Periodically capture authorised screen frames
- Submit frames for visual moderation
- Display a visible warning for flagged content
- Report minimal event metadata to the backend

### Django Backend

The backend will provide:

- Parent authentication and account management
- Child-profile management
- Device registration and pairing
- Monitoring-rule management
- Moderation API integration
- Safety-event storage
- Parent alert retrieval

## Technology Stack

- Flutter and Dart
- Native Android APIs
- Python and Django
- Django REST Framework
- SQLite during initial development
- PostgreSQL for later deployment
- Google Cloud Vision SafeSearch
- JSON Web Tokens for API authentication
- Git and GitHub for version control

## Project Structure

```text
GuardianLens/
├── apps/
│   ├── parent_app/
│   └── child_agent/
├── backend/
│   ├── accounts/
│   ├── child_profiles/
│   ├── devices/
│   ├── pairing/
│   ├── monitoring/
│   ├── moderation/
│   ├── alerts/
│   ├── config/
│   └── manage.py
├── venv/
├── .gitignore
├── requirements.txt
└── README.md
```

## Backend Setup

### 1. Activate the virtual environment

Using Windows PowerShell:

```powershell
cd D:\PROJECTS\GuardianLens
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\venv\Scripts\Activate.ps1
```

### 2. Install dependencies

```powershell
pip install -r requirements.txt
```

### 3. Apply database migrations

```powershell
cd backend
python manage.py makemigrations
python manage.py migrate
```

### 4. Create an administrator

```powershell
python manage.py createsuperuser
```

### 5. Start the backend

```powershell
python manage.py runserver
```

The backend will be available at:

```text
http://127.0.0.1:8000/
```

Django Admin will be available at:

```text
http://127.0.0.1:8000/admin/
```

## Parent Application Setup

```powershell
cd D:\PROJECTS\GuardianLens\apps\parent_app
flutter pub get
flutter run
```

## Child-Agent Setup

```powershell
cd D:\PROJECTS\GuardianLens\apps\child_agent
flutter pub get
flutter run
```

## Development Status

GuardianLens is currently under development as a final-year Computer Science project at Makerere University.

Current development priorities:

1. Backend and Django Admin setup
2. Parent registration and authentication
3. Parent account management
4. Child-profile creation
5. Parent-child device pairing
6. Child-agent monitoring foundation
7. Visual moderation integration
8. Parent alerts and monitoring controls

## Privacy and Ethical Position

GuardianLens is an academic prototype and does not provide guaranteed protection.

The project will:

- Require explicit permission for screen capture
- Preserve Android screen-capture indicators
- Avoid hidden monitoring
- Avoid bypassing protected application windows
- Minimise retention of captured screen data
- Avoid using real children’s private screen activity during development
- Store only necessary moderation-event information