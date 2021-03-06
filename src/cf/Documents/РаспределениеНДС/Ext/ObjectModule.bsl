﻿Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	
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

Процедура РаспределитьПоВыручке() Экспорт

	БазаРаспределенияСЕНВД = ВыручкаНДС + ВыручкаБезНДС + ВыручкаЕНВД + ВыручкаНДС0;
	БазаРаспределенияБезЕНВД =  ВыручкаНДС + ВыручкаБезНДС + ВыручкаНДС0;

	Если БазаРаспределенияСЕНВД = 0 Тогда
		Сообщить("На закладке ""Выручка от реализации"" не указаны параметры реализации!", СтатусСообщения.Внимание);
		Возврат;
	КонецЕсли;

	Для Каждого СтрТабЧасти Из СоставКосвенныхРасходов Цикл
		
		Если СтрТабЧасти.БазисРаспределенияВключаетЕНВД Тогда
		    БазаРаспределения = БазаРаспределенияСЕНВД;
		Иначе
		    БазаРаспределения = БазаРаспределенияБезЕНВД;
		КонецЕсли; 

		УчтеноСуммы   = 0;
		УчтеноНДС     = 0;
		УчтеноВыручки = 0;

		Если ВыручкаНДС <> 0 Тогда
			СтрТабЧасти.НДССумма = Окр(СтрТабЧасти.СуммаВсего * (ВыручкаНДС + УчтеноВыручки)/БазаРаспределения, 2) - УчтеноСуммы;
			СтрТабЧасти.НДС      = Окр(СтрТабЧасти.НДСВсего * (ВыручкаНДС + УчтеноВыручки)/БазаРаспределения, 2) - УчтеноНДС;

			УчтеноСуммы     = УчтеноСуммы + СтрТабЧасти.НДССумма;
			УчтеноНДС       = УчтеноНДС + СтрТабЧасти.НДС;
			УчтеноВыручки   = УчтеноВыручки + ВыручкаНДС;
		Иначе
			СтрТабЧасти.НДССумма = 0;
			СтрТабЧасти.НДС      = 0;
		КонецЕсли;

		Если ВыручкаБезНДС <> 0 Тогда
			СтрТабЧасти.БезНДССумма = Окр(СтрТабЧасти.СуммаВсего * (ВыручкаБезНДС + УчтеноВыручки)/БазаРаспределения, 2) - УчтеноСуммы;
			СтрТабЧасти.БезНДС      = Окр(СтрТабЧасти.НДСВсего * (ВыручкаБезНДС + УчтеноВыручки)/БазаРаспределения, 2) - УчтеноНДС;

			УчтеноСуммы   = УчтеноСуммы + СтрТабЧасти.БезНДССумма;
			УчтеноНДС     = УчтеноНДС + СтрТабЧасти.БезНДС;
			УчтеноВыручки = УчтеноВыручки + ВыручкаБезНДС;
		Иначе
			СтрТабЧасти.БезНДССумма = 0;
			СтрТабЧасти.БезНДС      = 0;
		КонецЕсли;

		Если ВыручкаЕНВД <> 0 и СтрТабЧасти.БазисРаспределенияВключаетЕНВД Тогда
			СтрТабЧасти.ЕНВДСумма = Окр(СтрТабЧасти.СуммаВсего * (ВыручкаЕНВД + УчтеноВыручки)/БазаРаспределения, 2) - УчтеноСуммы;
			СтрТабЧасти.ЕНВДНДС   = Окр(СтрТабЧасти.НДСВсего *   (ВыручкаЕНВД + УчтеноВыручки)/БазаРаспределения, 2) - УчтеноНДС;

			УчтеноСуммы   = УчтеноСуммы + СтрТабЧасти.ЕНВДСумма;
			УчтеноНДС     = УчтеноНДС + СтрТабЧасти.ЕНВДНДС;
			УчтеноВыручки = УчтеноВыручки + ВыручкаЕНВД;
		Иначе
			СтрТабЧасти.ЕНВДСумма = 0;
			СтрТабЧасти.ЕНВДНДС   = 0;
		КонецЕсли;
		
		Если ВыручкаНДС0 <> 0 Тогда
			СтрТабЧасти.НДС0Сумма = Окр(СтрТабЧасти.СуммаВсего * (ВыручкаНДС0 + УчтеноВыручки)/БазаРаспределения, 2) - УчтеноСуммы;
			СтрТабЧасти.НДС0      = Окр(СтрТабЧасти.НДСВсего * (ВыручкаНДС0 + УчтеноВыручки)/БазаРаспределения, 2) - УчтеноНДС;

			УчтеноСуммы   = УчтеноСуммы + СтрТабЧасти.НДС0Сумма;
			УчтеноНДС     = УчтеноНДС + СтрТабЧасти.НДС0;
			УчтеноВыручки = УчтеноВыручки + ВыручкаНДС0;
		Иначе
			СтрТабЧасти.НДС0Сумма = 0;
			СтрТабЧасти.НДС0      = 0;
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

