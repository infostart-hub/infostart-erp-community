﻿Функция ПараметрыУчетнойПолитики(Переписать=Ложь) Экспорт

	Если Переписать=Ложь Тогда
		Переписать=?(ДополнительныеСвойства.УчетнаяПолитика=Неопределено, Истина, Ложь);
	КонецЕсли;

	Если Переписать Тогда
		ДополнительныеСвойства.УчетнаяПолитика=ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(?(ЭтоНовый(), ТекущаяДата(), Дата), Ложь, Организация);
	КонецЕсли;

	Возврат ДополнительныеСвойства.УчетнаяПолитика;

КонецФункции

Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Движения по регистрам 

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_НДСПредъявленный(СтруктураШД, СтруктураТД, Отказ);
	ДвижениеПоРегистру_Хозрасчетный(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_Хозрасчетный(СтруктураШД, СтруктураТД, Отказ)
Перем мКэшВидовСубконтоПоСчетам;
	Для Каждого Строка Из СтруктураТД.Состав Цикл
		Если (Строка.СуммаБезНДС=0) Или (Строка.НДС=0) Тогда Продолжить; КонецЕсли;

		Проводка=Движения.Хозрасчетный.Добавить();
		Проводка.Период=СтруктураШД.Дата;
		Проводка.Организация=СтруктураШД.Организация;
		Проводка.Содержание="Списан НДС";
		Проводка.СчетДт=СтруктураШД.СчетСписанияНДС;
		
		БухгалтерскийУчет.УстановитьСубконтоПоСчету(Проводка.СчетДт, Проводка.СубконтоДт, 1, СтруктураШД.СубконтоСписанияНДС1,,,ОбщегоНазначения.ОпределитьВидСубконтоПоСчету(Проводка.СчетДт, мКэшВидовСубконтоПоСчетам));
		БухгалтерскийУчет.УстановитьСубконтоПоСчету(Проводка.СчетДт, Проводка.СубконтоДт, 2, СтруктураШД.СубконтоСписанияНДС2,,,ОбщегоНазначения.ОпределитьВидСубконтоПоСчету(Проводка.СчетДт, мКэшВидовСубконтоПоСчетам));
		БухгалтерскийУчет.УстановитьСубконтоПоСчету(Проводка.СчетДт, Проводка.СубконтоДт, 3, СтруктураШД.СубконтоСписанияНДС3,,,ОбщегоНазначения.ОпределитьВидСубконтоПоСчету(Проводка.СчетДт, мКэшВидовСубконтоПоСчетам));
		
		Проводка.СчетКт=Строка.СчетУчетаНДС; //19.XX
		БухгалтерскийУчет.УстановитьСубконтоПоСчету(Проводка.СчетКт, Проводка.СубконтоКт, "Контрагенты", Строка.Поставщик,,,ОбщегоНазначения.ОпределитьВидСубконтоПоСчету(Проводка.СчетКт, мКэшВидовСубконтоПоСчетам));
		БухгалтерскийУчет.УстановитьСубконтоПоСчету(Проводка.СчетКт, Проводка.СубконтоКт, "СФПолученные", Строка.СчетФактура,,,ОбщегоНазначения.ОпределитьВидСубконтоПоСчету(Проводка.СчетКт, мКэшВидовСубконтоПоСчетам));
		
		Проводка.Сумма=Строка.НДС;			
	КонецЦикла;	
КонецПроцедуры

Процедура ДвижениеПоРегистру_НДСПредъявленный(СтруктураШД, СтруктураТД, Отказ)
	тзДвижения=Движения.НДСПредъявленный.ВыгрузитьКолонки();
	Для каждого СтрокаКоллекции Из СтруктураТД.Состав Цикл
		ЗаполнитьЗначенияСвойств(тзДвижения.Добавить(), СтрокаКоллекции);
	КонецЦикла;
	тзДвижения.ЗаполнитьЗначения(Дата, "Период");
	тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
	тзДвижения.ЗаполнитьЗначения(Ссылка, "Регистратор");
	тзДвижения.ЗаполнитьЗначения(Перечисления.СобытияПоНДСПокупки.НДСсписанНаРасходы,"Событие");
	тзДвижения.ЗаполнитьЗначения(Дата,"ДатаСобытия");
	тзДвижения.ЗаполнитьЗначения(ВидДвиженияНакопления.Расход, "ВидДвижения");
	Движения.НДСПредъявленный.Загрузить(тзДвижения);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	УправлениеДокументамиСервер.ПередПроведением(Отказ, РежимПроведения, ЭтотОбъект);
	Если Отказ Тогда Возврат; КонецЕсли; 

	СтруктураШД=ДополнительныеСвойства.СтруктураШД;
	СтруктураТД=ДополнительныеСвойства.СтруктураТД;

	Если ДополнительныеСвойства.Свойство("РегистрыДляПроведения") Тогда
		Для каждого СтрокаМассива Из ДополнительныеСвойства.РегистрыДляПроведения Цикл
			Выполнить("ДвижениеПоРегистру_"+СтрокаМассива+"(СтруктураШД, СтруктураТД, Отказ);");
		КонецЦикла;
		Возврат;
	КонецЕсли;

	ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Заголовок=ЗаполнениеДокументов.ПредставлениеДокументаПриПроведении(ЭтотОбъект);

	//Автозаполнение ревизитов шапки\табличных частей
	АвтоЗаполнениеРеквизитовДокумента();

	//Формирование значений реквизитов шапки документа
	СтруктураШД=УправлениеДокументамиСервер.ПолучитьСтруктуруРеквизитовШапки(ЭтотОбъект);

	//Формирование значений реквизитов табличных частей
	//СтруктураТД=Новый Структура("Состав", УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "Состав", "СчетФактура.ДоговорКонтрагента Как СчетФактураДоговорКонтрагента,"));
	СтруктураТД=Новый Структура("Состав", УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "Состав"));

	//Инициализация доп.свойств документа	
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства, "Продажа");