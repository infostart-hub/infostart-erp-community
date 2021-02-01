﻿Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	Для каждого СтрокаКоллекции Из Товары Цикл
		Если ЗначениеЗаполнено(СтрокаКоллекции.ЕдиницаИзмеренияМест) И СтрокаКоллекции.КоличествоМест=0 Тогда
			СтрокаКоллекции.ЕдиницаИзмеренияМест=Неопределено;
		КонецЕсли;
	КонецЦикла;	
	Для каждого СтрокаКоллекции Из Комплектующие Цикл
		Если СтрокаКоллекции.Склад.Пустая() Тогда
			СтрокаКоллекции.Склад=Склад;
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

Функция КоэффициентПересчета(СтруктураШД)
	Если Не СтруктураШД.ВалютаДокумента=СтруктураШД.ВалютаРегламентированногоУчета Тогда
		Если Число(СтруктураШД.КурсДокумента)=0 Или Число(СтруктураШД.КратностьДокумента)=0 Тогда
			Возврат 1;
		КонецЕсли;
		Возврат СтруктураШД.КурсДокумента/СтруктураШД.КратностьДокумента;		
	КонецЕсли;
	Возврат 1; 
КонецФункции
 
Процедура ДополнитьТаблицуАтрибутамиШапки(СтруктураШД, тзСсылка, стрВидТабличнойЧасти)
	СтруктураРеквизитов=Новый Структура;
	СтруктураРеквизитов.Вставить("Организация", Организация);
	СтруктураРеквизитов.Вставить("Контрагент", Контрагент);
	СтруктураРеквизитов.Вставить("ДоговорКонтрагента", ДоговорКонтрагента);
	СтруктураРеквизитов.Вставить("Период", Дата);
	СтруктураРеквизитов.Вставить("Активность", Истина);
	СтруктураРеквизитов.Вставить("ВидТабличнойЧасти", стрВидТабличнойЧасти);
	Для каждого СтрокаКоллекции Из СтруктураРеквизитов Цикл
		тзСсылка.Колонки.Добавить(СтрокаКоллекции.Ключ);
		тзСсылка.ЗаполнитьЗначения(СтрокаКоллекции.Значение, СтрокаКоллекции.Ключ);
	КонецЦикла;
КонецПроцедуры
 