Процедура РассчитатьВыручку() Экспорт

	ВыручкаЕНВД   = 0;
	ВыручкаБезНДС = 0;
	ВыручкаНДС0   = 0;
	ВыручкаНДС    = 0;

	Отказ = Ложь;
	КонецПериода = УчетНалоговСервер.КонецПериодаПоУчетнойПолитике(Организация, НачалоПериода, Отказ);
	
	Если Не Отказ Тогда
		Выручка=УчетНалоговСервер.РассчитатьВыручкуДляНДС(Организация, НачалоПериода, КонецПериода);
		ЗаполнитьЗначенияСвойств(ЭтотОбъект,Выручка);
		//УчетНДС.РассчитатьВыручкуДляНДС(Организация, НачалоПериода, КонецПериода, ВыручкаЕНВД, ВыручкаБезНДС, ВыручкаНДС0, ВыручкаНДС);
	КонецЕсли;

КонецПроцедуры

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ)
	//Движения регистру "Учет НДС (предъявленный)"
	ДвижениеПоРегистру_НДСПредъявленный(СтруктураШД, СтруктураТД, Отказ);
	
	ДвижениеПоРегистру_НДСКосвенныеРасходы(СтруктураШД, СтруктураТД, Отказ);
	
	ДвижениеПоРегистру_НДСВключенныйВСтоимость(СтруктураШД, СтруктураТД, Отказ);
	
	ДвижениеПоРегистру_Хозрасчетный(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_НДСПредъявленный(СтруктураШД, СтруктураТД, Отказ)
    тзДвижения=Движения.НДСПредъявленный.ВыгрузитьКолонки();
	Для каждого СтрокаКоллекции Из СтруктураТД.СоставКосвенныхРасходов Цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		НоваяСтрока.СуммаБезНДС=СтрокаКоллекции.БезНДССумма+СтрокаКоллекции.ЕНВДСумма+СтрокаКоллекции.НДС0Сумма;
		НоваяСтрока.НДС=СтрокаКоллекции.БезНДС+СтрокаКоллекции.ЕНВДНДС+СтрокаКоллекции.НДС0;
		НоваяСтрока.ВидДвижения=ВидДвиженияНакопления.Расход;
	КонецЦикла;	
	Движения.НДСПредъявленный.Загрузить(тзДвижения);
КонецПроцедуры
 
Процедура ДвижениеПоРегистру_Хозрасчетный(СтруктураШД, СтруктураТД, Отказ)
	Для каждого СтрокаКоллекции Из СтруктураТД.СоставКосвенныхРасходов Цикл
		НоваяСтрока=Движения.Хозрасчетный.Добавить();
		НоваяСтрока.Организация=Организация;
		НоваяСтрока.Период=Дата;
		НоваяСтрока.Активность=Истина;
		НоваяСтрока.СчетКт=СтрокаКоллекции.СчетУчетаНДС;
		НоваяСтрока.СубконтоКт.Вставить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты, СтрокаКоллекции.Поставщик);
		НоваяСтрока.СубконтоКт.Вставить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.СФПолученные, СтрокаКоллекции.СчетФактура);

		Если ДляСписанияНДСиспользоватьСчетИАналитикуУчетаЗатрат Тогда
			НоваяСтрока.СчетДт=СчетСписанияНДС;
			БухгалтерскийУчет.УстановитьСубконтоПоСчету(НоваяСтрока.СчетДт, НоваяСтрока.СубконтоДт, 1, СубконтоСписанияНДС1);
			БухгалтерскийУчет.УстановитьСубконтоПоСчету(НоваяСтрока.СчетДт, НоваяСтрока.СубконтоДт, 2, СубконтоСписанияНДС2);
			БухгалтерскийУчет.УстановитьСубконтоПоСчету(НоваяСтрока.СчетДт, НоваяСтрока.СубконтоДт, 3, СубконтоСписанияНДС3);
			Если НоваяСтрока.СчетДт.УчетПоПодразделениям Тогда
				НоваяСтрока.ПодразделениеДт=СубконтоПодразделение;
			КонецЕсли;
			НоваяСтрока.Сумма=СтрокаКоллекции.БезНДС+СтрокаКоллекции.ЕНВДНДС+СтрокаКоллекции.НДС0;			
			Если ДополнительныеСвойства.УчетнаяПолитика.СистемаНалогообложения=Перечисления.СистемыНалогообложения.Общая ИЛИ
				ДополнительныеСвойства.УчетнаяПолитика.СистемаНалогообложения=Перечисления.СистемыНалогообложения.Общая_ЕНВД Тогда
				Если НоваяСтрока.СчетДт.НалоговыйУчет Тогда
					НоваяСтрока.СуммаНУДт=НоваяСтрока.Сумма;
				КонецЕсли;	
			КонецЕсли;	
		Иначе
			МассивСтрок=СтруктураТД.СчетаУчетаРасходов.НайтиСтроки(Новый Структура("ID_СоставКосвенныхРасходов", СтрокаКоллекции.ID));
			Для каждого СтрокаМассива Из МассивСтрок Цикл
				НоваяСтрока.СчетДт=СтрокаМассива.СчетЗатрат;
				БухгалтерскийУчет.УстановитьСубконтоПоСчету(НоваяСтрока.СчетДт, НоваяСтрока.СубконтоДт, 1, СтрокаМассива.Субконто1);
				БухгалтерскийУчет.УстановитьСубконтоПоСчету(НоваяСтрока.СчетДт, НоваяСтрока.СубконтоДт, 2, СтрокаМассива.Субконто2);
				БухгалтерскийУчет.УстановитьСубконтоПоСчету(НоваяСтрока.СчетДт, НоваяСтрока.СубконтоДт, 3, СтрокаМассива.Субконто3);
				Если НоваяСтрока.СчетДт.УчетПоПодразделениям Тогда
					НоваяСтрока.ПодразделениеДт=СтрокаМассива.Подразделение;
				КонецЕсли;
				НоваяСтрока.Сумма=СтрокаКоллекции.БезНДС+СтрокаКоллекции.ЕНВДНДС+СтрокаКоллекции.НДС0;
				Если ДополнительныеСвойства.УчетнаяПолитика.СистемаНалогообложения=Перечисления.СистемыНалогообложения.Общая ИЛИ
					ДополнительныеСвойства.УчетнаяПолитика.СистемаНалогообложения=Перечисления.СистемыНалогообложения.Общая_ЕНВД Тогда
					Если НоваяСтрока.СчетДт.НалоговыйУчет Тогда
						НоваяСтрока.СуммаНУДт=НоваяСтрока.Сумма;
					КонецЕсли;	
				КонецЕсли;	
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура ДвижениеПоРегистру_НДСКосвенныеРасходы(СтруктураШД, СтруктураТД, Отказ)
	 тзДвижения=Движения.НДСКосвенныеРасходы.ВыгрузитьКолонки();
	Для каждого СтрокаКоллекции Из СтруктураТД.СоставКосвенныхРасходов Цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		НоваяСтрока.СуммаБезНДС=СтрокаКоллекции.СуммаВсего;
		НоваяСтрока.НДС=СтрокаКоллекции.НДСВсего;
		НоваяСтрока.ВидДвижения=ВидДвиженияНакопления.Расход;
	КонецЦикла;	
	Движения.НДСКосвенныеРасходы.Загрузить(тзДвижения);

	
	
	//Если  СтруктураТД.СоставКосвенныхРасходов.Количество()=0 Тогда Возврат; КонецЕсли;
	//
	//тзДвижения = Движения.НДСКосвенныеРасходы;
	//ТаблицаДвиженийНДСКосвенныеРасходы = тзДвижения.ВыгрузитьКолонки();
	//
	//ТаблицаДляРаспределения = СтруктураТД.СоставКосвенныхРасходов.Скопировать();
	//ТаблицаДляРаспределения.Колонки.Удалить("НДС");
	//ТаблицаДляРаспределения.Колонки.НДСВсего.Имя = "НДС";
	//ТаблицаДляРаспределения.Колонки.СуммаВсего.Имя = "СуммаБезНДС";
	//
	//ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаДляРаспределения, ТаблицаДвиженийНДСКосвенныеРасходы);
	//ТаблицаДвиженийНДСКосвенныеРасходы.ЗаполнитьЗначения(СтруктураШД.Организация, "Организация");
	//
	//Если Не Отказ Тогда
	//	тзДвижения.мПериод = СтруктураШД.Дата;
	//	тзДвижения.мТаблицаДвижений = ТаблицаДвиженийНДСКосвенныеРасходы;
	//	тзДвижения.ВыполнитьРасход();
	//КонецЕсли;
КонецПроцедуры

Процедура ДвижениеПоРегистру_НДСВключенныйВСтоимость(СтруктураШД, СтруктураТД, Отказ)
    тзДвижения=Движения.НДСВключенныйВСтоимость.ВыгрузитьКолонки();
	Для каждого СтрокаКоллекции Из СтруктураТД.СоставКосвенныхРасходов Цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		НоваяСтрока.СуммаБезНДС=СтрокаКоллекции.БезНДССумма+СтрокаКоллекции.ЕНВДСумма+СтрокаКоллекции.НДС0Сумма;
		НоваяСтрока.НДС=СтрокаКоллекции.БезНДС+СтрокаКоллекции.ЕНВДНДС+СтрокаКоллекции.НДС0;
	КонецЦикла;	
	Движения.НДСВключенныйВСтоимость.Загрузить(тзДвижения);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий модуля

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
	СтруктураТД=Новый Структура;
	СтруктураТД.Вставить("СоставКосвенныхРасходов", УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "СоставКосвенныхРасходов"));
	СтруктураТД.Вставить("СчетаУчетаРасходов", УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "СчетаУчетаРасходов"));

	//Инициализация доп.свойств документа
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства, "Продажа");