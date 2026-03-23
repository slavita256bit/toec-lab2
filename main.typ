#import "@preview/modern-g7-32:0.2.0": *
#import "@local/typst-bsuir-core:0.7.9": *
#import "@preview/zap:0.5.0"

#set text(font: "Times New Roman", size: 14pt)
#show math.equation: set text(font: "STIX Two Math", size: 14pt)

#show: gost.with(
  title-template: custom-title-template.from-module(toec-template),
  department: "Кафедра теоретических основ электротехники",
  work: (
    type: "Лабораторная работа",
    number: "2",
    subject: "Исследование цепи постоянного тока методом узловых потенциалов и методом эквивалентного генератора",
    variant: "4",
  ),
  manager: (
    name: "Батюков С.В.",
  ),
  performer: (
    name: "Ермаков В. С.",
    group: "558301",
  ),
  footer: (city: "Минск", year: 2026),
  city: none,
  year: none,
  add-pagebreaks: false,
  text-size: 14pt,
)

#show: apply-toec-styling

// ИСХОДНЫЕ ДАННЫЕ
// E2 и E4 заданы как целые числа, чтобы они не форматировались с нулями после запятой
#let V = (
  E2: 30, E4: 15,
  R1: 2.4, R2: 2.0, R3: 3.9,
  R4: 1.0, R5: 3.9, R6: 2.4,
  base-node: 3
)

#let ground-better(node-name, length: 0.8, spacing: 0.2, stroke: 1pt) = {
  import zap: cetz, wire
  cetz.draw.get-ctx(ctx => {
      let (ctx, pos) = cetz.coordinate.resolve(ctx, node-name)
      let (x, y, z) = pos

      wire(pos, (x, y - 0.5)) // Провод вниз от узла

      let start_x = x - length / 2
      let end_x = x + length / 2
      let base_y = y - 0.5

      cetz.draw.line((start_x, base_y), (end_x, base_y), stroke: stroke)
      cetz.draw.line((start_x + spacing, base_y - spacing), (end_x - spacing, base_y - spacing), stroke: stroke)
      cetz.draw.line((start_x + 2*spacing, base_y - 2*spacing), (end_x - 2*spacing, base_y - 2*spacing), stroke: stroke)
  })
}

= Цель работы
Экспериментальная проверка метода узловых потенциалов, метода двух узлов (как частного случая метода узловых потенциалов), метода эквивалентного генератора напряжения.

= Расчёт домашнего задания

Исходные данные варианта №4 представлены в таблице 1.

#figure(
  caption: [Исходные данные],
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, 2.7em, 7em),
    align: center,
    table.header(
      table.cell(rowspan: 2, align: horizon)[№ вар.],
      [$E_2$], [$E_4$],[$R_1$], [$R_2$], [$R_3$], [$R_4$],[$R_5$], [$R_6$],
      table.cell(rowspan: 2, align: horizon)[Баз.\ узел],
      table.cell(rowspan: 2, align: horizon)[Нагр.],
      table.cell(rowspan: 2, align: horizon)[#par(justify: false, [Контур пот. диаграммы])],
      [В], [В],[кОм], [кОм], [кОм], [кОм], [кОм],[кОм]
    ),
    [4], [#V.E2], [#V.E4],[#V.R1], [#V.R2], [#V.R3], [#V.R4],[#V.R5], [#V.R6], [#V.base-node], [$R_3$],[2-1-5-4-6-3-2]
  )
)

Схема для расчётов представлена на рисунке 1.

