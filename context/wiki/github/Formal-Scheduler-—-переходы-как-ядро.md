# Formal Scheduler — переходы как ядро

## 1. Главная идея

Планировщик не должен мыслиться как механизм, который в основном отвечает на вопрос:

> когда запустить задачу?

Это слишком узко.

Главный вопрос:

> при каких условиях система может перейти из одного состояния в другое?

Время — только одно из возможных условий перехода.

Поэтому базовая модель должна строиться не вокруг таймеров, а вокруг:

```text
State
+
Event
+
Condition
+
Transition
```

или более явно:

```text
Current State
+ Observable Facts
+ Transition Rules
→ Set of Admissible Transitions
```

После этого отдельная policy выбирает один из допустимых переходов.

Ключевое разделение:

```text
admissibility ≠ selection ≠ temporal obligation
```

---

## 2. Что является ядром

Центральный объект системы — автомат задачи или процесса.

Например:

```text
Created
  ↓
Waiting
  ↓
Runnable
  ↓
Running
  ↓
Completed
```

с альтернативами:

```text
Running → Failed
Running → Cancelled
Running → LeaseExpired
Waiting → Cancelled
Runnable → Cancelled
```

Каждый переход должен иметь:

```text
source state
target state
guard / condition
event / cause
side effects
observable record
```

Пример:

```text
Waiting
+
current_time >= wakeup_at
→ Runnable
```

Другой пример:

```text
Waiting
+
dependency_A == Completed
→ Runnable
```

Ещё один:

```text
Running
+
lease_deadline < now
→ LeaseExpired
```

То есть время, зависимости, ресурсы, состояние worker и внешние события — это всё разные условия одного и того же механизма переходов.

---

## 3. Почему таймер — не фундамент

Обычный scheduler часто строится примерно так:

```text
time
→ timer fired
→ run job
```

Наша модель шире:

```text
state
+
facts
+
rules
→ admissible transition
```

Поэтому cron становится лишь частным случаем:

```text
current_time ∈ schedule
→ переход допустим
```

Точно так же dependency scheduler:

```text
A == Completed
→ B may become Runnable
```

Resource scheduler:

```text
cpu_available >= required_cpu
→ Dispatch allowed
```

Mutual exclusion:

```text
Running(A)
→ Running(B) forbidden
```

Retry:

```text
Failed(task)
∧ retry_count < retry_limit
→ Waiting
```

Таким образом, scheduler превращается из системы таймеров в **машину допустимых переходов**.

---

## 4. Минимальный автомат задачи

Первое приближение:

```text
Created
Waiting
Runnable
Running
Completed
Failed
Cancelled
LeaseExpired
```

Необязательно вводить всё сразу.

Минимальный первый набор:

```text
Created
Waiting
Runnable
Running
Completed
Failed
```

Пример переходов:

```text
Created → Waiting
Waiting → Runnable
Runnable → Running
Running → Completed
Running → Failed
```

Но сами стрелки ничего не значат без правил.

Например:

```text
Created → Waiting
when task registered successfully
```

```text
Waiting → Runnable
when all transition guards are satisfied
```

```text
Runnable → Running
when worker acquires execution lease
```

```text
Running → Completed
when worker reports successful completion
```

```text
Running → Failed
when task execution fails
```

---

## 5. Время как guard

Таймеры остаются важными, но теперь занимают правильное место.

Возможные временные guards:

```text
now >= run_at
```

```text
now >= retry_at
```

```text
now >= lease_deadline
```

```text
now > deadline
```

```text
elapsed_since(event) >= duration
```

То есть time subsystem не запускает задачи сам.

Он только изменяет набор фактов системы, после чего некоторые переходы становятся допустимыми.

Концептуально:

```text
Time advances
→ facts change
→ guards are re-evaluated
→ new transitions become admissible
```

---

## 6. Граф задач

Граф не нужно делать фундаментом scheduler.

Граф возникает из отношений между автоматами.

Например:

```text
A.Completed
→ B.Waiting → B.Runnable
```

или:

```text
A.Completed ∧ C.Completed
→ B.Runnable
```

или:

```text
A.Completed ∨ C.Completed
→ B.Runnable
```

Таким образом, dependency graph — это не отдельный scheduler.

Это набор transition conditions между задачами.

Позже можно получить:

```text
AND dependencies
OR dependencies
barriers
fork/join
mutual exclusion
resource dependencies
conditional branches
```

---

## 7. Selection policy

После вычисления допустимых переходов может оказаться, что их несколько:

```text
T1: A Runnable → Running
T2: B Runnable → Running
T3: C Waiting → Runnable
```

Transition algebra говорит:

```text
T1 allowed
T2 allowed
T3 allowed
```

Но она не обязана решать, какой запускать первым.

Для этого существует отдельная selection policy:

```text
FIFO
priority
deadline
fairness
weighted fairness
shortest task
resource locality
custom policy
```

Главный принцип:

> policy может выбирать только среди допустимых переходов.

Она не может сделать запрещённый переход допустимым.

---

## 8. Сетевой протокол

