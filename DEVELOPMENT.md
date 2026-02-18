# Guia de Desarrollo - Tavuel App (Flutter)

Documento de referencia con las convenciones, patrones y lineamientos para el desarrollo
de la aplicacion movil de Tavuel. **Lectura obligatoria** antes de contribuir al proyecto.

---

## Tabla de Contenidos

1. [Arquitectura del Proyecto](#1-arquitectura-del-proyecto)
2. [Convenciones de Codigo](#2-convenciones-de-codigo)
3. [State Management (Riverpod)](#3-state-management-riverpod)
4. [Tema y Colores](#4-tema-y-colores)
5. [Navegacion (GoRouter)](#5-navegacion-gorouter)
6. [API y Manejo de Errores](#6-api-y-manejo-de-errores)
7. [Modelos y Entidades](#7-modelos-y-entidades)
8. [Testing](#8-testing)
9. [Checklist de Code Review](#9-checklist-de-code-review)
10. [Dependencias](#10-dependencias)

---

## 1. Arquitectura del Proyecto

### Clean Architecture por Feature

Cada feature del proyecto se organiza en tres capas independientes:

```
lib/
  app/
    app.dart                  # Widget raiz (TavuelApp)
    routes/
      app_router.dart         # Configuracion de GoRouter y AppRoutes
    theme/
      app_theme.dart          # AppColors + AppTheme (light y dark)
  core/
    api/
      api_client.dart         # Cliente HTTP centralizado (Dio)
      api_interceptors.dart   # AuthInterceptor, SecureStorageHelper
    constants/
      app_constants.dart      # Constantes globales (URLs, timeouts, etc.)
    errors/
      app_exception.dart      # Jerarquia de excepciones
      failure.dart            # Failure + Result<T> para manejo funcional
    utils/
      validators.dart         # Validaciones reutilizables
  features/
    <nombre_feature>/
      data/
        datasources/          # Clases que hablan con la API o cache local
        models/               # Modelos con fromJson/toJson (extienden entity)
        repositories/         # Implementacion concreta del repository
      domain/
        entities/             # Clases puras sin dependencias externas
        repositories/         # Interfaces abstractas (contratos)
        usecases/             # Casos de uso (una accion = una clase)
      presentation/
        providers/            # Riverpod providers, notifiers, estados
        screens/              # Pantallas completas (Scaffold)
        widgets/              # Widgets reutilizables dentro del feature
  shared/
    providers/                # Providers compartidos entre features
    widgets/                  # Widgets compartidos (ej. ScaffoldWithNavBar)
```

### Flujo de datos

```
UI (Screen/Widget)
  --> Provider/Notifier (presentation)
    --> UseCase (domain)
      --> Repository interface (domain)
        --> Repository impl (data)
          --> Datasource (data) --> API / Cache
```

Las dependencias solo apuntan hacia adentro: `presentation -> domain <- data`. La capa
`domain` **nunca** importa nada de `data` ni de `presentation`.

### Cuando crear un nuevo feature vs agregar a uno existente

**Crear un nuevo feature cuando:**
- Es una funcionalidad con su propio flujo de navegacion (ej. `bookings`, `payments`)
- Tiene sus propias entidades de dominio distintas
- Puede desarrollarse y probarse de forma independiente
- Tiene al menos un screen propio

**Agregar a un feature existente cuando:**
- Es una pantalla o widget que opera sobre las mismas entidades
- Es una variante o extension de funcionalidad existente
- Comparte el mismo estado/provider

**Ejemplo:** Las resenas (`reviews`) son un feature separado de `provider_search`
porque tienen sus propias entidades (`Review`, `ReviewStats`), su propio repositorio
y su propio flujo (ver resenas, crear resena). Pero `provider_profile` vive dentro de
`provider_search` porque es parte del mismo flujo de busqueda.

---

## 2. Convenciones de Codigo

### Idioma

- **Codigo** (variables, funciones, clases, comentarios tecnicos): **Ingles**
- **Textos visibles al usuario** (labels, mensajes, errores): **Espanol**
- **Documentacion** (este archivo, comments de API): **Espanol**

```dart
// CORRECTO
class LoginScreen extends ConsumerWidget { ... }
final String errorMessage = 'Credenciales incorrectas.';

// INCORRECTO
class PantallaLogin extends ConsumerWidget { ... }
final String mensajeError = 'Invalid credentials.';
```

### Tildes obligatorias

Todo texto visible al usuario **DEBE** llevar tildes correctas. Lista de palabras
frecuentes que siempre deben tildarse:

| Palabra correcta | Error comun |
|---|---|
| informacion | informacion (sin tilde) |
| descripcion | descripcion (sin tilde) |
| direccion | direccion (sin tilde) |
| verificacion | verificacion (sin tilde) |
| conexion | conexion (sin tilde) |
| sesion | sesion (sin tilde) |
| accion | accion (sin tilde) |
| validacion | validacion (sin tilde) |
| autenticacion | autenticacion (sin tilde) |
| construccion | construccion (sin tilde) |
| calificacion | calificacion (sin tilde) |
| categoria | categoria (sin tilde) |
| numero | numero (sin tilde) |
| telefono | telefono (sin tilde) |
| cedula | cedula (sin tilde) |
| pagina | pagina (sin tilde) |
| mas | mas (sin tilde) |
| tambien | tambien (sin tilde) |
| aqui | aqui (sin tilde) |
| esta / estas | esta (sin tilde en verbo) |
| sera / seran | sera (sin tilde) |
| dias | dias (sin tilde) |
| anos | anos (sin tilde) |

**Signos de apertura:** En espanol se usan signos de apertura y cierre:
- Preguntas: `¿Estas seguro?` (no solo `Estas seguro?`)
- Exclamaciones: `¡Listo!` (no solo `Listo!`)

```dart
// CORRECTO
'Tu sesion ha expirado. Inicia sesion nuevamente.'
'¿Deseas cancelar la reserva?'
'¡Servicio completado!'
'Informacion de contacto'

// INCORRECTO
'Tu sesion ha expirado. Inicia sesion nuevamente.'  // sin tildes
'Deseas cancelar la reserva?'                        // sin signo de apertura
'Servicio completado!'                               // sin signo de apertura
'Informacion de contacto'                            // sin tilde
```

### Internacionalizacion

Usar `AppLocalizations` para todos los strings visibles al usuario. No hardcodear textos:

```dart
// CORRECTO
Text(AppLocalizations.of(context)!.welcomeMessage)

// INCORRECTO (solo aceptable en prototipos tempranos)
Text('Bienvenido a Tavuel')
```

El proyecto tiene `generate: true` en `pubspec.yaml` y usa `flutter_localizations`.
Los archivos de traduccion van en `lib/l10n/`.

### Naming Conventions

| Elemento | Convencion | Ejemplo |
|---|---|---|
| Clases | PascalCase | `AuthRepository`, `UserModel` |
| Variables y metodos | camelCase | `isLoading`, `fetchUser()` |
| Constantes | camelCase o SCREAMING_SNAKE | `defaultPageSize`, `API_KEY` |
| Archivos | snake_case | `auth_repository.dart`, `login_screen.dart` |
| Carpetas | snake_case | `provider_onboarding/`, `data/datasources/` |
| Providers (Riverpod) | camelCase + Provider suffix | `authProvider`, `reviewsRepositoryProvider` |
| Notifiers | PascalCase + Notifier suffix | `AuthNotifier`, `CreateReviewNotifier` |
| States | PascalCase + State suffix | `AuthState`, `ProviderReviewsState` |
| Enums | PascalCase (tipo), camelCase (valores) | `AuthStatus.authenticated` |

### Formato y estilo

- Maximo 80 columnas (preferido), 100 columnas (maximo absoluto)
- Usar `const` en todo lo que sea posible (constructors, widgets, listas)
- Trailing commas en parametros para mejor formato automatico
- Ordenar imports: dart > flutter > packages > proyecto (relativo)
- Documentar clases publicas con `///` (doc comments)

---

## 3. State Management (Riverpod)

### Cuando usar cada tipo de Provider

| Tipo | Cuando usarlo | Ejemplo en el proyecto |
|---|---|---|
| `Provider` | Valores inmutables, dependency injection | `apiClientProvider`, `authRepositoryProvider` |
| `StateNotifierProvider` | Estado mutable complejo con logica de negocio | `authProvider`, `providerReviewsProvider` |
| `FutureProvider` | Datos asincronos de una sola lectura | `providerStatsProvider`, `myReviewsProvider` |
| `StreamProvider` | Datos en tiempo real (WebSocket, Firebase) | Notificaciones, tracking en vivo |
| `StateProvider` | Estado simple (bool, int, enum) | Toggles de UI, filtros simples |
| `Provider.family` | Providers parametrizados | `providerReviewsProvider` (por providerId) |

### Patron para estados con loading/error/data

Siempre definir un state class con al menos estos campos:

```dart
class FeatureState {
  final bool isLoading;
  final String? errorMessage;
  final List<Item> items;       // o el dato principal
  final bool hasMore;           // si hay paginacion

  const FeatureState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
    this.hasMore = true,
  });

  FeatureState copyWith({ ... });
}
```

Patron del Notifier:

```dart
class FeatureNotifier extends StateNotifier<FeatureState> {
  final FeatureRepository _repository;

  FeatureNotifier(this._repository) : super(const FeatureState());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getData();

    result.when(
      success: (data) {
        state = state.copyWith(
          isLoading: false,
          items: data,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }
}
```

### Naming de providers

```dart
// Dependency injection (Provider)
final featureRemoteDatasourceProvider = Provider<FeatureDatasource>((ref) { ... });
final featureRepositoryProvider = Provider<FeatureRepository>((ref) { ... });
final featureUsecaseProvider = Provider<FeatureUsecase>((ref) { ... });

// State management (StateNotifierProvider)
final featureProvider = StateNotifierProvider<FeatureNotifier, FeatureState>((ref) { ... });

// Datos asincronos (FutureProvider)
final featureDataProvider = FutureProvider<FeatureData>((ref) async { ... });

// Parametrizado (family)
final featureByIdProvider = StateNotifierProvider.family<...>((ref, id) { ... });
```

### Organizacion del archivo de providers

Cada feature tiene un archivo `<feature>_provider.dart` que contiene, en este orden:

1. **Dependency Injection** -- Providers para datasource, repository, usecases
2. **State classes** -- FeatureState con copyWith
3. **Notifier classes** -- Logica de negocio
4. **Riverpod Providers** -- La declaracion final de los providers

Ver `auth_provider.dart` y `reviews_provider.dart` como referencia.

---

## 4. Tema y Colores

### Regla de oro: NUNCA colores hardcodeados

```dart
// PROHIBIDO
color: Colors.blue,
color: Color(0xFF1E88E5),
backgroundColor: Colors.white,

// CORRECTO - usando AppColors (colores de marca constantes)
color: AppColors.primary,
color: AppColors.textSecondary,

// CORRECTO - usando el tema de Material (se adapta a light/dark)
color: Theme.of(context).colorScheme.primary,
color: Theme.of(context).colorScheme.onSurface,

// CORRECTO - usando el textTheme
style: Theme.of(context).textTheme.headlineMedium,
```

### Paleta de colores definida

Los colores estan centralizados en `lib/app/theme/app_theme.dart` dentro de `AppColors`:

| Categoria | Colores |
|---|---|
| **Primario** (azul) | `primary`, `primaryLight`, `primaryDark` |
| **Secundario** (naranja) | `secondary`, `secondaryLight`, `secondaryDark` |
| **Neutros** | `background`, `surface`, `surfaceVariant`, `onBackground`, `onSurface` |
| **Texto** | `textPrimary`, `textSecondary`, `textHint`, `textOnPrimary`, `textOnSecondary` |
| **Semanticos** | `success`, `warning`, `error`, `info` |
| **Estado de reserva** | `statusPending`, `statusConfirmed`, `statusInProgress`, `statusCompleted`, `statusCancelled` |
| **Dark mode** | `darkBackground`, `darkSurface`, `darkSurfaceVariant` |

### Como agregar un nuevo color

1. Agregar la constante en `AppColors` con nombre semantico (no `blue2`, sino `cardBorder`)
2. Si es un color de marca, agregar variante dark
3. Usarlo en el `ThemeData` si aplica (tanto en `lightTheme` como en `darkTheme`)
4. Nunca agregar colores especificos de un solo widget en AppColors -- esos van en el tema del widget

### Dark mode

- `AppTheme.lightTheme` y `AppTheme.darkTheme` ya estan definidos
- Todos los colores nuevos **deben** tener contraparte oscura
- Para adaptar widgets: usar `Theme.of(context)` en vez de `AppColors` directamente cuando el color deba cambiar entre temas
- Usar `AppColors` directamente solo para colores de marca que no cambian (ej. gradientes del banner)

### Tipografia

La app usa **Poppins** via `google_fonts`. El `textTheme` ya esta definido completo
en `AppTheme.lightTheme`. Siempre referenciarse al tema:

```dart
// CORRECTO
style: Theme.of(context).textTheme.bodyMedium,
style: Theme.of(context).textTheme.headlineSmall?.copyWith(
  color: AppColors.primary,
),

// INCORRECTO
style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
```

---

## 5. Navegacion (GoRouter)

### Estructura de rutas

Todas las rutas se definen como constantes en `AppRoutes` (`lib/app/routes/app_router.dart`):

```dart
abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String providerProfile = '/provider-profile/:id';
  static const String reviews = '/reviews/:providerId';
  // ...
}
```

### Navegacion

```dart
// Reemplazo completo (resetea el stack) - para cambios de flujo
context.go(AppRoutes.home);

// Push (agrega al stack) - para navegar hacia adelante
context.push(AppRoutes.providerSearch);

// Pop (regresa)
context.pop();
```

### Pasar parametros

```dart
// Via path parameters (definidos con :param en la ruta)
context.push('/provider-profile/${provider.id}');

// Leer path parameters en el builder
final id = state.pathParameters['id']!;

// Via query parameters
context.push('${AppRoutes.providerSearch}?category=plomeria');

// Leer query parameters
final category = state.uri.queryParameters['category'];

// Via extra (para objetos complejos - NO persistente en deep links)
context.push(AppRoutes.bookingDetail, extra: bookingObject);
final booking = state.extra as Booking;
```

### Bottom Navigation

La app usa `StatefulShellRoute.indexedStack` para mantener el estado de cada tab.
Los tabs cambian segun el modo (CLIENT vs PROVIDER) via `ScaffoldWithNavBar`.

### Agregar una nueva ruta

1. Agregar la constante en `AppRoutes`
2. Agregar el `GoRoute` en la lista de `routes` del `GoRouter`
3. Si es una pantalla dentro del bottom nav, agregarla como branch o sub-route
4. Si requiere autenticacion (la mayoria), no necesita nada extra -- el `redirect` guard ya lo maneja

### Auth Guard

El `redirect` del router verifica automaticamente si el usuario esta autenticado. Las
rutas publicas son: `splash`, `login`, `register`. Todo lo demas requiere sesion activa.

---

## 6. API y Manejo de Errores

### ApiClient

Todas las llamadas HTTP pasan por `ApiClient` (`lib/core/api/api_client.dart`). **Nunca**
crear instancias de `Dio` directamente en datasources.

```dart
class MyDatasource {
  final ApiClient _apiClient;

  MyDatasource(this._apiClient);

  Future<MyModel> getData() async {
    final response = await _apiClient.get('/my-endpoint');
    return MyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    await _apiClient.post('/my-endpoint', data: data);
  }

  Future<void> uploadPhoto(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    await _apiClient.uploadFile('/upload', formData: formData);
  }
}
```

El `ApiClient` ya incluye:
- **AuthInterceptor**: Agrega el token Bearer automaticamente
- **Refresh token**: Reintenta con token nuevo si recibe 401
- **Log interceptor**: Solo en debug mode
- **Timeouts**: Configurados en `AppConstants`

### Jerarquia de errores

```
Exception (dart)
  └── AppException (base)
        ├── NetworkException        (timeout, sin internet)
        ├── UnauthorizedException   (401 - sesion expirada)
        ├── ServerException         (5xx)
        ├── NotFoundException       (404)
        ├── ForbiddenException      (403)
        ├── ValidationException     (422 - datos invalidos)
        └── CacheException          (error de storage local)
```

### Patron Result<T>

Los repositories retornan `Result<T>` en vez de lanzar excepciones:

```dart
// En el repository interface (domain)
abstract class MyRepository {
  Future<Result<List<Item>>> getItems();
  Future<Result<void>> deleteItem(String id);
}

// En la implementacion (data)
class MyRepositoryImpl implements MyRepository {
  final MyDatasource _datasource;

  @override
  Future<Result<List<Item>>> getItems() async {
    try {
      final items = await _datasource.getItems();
      return Result.success(items);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.failure(Failure(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}

// En el notifier (presentation)
final result = await _repository.getItems();
result.when(
  success: (items) => state = state.copyWith(items: items, isLoading: false),
  failure: (f) => state = state.copyWith(errorMessage: f.message, isLoading: false),
);
```

### Manejo de mensajes del backend NestJS

El backend (NestJS) puede devolver `message` como `String` o como `List<String>`
(por ejemplo en errores de validacion de class-validator). El `ApiClient` ya maneja
ambos casos:

```dart
// Ya implementado en api_client.dart - _handleResponseError
final rawMessage = data['message'];
if (rawMessage is String) {
  message = rawMessage;
} else if (rawMessage is List) {
  message = rawMessage.join('. ');
}
```

Si necesitas acceder a mensajes individuales de validacion, usar `ValidationException`
con `fieldErrors`.

---

## 7. Modelos y Entidades

### Entity (domain)

Clase pura en Dart, sin dependencias de paquetes externos. Representa el concepto
de negocio:

```dart
// lib/features/auth/domain/entities/user.dart

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String role;
  // ...

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.role = 'CLIENT',
  });

  // Getters derivados (logica de dominio pura)
  String get fullName => '$firstName $lastName';
  bool get isProvider => role == 'PROVIDER';
}
```

### Model (data)

Extiende la entity y agrega serializacion:

```dart
// lib/features/auth/data/models/user_model.dart

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phone,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'CLIENT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
    };
  }
}
```

### Reglas

- **Entity**: Sin imports de paquetes. Solo Dart puro. Campos `final`, constructor `const`
- **Model**: Extiende entity. Tiene `fromJson` factory y `toJson` method
- Los models solo se usan en la capa `data`. La capa `domain` y `presentation` solo ven entities
- Para campos opcionales del JSON, siempre usar valores por defecto:
  `json['role'] as String? ?? 'CLIENT'`
- Para fechas: `DateTime.parse(json['createdAt'] as String)` con null check

### Consistencia

El proyecto actualmente usa serializacion manual (no freezed). Si decides usar
`json_serializable` (ya esta en dev_dependencies), hazlo de forma consistente
dentro de todo el feature. No mezclar manual y generado en el mismo feature.

Pasos para `json_serializable`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  // ...

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
```

Luego ejecutar: `dart run build_runner build --delete-conflicting-outputs`

---

## 8. Testing

### Estructura

Los tests espejean la estructura de `lib/`:

```
test/
  features/
    auth/
      data/
        datasources/
          auth_remote_datasource_test.dart
        models/
          user_model_test.dart
        repositories/
          auth_repository_impl_test.dart
      domain/
        usecases/
          login_usecase_test.dart
      presentation/
        providers/
          auth_provider_test.dart
  core/
    api/
      api_client_test.dart
    errors/
      failure_test.dart
```

### Nomenclatura

Los nombres de los tests se escriben en **espanol** para facilitar la lectura de reportes:

```dart
void main() {
  group('LoginUsecase', () {
    test('deberia retornar un User cuando las credenciales son correctas', () async {
      // arrange
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => Result.success(testUser));

      // act
      final result = await loginUsecase(email: 'test@test.com', password: '123456');

      // assert
      expect(result.isSuccess, true);
      expect(result.data, testUser);
    });

    test('deberia retornar AuthFailure cuando las credenciales son incorrectas', () async {
      // ...
    });
  });
}
```

### Mocks con mocktail

```dart
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockApiClient extends Mock implements ApiClient {}
```

### Patron AAA (Arrange-Act-Assert)

Todos los tests siguen el patron AAA con comentarios:

```dart
test('descripcion del caso', () async {
  // arrange - preparar datos y mocks
  final mockRepo = MockAuthRepository();
  when(() => mockRepo.login(...)).thenAnswer(...);

  // act - ejecutar la accion
  final result = await usecase.call(...);

  // assert - verificar resultados
  expect(result.isSuccess, true);
  verify(() => mockRepo.login(...)).called(1);
});
```

### Ejecutar tests

```bash
# Todos los tests
flutter test

# Un archivo especifico
flutter test test/features/auth/domain/usecases/login_usecase_test.dart

# Con coverage
flutter test --coverage
```

---

## 9. Checklist de Code Review

Antes de enviar un PR o merge, verificar cada punto:

### Textos y UI
- [ ] Tildes correctas en **todos** los textos visibles al usuario
- [ ] Signos de apertura en preguntas (`¿...?`) y exclamaciones (`¡...!`)
- [ ] Sin colores hardcodeados (`Colors.xxx`, `Color(0xFF...)`) -- usar `AppColors` o `Theme.of(context)`
- [ ] Sin estilos de texto hardcodeados -- usar `Theme.of(context).textTheme`
- [ ] Strings en archivos de localizacion (o al menos, no hardcodeados en el widget)

### Arquitectura
- [ ] Clean Architecture respetada: `presentation -> domain <- data`
- [ ] Entities puras (sin imports de paquetes)
- [ ] Models con `fromJson`/`toJson` que extienden entity
- [ ] Repository interface en `domain/`, implementacion en `data/`
- [ ] Datasource solo se usa desde el repository impl, nunca desde presentation

### Estado y logica
- [ ] Estado de loading manejado (mostrar indicador de carga)
- [ ] Estado de error manejado (mostrar mensaje al usuario)
- [ ] Estado vacio manejado (empty state con mensaje descriptivo)
- [ ] `Result.when()` usado para manejar exito/fallo en notifiers
- [ ] No hay logica de negocio en la UI (screens/widgets)

### Calidad de codigo
- [ ] Sin `print()` en codigo de produccion -- usar `debugPrint()` en debug o un logger
- [ ] Constructores `const` donde sea posible
- [ ] Widgets `const` donde sea posible
- [ ] Archivos nombrados en snake_case
- [ ] Clases nombradas en PascalCase
- [ ] Imports organizados (dart > flutter > packages > relativos)

### Seguridad
- [ ] Tokens almacenados en `flutter_secure_storage` (nunca SharedPreferences)
- [ ] Sin datos sensibles en logs
- [ ] Sin API keys hardcodeadas en el codigo

---

## 10. Dependencias

### Dependencias principales y su proposito

| Paquete | Version | Proposito |
|---|---|---|
| **flutter_riverpod** | ^2.5.1 | State management (providers, notifiers) |
| **riverpod_annotation** | ^2.3.5 | Generacion de codigo para Riverpod |
| **dio** | ^5.4.1 | Cliente HTTP (reemplaza http package) |
| **go_router** | ^14.0.2 | Navegacion declarativa con deep links |
| **json_annotation** | ^4.8.1 | Anotaciones para serializacion JSON |
| **firebase_core** | ^2.27.0 | Core de Firebase (requerido por otros paquetes Firebase) |
| **firebase_messaging** | ^14.7.15 | Push notifications |
| **google_sign_in** | ^6.2.1 | Autenticacion con Google |
| **image_picker** | ^1.0.7 | Seleccion de fotos (camara/galeria) |
| **cached_network_image** | ^3.3.1 | Cache de imagenes de red |
| **flutter_secure_storage** | ^9.0.0 | Almacenamiento seguro (tokens, datos sensibles) |
| **geolocator** | ^11.0.0 | Obtencion de ubicacion GPS |
| **google_maps_flutter** | ^2.6.0 | Mapas de Google (tracking, seleccion de direccion) |
| **shimmer** | ^3.0.0 | Efecto de carga skeleton/shimmer |
| **flutter_rating_bar** | ^4.0.1 | Widget de estrellas para calificaciones |
| **google_fonts** | ^6.2.1 | Tipografia Poppins y otras fuentes |
| **socket_io_client** | ^2.0.3+1 | WebSocket para tracking en tiempo real |
| **intl** | ^0.19.0 | Formato de fechas, numeros, moneda (es_CO) |
| **flutter_localizations** | SDK | Soporte de idiomas de Material/Cupertino |

### Dev dependencies

| Paquete | Version | Proposito |
|---|---|---|
| **flutter_test** | SDK | Framework de testing |
| **flutter_lints** | ^4.0.0 | Reglas de linting |
| **build_runner** | ^2.4.8 | Generacion de codigo (json_serializable, riverpod) |
| **json_serializable** | ^6.7.1 | Generador de fromJson/toJson |
| **riverpod_generator** | ^2.4.0 | Generador de providers con anotaciones |

### Proceso para agregar una nueva dependencia

1. **Justificar**: Verificar que no haya una solucion con las dependencias actuales
2. **Evaluar**: Revisar en pub.dev:
   - Puntaje (likes, pub points, popularity)
   - Fecha de ultima actualizacion (no mas de 6 meses sin actividad)
   - Compatibilidad con la version de Flutter/Dart del proyecto
   - Licencia compatible (MIT, BSD, Apache)
   - Soporte de null safety
3. **Probar en rama**: Instalar en una rama separada y verificar que no rompa builds
4. **Agregar con version acotada**: Usar `^` para minor updates automaticos

```bash
# Agregar dependencia
flutter pub add nombre_paquete

# Agregar dev dependency
flutter pub add --dev nombre_paquete

# Verificar que todo compile
flutter pub get && flutter analyze
```

5. **Documentar** en la tabla de arriba si es una dependencia principal

---

## Apendice: Comandos Utiles

```bash
# Ejecutar la app en dispositivo conectado (modo debug)
flutter run

# Generar codigo (json_serializable, riverpod_generator)
dart run build_runner build --delete-conflicting-outputs

# Generar codigo en modo watch (regenera al guardar)
dart run build_runner watch --delete-conflicting-outputs

# Analisis estatico
flutter analyze

# Formatear codigo
dart format lib/ test/

# Limpiar cache de build
flutter clean && flutter pub get

# Generar archivos de localizacion
flutter gen-l10n
```

---

## Apendice: Configuracion del Entorno de Desarrollo

### Variables importantes

- **API Base URL (dev):** `http://192.168.10.7:3000/v1` (definido en `AppConstants`)
- **API Base URL (prod):** `https://api.tavuel.com/v1`
- **Backend:** NestJS sobre Fastify, puerto 3000
- **Base de datos:** PostgreSQL (via Prisma en el backend)

### Estructura del monorepo Tavuel

```
C:/Dev/Tavuel/
  Tavuel-App/           # <-- Este proyecto (Flutter)
  Tavuel-Back/          # Backend NestJS
  Tavuel-Front/         # Admin panel Next.js
  Tavuel-Architecture/  # Documentacion de arquitectura
```

### OneDrive

**NUNCA** desarrollar dentro de OneDrive. El proyecto vive en `C:/Dev/Tavuel/` para
evitar problemas de:
- Archivos marcados como Hidden (Gradle los ignora)
- Bloqueo de archivos `.dll.node` (Prisma)
- Conflictos de sincronizacion