#lab-figure(
  caption:[Исходная схема электрической цепи],
  above: -3em,
  circuit-better(scale-factor: 80%, {
    import zap: *

    node-better("1", (0, -1), label: (content: "1", anchor: "west"), visible: true)
    node-better("3", (16, -1), label: (content: "3", anchor: "east"), visible: true)
    node-better("2", (8, 9), label: (content: "2", anchor: "north"), visible: true)
    node-better("4", (8, 3), label: (content: "4", anchor: "north-west"), visible: true)

    node-better("5", (4, 1), label: (content: "5", anchor: "north-west"), visible: true)
    node-better("6", (12, 1), label: (content: "6", anchor: "north-east"), visible: true)

    // Внешний контур
    resistor-better("R1", "1", "2", label: (content: $R_1$, anchor: "right"), arrow-label: $I_1$, arrow-side: "left", arrow-dir: "forward")
    resistor-better("R5", "2", "3", label: (content: $R_5$, anchor: "left"), arrow-label: $I_5$, arrow-side: "right", arrow-dir: "forward")
    resistor-better("R3", "1", "3", label: (content: $R_3$, anchor: "bottom"), arrow-label: $I_3$, arrow-side: "top", arrow-dir: "forward")

    // Внутренняя звезда
    resistor-better("R6", "2", "4", label: (content: $R_6$, anchor: "right"), arrow-label: $I_6$, arrow-side: "left", arrow-dir: "forward")

    // Ветвь 4-1 (с E2)
    resistor-better("R2", "4", "5", position: 50%, label: (content: $R_2$, anchor: "top"), arrow-label: $I_2$, arrow-side: "right", arrow-dir: "forward")
    source-better("E2", "5", "1", position: 30%, arrow-dir: "forward", label: (content: $E_2$, anchor: "bottom"))

    // Ветвь 4-3 (с E4)
    resistor-better("R4", "4", "6", label: (content: $R_4$, anchor: "top"), arrow-label: $I_4$, arrow-side: "left", arrow-dir: "forward")
    source-better("E4", "6", "3", position: 30%, arrow-dir: "forward", label: (content: $E_4$, anchor: "bottom"))

    ground-better("3")
  })
)

#heading("Домашнее задание", numbering: none)

Примем узел #V.base-node за базисный. Тогда его потенциал равен нулю: $phi_#V.base-node = 0$.

Получаем
#mathtype-mimic[
  $U_13 &= phi_1 - phi_3 = phi_1;$

  $U_23 &= phi_2 - phi_3 = phi_2;$

  $U_43 &= phi_4 - phi_3 = phi_4$.
]


Составим систему уравнений по методу узловых потенциалов:

#set math.cases(gap: 1em)
#mathtype-mimic[
  $
  cases(
    U_13 (1/R_1 + 1/R_2 + 1/R_3) - U_23 (1/R_1) - U_43 (1/R_2) = E_2 / R_2,
    -U_13 (1/R_1) + U_23 (1/R_1 + 1/R_5 + 1/R_6) - U_43 (1/R_6) = 0,
    -U_13 (1/R_2) - U_23 (1/R_6) + U_43 (1/R_2 + 1/R_4 + 1/R_6) = - E_2 / R_2 - E_4 / R_4
  )
  $
]

Подставим численные значения сопротивлений и ЭДС:

#mathtype-mimic[
  $
  cases(
    U_13 (1/#V.R1 + 1/#V.R2 + 1/#V.R3) - U_23 (1/#V.R1) - U_43 (1/#V.R2) = #V.E2 / #V.R2,
    -U_13 (1/#V.R1) + U_23 (1/#V.R1 + 1/#V.R5 + 1/#V.R6) - U_43 (1/#V.R6) = 0,
    -U_13 (1/#V.R2) - U_23 (1/#V.R6) + U_43 (1/#V.R2 + 1/#V.R4 + 1/#V.R6) = - #V.E2 / #V.R2 - #V.E4 / #V.R4
  )
  $
]

// Объявляем переменные с результатами решения матрицы из Mathcad
#let U13 = 4.886
#let U23 = -3.958
#let U43 = -15.238

Решим систему уравнений матричным методом.

#mathtype-mimic(receive: true,[
  $
  U_13 &= #U13 " В"; \
  U_23 &= #U23 " В"; \
  U_43 &= #U43 " В".
  $
])


// Вычисляем токи внутри Typst, чтобы избежать опечаток при переносе
#let I3 = U13 / V.R3
#let I4 = (U43 + V.E4) / V.R4
#let I2 = (U43 - U13 + V.E2) / V.R2
#let I5 = U23 / V.R5
#let I6 = I2 + I4
#let I1 = I5 + I6

Произвольно проставим направления токов в цепи, рассчитаем токи в ветвях по обобщенному закону Ома.

