# Food Rescue Mobile — Frontend Foundation

Flutter/Riverpod/GoRouter foundation for the Food Rescue application.

Backend architecture:
- Spring Boot 3
- PostgreSQL + PostGIS
- Redis
- RabbitMQ
- AWS S3
- JWT authentication

API base prefix from the project documentation:
`/api/v1`

Core documented endpoints include:
- POST `/auth/register`
- POST `/auth/login`
- POST `/auth/refresh`
- POST `/auth/logout`
- GET `/auth/me`
- POST `/donors`
- GET `/donors/{id}`
- PUT `/donors/{id}`
- POST `/ngos`
- GET `/ngos/{id}`
- PUT `/ngos/{id}`
- POST `/listings`
- GET `/listings`
- GET `/listings/nearby`
- GET `/listings/{id}`
- PUT `/listings/{id}`
- DELETE `/listings/{id}`
- POST `/listings/{id}/claim`
- GET `/claims`
- GET `/claims/{id}`
- PUT `/claims/{id}/status`
- POST `/claims/{id}/cancel`
- GET `/notifications`
- PUT `/notifications/{id}/read`

## Important profile-check assumption

The backend documentation defines profile creation and `/donors/{id}` / `/ngos/{id}`, but does not explicitly document `/donors/me` or `/ngos/me`.

This frontend foundation uses:
- GET `/donors/me`
- GET `/ngos/me`

for onboarding guards.

If your backend does not expose those endpoints, either:
1. add these small authenticated endpoints to the backend, or
2. change `ProfileRepository` to use the actual profile lookup mechanism.

## Setup

1. Copy the `lib/` directory into the Flutter project.
2. Merge the dependencies from `pubspec.yaml`.
3. Set your backend URL in `lib/core/config/app_config.dart`.
4. Add your logo/assets if required.
5. Run:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Architecture

```text
UI
 |
Riverpod Providers
 |
Repositories
 |
ApiService
 |
Spring Boot REST API
```

Authentication state controls routing:

```text
No JWT
  -> Login

JWT + no Donor/NGO profile
  -> Organization Setup

JWT + profile
  -> Role Home
```

The organization setup flow is intentionally UI-light. The provider is responsible for:
- step state
- validation
- donor/NGO payload preparation
- profile creation
- refreshing auth state after profile creation
