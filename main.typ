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
//     name: "Каптюг И. М.",
//     name: "Рудаков Г. А.",
    group: "558301",
  ),
  footer: (city: "Минск", year: 2026),
  city: none,
  year: none,
  add-pagebreaks: false,
  text-size: 14pt,
)

#show: apply-toec-styling

#let fmt2(v) = {
  if type(v) not in (float, int) { return v }
  let s = str(calc.round(v, digits: 2))
  let parts = s.split(".")
  if parts.len() == 1 { return eval("$" + parts.at(0) + "$") }
  return [#eval("$" + parts.at(0) + "$")#math.class("normal", [,])#eval("$" + parts.at(1) + "$")]
}

// ИСХОДНЫЕ ДАННЫЕ
#let V = (
  E2: 30.0, E4: 15.0,
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
      [$E_2$], [$E_4$], [$R_1$], [$R_2$], [$R_3$], [$R_4$], [$R_5$], [$R_6$],
      table.cell(rowspan: 2, align: horizon)[Баз.\ узел],
      table.cell(rowspan: 2, align: horizon)[Нагр.],
      table.cell(rowspan: 2, align: horizon)[#par(justify: false, [Контур пот. диаграммы])],
      [В], [В], [кОм], [кОм], [кОм], [кОм], [кОм], [кОм]
    ),
    [4], [#V.E2], [#V.E4], [#V.R1], [#V.R2], [#V.R3], [#V.R4], [#V.R5], [#V.R6], [#V.base-node], [$R_3$], [2-1-5-4-6-3-2]
  )
)

Схема для расчётов представлена на рисунке 1.