#mathtype-mimic(receive: true,[
  $I_3 &= U_13 / R_3 = #U13 / #V.R3 = #I3 " мА";$

  $I_4 &= (U_43 + E_4) / R_4 = (#U43 + #V.E4) / #V.R4 = #I4 " мА";$

  $I_2 &= (U_43 - U_13 + E_2) / R_2 = (#U43 - #U13 + #V.E2) / #V.R2 = #I2 " мА";$

  $I_5 &= U_23 / R_5 = (#U23) / #V.R5 = #I5 " мА";$

  $I_6 &= I_2 + I_4 = #I2 + (#I4) = #I6 " мА";$

  $I_1 &= I_5 + I_6 = (#I5) + #I6 = #I1 " мА".$
])

Определяем ток в ветви с сопротивлением $R_3$ методом эквивалентного генератора. Для этого размыкаем ветвь с сопротивлением нагрузки $R_3$. Полученная схема представлена на рисунке 2.

#lab-figure(
  caption: [Схема для определения напряжения холостого хода],
  above: -2em,
  circuit-better(scale-factor: 80%, {
    import zap: *

    // Узлы (1 и 3 делаем белыми внутри, чтобы показать разрыв)
    node-better("1", (0, -1), label: (content: "1", anchor: "west", distance: 0.15), visible: true, fill: white, stroke: black)
    node-better("3", (16, -1), label: (content: "3", anchor: "east", distance: 0.15), visible: true, fill: white, stroke: black)
    node-better("2", (8, 9), label: (content: "2", anchor: "north", distance: 0.15), visible: true)
    node-better("4", (8, 3), label: (content: "4", anchor: "north-west", distance: 0.15), visible: true)
    node-better("5", (4, 1), visible: false)
    node-better("6", (12, 1), visible: false)

    // Внешний контур (без R3)
    resistor-better("R1", "1", "2", label: (content: $R_1$, anchor: "right", distance: 0.7))
    resistor-better("R5", "2", "3", label: (content: $R_5$, anchor: "left", distance: 0.7))
    resistor-better("R6", "2", "4", label: (content: $R_6$, anchor: "right", distance: 0.7))

    // Ветвь 4-1 (с E2)
    resistor-better("R2", "4", "5", label: (content: $R_2$, anchor: "top", distance: 0.6))
    source-better("E2", "5", "1", position: 30%, arrow-dir: "forward", label: (content: $E_2$, anchor: "bottom"))

    // Ветвь 4-3 (с E4)
    resistor-better("R4", "4", "6", label: (content: $R_4$, anchor: "top", distance: 0.6))
    source-better("E4", "6", "3", position: 30%, arrow-dir: "forward", label: (content: $E_4$, anchor: "bottom"))

    // Стрелка напряжения холостого хода U_xx (от узла 1 к 3)
    cetz.draw.line(
      (0, -1.8), (16, -1.8),
      stroke: 0.8pt + black,
      mark: (end: ">", fill: black)
    )
    cetz.draw.content(
      (8, -1.8),
      box(fill: white, inset: 2pt)[$U_"хх"$],
      anchor: "south"
    )
  })
)

// Вычисления напряжений и токов для режима ХХ
#let g12 = 1 / (V.R1 + V.R2)
#let g45 = 1 / (V.R4 + V.R5)
#let g6 = 1 / V.R6

#let U24 = (V.E2 * g12 + V.E4 * g45) / (g12 + g6 + g45)
#let I12 = (V.E2 - U24) * g12
#let I45 = (V.E4 - U24) * g45

#let phi1_xx = V.E2 - I12 * V.R2
#let phi3_xx = V.E4 - I45 * V.R4
#let Uxx = phi1_xx - phi3_xx

После удаления сопротивления $R_3$ узлы 1 и 3 перестают быть точками разветвления (к ним подключено лишь по два элемента). Схема сводится к двум узлам (2 и 4), между которыми параллельно включены три ветви (левая, средняя и правая). Применим метод двух узлов.

Определим проводимости параллельных ветвей:
#mathtype-mimic[
  $g_12 &= 1 / (R_1 + R_2) = 1 / (#V.R1 + #V.R2) = #g12 " мСм";$

  $g_45 &= 1 / (R_4 + R_5) = 1 / (#V.R4 + #V.R5) = #g45 " мСм";$

  $g_6 &= 1 / R_6 = 1 / #V.R6 = #g6 " мСм".$
]

Найдём межузловое напряжение $U_24$:
#mathtype-mimic(receive: true,[
  $
  U_24 = (E_2 g_12 + E_4 g_45) / (g_12 + g_6 + g_45) = (#V.E2 dot #g12 + #V.E4 dot #g45) / (#g12 + #g6 + #g45) = #U24 " В".
  $
])

Определим токи $I_12$ (в левой ветви) и $I_45$ (в правой ветви), текущие от узла 4 к узлу 2:
#mathtype-mimic[
  $
  I_12 &= (E_2 - U_24) g_12 = (#V.E2 - #U24) dot #g12 = #I12 " мА"; \
  I_45 &= (E_4 - U_24) g_45 = (#V.E4 - #U24) dot #g45 = #I45 " мА".
  $
]

Пройдя по контурам от 4-го узла к 1-му и 3-му, определим их потенциалы:
#mathtype-mimic[
  $phi_1 &= E_2 - I_12 R_2 = #V.E2 - #I12 dot #V.R2 = #phi1_xx " В";$

  $phi_3 &= E_4 - I_45 R_4 = #V.E4 - #I45 dot #V.R4 = #phi3_xx " В".$
]

Находим напряжение холостого хода.
#mathtype-mimic(receive: true,[
  $ U_"хх" = phi_1 - phi_3 = #phi1_xx - (#phi3_xx) = #Uxx " В". $
])

