import random

class CSPLivelockEmulator:
    def __init__(self):
        # Локальные флаги намерений процессов (находятся в изолированных памятях)
        self.p1_intent = False
        self.p2_intent = False
        
        # Счетчик полезной работы, выполненной системой
        self.useful_work_done = 0
        self.trace = []

    def run_simulation(self, steps=20):
        for tick in range(steps):
            self.trace.append(f"\n--- ТАКТ {tick} ---")
            
            # На каждом такте планировщик железа заставляет процессы принимать решения.
            # Мы симулируем идеальную симметрию шагов (худший сценарий для ливлока)
            
            # Шаг 1: Оба процесса одновременно заявляют о намерении занять ресурс
            self.p1_intent = True
            self.p2_intent = True
            self.trace.append("🤖 [P1]: Выставил флаг НАМЕРЕНИЯ = TRUE")
            self.trace.append("🤖 [P2]: Выставил флаг НАМЕРЕНИЯ = TRUE")
            
            # Шаг 2: Вежливый алгоритм разрешения конфликтов Хоара
            # Каждый процесс смотрит на флаг оппонента. Если оппонент тоже хочет,
            # мы вежливо сбрасываем свой флаг (уступаем дорогу), чтобы избежать дедлока.
            p1_sees_p2 = self.p2_intent
            p2_sees_p1 = self.p1_intent
            
            if p1_sees_p2 and p2_sees_p1:
                self.trace.append("⚠️ [КОНФЛИКТ]: Оба видят намерения друг друга!")
                
                # Внутренний τ-шаг: уступаем дорогу
                self.p1_intent = False
                self.p2_intent = False
                self.trace.append("🔄 [P1]: (τ-шаг) Вежливо сбросил флаг в FALSE")
                self.trace.append("🔄 [P2]: (τ-шаг) Вежливо сбросил флаг in FALSE")
            else:
                # Если конфликта нет, кто-то один успевает сделать полезную работу
                if self.p1_intent:
                    self.useful_work_done += 1
                    self.trace.append("🎉 [P1]: Захватил ресурс и сделал ПОЛЕЗНУЮ РАБОТУ!")
                    self.p1_intent = False
                elif self.p2_intent:
                    self.useful_work_done += 1
                    self.trace.append("🎉 [P2]: Захватил ресурс и сделал ПОЛЕЗНУЮ РАБОТУ!")
                    self.p2_intent = False
                    
        return self.useful_work_done, self.trace

# Запуск
emu = CSPLivelockEmulator()
work, log = emu.run_simulation(steps=10)
print("\n".join(log))
print(f"\n📊 Финальный результат: выполнено тактов: 10, Полезной работы: {work}")