#lab-figure(
  caption: [Исходная схема электрической цепи],
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
    U_13 (#fmt2(1)/R_1 + #fmt2(1)/R_2 + #fmt2(1)/R_3) - U_23 (#fmt2(1)/R_1) - U_43 (#fmt2(1)/R_2) = E_2 / R_2,
    -U_13 (#fmt2(1)/R_1) + U_23 (#fmt2(1)/R_1 + #fmt2(1)/R_5 + #fmt2(1)/R_6) - U_43 (#fmt2(1)/R_6) = 0,
    -U_13 (#fmt2(1)/R_2) - U_23 (#fmt2(1)/R_6) + U_43 (#fmt2(1)/R_2 + #fmt2(1)/R_4 + #fmt2(1)/R_6) = - E_2 / R_2 - E_4 / R_4
  )
  $
]

Подставим численные значения сопротивлений и ЭДС:

#mathtype-mimic[
  $
  cases(
    U_13 (#fmt2(1)/#fmt2(V.R1) + #fmt2(1)/#fmt2(V.R2) + #fmt2(1)/#fmt2(V.R3)) - U_23 (#fmt2(1)/#fmt2(V.R1)) - U_43 (#fmt2(1)/#fmt2(V.R2)) = #fmt2(V.E2) / #fmt2(V.R2),
    -U_13 (#fmt2(1)/#fmt2(V.R1)) + U_23 (#fmt2(1)/#fmt2(V.R1) + #fmt2(1)/#fmt2(V.R5) + #fmt2(1)/#fmt2(V.R6)) - U_43 (#fmt2(1)/#fmt2(V.R6)) = 0,
    -U_13 (#fmt2(1)/#fmt2(V.R2)) - U_23 (#fmt2(1)/#fmt2(V.R6)) + U_43 (#fmt2(1)/#fmt2(V.R2) + #fmt2(1)/#fmt2(V.R4) + #fmt2(1)/#fmt2(V.R6)) = - #fmt2(V.E2) / #fmt2(V.R2) - #fmt2(V.E4) / #fmt2(V.R4)
  )
  $
]

// Объявляем переменные с результатами решения матрицы из Mathcad
#let U13 = 4.886
#let U23 = -3.958
#let U43 = -15.238

Решим систему уравнений матричным методом.

#mathtype-mimic(receive: true, [
  $
  U_13 &= #_fmt(U13) " В"; \
  U_23 &= #_fmt(U23) " В"; \
  U_43 &= #_fmt(U43) " В".
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

#mathtype-mimic(receive: true, [
  $I_3 &= U_13 / R_3 = #fmt2(U13) / #fmt2(V.R3) = #fmt2(calc.round(I3, digits: 2)) " мА";$

  $I_4 &= (U_43 + E_4) / R_4 = (#fmt2(U43) + #fmt2(V.E4)) / #fmt2(V.R4) = #fmt2(calc.round(I4, digits: 2)) " мА";$

  $I_2 &= (U_43 - U_13 + E_2) / R_2 = (#fmt2(U43) - #fmt2(U13) + #fmt2(V.E2)) / #fmt2(V.R2) = #fmt2(calc.round(I2, digits: 2)) " мА";$

  $I_5 &= U_23 / R_5 = (#fmt2(U23)) / #fmt2(V.R5) = #fmt2(calc.round(I5, digits: 2)) " мА";$

  $I_6 &= I_2 + I_4 = #fmt2(calc.round(I2, digits: 2)) + (#fmt2(calc.round(I4, digits: 2))) = #fmt2(calc.round(I6, digits: 2)) " мА";$

  $I_1 &= I_5 + I_6 = (#fmt2(calc.round(I5, digits: 2))) + #fmt2(calc.round(I6, digits: 2)) = #fmt2(calc.round(I1, digits: 2)) " мА".$
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
  $g_12 &= #fmt2(1) / (R_1 + R_2) = #fmt2(1) / (#fmt2(V.R1) + #fmt2(V.R2)) = #fmt2(g12) " мСм";$

  $g_45 &= #fmt2(1) / (R_4 + R_5) = #fmt2(1) / (#fmt2(V.R4) + #fmt2(V.R5)) = #fmt2(g45) " мСм";$

  $g_6 &= #fmt2(1) / R_6 = #fmt2(1) / #fmt2(V.R6) = #fmt2(g6) " мСм".$
]

Найдём межузловое напряжение $U_24$:
#mathtype-mimic(receive: true, [
  $
  U_24 = (E_2 g_12 + E_4 g_45) / (g_12 + g_6 + g_45) = (#_fmt(V.E2) dot #_fmt(g12) + #_fmt(V.E4) dot #_fmt(g45)) / (#_fmt(g12) + #_fmt(g6) + #_fmt(g45)) = #_fmt(U24) " В".
  $
])

Определим токи $I_12$ (в левой ветви) и $I_45$ (в правой ветви), текущие от узла 4 к узлу 2:
#mathtype-mimic[
  $
  I_12 &= (E_2 - U_24) g_12 = (#_fmt(V.E2) - #_fmt(U24)) dot #_fmt(g12) = #_fmt(I12) " мА"; \
  I_45 &= (E_4 - U_24) g_45 = (#_fmt(V.E4) - #_fmt(U24)) dot #_fmt(g45) = #_fmt(I45) " мА".
  $
]

Пройдя по контурам от 4-го узла к 1-му и 3-му, определим их потенциалы:
#mathtype-mimic[
  $phi_1 &= E_2 - I_12 R_2 = #_fmt(V.E2) - #_fmt(I12) dot #_fmt(V.R2) = #_fmt(phi1_xx) " В";$

  $phi_3 &= E_4 - I_45 R_4 = #_fmt(V.E4) - #_fmt(I45) dot #_fmt(V.R4) = #_fmt(phi3_xx) " В".$
]

Находим напряжение холостого хода.
#mathtype-mimic(receive: true, [
  $ U_"хх" = phi_1 - phi_3 = #_fmt(phi1_xx) - (#_fmt(phi3_xx)) = #_fmt(Uxx) " В". $
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
  R_56 &= (R_5 R_6) / (R_4 + R_5 + R_6) = (#_fmt(V.R5) dot #_fmt(V.R6)) / (#_fmt(V.R4) + #_fmt(V.R5) + #_fmt(V.R6)) = #_fmt(R56) " кОм"; \
  R_46 &= (R_4 R_6) / (R_4 + R_5 + R_6) = (#_fmt(V.R4) dot #_fmt(V.R6)) / (#_fmt(V.R4) + #_fmt(V.R5) + #_fmt(V.R6)) = #_fmt(R46) " кОм"; \
  R_45 &= (R_4 R_5) / (R_4 + R_5 + R_6) = (#_fmt(V.R4) dot #_fmt(V.R5)) / (#_fmt(V.R4) + #_fmt(V.R5) + #_fmt(V.R6)) = #_fmt(R45) " кОм".
  $
]

Полученная схема после эквивалентного преобразования представлена на рисунке 4.

#lab-figure(
  caption: [Схема после эквивалентного преобразования треугольника в звезду],
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
#mathtype-mimic(receive: true, [
  $ R_"вн" &= ((R_1 + R_56)(R_2 + R_46)) / (R_1 + R_56 + R_2 + R_46) + R_45
           &= ((#_fmt(V.R1) + #_fmt(R56))(#_fmt(V.R2) + #_fmt(R46))) / (#_fmt(V.R1) + #_fmt(R56) + #_fmt(V.R2) + #_fmt(R46)) + #_fmt(R45) = #_fmt(Rbh) " кОм". $
])

Определим искомый ток в ветви с сопротивлением нагрузки $R_3$.
#mathtype-mimic(receive: true, [
  $ I_3 = U_"хх" / (R_"вн" + R_3) = #_fmt(Uxx) / (#_fmt(Rbh) + #_fmt(V.R3)) = #_fmt(Uxx / (Rbh + V.R3)) " мА". $
])

Значение тока $I_3$, рассчитанное методом эквивалентного генератора, полностью совпадает со значением, полученным ранее методом узловых потенциалов.

// Определим искомый ток в короткого замыкания.
// #mathtype-mimic(receive: true, [
//   $ I_"к.з." = U_"хх" / R_"вн" = #_fmt(Uxx) / #_fmt(Rbh) = #_fmt(Uxx / Rbh) " мА". $
// ])
//
// Определим потенциалы узлов 5 и 6:
// #let phi5 = U43 - I2 * V.R2
// #let phi6 = U43 - I4 * V.R4
// #mathtype-mimic[
//   $phi_5 &= phi_4 - I_2 R_2 = #_fmt(U43) - #_fmt(I2) dot #_fmt(V.R2) = #_fmt(phi5) " В";$
//
//   $phi_6 &= phi_4 - I_4 R_4 = #_fmt(U43) - (#_fmt(I4)) dot #_fmt(V.R4) = #_fmt(phi6) " В".$
// ]


#heading("Сводные таблицы результатов", numbering: none)

#let _fmtS(body) = {text(size: 10pt, _fmt(body))}

#figure(
  caption: [Результаты расчётов и измерений],
  table(
    columns: (auto, auto, auto, 2em, 2em, 2em, 2em, 2em, 2em, 2em, 2em, 2em, 2em, 2em, 2em),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[Данные],
      table.cell(rowspan: 2)[$E_2$],
      table.cell(rowspan: 2)[$E_4$],
      table.cell(colspan: 9)[Метод узловых напряжений],
      table.cell(colspan: 3)[Метод двух узлов],
      [$U_13$], [$U_23$], [$U_43$], [$I_1$], [$I_2$], [$I_3$], [$I_4$], [$I_5$], [$I_6$], [$U_24$], [$I_12$], [$I_45$]
    ),
    [Расчетные], [#_fmtS(V.E2)], [#_fmtS(V.E4)],
    [#_fmtS(U13)], [#_fmtS(U23)], [#_fmtS(U43)],
    [#_fmtS(I1)], [#_fmtS(I2)], [#_fmtS(I3)], [#_fmtS(I4)], [#_fmtS(I5)], [#_fmtS(I6)],
    [#_fmtS(U24)], [#_fmtS(I12)], [#_fmtS(I45)],
    [Эксперимент.], [], [], [], [], [], [], [], [], [], [], [], [], [], []
  )
)

#v(1em)

// #let U21 = U23 - U13
// #let U15 = U13 - phi5
// #let U54 = phi5 - U43
// #let U46 = U43 - phi6
// #let U63 = phi6 - 0
// #let U32 = 0 - U23

#figure(
  caption: [Продолжение таблицы 2.2],
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[Данные],
      table.cell(colspan: 4)[Метод экв. генератора],
      table.cell(rowspan: 2, colspan: 6)[#par(justify: false, [Опытные данные для построения потенциальной диаграммы – напряжения участков цепи])],
      [$U_"хх"$], [$I_"к.з"$], [$R_"вн"$], [$I_"н"$]
    ),
    [Расчетные], [#_fmt(Uxx)], [/*3.74*/], [#_fmt(Rbh)], [#_fmt(Uxx / (Rbh + V.R3))], table.cell(colspan: 6)[2-1-5-4-6-3-2], // [#_fmt(U21)], [#_fmt(U15)], [#_fmt(U54)], [#_fmt(U46)], [#_fmt(U63)], [#_fmt(U32)],
    [Эксперимент.], [], [], [], [], [], [], [], [], [],
  )
)