Для нахождения внутреннего сопротивления эквивалентного генератора $R_"вн"$ исключим из схемы источники ЭДС (заменив их короткозамкнутыми участками) и рассчитаем эквивалентное сопротивление относительно зажимов 1 и 3. Полученная схема представлена на рисунке 3.

#lab-figure(
  caption: [Схема для определения внутреннего сопротивления],
  above: 0em,
  circuit-better(scale-factor: 80%, {
    import zap: *

    // Узлы 1, 2, 3, 4
    node-better("1", (0, -1), label: (content: "1", anchor: "west", distance: 0.15), visible: true)
    node-better("3", (16, -1), label: (content: "3", anchor: "east", distance: 0.15), visible: true)
    node-better("2", (8, 9), label: (content: "2", anchor: "north", distance: 0.15), visible: true)
    node-better("4", (8, 3), label: (content: "4", anchor: "north-west", distance: 0.15), visible: true)

    // Внешний контур (R3 удален, источники закорочены)
    resistor-better("R1", "1", "2", label: (content: $R_1$, anchor: "right", distance: 0.7))
    resistor-better("R5", "2", "3", label: (content: $R_5$, anchor: "left", distance: 0.7))

    // Внутренняя звезда
    resistor-better("R6", "2", "4", label: (content: $R_6$, anchor: "right", distance: 0.7))

    // Ветвь 4-1 (с E2, теперь R2)
    resistor-better("R2", "4", "1", label: (content: $R_2$, anchor: "top", distance: 0.6))

    // Ветвь 4-3 (с E4, теперь R4)
    resistor-better("R4", "4", "3", label: (content: $R_4$, anchor: "top", distance: 0.6))
  })
)


// Вычисления преобразования треугольника R4, R5, R6 в звезду
#let R56 = (V.R5 * V.R6) / (V.R4 + V.R5 + V.R6)
#let R46 = (V.R4 * V.R6) / (V.R4 + V.R5 + V.R6)
#let R45 = (V.R4 * V.R5) / (V.R4 + V.R5 + V.R6)
#let Rbh = ((V.R1 + R56) * (V.R2 + R46)) / (V.R1 + R56 + V.R2 + R46) + R45

Для упрощения мостовой схемы преобразуем правый треугольник сопротивлений $R_4, R_5, R_6$ в эквивалентную звезду:

