import random

class MicroVMWithCAS:
    def __init__(self):
        # Общая ячейка памяти, за которую борются потоки
        self.shared_var = "A"
        
        # Локальные регистры потоков
        self.t1_expected = None
        self.t2_expected = None
        
        self.trace = []
        self.aba_detected = False

    def atomic_cas(self, expected, new_val):
        """Аппаратный CAS на уровне транзисторов шины процессора"""
        if self.shared_var == expected:
            self.shared_var = new_val
            return True
        return False

    def run_aba_simulation(self):
        self.trace.append("=== СТАРТ СИМУЛЯЦИИ LOCK-FREE ===")
        self.trace.append(f"Начальное состояние памяти: {self.shared_var}")

        # Такт 1: Поток 1 считывает текущее значение для последующего CAS
        self.t1_expected = self.shared_var
        self.trace.append(f"⏱️ [T1]: Считал значение '{self.t1_expected}'. Планирует заменить его на 'C'.")

        # ПЛАНИРОВЩИК ВЫТЕСНЯЕТ ПОТОК 1 (Конкуренция)
        self.trace.append("⚠️ [ПЛАНИРОВЩИК]: Переключил контекст на Поток 2.")

        # Такт 2: Поток 2 делает быстрый Lock-Free шаг A -> B
        self.t2_expected = self.shared_var # Считал 'A'
        if self.atomic_cas(self.t2_expected, "B"):
            self.trace.append(f"🔄 [T2]: Успешный CAS! Заменил '{self.t2_expected}' на 'B'. Память = {self.shared_var}")

        # Такт 3: Поток 2 (или внешняя среда) делает шаг обратно B -> A
        self.t2_expected = self.shared_var # Считал 'B'
        if self.atomic_cas(self.t2_expected, "A"):
            self.trace.append(f"🔄 [T2]: Успешный CAS! Вернул '{self.t2_expected}' обратно в 'A'. Память = {self.shared_var}")

        # ПЛАНИРОВЩИК ВОЗВРАЩАЕТ ПОТОК 1
        self.trace.append("⚠️ [ПЛАНИРОВЩИК]: Вернул контекст Потоку 1.")

        # Такт 4: Поток 1 просыпается и выполняет свой CAS, думая, что ничего не произошло
        success = self.atomic_cas(self.t1_expected, "C")
        
        if success:
            self.trace.append(f"💥 [T1]: Успешный CAS! Заменил '{self.t1_expected}' на 'C'. Память = {self.shared_var}")
            self.trace.append("🚨 ВНИМАНИЕ: ABA-состояние сработало! Поток 1 не заметил скрытых изменений!")
            self.aba_detected = True
        else:
            self.trace.append("❌ [T1]: CAS отклонен! Память изменилась.")

        return self.aba_detected, self.trace

# Запуск лабораторной
vm = MicroVMWithCAS()
is_bug, log = vm.run_aba_simulation()
print("\n".join(log))

