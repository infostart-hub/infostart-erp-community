﻿
&НаКлиенте
Процедура УстановитьДоступностьСостава()
	ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(СписокГруппы,"НоменклатурнаяГруппа",Объект.Ссылка);
	ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(СписокГруппы,"ЭтоГруппа",Ложь);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ РАБОТЫ СО СПИСКОМ ГРУППЫ

&НаКлиенте
Процедура тпСписокГруппы_ПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
Перем ВыбЭлемент;
	//
	//Отказ = Истина;

	//Если Копирование Тогда
	//	ПоказатьПредупреждение(, "Ввод новой записи копированием запрещен!");
	//	Возврат;
	//КонецЕсли; 
	//
	//Если Объект.Ссылка.Пустая() Тогда
	//	Ответ = Вопрос("Элемент еще не записан. Записать?", РежимДиалогаВопрос.ОКОтмена);
	//	Если Ответ <> КодВозвратаДиалога.ОК Тогда Возврат; КонецЕсли;
	////	Если Не ЗаписатьВФорме() Тогда Возврат; КонецЕсли; 
	//КонецЕсли;

	//Если ВвестиЗначение(ВыбЭлемент,,Тип("СправочникСсылка.Номенклатура")) Тогда
	//	Если ТипЗнч(ВыбЭлемент)=Тип("Массив") Тогда ВыбЭлемент=ВыбЭлемент[0]; КонецЕсли; 
	//	
	//	ОбъектНоменклатуры = ВыбЭлемент.ПолучитьОбъект();
	//	Если ОбъектНоменклатуры.ЭтоГруппа Тогда
	//		ПоказатьПредупреждение(, "В состав номенклатурной группы могут включаться только элементы номенклатуры!");
	//	Иначе
	//		Если ЗначениеЗаполнено(ОбъектНоменклатуры.НоменклатурнаяГруппа) Тогда
	//			стрВопрос="Выбранная номенклатура "+ВыбЭлемент+" уже входит в группу "+ОбъектНоменклатуры.НоменклатурнаяГруппа+". Включить ее текущую номенклатурную группу?";
	//			Если Вопрос(стрВопрос, РежимДиалогаВопрос.ОКОтмена) = КодВозвратаДиалога.Отмена Тогда Возврат; КонецЕсли;
	//		КонецЕсли;
	//		ОбъектНоменклатуры.НоменклатурнаяГруппа = Объект.Ссылка;
	//		ОбъектНоменклатуры.Записать();
	//		СписокГруппы.Обновить();
	//	КонецЕсли; 
	//КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура тпСписокГруппы_ПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	//Если НоваяСтрока Тогда
	//	Элемент.ТекущиеДанные.Вес = 1;
	//	Элемент.ТекущиеДанные.НоменклатурнаяГруппа = Объект.Ссылка;
	//КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура тпСписокГруппы_ПередУстановкойПометкиУдаления(Элемент, Отказ)
	//Отказ=Истина;

	//ОбъектНоменклатуры=Элемент.ТекущиеДанные.Ссылка.ПолучитьОбъект();
	//ОбъектНоменклатуры.НоменклатурнаяГруппа=ПредопределенноеЗначение("Справочник.Номенклатура.ПустаяСсылка");
	//ОбъектНоменклатуры.Записать();

	//СписокГруппы.Обновить();	
КонецПроцедуры

&НаКлиенте
Процедура тпСписокГруппы_Выбор(Элемент, ВыбраннаяСтрока, Колонка, СтандартнаяОбработка)
	
	//СтандартнаяОбработка = Ложь;
	//
	//ФормаЭлемента=ВыбраннаяСтрока.ПолучитьФорму("ФормаЭлемента", ЭтаФорма, ВыбраннаяСтрока);
	//ФормаЭлемента.Открыть();
	//
	//Если ФормаЭлемента.ЭлементыФормы.ОсновнаяПанель.Страницы.Дополнительные.Видимость = Ложь Тогда
	//	ФормаЭлемента.ЭлементыФормы.ОсновнаяПанель.Страницы.Дополнительные.Видимость = Истина;
	//КонецЕсли;
	//
	//ФормаЭлемента.ЭлементыФормы.ОсновнаяПанель.ТекущаяСтраница = ФормаЭлемента.ЭлементыФормы.ОсновнаяПанель.Страницы.Дополнительные;
	//ФормаЭлемента.ТекущийЭлемент = ФормаЭлемента.ЭлементыФормы.ВесовойКоэффициентВхождения;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	СобытияФормыСервер.ПриСозданииНаСервере(Отказ, СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Объект.Ссылка.Пустая() Тогда
		Если НЕ ЗначениеЗаполнено(Объект.СтавкаНДС) Тогда
			Объект.СтавкаНДС = УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнаяСтавкаНДС");
		КонецЕсли;
	КонецЕсли;

	УстановитьДоступностьСостава();

	СобытияФормыКлиент.ПриОткрытии(Отказ, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	СобытияФормыКлиент.ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	СобытияФормыКлиент.ПриЗакрытии(ЗавершениеРаботы, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	СобытияФормыКлиент.ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	СобытияФормыКлиент.ОбработкаОповещения(ИмяСобытия, Параметр, Источник, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаАктивизации(АктивныйОбъект, Источник)
	СобытияФормыКлиент.ОбработкаАктивизации(АктивныйОбъект, Источник, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаЗаписиНового(НовыйОбъект, Источник, СтандартнаяОбработка)
	СобытияФормыКлиент.ОбработкаЗаписиНового(НовыйОбъект, Источник, СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	СобытияФормыСервер.ПриЧтенииНаСервере(ТекущийОбъект, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	СобытияФормыКлиент.ПередЗаписью(Отказ, ПараметрыЗаписи, ЭтаФорма, Объект);
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	СобытияФормыСервер.ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи, ЭтаФорма, Объект);	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)	
	СобытияФормыСервер.ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи, ЭтаФорма, Объект);
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)	
	СобытияФормыСервер.ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	СобытияФормыКлиент.ПослеЗаписи(ПараметрыЗаписи, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	СобытияФормыКлиент.ВнешнееСобытие(Источник, Событие, Данные, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ВыборЗначения(СтандартнаяОбработка)
	СобытияФормыКлиент.ВыборЗначения(СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры



