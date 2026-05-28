# Development Guide — SOS Semantic Cloud MVP

Руководство для разработчиков, работающих над расширением проекта.

---

## 🏗️ Структура проекта (v0.1.1)

```
sos_semantic_cloud_mvp/
├── scripts/
│   ├── simulation.gd              # Ядро симуляции (157 строк)
│   ├── word_node.gd               # Модель слова (55 строк)
│   ├── meaning_cloud.gd           # Модель облака (71 строк)
│   ├── context_field.gd           # Контекстный ветер (34 строк)
│   ├── semantic_dictionary.gd     # Словарь данных (46 строк)
│   ├── main.gd                    # Entry point (39 строк)
│   ├── ui_controller.gd           # UI логика (50 строк) ✨ УЛУЧШЕНО
│   ├── word_node_view.gd          # Визуализация слова (26 строк)
│   ├── meaning_cloud_view.gd      # Визуализация облака (30 строк)
│   ├── save_manager.gd            # Сохранение/загрузка (110 строк) 🆕
│   ├── test_runner.gd             # Юнит-тесты (150 строк) 🆕
│   └── demo_runner.gd             # Демонстрация (105 строк) 🆕
│
├── scenes/
│   ├── Main.tscn                  # Главная сцена
│   ├── WordNode.tscn              # Шаблон слова
│   ├── MeaningCloud.tscn          # Шаблон облака с шейдером
│   └── UI.tscn                    # Интерфейс ✨ УЛУЧШЕНО
│
├── assets/
│   ├── shaders/
│   │   └── cloud_shader.gdshader  # CanvasItem шейдер
│   └── icons/
│       └── icon.svg               # Иконка проекта
│
├── data/
│   └── meanings_ru.json           # Семантический словарь
│
├── docs/
│   ├── README.md                  # Обзор проекта ✨ УЛУЧШЕНО
│   ├── USAGE.md                   # Руководство использования 🆕
│   ├── codebase-guide.md          # Архитектура
│   ├── data-layer.md              # Структура данных
│   ├── conventions.md             # Стиль кода
│   ├── DEVELOPMENT.md             # Этот файл 🆕
│   ├── CLAUDE.md                  # Заметки AI
│   └── .doc-index.json            # Индекс документации
│
├── project.godot                  # Конфиг Godot ✨ ОБНОВЛЕНО
├── CHANGELOG.md                   # История версий 🆕
├── README.md                      # Главный README ✨ ОБНОВЛЕНО
├── .gitignore
└── .git/
```

**Всего:** 800+ строк GDScript + 15 КБ документации

---

## 🧠 Архитектура и паттерны

### Model-View-Controller

```
┌─────────────────────────────────────────────────┐
│           VIEW LAYER (Presentation)             │
│  • WordNodeView.tscn → word_node_view.gd       │
│  • MeaningCloud.tscn → meaning_cloud_view.gd   │
│  • UI.tscn → ui_controller.gd                  │
└──────────────────┬──────────────────────────────┘
                   │ signals & callbacks
┌──────────────────▼──────────────────────────────┐
│       CONTROL LAYER (Logic & Events)            │
│  • main.gd (orchestration)                     │
│  • ui_controller.gd (UI handling)              │
│  • save_manager.gd (persistence)               │
│  • test_runner.gd (testing)                    │
│  • demo_runner.gd (demos)                      │
└──────────────────┬──────────────────────────────┘
                   │ queries & commands
┌──────────────────▼──────────────────────────────┐
│         MODEL LAYER (Pure Data & Logic)         │
│  • Simulation (singleton — autoload)           │
│  • ContextField (singleton — autoload)         │
│  • SemanticDictionary (singleton — autoload)   │
│  • WordNode (RefCounted class)                 │
│  • MeaningCloud (RefCounted class)             │
└─────────────────────────────────────────────────┘
```

### RefCounted vs Node

**RefCounted модели** (независимы от сцены):
- `WordNode` — хранит текст, позицию, массив облаков
- `MeaningCloud` — хранит позицию, вес, энтропию, тип

**Node представления** (привязаны к сцене):
- `WordNodeView` — рисует label, отслеживает модель
- `MeaningCloudView` — рисует sprite, применяет шейдер