#mathtype-mimic[
  $
  R_56 &= (R_5 R_6) / (R_4 + R_5 + R_6) = (#V.R5 dot #V.R6) / (#V.R4 + #V.R5 + #V.R6) = #R56 " кОм"; \
  R_46 &= (R_4 R_6) / (R_4 + R_5 + R_6) = (#V.R4 dot #V.R6) / (#V.R4 + #V.R5 + #V.R6) = #R46 " кОм"; \
  R_45 &= (R_4 R_5) / (R_4 + R_5 + R_6) = (#V.R4 dot #V.R5) / (#V.R4 + #V.R5 + #V.R6) = #R45 " кОм".
  $
]

Полученная схема после эквивалентного преобразования представлена на рисунке 4.

#lab-figure(
  caption:[Схема после эквивалентного преобразования треугольника в звезду],
  above: -2em,
  circuit-better(scale-factor: 80%, {
    import zap: *

    node-better("1", (0, -1), label: (content: "1", anchor: "west", distance: 0.15), visible: true, fill: white, stroke: black)
    node-better("3", (16, -1), label: (content: "3", anchor: "east", distance: 0.15), visible: true, fill: white, stroke: black)
    node-better("2", (8, 9), label: (content: "2", anchor: "north", distance: 0.15), visible: true)
    node-better("4", (8, 3), label: (content: "4", anchor: "north-west", distance: 0.15), visible: true)
    node-better("O", (12, 4), visible: true) // Центр звезды

    resistor-better("R1", "1", "2", label: (content: $R_1$, anchor: "right", distance: 0.7))
    resistor-better("R2", "1", "4", label: (content: $R_2$, anchor: "bottom", distance: 0.6))

    resistor-better("R56", "2", "O", label: (content: $R_56$, anchor: "right", distance: 0.8))
    resistor-better("R46", "4", "O", label: (content: $R_46$, anchor: "bottom", distance: 0.7))
    resistor-better("R45", "O", "3", label: (content: $R_45$, anchor: "top", distance: 0.9))

    cetz.draw.line((0, -1.8), (16, -1.8), stroke: 0.8pt + black)
    cetz.draw.content((8, -1.8), box(fill: white, inset: 2pt)[$R_"вн"$], anchor: "south")
  })
)

Найдём внутреннее сопротивление.
#mathtype-mimic(receive: true,[
  $ R_"вн" &= ((R_1 + R_56)(R_2 + R_46)) / (R_1 + R_56 + R_2 + R_46) + R_45
           &= ((#V.R1 + #R56)(#V.R2 + #R46)) / (#V.R1 + #R56 + #V.R2 + #R46) + #R45 = #Rbh " кОм". $
])

Определим искомый ток в ветви с сопротивлением нагрузки $R_3$.
#mathtype-mimic(receive: true,[
  $ I_3 = U_"хх" / (R_"вн" + R_3) = #Uxx / (#Rbh + #V.R3) = #(Uxx / (Rbh + V.R3)) " мА". $
])

Значение тока $I_3$, рассчитанное методом эквивалентного генератора, полностью совпадает со значением, полученным ранее методом узловых потенциалов.


#heading("Сводные таблицы результатов", numbering: none)

// Этот блок перехватывает округление чисел в таблицах до 3 знаков (и обходит пакет typst-bsuir-core)
#let apply-3-decimals(body) = {
  show table.cell: cell => {
    let format-val3(it) = {
      let val = float(it.text.replace(",", "."))
      let rounded = calc.round(val, digits: 3)
      let str-val = str(rounded).replace(".", ",")
      let parts = str-val.split(",")
      let fractional = if parts.len() == 1 { "000" }
                       else if parts.at(1).len() == 1 { parts.at(1) + "00" }
                       else if parts.at(1).len() == 2 { parts.at(1) + "0" }
                       else { parts.at(1) }
      // sym.wj добавляется, чтобы спрятать число от глобального regex (защищает 3 знака от урезания до 2)
      parts.at(0) + "," + sym.wj + fractional
    }
    show regex("[0-9]+[\.,][0-9]+"): format-val3
    cell
  }
  body
}

