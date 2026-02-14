# DentIn

Professional network for dentists: connect, find jobs, events, marketplace, and clinic rentals.

---

## Features

| Feature | Description |
|--------|-------------|
| **Auth** | Login, register (with OTP), forget password |
| **Home** | Feed, posts, comments, likes, saved/hidden posts |
| **Profile** | View & edit profile, education, experience, clinic info |
| **Users** | Discover professionals, search, filters |
| **Jobs** | Browse jobs, post jobs, apply |
| **Store** | Products marketplace, add product, contact seller |
| **Rent clinic** | List and find dental clinic rentals |
| **Events** | Calendar, event list, event details |
| **Messages** | Chat (Firebase Realtime) |
| **Friends** | Friend requests (incoming/outgoing) |
| **Notifications** | FCM notifications |
| **Stories** | Explore stories |

---

## Architecture

Feature-first structure. Each feature is self-contained: **UI** → **Cubit** → **Repository** → **API**.

```
lib/
├── main.dart
├── core/                    # Shared app layer
│   ├── config/              # Firebase, env
│   ├── constant/            # App texts, colors
│   ├── di/                  # GetIt dependency injection (inject.dart)
│   ├── network/             # Dio client, API service, constants
│   ├── routing/             # App routes, router
│   ├── services/            # Storage, Firebase, FCM, connectivity
│   ├── utils/               # Navigation, scroll, memory, performance
│   └── widgets/             # Reusable & optimized widgets
├── features/                # One folder per feature
│   ├── auth/                # login, register, forget_password
│   ├── home/                # posts, feed, create post
│   ├── profile/             # profile, edit profile
│   ├── users/               # users list, search, filters
│   ├── jobs/                # jobs list, post job, job details
│   ├── store/               # products, add product, product details
│   ├── rent_clinic/         # rent list, add rent
│   ├── events/              # events, event details, calendar
│   ├── messages/            # chat
│   ├── friends/             # friend requests
│   ├── notifications/      # notifications screen
│   └── explore_stories/     # stories
└── shared/                  # Shared UI components
```

**Per-feature layout:**

```
features/<feature>/
├── ui/ or *.dart            # Screens & widgets
├── cubit/                   # Cubit + state (BLoC pattern)
└── data/
    ├── models/              # DTOs, request/response models
    └── repo/                # Repository (calls API, returns models)
```

**Data flow:**  
`Screen` → `Cubit` → `Repository` → `ApiService` (Dio) → backend.

**State management:** BLoC (Cubit). **DI:** GetIt. **Network:** Dio + interceptors (auth, logging).

---

## Tech stack

- **Flutter** — UI
- **Dart** — 3.8+
- **BLoC (Cubit)** — State management
- **GetIt** — Dependency injection
- **Dio** — HTTP client
- **Firebase** — Core, Realtime DB (chat), FCM
- **SharedPreferences** — Local storage
- **flutter_screenutil** — Responsive UI

## Preview

<img width="180" height="428" alt="Hotpot 0" src="https://github.com/user-attachments/assets/79239082-be1b-4b89-a0e5-2c5db6bfc6f3" />
<img width="180" height="428" alt="Hotpot 1" src="https://github.com/user-attachments/assets/fbaee14f-fa7a-4c14-9a06-865f2cf1a4ef" />
<img width="180" height="428" alt="Hotpot 2" src="https://github.com/user-attachments/assets/b5ff6d11-18b0-482d-87ee-ef2d511eea73" />
<img width="180" height="428" alt="Hotpot 3" src="https://github.com/user-attachments/assets/441caebd-9312-4802-9bf8-fbf61040898d" />
<img width="180" height="428" alt="Hotpot 4" src="https://github.com/user-attachments/assets/769e50ca-fa72-42df-b679-e4ca6dc362d4" />






