﻿&НаКлиенте
Процедура ВыполнитьДействие(Команда)
	ДинамическиеСпискиКлиент.ВыполнитьДействие(Команда.Имя, ЭтаФорма);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Динамический список"

&НаКлиенте
Процедура ДинамическийСписок_Выбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)	
	ДинамическиеСпискиКлиент.Выбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка, ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура ДинамическийСписок_ВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	Если ТипЗнч(Значение)=Тип("Массив") Тогда
		ОповеститьОВыборе(Значение[0]);
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ДинамическиеСпискиСервер.НастройкаПоПравилам(ДинамическийСписок, ЭтаФорма);	
	Элементы.ДинамическийСписок.РежимВыбора=Параметры.РежимВыбора;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ДинамическиеСпискиКлиент.ПриОткрытии(Отказ, ДинамическийСписок, ЭтаФорма);
КонецПроцедуры