// Применяем 3 знака и устанавливаем уменьшенный шрифт для компактности
#apply-3-decimals[
  #let s(body) = text(size: 10pt)[#body]

  // Новая функция для 2-х знаков после запятой (для экспериментальных данных)
  #let s2(v) = {
    if type(v) in (float, int) {
      let rounded = calc.round(float(v), digits: 2)
      let str-val = str(rounded).replace(".", ",")
      let parts = str-val.split(",")
      let fractional = if parts.len() == 1 { "00" }
                       else if parts.at(1).len() == 1 { parts.at(1) + "0" }
                       else { parts.at(1) }

      // Добавляем sym.wj после запятой, чтобы "спрятать" это число от правила 3-х знаков
      text(size: 10pt)[#parts.at(0),#sym.wj#fractional]
    } else {
      text(size: 10pt)[#v]
    }
  }

  #figure(
    caption:[Результаты расчётов и измерений],
    table(
      columns: (6em, 2em, 2em, 2em, 2.2em, 2.5em, 2em, 2em, 2em, 2em, 2.2em, 2em, 2em, 2em, 2em),
      align: center + horizon,
      table.header(
        table.cell(rowspan: 2)[Данные],
        table.cell(rowspan: 2)[$E_2$],
        table.cell(rowspan: 2)[$E_4$],
        table.cell(colspan: 9)[Метод узловых напряжений],
        table.cell(colspan: 3)[Метод двух узлов],[$U_13$], [$U_23$], [$U_43$],[$I_1$], [$I_2$], [$I_3$], [$I_4$],[$I_5$], [$I_6$], [$U_24$], [$I_12$],[$I_45$]
      ),
      [Расчетные], s(V.E2), s(V.E4),
      s(U13), s(U23), s(U43),
      s(I1), s(I2), s(I3), s(I4), s(I5), s(I6),
      s(U24), s(I12), s(I45),

      // Пример использования s2 для экспериментальных данных
      [Эксперимент.], [#s2(29.9)], [#s2(16.07)], [#s2(4.47)], [#s2(-4.44)], [#s2(-16.11)], [#s2(3.6)], [#s2(4.85)], [#s2(1.16)], [#s2(-0.14)], [#s2(-1.1)], [#s2(4.7)], [#s2(11.72)], [#s2(4.1)], [#s2(0.8)]
    )
  )

  #v(1em)

  #figure(
    caption:[Продолжение таблицы 2.2],
    table(
      columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      align: center + horizon,
      table.header(
        table.cell(rowspan: 2)[Данные],
        table.cell(colspan: 4)[Метод экв. генератора],
        table.cell(rowspan: 2, colspan: 6)[#par(justify: false,[Опытные данные для построения потенциальной диаграммы – напряжения участков цепи])],
        [$U_"хх"$],[$I_"к.з"$], [$R_"вн"$], [$I_"н"$]
      ),
      [Расчетные], s(Uxx), [/*3.74*/], s(Rbh), s(Uxx / (Rbh + V.R3)), table.cell(colspan: 6)[2-1-5-4-6-3-2],
      [Эксперимент.], [#s2(6.87)], [#s2(3.3)], [#s2(2.08)], [#s2(1.15)], [#s2(8.55)], [#s2(-21.3)], [#s2(-11.72)], [#s2(-11.72)], [#s2(4.44)], [#s2(0)],
    )
  )
]

#heading(numbering: none)[Вывод]
В ходе выполнения лабораторной работы были исследованы методы узловых потенциалов, двух узлов и эквивалентного генератора. Выполненные теоретические расчёты были проверены экспериментально. Для заданного внешнего контура была построена потенциальная диаграмма.

#heading(numbering: none)[Потенциальная диаграмма]

#figure(
  potential-diagram((
    // Узел 2 (Старт)
    (r: 0,   phi: 0,      label: [2], anchor: "south-east"),
    // Участок 2-1 (Резистор R1 = 2.4 кОм)
    (r: 2.4, phi: 8.95,   label: [1], anchor: "south", r-label: $R_1$),
    // Участок 1-5 (Источник E2 = 30 В, идем против направления ЭДС, скачок вниз)
    (r: 2.4, phi: -21.30, label: [5], anchor: "north-west", e-label: move(dy: 1.5em, $E_2$)),
    // Участок 5-4 (Резистор R2 = 2.0 кОм -> 2.4 + 2.0 = 4.4)
    (r: 4.4, phi: -11.72, label: [4], anchor: "north", r-label: $R_2$),
    // Участок 4-6 (Резистор R4 = 1.0 кОм -> 4.4 + 1.0 = 5.4)
    (r: 5.4, phi: -11.72, label: [6], anchor: "north-east", r-label: $R_4$),
    // Участок 6-3 (Источник E4 = 15 В, идем против направления ЭДС, скачок вверх)
    (r: 5.4, phi: 4.44,   label: [3], anchor: "south-east", e-label: move(dy: 2em, $E_4$)),
    // Участок 3-2 (Резистор R5 = 3.9 кОм -> 5.4 + 3.9 = 9.3)
    (r: 8, phi: 0,      label: [2], anchor: "south-west", r-label: $R_5$),
  ))
)