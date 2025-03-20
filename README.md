# AppFramework

Фреймворк для iOS приложений, обеспечивающий функционал WebView с предварительной обработкой и сбором данных устройства.

## Требования

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Установка

### Swift Package Manager

1. В Xcode выберите File → Add Packages...
2. Вставьте URL репозитория в поле поиска
3. Выберите версию фреймворка
4. Нажмите Add Package

### Ручное добавление

1. Скопируйте папку `AppFramework` в ваш проект
2. В Xcode выберите ваш проект в навигаторе
3. Выберите ваш таргет
4. Во вкладке "General" в секции "Frameworks, Libraries, and Embedded Content" нажмите "+"
5. Выберите `AppFramework.framework`

## Настройка

### Info.plist

Добавьте следующие разрешения в Info.plist вашего проекта:

```xml
<!-- Push Notifications -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>Приложение запрашивает доступ к камере для работы с веб-контентом</string>

<!-- Microphone Permission -->
<key>NSMicrophoneUsageDescription</key>
<string>Приложение запрашивает доступ к микрофону для работы с веб-контентом</string>

<!-- Location Permission -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Приложение запрашивает доступ к геолокации для работы с веб-контентом</string>
```

## Использование

### Инициализация

```swift
import SwiftUI
import AppFramework

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        await AppFramework.shared.initialize()
                    }
                }
        }
    }
}
```

### Использование WebView компонента

```swift
import SwiftUI
import AppFramework

struct ContentView: View {
    var body: some View {
        WebViewComponent()
    }
}
```

## Функционал

Фреймворк автоматически:

1. Останавливает все процессы при первом запуске
2. Собирает данные с устройства:
   - APNS token
   - Attribution token
   - Bundle ID
3. Формирует домен на основе bundle ID
   - Пример: bundle_id "com.example.app" → домен "comexampleapp.top"
4. Отправляет запрос на сервер
5. Обрабатывает ответ:
   - При получении URL открывает WebView
   - При пустом ответе продолжает работу приложения
6. Кэширует данные для последующих запусков

## Особенности

- Таймаут на сбор данных: 10 секунд
- Автоматическое кэширование WebView контента
- Поддержка поворота экрана
- Автоматический запрос необходимых разрешений
- Поддержка работы с камерой в WebView
- Скрытый Status Bar
- Черная Safe Area

## Отладка

Для отслеживания процесса инициализации и работы фреймворка, проверьте консоль Xcode на наличие сообщений с префиксом "AppFramework:".

## Известные проблемы

1. WebView может не загружаться если устройство не имеет подключения к интернету
2. Push-уведомления могут не работать на симуляторе

## Поддержка

При возникновении проблем или вопросов, создайте issue в репозитории проекта.

## Лицензия

AppFramework доступен под лицензией MIT. Подробности в файле LICENSE.