**Autoload синглтоны** (глобальный доступ):
- `Simulation` — основной цикл
- `ContextField` — контекстный ветер
- `SemanticDictionary` — словарь
- `SaveManager` — сохранение (v0.1.1+)

---

## 🔄 Цикл симуляции

```gdscript
# main.gd._process(_delta)
1. context.update()                           # Обновить контекстный ветер
2. simulation.step(context)                   # Один шаг симуляции
   ├─ for each word in words:
   │  ├─ for each cloud in word.clouds:
   │  │  ├─ _apply_context_force(cloud, ctx)  # Применить силу
   │  │  ├─ _update_weight_and_entropy()      # Обновить параметры
   │  │  └─ _update_position()                # Обновить позицию
   │  └─ _detect_precipitation(word)          # Проверить на осадки
3. simulation.render()                        # Hook для глобальных оверлеев
```

**Частота:** 60 FPS (Godot стандарт)  
**На каждый кадр:** ~100-200 облаков обновляется

---

## 📊 Типы данных

### MeaningCloud API

```gdscript
# Создание
var cloud = MeaningCloud.new("истина", 0.25, 0.6, Vector2(100, 100), "abstract")

# Чтение
cloud.label              # "истина" → String
cloud.position           # Vector2(100, 100) → Vector2
cloud.weight             # 0.25 → float (0.0-1.0)
cloud.entropy            # 0.6 → float (0.0-1.0, неопределённость)
cloud.cloud_type         # CloudType.ABSTRACT → enum

# Операции
cloud.apply_force(Vector2(1, 0))  # Применить физическую силу
cloud.drift_distance()            # Расстояние от начальной позиции
cloud.stability()                 # weight * (1.0 - entropy)
```

### WordNode API

```gdscript
# Создание
var word = WordNode.new("свет", Vector2(200, 200))

# Управление облаками
word.add_cloud("истина", 0.25, 0.6, Vector2(100, 100), "abstract")
word.meaning_clusters  # Array[MeaningCloud]

# Анализ
word.dominant_cloud()  # → MeaningCloud (с наивысшим score)
word.system_entropy()  # → float (средняя энтропия всех облаков)
```

### Simulation API

```gdscript
# Добавление/удаление
var word = Simulation.add_word("свет")
Simulation.remove_word("свет")
var found = Simulation.get_word("свет")

# Данные
Simulation.words  # Array[WordNode]
Simulation.frame_count  # int

# Метрики
var metrics = Simulation.system_metrics()
# → {word_count, cloud_count, system_entropy, avg_weight, frame, precipitation_count}

# Экспорт
var state = Simulation.export_state()
# → {version, frame, timestamp, words, metrics, precipitation_log}

# События
Simulation.word_added.connect(func(word: WordNode): ...)
Simulation.word_removed.connect(func(text: String): ...)
Simulation.precipitation_detected.connect(func(word, meaning, weight, entropy): ...)
```

### SaveManager API

```gdscript
# Сохранение
SaveManager.save_state("my_sim")          # → bool
SaveManager.export_json("results")         # → bool

# Загрузка
SaveManager.load_state("simulation_my_sim.json")  # → bool
var saves = SaveManager.list_saves()       # → Array[String]

# Места сохранения
# Windows: %APPDATA%/Godot/app_userdata/SOS Semantic Cloud MVP/sos_saves/
# macOS: ~/Library/Application Support/Godot/app_userdata/.../sos_saves/
# Linux: ~/.local/share/godot/app_userdata/.../sos_saves/
```

---

## 🛠️ Расширение функциональности

### Добавление нового типа облака

1. **Добавить тип в enum** (`meaning_cloud.gd`):

```gdscript
enum CloudType {
    ABSTRACT, PRACTICAL, CONFLICT, METAPHOR, TECHNICAL, NEUTRAL,
    QUANTUM  # ← новый тип
}
```

2. **Добавить парсер** (`meaning_cloud.gd._parse_type`):

```gdscript
"quantum": return CloudType.QUANTUM
```

3. **Добавить визуализацию** (`meaning_cloud_view.gd._update_visuals`):

```gdscript
MeaningCloud.CloudType.QUANTUM: color = Color.CYAN
```

4. **Добавить в словарь** (`data/meanings_ru.json`):

