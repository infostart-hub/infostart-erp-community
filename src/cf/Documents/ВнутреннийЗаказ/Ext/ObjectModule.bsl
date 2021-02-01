﻿Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	Для Каждого СтрокаКоллекции Из Товары Цикл
		Если ЗначениеЗаполнено(СтрокаКоллекции.ЕдиницаИзмеренияМест) И СтрокаКоллекции.КоличествоМест=0 Тогда
			СтрокаКоллекции.ЕдиницаИзмеренияМест=Неопределено;
		КонецЕсли;		
	КонецЦикла;		
КонецПроцедуры

Функция ПараметрыУчетнойПолитики(Переписать=Ложь) Экспорт

	Если Переписать=Ложь Тогда
		Переписать=?(ДополнительныеСвойства.УчетнаяПолитика=Неопределено, Истина, Ложь);
	КонецЕсли;

	Если Переписать Тогда
		ДополнительныеСвойства.УчетнаяПолитика=ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(?(ЭтоНовый(), ТекущаяДата(), Дата), Ложь, Организация);
	КонецЕсли;

	Возврат ДополнительныеСвойства.УчетнаяПолитика;

КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Подготовка таблиц для проведения

Процедура ДополнитьТаблицуАтрибутамиШапки(СтруктураШД, тзСсылка, стрВидТабличнойЧасти)
	СтруктураРеквизитов=Новый Структура;
	СтруктураРеквизитов.Вставить("Организация", Организация);
	СтруктураРеквизитов.Вставить("Подразделение", Подразделение);
	СтруктураРеквизитов.Вставить("Период", Дата);
	СтруктураРеквизитов.Вставить("Активность", Истина);
	СтруктураРеквизитов.Вставить("ВидТабличнойЧасти", стрВидТабличнойЧасти);
	Для каждого СтрокаКоллекции Из СтруктураРеквизитов Цикл
		тзСсылка.Колонки.Добавить(СтрокаКоллекции.Ключ);
		тзСсылка.ЗаполнитьЗначения(СтрокаКоллекции.Значение, СтрокаКоллекции.Ключ);
	КонецЦикла;
КонецПроцедуры
 
Функция СформироватьТаблицу_Товары(СтруктураШД, Отказ, Заголовок)
	тзДанные=Товары.Выгрузить();
	тзДанные.Колонки.Размещение.Имя="Склад";
	тзДанные.Колонки.Добавить("НомерСтрокиТабличнойЧасти");

	Для каждого СтрокаКоллекции Из тзДанные Цикл
		СтрокаКоллекции.Количество=СтрокаКоллекции.Количество * СтрокаКоллекции.Коэффициент/СтрокаКоллекции.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент;
		СтрокаКоллекции.НомерСтрокиТабличнойЧасти=СтрокаКоллекции.НомерСтроки;
	КонецЦикла;

	ДополнитьТаблицуАтрибутамиШапки(СтруктураШД, тзДанные, "Товары");
	
	Возврат тзДанные;
КонецФункции

Функция СформироватьТаблицу_ТараВТ(СтруктураШД, Отказ, Заголовок)
	тзДанные=ВозвратнаяТара.Выгрузить();
	тзДанные.Колонки.Размещение.Имя="Склад";

	ДополнитьТаблицуАтрибутамиШапки(СтруктураШД, тзДанные, "Тара");

	Возврат тзДанные;	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Движения по регистрам 

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ)
	ДвиженияПоРегистрам_ВнутренниеЗаказы(СтруктураШД, СтруктураТД, Отказ);
	ДвижениеПоРегистру_УчетРезервовТМЦ(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвиженияПоРегистрам_ВнутренниеЗаказы(СтруктураШД, СтруктураТД, Отказ)
	тзДвижения=Движения.ВнутренниеЗаказы.ВыгрузитьКолонки();

	//Товары
	Для каждого СтркаКоллекции Из СтруктураТД.Товары Цикл
		ЗаполнитьЗначенияСвойств(тзДвижения.Добавить(), СтркаКоллекции);
	КонецЦикла; 

	//Возвратная тара
	Для каждого СтркаКоллекции  Из СтруктураТД.Тара Цикл
		ЗаполнитьЗначенияСвойств(тзДвижения.Добавить(), СтркаКоллекции);
	КонецЦикла;
	
	тзДвижения.ЗаполнитьЗначения(Ссылка, "ВнутреннийЗаказ");
	Движения.ВнутренниеЗаказы.Загрузить(тзДвижения);
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетРезервовТМЦ(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ Константы.УчетРезервов.Получить() Тогда Возврат; КонецЕсли; 
	
	СтруктураШД.Вставить("тзУчетРезервовТМЦ", Движения.УчетРезервовТМЦ.ВыгрузитьКолонки());
	Если Константы.УчетПотребностей.Получить() Тогда
		СтруктураШД.Вставить("тзУчетПотребностей", Движения.УчетПотребностей.ВыгрузитьКолонки());
	КонецЕсли;	
	УправлениеРезервамиСервер.СформироватьДвиженияПриход(СтруктураШД, СтруктураТД, Отказ);

	Движения.УчетРезервовТМЦ.Загрузить(СтруктураШД.тзУчетРезервовТМЦ);
	Если СтруктураШД.Свойство("тзУчетПотребностей") Тогда
		Движения.УчетПотребностей.Загрузить(СтруктураШД.тзУчетПотребностей);
	КонецЕсли;	
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

Процедура ОбработкаЗаполнения(Основание)
	Если Не ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание) Тогда Возврат; КонецЕсли;

	Если ТипЗнч(Основание)=Тип("ДокументСсылка.ЗаказНаПроизводство") Тогда
		Для Каждого СтрокаТабличнойЧасти Из Основание.Комплектующие Цикл
			ЗаполнитьЗначенияСвойств(Товары.Добавить(), СтрокаТабличнойЧасти);
		КонецЦикла;
	Иначе
		ЗаполнениеДокументов.ЗаполнитьТабличныеЧастиДокументаПоОснованию(ЭтотОбъект, Основание);
	КонецЕсли;	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Заголовок=ЗаполнениеДокументов.ПредставлениеДокументаПриПроведении(ЭтотОбъект);

	//Автозаполнение ревизитов шапки\табличных частей
	АвтоЗаполнениеРеквизитовДокумента();

	//Формирование значений реквизитов шапки документа
	СтруктураШД=УправлениеДокументамиСервер.СформироватьСтруктуруШД(ЭтотОбъект);

	//Формирование значений табличный частей документа
	СтруктураТД=Новый Структура;
	СтруктураТД.Вставить("Товары", СформироватьТаблицу_Товары(СтруктураШД, Отказ, Заголовок));
	СтруктураТД.Вставить("Тара"  , СформироватьТаблицу_ТараВТ(СтруктураШД, Отказ, Заголовок));

	//Инициализация доп.свойств документа	
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства);