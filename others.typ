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
    name: "Каптюг И. М.",
    group: "558301",
  ),
  footer: (city: "Минск", year: 2026),
  city: none,
  year: none,
  add-pagebreaks: false,
  text-size: 14pt,
)


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
    name: "Рудаков Г. А.",
    group: "558301",
  ),
  footer: (city: "Минск", year: 2026),
  city: none,
  year: none,
  add-pagebreaks: false,
  text-size: 14pt,
)