Сеть должна быть транспортом к семантике scheduler, а не определять её.

Минимальные операции:

```text
submit
cancel
query
subscribe/events
stats
```

Например:

```text
submit(task)
→ task registered
→ Created
```

После этого автомат и transition rules определяют дальнейшую жизнь задачи.

Особенно важно строго определить значение acknowledgement.

Например:

```text
accepted
```

может означать:

1. пакет получен;
2. команда распознана;
3. задача зарегистрирована;
4. задача сохранена устойчиво;
5. система принимает обязательство не потерять задачу.

Это разные семантики.

---

## 9. Worker и lease

Нельзя связывать выполнение задачи с worker навечно.

Лучше рассматривать:

```text
Runnable
+
worker available
→ Running(worker, lease_until)
```

Worker получает временное право исполнения.

Если:

```text
now > lease_until
```

то:

```text
Running → LeaseExpired
```

После этого задача может:

```text
LeaseExpired → Runnable
```

или:

```text
LeaseExpired → Failed
```

в зависимости от правил.

Это особенно важно для будущей распределённости.

---

## 10. Event History

История должна быть объектом первого класса.

Пример:

```text
Task #42

10:00 Created
10:00 Waiting
10:05 Runnable
10:05 Running(worker=7)
10:05 Completed
```

Запись должна отражать:

```text
task
old_state
new_state
cause
timestamp
relevant context
```

Например:

```text
{
  task: 42,
  from: Waiting,
  to: Runnable,
  cause: TimerReached,
  at: ...
}
```

История нужна не только для debugging.

Она является наблюдаемой execution trace, на которой можно проверять temporal properties.

---

## 11. Temporal logic

Temporal logic описывает уже не отдельный переход, а свойства последовательностей переходов.

Например safety:

```text
Running(task)
→ task must not simultaneously be Running on another worker
```

Liveness:

```text
Runnable(task)
→ eventually Running(task)
```

или:

```text
Running(task)
→ eventually
Completed(task)
or Failed(task)
or LeaseExpired(task)
```

При этом liveness всегда требует явных assumptions:

```text
worker eventually available
scheduler progresses
network not permanently partitioned
etc.
```

---

## 12. Распределённость

Распределённость не должна создавать новую семантику задач.

Она должна распределить уже определённый transition system.

Нужно будет решить:

```text
who owns state?
who may perform transition?
how transitions are serialized?
what happens after partition?
what happens after node crash?
how duplicate commands are detected?
```

Особенно важны:

```text
task identity
idempotency
lease
state ownership
event ordering
recovery
```

---

## 13. Марков, Вирт, Рефал

Эти системы не стоит встраивать непосредственно в scheduler loop.

Более естественная роль:

```text
rule source
↓
Wirth parser
↓
Markov normalization
↓
Refal structural transformation
↓
internal transition representation
↓
scheduler runtime
```

То есть scheduler может получить собственный язык правил.

Например:

```text
WHEN
    task.state == Waiting
    AND dependency(A).state == Completed
    AND now >= task.run_at

THEN
    task.state := Runnable
```

Внутри это компилируется в компактную executable transition rule.

Таким образом, Марков / Вирт / Рефал становятся не украшением, а механизмом построения и преобразования правил диспетчера.

---

## 14. Первый настоящий эксперимент

Минимальный, но уже реальный сценарий:

```text
1. Client submits task.
2. Task enters Waiting.
3. Task contains run_at = T.
4. Before T:
      Waiting → Runnable forbidden.
5. At or after T:
      Waiting → Runnable allowed.
6. Worker acquires task:
      Runnable → Running.
7. Worker receives lease.
8. Worker reports completion:
      Running → Completed.
9. All transitions appear in event history.
```

Здесь уже присутствуют:

```text
network protocol
task automaton
time guard
transition engine
worker
lease
event history
temporal trace
```

При этом ещё нет необходимости вводить:

```text
distributed consensus
complex queue
priority scheduler
workflow DSL
retry engine
persistent database
```

---

## 15. Основной принцип проекта

Не:

```text
Scheduler = Queue + Timers
```

а:

```text
Scheduler =
State
+
Transition Rules
+
Observable Facts
+
Selection Policy
+
Temporal Obligations
```

Таймер является только одним источником фактов.

Очередь является только одним возможным представлением множества кандидатов.

Граф является только одним способом выразить зависимости.

В центре находится:

# ПЕРЕХОД

Именно переход связывает:

```text
состояние
условия
время
ресурсы
процессы
ошибки
распределённость
темпоральную логику
```

---

## 16. Рабочая формулировка

> Formal Scheduler — это система, которая хранит явное состояние процессов, вычисляет допустимые переходы по формальным правилам, выбирает переходы согласно отдельной policy, исполняет их и сохраняет наблюдаемую историю, пригодную для проверки temporal properties.

Главный исследовательский вопрос:

> Можно ли построить практически полезный низколатентный диспетчер, в котором переходы являются первичным объектом, а время, очередь, зависимости, ресурсы и распределённость выражаются как условия и последствия этих переходов?