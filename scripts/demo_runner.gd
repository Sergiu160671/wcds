## DemoRunner — автоматическая демонстрация возможностей симуляции.
extends Node

var demo_enabled: bool = true
var demo_step: int = 0
var demo_timer: float = 0.0
var demo_interval: float = 2.0  # 2 секунды между шагами


func _ready() -> void:
	if not demo_enabled:
		return
	
	print("\n=== SOS Demo Mode ===\n")
	print("Демонстрация начнётся через 3 секунды...")
	print("Слова будут добавляться автоматически с демонстрацией контекстного ветра.\n")
	
	await get_tree().create_timer(3.0).timeout
	_start_demo()


func _process(delta: float) -> void:
	if not demo_enabled:
		return
	
	demo_timer += delta
	if demo_timer >= demo_interval:
		demo_timer = 0.0
		_next_demo_step()


func _start_demo() -> void:
	print("\n[Demo] Начало демонстрации\n")
	demo_step = 0


func _next_demo_step() -> void:
	match demo_step:
		0:
			print("[Demo] Этап 1: Добавление слов")
			Simulation.add_word("свет")
			Simulation.add_word("тьма")
			Simulation.add_word("война")
			demo_step += 1
		
		1:
			print("[Demo] Этап 2: Установка контекста 'наука'")
			ContextField.configure(Vector2.RIGHT, 0.6, ["наука", "излучение", "волна"])
			demo_step += 1
		
		2:
			print("[Demo] Этап 3: Слова дрейфуют под контекстным ветром...")
			print("      (Облака смещаются в соответствии с фильтром)")
			demo_step += 1
		
		3:
			print("[Demo] Этап 4: Смена контекста на 'борьба'")
			ContextField.configure(Vector2.LEFT, 0.7, ["конфликт", "война", "соперничество"])
			demo_step += 1
		
		4:
			print("[Demo] Этап 5: Добавление слова 'огонь'")
			Simulation.add_word("огонь")
			demo_step += 1
		
		5:
			print("[Demo] Этап 6: Показ статистики")
			_print_stats()
			demo_step += 1
		
		6:
			print("[Demo] Этап 7: Очистка контекста")
			ContextField.configure(Vector2.RIGHT, 0.0, [])
			demo_step += 1
		
		7:
			print("[Demo] Этап 8: Финальная статистика и осадки смысла")
			_print_final_stats()
			demo_step += 1
		
		8:
			print("[Demo] Этап 9: Сохранение состояния")
			SaveManager.save_state("demo_session")
			print("      ✓ Состояние сохранено в user://sos_saves/\n")
			demo_step += 1
		
		9:
			print("[Demo] Демонстрация завершена!")
			print("      Вы можете продолжить эксперименты в интерактивном режиме.\n")
			demo_enabled = false


func _print_stats() -> void:
	var metrics = Simulation.system_metrics()
	print("\n📊 Текущие метрики:")
	print("   Слов в симуляции: %d" % metrics.get("word_count", 0))
	print("   Облаков значений: %d" % metrics.get("cloud_count", 0))
	print("   Энтропия системы: %.3f" % metrics.get("system_entropy", 0))
	print("   Средний вес облаков: %.3f" % metrics.get("avg_weight", 0))
	print()


func _print_final_stats() -> void:
	var metrics = Simulation.system_metrics()
	var log = Simulation.precipitation_log
	
	print("\n🎯 Финальная статистика:")
	print("   Слов: %d" % metrics.get("word_count", 0))
	print("   Облаков: %d" % metrics.get("cloud_count", 0))
	print("   Кадров: %d" % metrics.get("frame", 0))
	print("   Осадков смысла: %d" % metrics.get("precipitation_count", 0))
	
	if log.size() > 0:
		print("\n   📍 Зафиксированные смыслы:")
		for entry in log:
			print("      • %s → '%s' (вес: %.2f)" % [entry["word"], entry["meaning"], entry["weight"]])
	print()
