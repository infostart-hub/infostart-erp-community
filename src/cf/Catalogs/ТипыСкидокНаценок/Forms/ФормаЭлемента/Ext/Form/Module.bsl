﻿&НаСервереБезКонтекста
Функция ЗначениеПеречисления(Ииндекс)
	Возврат Перечисления.ДниНедели[Ииндекс];
КонецФункции

&НаКлиенте
Процедура ИзменитьТипЗначенияУсловия()
	Если Объект.Условие = ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.ПоВидуОплаты") Тогда
		Элементы.ЗначениеУсловия.ОграничениеТипа=Новый ОписаниеТипов("СправочникСсылка.ВидыОплатЧекаККМ");
	Иначе
		КвалификаторыЧисла = Новый КвалификаторыЧисла(15, 2, ДопустимыйЗнак.Неотрицательный);
		Элементы.ЗначениеУсловия.ОграничениеТипа=Новый ОписаниеТипов("Число", КвалификаторыЧисла);
	КонецЕсли;

	Объект.ЗначениеУсловия=Элементы.ЗначениеУсловия.ОграничениеТипа.ПривестиЗначение(Объект.ЗначениеУсловия);

	Если Объект.Условие = ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.БезУсловий") Тогда
		Объект.ЗначениеУсловия = 0;
		Элементы.ЗначениеУсловия.Доступность=Ложь;
	Иначе
		Элементы.ЗначениеУсловия.Доступность=Истина;
	КонецЕсли;
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Обработчики событий атрибутов

&НаКлиенте
Процедура Атрибут_ПриИзменении(Элемент)
	Если Элемент.Имя="Условие" Тогда
		ИзменитьТипЗначенияУсловия();
		
	ИначеЕсли Элемент.Имя="ВидСкидки" Тогда
		Если Объект.ВидСкидки = ПредопределенноеЗначение("Перечисление.ВидыСкидок.Оптовая") Тогда
			Если Объект.Условие = ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.ПоВидуОплаты") Тогда
				Объект.Условие = ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.ПоСуммеДокумента");
				ИзменитьТипЗначенияУсловия();
			КонецЕсли;
			
			ЭлементСпискаКУдалению=Элементы.Условие.СписокВыбора.НайтиПоЗначению(ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.ПоВидуОплаты"));
			Если НЕ ЭлементСпискаКУдалению=Неопределено Тогда
				Элементы.Условие.СписокВыбора.Удалить(ЭлементСпискаКУдалению);
			КонецЕсли;
		Иначе
			ЭлементСпискаКДобавлению=Элементы.Условие.СписокВыбора.НайтиПоЗначению(ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.ПоВидуОплаты"));
			Если ЭлементСпискаКДобавлению=Неопределено Тогда
				Элементы.Условие.СписокВыбора.Добавить(ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.ПоВидуОплаты"));
			КонецЕсли;
		КонецЕсли;

	ИначеЕсли Элемент.Имя="ОбщееВремяНачала" ИЛИ Элемент.Имя="ОбщееВремяОкончания" Тогда	
		Если Объект.ОбщееВремяНачала > Объект.ОбщееВремяОкончания Тогда
			Если Элемент.Имя="ОбщееВремяОкончания" Тогда
				Объект.ОбщееВремяНачала = Объект.ОбщееВремяОкончания;
			Иначе
				Объект.ОбщееВремяОкончания = Объект.ОбщееВремяНачала;
			КонецЕсли;
		КонецЕсли;
		
		Для Каждого СтрокаКоллекци Из Объект.ВремяПоДнямНедели Цикл
			СтрокаКоллекци.ВремяНачала=Объект.ОбщееВремяНачала;
			СтрокаКоллекци.ВремяОкончания=Объект.ОбщееВремяОкончания;
			СтрокаКоллекци.Выбран=Истина;
		КонецЦикла;		
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Время по дням недели"

&НаКлиенте
Процедура тпВремяПоДнямНедели_Колонка_ПриИзменении(Элемент)
	стрКолонка=стрЗаменить(Элемент.Имя, "ВремяПоДнямНедели", "");
	ТекущиеДанные=Элементы.ВремяПоДнямНедели.ТекущиеДанные;

	Если стрКолонка="ВремяНачала" Тогда
		Если ТекущиеДанные.ВремяНачала > ТекущиеДанные.ВремяОкончания Тогда
			ТекущиеДанные.ВремяОкончания = ТекущиеДанные.ВремяНачала;
		КонецЕсли;

	ИначеЕсли стрКолонка="ВремяНачала" Тогда
		Если ТекущиеДанные.ВремяНачала > ТекущиеДанные.ВремяОкончания Тогда
			ТекущиеДанные.ВремяНачала = ТекущиеДанные.ВремяОкончания;
		КонецЕсли;		
	КонецЕсли;	
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
		Для ъ=0 По 6 Цикл
			НоваяСтрока=Объект.ВремяПоДнямНедели.Добавить();
			НоваяСтрока.ДеньНедели     = ЗначениеПеречисления(ъ);
			НоваяСтрока.ВремяНачала    = '00010101000000';
			НоваяСтрока.ВремяОкончания = '00010101235959';
			НоваяСтрока.Выбран         = Истина;
		КонецЦикла;
		Объект.ОбщееВремяНачала='00010101000000';
		Объект.ОбщееВремяОкончания='00010101235959';
		Объект.Условие=ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.ПоСуммеДокумента");
		Объект.ВидСкидки=ПредопределенноеЗначение("Перечисление.ВидыСкидок.Розничная");
	КонецЕсли; 
	
	ИзменитьТипЗначенияУсловия();
	
	Элементы.Условие.СписокВыбора.Добавить(ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.ПоСуммеДокумента"));
	Элементы.Условие.СписокВыбора.Добавить(ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.ПоКоличествуТовара"));
	Элементы.Условие.СписокВыбора.Добавить(ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.ПоВидуОплаты"));
	Элементы.Условие.СписокВыбора.Добавить(ПредопределенноеЗначение("Перечисление.УсловияСкидкиНаценки.БезУсловий"));	

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