```json
{
    "label": "пример",
    "type": "quantum",
    "weight": 0.5,
    "entropy": 0.5,
    "keywords": ["квант", "волна"]
}
```

---

## 🧪 Тестирование

### Запуск тестов

```bash
# 1. Добавить TestRunner в Main.tscn как первый дочерний узел
# 2. Запустить проект (F5)
# 3. Проверить консоль Output
```

### Написание нового теста

```gdscript
# В test_runner.gd добавить новый метод:

func test_my_feature() -> void:
    print("[Test] My Feature")
    
    # Arrange
    var value = some_operation()
    
    # Act & Assert
    _assert(value == expected, "Description", "(got: %s)" % value)
    
    print()  # Blank line
```

### Виды тестов

- ✓ **Unit Tests** — отдельные компоненты (`test_runner.gd`)
- 🟡 **Integration Tests** — взаимодействие компонентов (в разработке)
- 🟡 **Performance Tests** — нагрузочное тестирование (в разработке)

---

## 📝 Стиль кода

### Соглашения

```gdscript
# Классы — PascalCase
class_name WordNode

# Файлы — snake_case
# word_node.gd

# Переменные — snake_case
var dominant_cloud: MeaningCloud
var bias_keywords: Array[String]

# Константы — UPPER_SNAKE_CASE
const WEIGHT_THRESHOLD: float = 0.85
const MAX_TRAIL_LENGTH: int = 60

# Функции — snake_case
func add_word(text: String) -> WordNode:
    pass

# Типизация всегда
func apply_force(force: Vector2) -> void:
    pass

# Сигналы — snake_case (глаголы)
signal word_added(word: WordNode)
signal precipitation_detected(word: String, meaning: String)
```

### Документирование

```gdscript
## Краткое описание класса или функции.
## Может быть многострочным.
##
## Длинное описание с деталями реализации и примерами использования.
extends Node

## Имя переменной — тип и смысл.
var frame_count: int = 0

func example_function(param: String) -> Dictionary:
    ## Документация функции в docstring формате.
    pass
```

---

## 🔍 Отладка

### Логирование

Все компоненты выводят информацию с префиксом:

```gdscript
print("[ComponentName] Message")
print("[Simulation] Added 'свет': 4 clouds spawned")
print("[ContextField] Wind set → dir=(1, 0) strength=0.70")
print("[Precipitation] Frame 1423: свет → 'истина' (w=0.90 e=0.18)")
```

### Просмотр метрик

```gdscript
# Вывести состояние симуляции
var state = Simulation.export_state()
print(JSON.stringify(state, "\t"))

# Отслеживать метрики каждый кадр
func _process(_delta):
    var m = Simulation.system_metrics()
    print("Frame %d: %d слов, %d облаков, энтропия %.2f" %
        [m["frame"], m["word_count"], m["cloud_count"], m["system_entropy"]])
```

### Профилирование

1. Запустить проект
2. Debugger → Profiler tab
3. Найти узкие места в `step()` и `apply_force()`

---

## 🚀 Оптимизация

### Текущие ограничения

- ~20 слов (80-100 облаков) работают на 60 FPS
- ~50 слов требуют оптимизации
- ~100+ слов нуждаются в spatial hashing

### Возможные улучшения

1. **Spatial Hashing** — разделить пространство на ячейки
2. **Object Pooling** — переиспользовать облака вместо создания/удаления
3. **Culling** — не обновлять невидимые облака
4. **Multi-threading** — параллельное обновление облаков (если поддерживается)

---

## 📚 Ресурсы

- [Godot 4 Docs](https://docs.godotengine.org/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
- [Project Documentation](docs/)

---

## 📋 Чек-лист для контрибьюторов

- [ ] Fork репозитория
- [ ] Создать branch: `git checkout -b feature/my-feature`
- [ ] Внести изменения с комментариями
- [ ] Запустить тесты: убедиться в TestRunner
- [ ] Обновить документацию
- [ ] Обновить CHANGELOG.md
- [ ] Commit: `git commit -m "Add: my feature"`
- [ ] Push: `git push origin feature/my-feature`
- [ ] Создать Pull Request

---

**Версия:** v0.1.1  
**Последнее обновление:** 2026-05-28