Функция СформироватьТаблицу_Товары(СтруктураШД, Отказ, Заголовок)
	ОписаниеТипаЧисло=ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15, 2);
	КоэффициентПересчета=КоэффициентПересчета(СтруктураШД);

	тзДанные=Товары.Выгрузить();
	тзДанные.Колонки.Добавить("Услуга");
	тзДанные.Колонки.Добавить("Набор");
	тзДанные.Колонки.Добавить("Комплект");
	тзДанные.Колонки.Добавить("НомерСтрокиТабличнойЧасти"); //НомерСтроки
	тзДанные.Колонки.Добавить("КоличествоВЕдиницахДокумента"); //Количество
	тзДанные.Колонки.Добавить("КоличествоДок"); //Количество

	Для каждого СтрокаКоллекции Из тзДанные Цикл
		СтрокаКоллекции.КоличествоВЕдиницахДокумента=СтрокаКоллекции.Количество;
		СтрокаКоллекции.КоличествоДок=СтрокаКоллекции.Количество;
		СтрокаКоллекции.Количество=СтрокаКоллекции.Количество * СтрокаКоллекции.Коэффициент /СтрокаКоллекции.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент;
		СтрокаКоллекции.НомерСтрокиТабличнойЧасти=СтрокаКоллекции.НомерСтроки;
		СтрокаКоллекции.Услуга=СтрокаКоллекции.Номенклатура.Услуга;
		СтрокаКоллекции.Набор=СтрокаКоллекции.Номенклатура.Набор;
		СтрокаКоллекции.Комплект=СтрокаКоллекции.Номенклатура.Комплект;
		СтрокаКоллекции.ЕдиницаИзмерения=СтрокаКоллекции.Номенклатура.ЕдиницаХраненияОстатков;
		СтрокаКоллекции.Сумма=Окр(СтрокаКоллекции.Сумма*КоэффициентПересчета, 2);
		Если СтрокаКоллекции.Набор Тогда
			стрСообщение="В строке номер """+СокрЛП(СтрокаКоллекции.НомерСтроки)+""" табличной части ""Товары"": ";
			стрСообщение=стрСообщение+"содержится набор-пакет. Наборов-пакетов здесь быть не должно!";
			ОбщегоНазначения.СообщитьОбОшибке(стрСообщение, Отказ, Заголовок);
		КонецЕсли;
	КонецЦикла;
	
	ДополнитьТаблицуАтрибутамиШапки(СтруктураШД, тзДанные, "Товары");
	
	Возврат тзДанные;
КонецФункции

Функция СформироватьТаблицу_Комплектующие(СтруктураШД, Отказ, Заголовок)
	ОписаниеТипаЧисло=ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15, 2);
	КоэффициентПересчета=КоэффициентПересчета(СтруктураШД);

	тзДанные=Комплектующие.Выгрузить();
	тзДанные.Колонки.Добавить("Услуга");
	тзДанные.Колонки.Добавить("Набор");
	тзДанные.Колонки.Добавить("Комплект");
	тзДанные.Колонки.Добавить("ВестиУчетПоХарактеристикам");
	тзДанные.Колонки.Добавить("НомерСтрокиТабличнойЧасти"); //НомерСтроки
	тзДанные.Колонки.Добавить("КоличествоВЕдиницахДокумента"); //Количество
	тзДанные.Колонки.Добавить("КоличествоДок"); //Количество
	тзДанные.Колонки.Добавить("ВидЦенности");
	тзДанные.Колонки.Добавить("Ценность");	

	Для каждого СтрокаКоллекции Из тзДанные Цикл
		СтрокаКоллекции.КоличествоВЕдиницахДокумента=СтрокаКоллекции.Количество;
		СтрокаКоллекции.КоличествоДок=СтрокаКоллекции.Количество;
		СтрокаКоллекции.Количество=СтрокаКоллекции.Количество * СтрокаКоллекции.Коэффициент /СтрокаКоллекции.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент;
		СтрокаКоллекции.НомерСтрокиТабличнойЧасти=СтрокаКоллекции.НомерСтроки;
		СтрокаКоллекции.Услуга=СтрокаКоллекции.Номенклатура.Услуга;
		СтрокаКоллекции.Набор=СтрокаКоллекции.Номенклатура.Набор;
		СтрокаКоллекции.Комплект=СтрокаКоллекции.Номенклатура.Комплект;
		СтрокаКоллекции.ЕдиницаИзмерения=СтрокаКоллекции.Номенклатура.ЕдиницаХраненияОстатков;
		СтрокаКоллекции.ВестиУчетПоХарактеристикам=СтрокаКоллекции.Номенклатура.ВестиУчетПоХарактеристикам;
		СтрокаКоллекции.Сумма=Окр(СтрокаКоллекции.Сумма*КоэффициентПересчета, 2);
		Если СтрокаКоллекции.Набор Тогда
			стрСообщение="В строке номер """+СокрЛП(СтрокаКоллекции.НомерСтроки)+""" табличной части ""Товары"": ";
			стрСообщение=стрСообщение+"содержится набор-пакет. Наборов-пакетов здесь быть не должно!";
			ОбщегоНазначения.СообщитьОбОшибке(стрСообщение, Отказ, Заголовок);
		КонецЕсли;
	КонецЦикла;
	
	УчетНДС.ОпределениеДополнительныхПараметровТаблицыПартийДляПодсистемыУчетаНДС(СтруктураШД, тзДанные);
	
	ДополнитьТаблицуАтрибутамиШапки(СтруктураШД, тзДанные, "Комплектующие");
	
	Возврат тзДанные;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Движения по регистрам 

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_ЗаказыНаПроизводство(СтруктураШД, СтруктураТД, Отказ);
	ДвижениеПоРегистру_УчетРезервовТМЦ(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_ЗаказыНаПроизводство(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ЗаказыНаПроизводство") Тогда Возврат; КонецЕсли;
	тзДвидения=Движения.ЗаказыНаПроизводство.ВыгрузитьКолонки();

	Для Каждого СтрокаТабличнойЧасти Из СтруктураТД.Товары Цикл
		НоваяСтрока=тзДвидения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТабличнойЧасти);
		НоваяСтрока.Стоимость=СтрокаТабличнойЧасти.Сумма;
	КонецЦикла;

	тзДвидения.ЗаполнитьЗначения(Ссылка, "ЗаказНаряд");
	тзДвидения.ЗаполнитьЗначения(ПериодВыпускаПо, "ДатаВыпуска");
	тзДвидения.ЗаполнитьЗначения(ВидДвиженияНакопления.Приход, "ВидДвижения");

	Движения.ЗаказыНаПроизводство.Загрузить(тзДвидения);
КонецПроцедуры

Процедура ДвижениеПоРегистру_СписанныеТовары(СтруктураШД, СтруктураТД, Отказ)
	Если Константы.УчетРезервов.Получить() Тогда Возврат; КонецЕсли; 
	тзДвижения=Движения.СписанныеТовары.ВыгрузитьКолонки(); НомерСтроки=0;
	
	//Материалы
	Для каждого СтрокаКоллекции Из СтруктураТД.Комплектующие Цикл
		НоваяСтрока=тзДвижения.Добавить(); НомерСтроки=НомерСтроки+1;
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		НоваяСтрока.НомерСтрокиДокумента=НомерСтроки;
		НоваяСтрока.ВидТабличнойЧасти="Товары";
		НоваяСтрока.ДопустимыйСтатус1=Перечисления.СтатусыПартийТоваров.Купленный;
		НоваяСтрока.ДопустимыйСтатус3=Перечисления.СтатусыПартийТоваров.НаКомиссию;
	КонецЦикла; 

    Если тзДвижения.Количество()=0 Тогда Возврат; КонецЕсли; 

	тзДвижения.ЗаполнитьЗначения(Дата, "Период");
	тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
    тзДвижения.ЗаполнитьЗначения(Перечисления.КодыОперацийПартииТоваров.РезервированиеПодЗаказ, "КодОперацииПартииТоваров");
	тзДвижения.ЗаполнитьЗначения(Истина, "СписыватьТолькоПоЗаказу");
	тзДвижения.ЗаполнитьЗначения(Ссылка, "ЗаказСписания");
	тзДвижения.ЗаполнитьЗначения(ЦФО, "Подразделение");

	Движения.СписанныеТовары.Загрузить(тзДвижения);
	Движения.СписанныеТовары.Записать(Истина);
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
// Обработчики событий модуля

Процедура ОбработкаЗаполнения(Основание)
	Если Не ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание) Тогда Возврат; КонецЕсли;
	ЗаполнениеДокументов.ЗаполнитьТабличныеЧастиДокументаПоОснованию(ЭтотОбъект, Основание);
КонецПроцедуры

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
	СтруктураШД=УправлениеДокументамиСервер.СформироватьСтруктуруШД(ЭтотОбъект);

	//Формирование значений табличный частей документа
	СтруктураТД=Новый Структура;
	СтруктураТД.Вставить("Товары", СформироватьТаблицу_Товары(СтруктураШД, Отказ, Заголовок));
	СтруктураТД.Вставить("Комплектующие", СформироватьТаблицу_Комплектующие(СтруктураШД, Отказ, Заголовок));

	//Инициализация доп.свойств документа	
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	ДокументОснование=Неопределено;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства);
