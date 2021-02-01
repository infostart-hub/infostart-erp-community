﻿Функция ПараметрыУчетнойПолитики(Переписать=Ложь) Экспорт

	Если Переписать=Ложь Тогда
		Переписать=?(ДополнительныеСвойства.УчетнаяПолитика=Неопределено, Истина, Ложь);
	КонецЕсли;

	Если Переписать Тогда
		ДополнительныеСвойства.УчетнаяПолитика=ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(?(ЭтоНовый(), ТекущаяДата(), Дата), Ложь, Организация);
	КонецЕсли;

	Возврат ДополнительныеСвойства.УчетнаяПолитика;

КонецФункции

Процедура ПодготовитьТаблицуТоваровУпр(ТаблицаТоваров, СтруктураШД)
    ОписаниеТипа=ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15, 2);
	
	// Надо добавить колонки "СуммаБезНДС" и "КоличествоДопРасходы".
	ТаблицаТоваров.Колонки.Добавить("СуммаБезНДС",          ОписаниеТипа);
	ТаблицаТоваров.Колонки.Добавить("КоличествоДопРасходы", ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15, 3));
	ТаблицаТоваров.Колонки.Добавить("СтоимостьБезСкидок",   ОписаниеТипа);
	ТаблицаТоваров.Колонки.Добавить("НДСУпр",               ОписаниеТипа);
	ТаблицаТоваров.Колонки.Добавить("Контрагент");
	ТаблицаТоваров.Колонки.Добавить("СтоимостьСписаниеУУ", ОписаниеТипа);
	ТаблицаТоваров.Колонки.Добавить("СтоимостьСписаниеНУ", ОписаниеТипа);
	

	Если СтруктураШД.ВидСклада = Перечисления.ВидыСкладов.Розничный Тогда
		ИмяКолонкиЦена = "ЦенаВРознице";
	Иначе
		ИмяКолонкиЦена = "Цена";
	КонецЕсли;

	// Надо заполнить новые колонки.
	Для каждого СтрокаТаблицы Из ТаблицаТоваров Цикл
		СтрокаТаблицы.СтоимостьСписаниеУУ=СтрокаТаблицы.СебестоимостьУУ;
		СтрокаТаблицы.СтоимостьСписаниеНУ=СтрокаТаблицы.СебестоимостьНУ;
		
		СтрокаТаблицы.СуммаНДС    = СтрокаТаблицы.НДС;
		СтрокаТаблицы.СуммаБезНДС = СтрокаТаблицы.Сумма - ?(УчитыватьНДС И СуммаВключаетНДС, СтрокаТаблицы.НДС, 0);
		СтрокаТаблицы.Стоимость   = СтрокаТаблицы.СуммаБезНДС + СтрокаТаблицы.НДС;
		СтрокаТаблицы.КоличествоДопРасходы = 0;
		ТекЦена = СтрокаТаблицы[ИмяКолонкиЦена];
		СтрокаТаблицы.СтоимостьБезСкидок = ТекЦена * ?(НЕ ЗначениеЗаполнено(СтрокаТаблицы.КоличествоДок), 0, СтрокаТаблицы.КоличествоДок);
		Если УчитыватьНДС И Не СуммаВключаетНДС Тогда
			СтрокаТаблицы.СтоимостьБезСкидок = СтрокаТаблицы.СтоимостьБезСкидок + УчетНалоговСервер.РассчитатьСуммуНДС(СтрокаТаблицы.СтоимостьБезСкидок, 
												УчитыватьНДС, СуммаВключаетНДС, УчетНалоговСервер.СтавкаНДС(СтрокаТаблицы.СтавкаНДС));
		КонецЕсли;		
		СтрокаТаблицы.Стоимость            = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.Стоимость, ДополнительныеСвойства.ВалютаБухУчета,
		                                   СтруктураШД.ВалютаУправленческогоУчета,
		                                   1, СтруктураШД.КурсВалютыУправленческогоУчета,
		                                   1, СтруктураШД.КратностьВалютыУправленческогоУчета);
		СтрокаТаблицы.НДСУпр               = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.НДС, ДополнительныеСвойства.ВалютаБухУчета,
		                                   СтруктураШД.ВалютаУправленческогоУчета,
		                                   1, СтруктураШД.КурсВалютыУправленческогоУчета,
		                                   1, СтруктураШД.КратностьВалютыУправленческогоУчета);
		СтрокаТаблицы.СтоимостьБезСкидок   = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.СтоимостьБезСкидок, ДополнительныеСвойства.ВалютаБухУчета,
		                                   СтруктураШД.ВалютаУправленческогоУчета,
		                                   1, СтруктураШД.КурсВалютыУправленческогоУчета,
		                                   1, СтруктураШД.КратностьВалютыУправленческогоУчета);

		Если ЗначениеЗаполнено(СтрокаТаблицы.ФизЛицо) Тогда
			Если ТипЗнч(СтрокаТаблицы.ФизЛицо)=Тип("СправочникСсылка.Контрагенты") Тогда
				СтрокаТаблицы.Контрагент=СтрокаТаблицы.ФизЛицо;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры 

Функция ПодготовитьТаблицуСкидок(ТаблицаТоваров, СтруктураШД)

	ТаблицаДвижений=Новый ТаблицаЗначений;
	ТаблицаДвижений.Колонки.Добавить("Номенклатура");
	ТаблицаДвижений.Колонки.Добавить("ПолучательСкидки");
	ТаблицаДвижений.Колонки.Добавить("ХарактеристикаНоменклатуры");
	ТаблицаДвижений.Колонки.Добавить("УсловиеСкидки");
	ТаблицаДвижений.Колонки.Добавить("ЗначениеУсловияСкидки");
	ТаблицаДвижений.Колонки.Добавить("СуммаСкидки", ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,2));

	Если СтруктураШД.ВидСклада = Перечисления.ВидыСкладов.Розничный Тогда
		ИмяКолонкиЦена = "ЦенаВРознице";
	Иначе
		ИмяКолонкиЦена = "Цена";
	КонецЕсли;

	Для каждого СтрокаТаблицы Из ТаблицаТоваров Цикл
		СуммаБезСкидки = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(Окр(СтрокаТаблицы[ИмяКолонкиЦена] * ?(НЕ ЗначениеЗаполнено(СтрокаТаблицы.КоличествоВЕдиницахДокумента), 0, СтрокаТаблицы.КоличествоВЕдиницахДокумента), 2), ДополнительныеСвойства.ВалютаБухУчета,
		   СтруктураШД.ВалютаУправленческогоУчета,
		   1, СтруктураШД.КурсВалютыУправленческогоУчета,
		   1, СтруктураШД.КратностьВалютыУправленческогоУчета);

		СуммаСоСкидками = СуммаБезСкидки;
		СкидкиЕсть = Ложь;

		//Автоматические скидки.
		Если СтрокаТаблицы.ПроцентАвтоматическихСкидок <> 0 Тогда
			СтрокаДвижений = ТаблицаДвижений.Добавить();
			СтрокаДвижений.Номенклатура = СтрокаТаблицы.Номенклатура;
			СтрокаДвижений.ПолучательСкидки = СтрокаТаблицы.Склад;
			СтрокаДвижений.ХарактеристикаНоменклатуры = СтрокаТаблицы.ХарактеристикаНоменклатуры;
			СтрокаДвижений.УсловиеСкидки = СтрокаТаблицы.УсловиеАвтоматическойСкидки;
			СтрокаДвижений.ЗначениеУсловияСкидки = СтрокаТаблицы.ЗначениеУсловияАвтоматическойСкидки;
			СтрокаДвижений.СуммаСкидки = Окр(СуммаБезСкидки / 100 * СтрокаТаблицы.ПроцентАвтоматическихСкидок, 2);

			СуммаСоСкидками = СуммаСоСкидками - СтрокаДвижений.СуммаСкидки;
			СкидкиЕсть = Истина;
		КонецЕсли;

		//Ручные скидки.
		Если СтрокаТаблицы.ПроцентСкидкиНаценки <> 0 Тогда
			СтрокаДвижений = ТаблицаДвижений.Добавить();
			СтрокаДвижений.Номенклатура = СтрокаТаблицы.Номенклатура;
			СтрокаДвижений.ПолучательСкидки = СтрокаТаблицы.Склад;
			СтрокаДвижений.ХарактеристикаНоменклатуры = СтрокаТаблицы.ХарактеристикаНоменклатуры;
			СтрокаДвижений.УсловиеСкидки = Перечисления.УсловияСкидкиНаценки.РучнаяСкидка;
			СтрокаДвижений.ЗначениеУсловияСкидки = СтрокаТаблицы.ПроцентСкидкиНаценки;
			СтрокаДвижений.СуммаСкидки = Окр(СуммаБезСкидки / 100 * СтрокаТаблицы.ПроцентСкидкиНаценки, 2);

			СуммаСоСкидками = СуммаСоСкидками - СтрокаДвижений.СуммаСкидки;
			СкидкиЕсть = Истина;
		КонецЕсли;

		Разница = СтрокаТаблицы.Стоимость - СуммаСоСкидками;
		Если Разница <> 0 И СкидкиЕсть Тогда
			СтрокаДвижений.СуммаСкидки = СтрокаДвижений.СуммаСкидки + Разница;
		КонецЕсли;

		//Натуральные скидки.
		Если СтрокаТаблицы.Комплект Тогда
			Если ЦенообразованиеСервер.ЭтоСпецПредложение(СтруктураШД.Дата,
			        СтрокаТаблицы.Номенклатура,
			        СтрокаТаблицы.ХарактеристикаНоменклатуры,
			        ЦенообразованиеСервер.МассивПолучателейСкидки(Перечисления.ВидыСкидок.Розничная, ЭтотОбъект)) Тогда

				Комплектующие = СоставНабора.НайтиСтроки(Новый Структура("ID_Товары", СтрокаТаблицы.ID));

				СтоимостьКомплектующих = 0;
				СоответствиеКомплектующих = Новый Соответствие;

				Для Каждого Комплектующая Из Комплектующие Цикл
					Цена = Комплектующая.Цена;

					СтоимостьКомплектующей = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(Цена * СтрокаТаблицы.Количество * Комплектующая.Количество,
					   ДополнительныеСвойства.ВалютаБухУчета, СтруктураШД.ВалютаУправленческогоУчета,
					   1, СтруктураШД.КурсВалютыУправленческогоУчета, 1,
					   СтруктураШД.КратностьВалютыУправленческогоУчета);

					СтоимостьКомплектующих = СтоимостьКомплектующих + СтоимостьКомплектующей;
					СоответствиеКомплектующих.Вставить(Комплектующая, СтоимостьКомплектующей);
				КонецЦикла;

				СуммаСкидки = СтоимостьКомплектующих - СтрокаТаблицы.Стоимость;

				Для Каждого Комплектующая Из СоответствиеКомплектующих Цикл
					СтрокаДвижений = ТаблицаДвижений.Добавить();
					СтрокаДвижений.Номенклатура = Комплектующая.Ключ.Номенклатура;
					СтрокаДвижений.ХарактеристикаНоменклатуры = Комплектующая.Ключ.ХарактеристикаНоменклатуры;
					СтрокаДвижений.УсловиеСкидки = Перечисления.УсловияСкидкиНаценки.СпецПредложение;
					СтрокаДвижений.ЗначениеУсловияСкидки = СтрокаТаблицы.Номенклатура;
					СтрокаДвижений.СуммаСкидки = Комплектующая.Значение / СтоимостьКомплектующих * СуммаСкидки;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	ТаблицаДвижений.Свернуть("Номенклатура,ПолучательСкидки,ХарактеристикаНоменклатуры,УсловиеСкидки,ЗначениеУсловияСкидки", "СуммаСкидки");

	Возврат ТаблицаДвижений;

КонецФункции 

Функция ПодготовитьТаблицуТоваров(ТаблицаТоваров , СтруктураШД)

	Если СтруктураШД.ВидСклада = Перечисления.ВидыСкладов.Розничный Тогда
		ТаблицаТоваров.Колонки.Цена.Имя = "ЦенаВРознице";
	КонецЕсли;
	
	ПодготовитьТаблицуТоваровУпр(ТаблицаТоваров, СтруктураШД);

	Возврат ТаблицаТоваров;

КонецФункции 

Процедура ПроверитьЗаполнениеТабличнойЧастиТоварыУпр(ТаблицаПоТоварам, СтруктураШД, Отказ, Заголовок)
	// Проверим заполнение автоматических скидок.
	Для каждого СтрокаТаблицы Из ТаблицаПоТоварам Цикл
		ПроцентНеЗаполнен          = НЕ ЗначениеЗаполнено(СтрокаТаблицы.ПроцентАвтоматическихСкидок);
		УсловиеНеЗаполнено         = НЕ ЗначениеЗаполнено(СтрокаТаблицы.УсловиеАвтоматическойСкидки);
		ЗначениеУсловияНеЗаполнено = НЕ ЗначениеЗаполнено(СтрокаТаблицы.ЗначениеУсловияАвтоматическойСкидки);

		Если (ПроцентНеЗаполнен И УсловиеНеЗаполнено И ЗначениеУсловияНеЗаполнено)
		 Или Не(ПроцентНеЗаполнен Или УсловиеНеЗаполнено Или ЗначениеУсловияНеЗаполнено)Тогда // ошибок нет
		Иначе
			Если НЕ ПроцентНеЗаполнен
			   И  НЕ УсловиеНеЗаполнено
			   И  ТипЗнч(СтрокаТаблицы.ЗначениеУсловияАвтоматическойСкидки) = Тип("Число")
			   И  СтрокаТаблицы.ЗначениеУсловияАвтоматическойСкидки = 0 Тогда
				// Ошибок нет.
			Иначе
				СтрокаНачалаСообщенияОбОшибке = "В строке номер """+ СокрЛП(СтрокаТаблицы.НомерСтроки)
				                              + """ табличной части ""Товары"": ";
				Если ПроцентНеЗаполнен Тогда
					СтрокаСообщения = "Не заполнено значение реквизита ""Процент автоматической скидки""!";
					ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке + СтрокаСообщения, Отказ, Заголовок);
				КонецЕсли;
				Если УсловиеНеЗаполнено Тогда
					СтрокаСообщения = "Не заполнено значение реквизита ""Условие автоматической скидки""!";
					ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке + СтрокаСообщения, Отказ, Заголовок);
				КонецЕсли;
				Если ЗначениеУсловияНеЗаполнено Тогда
					СтрокаСообщения = "Не заполнено значение реквизита ""Значение условия автоматической скидки""!";
					ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке + СтрокаСообщения, Отказ, Заголовок);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры 

Процедура ПроверитьЗаполнениеТабличнойЧастиТовары(ТаблицаПоТоварам, СтруктураШД, Отказ, Заголовок)
	ПроверитьЗаполнениеТабличнойЧастиТоварыУпр(ТаблицаПоТоварам, СтруктураШД, Отказ, Заголовок);
КонецПроцедуры 

Функция ПодготовитьТаблицыДокумента(СтруктураШД, Отказ, Заголовок)
	//Таличная часть "Товары"
	ТаблицаТоваров=УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "Товары");

	тзТовары=ПодготовитьТаблицуТоваров(ТаблицаТоваров, СтруктураШД);
	ПроверитьЗаполнениеТабличнойЧастиТовары(тзТовары, СтруктураШД, Отказ, Заголовок);

	//Таличная часть "Оплата платежными картами"
	ТаблицаПоПлатежнымКартам=УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "ОплатаПлатежнымиКартами", "Док.ВидОплаты.ТипОплаты Как ТипОплаты,");
	//*** УправлениеРозничнойТорговлейСервер.ПроверитьКорректностьТипаОплатыВТЧ(ЭтотОбъект, "ОплатаПлатежнымиКартами", ТаблицаПоПлатежнымКартам, Отказ, Заголовок, Перечисления.ТипыОплатЧекаККМ.ПлатежнаяКарта);

	//Таличная часть "Оплата банковскими кредитами"
	ТаблицаПоБанковскимКредитам=УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "ОплатаБанковскимиКредитами", "Док.ВидОплаты.ТипОплаты Как ТипОплаты,");
	УправлениеРозничнойТорговлейСервер.ПроверитьКорректностьТипаОплатыВТЧ(ЭтотОбъект, "ОплатаБанковскимиКредитами", ТаблицаПоБанковскимКредитам, Отказ, Заголовок, Перечисления.ТипыОплатЧекаККМ.БанковскийКредит);

	//Структура табличных частей
	СтруктураТД=Новый Структура;
	СтруктураТД.Вставить("Товары", тзТовары);
	СтруктураТД.Вставить("Скидки", ПодготовитьТаблицуСкидок(тзТовары, СтруктураШД));
	СтруктураТД.Вставить("ПлатежныеКарты", ТаблицаПоПлатежнымКартам);
	СтруктураТД.Вставить("БанковскиеКредиты", ТаблицаПоБанковскимКредитам);
	СтруктураТД.Вставить("ДисконтныеКарты", УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "ПродажиПоДисконтнымКартам"));

	ВзаиморасчетыСервер.ПодготовкаТаблицыЗначенийДляЦелейПриобретенияИРеализации(тзТовары, СтруктураШД, Истина);

	ТаблицаПоТоварамБезУслуг=ОбщегоНазначения.ОтобратьСтрокиПоКритериям(СтруктураТД.Товары, Новый Структура("Услуга", Ложь)).Выгрузить();
	ТаблицаПоКомплектам=УправлениеЗапасами.СформироватьТаблицуКомплектующих(ТаблицаПоТоварамБезУслуг, ЭтотОбъект);

	СтруктураТД.Вставить("Комплекты", ТаблицаПоКомплектам);
	СтруктураТД.Вставить("ТоварыБезУслуг", ТаблицаПоТоварамБезУслуг );
	
	Возврат СтруктураТД;
КонецФункции

Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	Для каждого СтрокаКоллекции из Товары Цикл
		Если НЕ ЗначениеЗаполнено(СтрокаКоллекции.Склад) Тогда
			СтрокаКоллекции.Склад=Склад;
		КонецЕсли;
		Если НЕ УчитыватьНДС Тогда
			СтрокаКоллекции.СтавкаНДС=Перечисления.СтавкиНДС.БезНДС;
		КонецЕсли;
	КонецЦикла;
	
	//Удаляем неиспользуемые строки состав набора
	МассивСтрок=Новый Массив;
	Для каждого СтрокаКоллекции Из СоставНабора Цикл
		Если Товары.Найти(СтрокаКоллекции.ID_Товары, "ID")=Неопределено Тогда
			МассивСтрок.Добавить(СтрокаКоллекции);
		КонецЕсли;
	КонецЦикла;
	Для каждого СтрокаКоллекции Из МассивСтрок Цикл
		СоставНабора.Удалить(СтрокаКоллекции);
	КонецЦикла;	

	СуммаДокумента=ЦенообразованиеСервер.ПолучитьСуммуДокументаСНДС(ЭтотОбъект, "Товары");
	СуммаНДС=ЦенообразованиеСервер.ПолучитьНДСДокумента(ЭтотОбъект);
КонецПроцедуры

Процедура ЗаполнитьТоварыПоИнвентаризацииТоваров(ДокументОснование) Экспорт

	УчитыватьНДС     = Истина;
	СуммаВключаетНДС = Истина;

	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДокументСсылка"         , Ссылка);
	Запрос.УстановитьПараметр("ДокументОснованиеСсылка", ДокументОснование);
	Запрос.УстановитьПараметр("ТоварНовый"             , Справочники.Качество.Новый);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	Док.Номенклатура,
	|	Док.ЕдиницаИзмерения,
	|	Док.Ссылка.Склад                              КАК Склад,
	|	Док.Ссылка.Склад.ВидСклада                    КАК ВидСклада,
	|	МИНИМУМ(Док.НомерСтроки) 					  КАК НомерСтроки,
	|	МАКСИМУМ(Док.КоличествоУчет - Док.Количество) КАК КоличествоОтклонение,
	|	ВЫБОР
	|		КОГДА СУММА(ВложенныйЗапрос.Количество) ЕСТЬ NULL ТОГДА
	|			0
	|		ИНАЧЕ
	|			СУММА(ВложенныйЗапрос.Количество)
	|	КОНЕЦ КАК КоличествоСписанное,
	|	Док.ЦенаВРознице КАК Цена,
	|	Док.ХарактеристикаНоменклатуры,
	|	Док.СерияНоменклатуры,
	|	Док.Качество
	|ИЗ
	|	Документ.ИнвентаризацияТМЦ.Товары КАК Док
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	(ВЫБРАТЬ
	|       ДокСписание.Номенклатура,
	|       ДокСписание.ХарактеристикаНоменклатуры,
	|       ДокСписание.СерияНоменклатуры,
	|       ДокСписание.Качество,
	|       ДокСписание.Ссылка.Склад                         КАК Склад,
	|		ДокСписание.Количество                           КАК Количество,
	|       ДокСписание.Цена
	|	 ИЗ
	|       Документ.СписаниеТоваров.Товары КАК ДокСписание
	|    ГДЕ
	|       ДокСписание.Ссылка.Проведен
	|       И ДокСписание.Ссылка.ИнвентаризацияТМЦ = &ДокументОснованиеСсылка
	|
	|    ОБЪЕДИНИТЬ ВСЕ
	|
	|	 ВЫБРАТЬ 
	|       ДокОтчетККМ.Номенклатура,
	|       ДокОтчетККМ.ХарактеристикаНоменклатуры,
	|       ДокОтчетККМ.СерияНоменклатуры,
	|       &ТоварНовый                                      КАК Качество,
	|       ДокОтчетККМ.Склад                                КАК Склад,
	|       ДокОтчетККМ.Количество                           КАК Количество,
	|       ДокОтчетККМ.Цена
	|	 ИЗ
	|       Документ.ОтчетОРозничныхПродажах.Товары КАК ДокОтчетККМ
	|    ГДЕ
	|       ДокОтчетККМ.Ссылка <> &ДокументСсылка
	|       И ДокОтчетККМ.Ссылка.Проведен
	|       И ДокОтчетККМ.Ссылка.ИнвентаризацияТМЦ = &ДокументОснованиеСсылка) КАК ВложенныйЗапрос
	|ПО
	|      Док.Номенклатура               = ВложенныйЗапрос.Номенклатура
	|    И Док.ХарактеристикаНоменклатуры = ВложенныйЗапрос.ХарактеристикаНоменклатуры
	|    И Док.СерияНоменклатуры          = ВложенныйЗапрос.СерияНоменклатуры
	|    И Док.Качество                   = ВложенныйЗапрос.Качество
	|    И Док.Ссылка.Склад               = ВложенныйЗапрос.Склад
	|    И Док.Цена                       = ВложенныйЗапрос.Цена
	|ГДЕ
	|	Док.Ссылка = &ДокументОснованиеСсылка
	|   И ((Док.КоличествоУчет - Док.Количество) > 0)
	|СГРУППИРОВАТЬ ПО
	|	Док.Ссылка.Склад,
	|	Док.Номенклатура,
	|	Док.ЕдиницаИзмерения,
	|	Док.ЦенаВРознице,
	|	Док.ХарактеристикаНоменклатуры,
	|	Док.СерияНоменклатуры,
	|	Док.Качество
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		КоличествоСписать = Выборка.КоличествоОтклонение - Выборка.КоличествоСписанное;
		Если КоличествоСписать <= 0 Тогда Продолжить; КонецЕсли;

		СтрокаТабличнойЧасти = Товары.Добавить();
		СтрокаТабличнойЧасти.Номенклатура               = Выборка.Номенклатура;
		СтрокаТабличнойЧасти.ЕдиницаИзмерения           = Выборка.ЕдиницаИзмерения;
		СтрокаТабличнойЧасти.Коэффициент                = Выборка.ЕдиницаИзмерения.Коэффициент;
		СтрокаТабличнойЧасти.Количество                 = КоличествоСписать;
		СтрокаТабличнойЧасти.Цена                       = Выборка.Цена;
		СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры = Выборка.ХарактеристикаНоменклатуры;
		СтрокаТабличнойЧасти.СерияНоменклатуры          = Выборка.СерияНоменклатуры;
		СтрокаТабличнойЧасти.Склад                      = Выборка.Склад;

		ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(СтрокаТабличнойЧасти   , ЭтотОбъект);
		ОбработкаТабличныхЧастей.ЗаполнитьСтавкуНДСТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект, "Реализация");
		ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект);
	КонецЦикла;

#Если Клиент Тогда
	Если Товары.Количество() = 0 Тогда
		Сообщить("В документе """ + ДокументОснование.Метаданные().Представление() + """ № " + ДокументОснование.Номер +" отсутствуют товары учетное количество которых превышает фактическое.");
	КонецЕсли;
#КонецЕсли

КонецПроцедуры 

////////////////////////////////////////////////////////////////////////////////
// Движения по регистрам 

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ);
	//Движения по регистру "Розничная выручка"
	ДвижениеПоРегистру_РозничнаяВыручка(СтруктураШД, СтруктураТД, Отказ);

	//Движения регистрам "Продажи по дисконтным картам"
	ДвижениеПоРегистру_ПродажиПоДисконтнымКартам(СтруктураШД, СтруктураТД, Отказ);

	//Движения регистрам "Предоставленные скидки"
	ДвижениеПоРегистру_ПредоставленныеСкидки(СтруктураШД, СтруктураТД, Отказ);

	//Движения по регистру "Учет ТМЦ"
	ДвижениеПоРегистру_УчетТМЦ(СтруктураШД, СтруктураТД, Отказ);
	
	//Движения по регистру "Списанные товары"
	ДвижениеПоРегистру_СписанныеТовары(СтруктураШД, СтруктураТД, Отказ);

	//Движения по регистру "Взаиморасчеты с контрагентами"
	ДвижениеПоРегистру_ВзаиморасчетыСКонтрагентами(СтруктураШД, СтруктураТД, Отказ);

	//Движения по регистру "Учет НДС"
	ДвижениеПоРегистру_УчетНДС(СтруктураШД, СтруктураТД, Отказ);

	//Движения регистрам "Учет партий ТМЦ, Продажи"
	ДвижениеПоРегистру_УчетПартийТМЦ(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры 

Процедура ДвижениеПоРегистру_ПредоставленныеСкидки(СтруктураШД, СтруктураТД, Отказ)
	НаборДвижений = Движения.ПредоставленныеСкидки;
	ТаблицаДвижений = НаборДвижений.ВыгрузитьКолонки();
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(СтруктураТД.Скидки, ТаблицаДвижений);

	ТаблицаДвижений.ЗаполнитьЗначения(Ссылка, "ДокументСкидки");

	НаборДвижений.мПериод          = Дата;
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;
	Движения.ПредоставленныеСкидки.ВыполнитьДвижения();
КонецПроцедуры

Процедура ДвижениеПоРегистру_ПродажиПоДисконтнымКартам(СтруктураШД, СтруктураТД, Отказ)
	Движения.ПродажиПоДисконтнымКартам.Загрузить(СтруктураТД.ДисконтныеКарты);
КонецПроцедуры

Процедура ДвижениеПоРегистру_СписанныеТовары(СтруктураШД, СтруктураТД, Отказ)
	ТаблицаПоТоварамБезУслуг=СтруктураТД.ТоварыБезУслуг; //Комплекты...... необходимо проверить
	
	ТаблицаДвижений=Движения.СписанныеТовары.ВыгрузитьКолонки();
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоТоварамБезУслуг, ТаблицаДвижений);
	ТаблицаДвижений.ЗаполнитьЗначения(Дата,   "Период");
	ТаблицаДвижений.ЗаполнитьЗначения(Ссылка, "Регистратор");
	ТаблицаДвижений.ЗаполнитьЗначения(Истина, "Активность");
	ТаблицаДвижений.ЗаполнитьЗначения(Справочники.Качество.Новый, "Качество");
	ТаблицаДвижений.ЗаполнитьЗначения(Перечисления.КодыОперацийПартииТоваров.РеализацияРозница, "КодОперацииПартииТоваров");
	ТаблицаДвижений.ЗаполнитьЗначения(Подразделение, "Подразделение");
	ТаблицаДвижений.ЗаполнитьЗначения(Проект, "Проект");

	Для каждого Строка Из ТаблицаДвижений Цикл
		СтрокаТЧ = ТаблицаПоТоварамБезУслуг.Получить(ТаблицаДвижений.Индекс(Строка));

		Строка.СуммаЗадолженности   = СтрокаТЧ.СуммаБезНДС + СтрокаТЧ.НДС;
		Строка.ВалютаДокумента = СтруктураШД.ВалютаРегламентированногоУчета;
		Строка.КурсДокумента = 1;
		Строка.КратностьДокумента = 1;
	КонецЦикла;
	
	// Возврат текущего дня отражается строчками с "-" 
	// Возвращаемое количество всегда меньше реализованного
	////КолонкиГруппировок = "";
	////КолонкиСуммирования = "";
	////Для каждого Колонка Из ТаблицаДвижений.Колонки Цикл
	////	Если Колонка.ТипЗначения.СодержитТип(Тип("Число")) Тогда
	////		КолонкиСуммирования = КолонкиСуммирования + Колонка.Имя +",";
	////	Иначе
	////		КолонкиГруппировок = КолонкиГруппировок + Колонка.Имя +",";
	////	КонецЕсли;
	////КонецЦикла;
	////ТаблицаДвижений.Свернуть(КолонкиГруппировок, КолонкиСуммирования);
	//}LEE отключена свертка т.к. нарушается порядок строк ТЧ и партий

	Инд = 0;
	Для каждого Строка Из ТаблицаДвижений Цикл
		Инд = Инд + 1; Строка.НомерСтрокиДокумента = Инд;
	КонецЦикла;
	
	НаборДвижений=Движения.СписанныеТовары;
	НаборДвижений.мПериод          = Дата;
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

	Если Не Отказ Тогда
		Движения.СписанныеТовары.ВыполнитьДвижения();
	КонецЕсли;

	Если Движения.СписанныеТовары.Модифицированность() Тогда
	    Движения.СписанныеТовары.Записать(Истина);
	КонецЕсли;

КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетТМЦ(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ТоварыНаСкладах") Тогда Возврат; КонецЕсли;

	тзДвижения=Движения.ТоварыНаСкладах.ВыгрузитьКолонки();

	Для каждого СтрокаКоллекции Из СтруктураТД.ТоварыБезУслуг Цикл
		Если СтрокаКоллекции.ВидСклада=Перечисления.ВидыСкладов.Оптовый Тогда
			НоваяСтрока=тзДвижения.Добавить();
			НоваяСтрока.Качество=Справочники.Качество.Новый;
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		КонецЕсли;		
	КонецЦикла;

	//Регистр "Учет ТМЦ" (по ячейкам)
	Если тзДвижения.Количество()>0 Тогда
		тзДвижения.ЗаполнитьЗначения(Дата, "Период");
		тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
		тзДвижения.ЗаполнитьЗначения(Ссылка, "Регистратор");
		тзДвижения.ЗаполнитьЗначения(ВидДвиженияНакопления.Расход, "ВидДвижения");
		Движения.ТоварыНаСкладах.Загрузить(тзДвижения);
	КонецЕсли;
КонецПроцедуры 

Процедура ДвижениеПоРегистру_УчетПартийТМЦ(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ПартииТоваровНаСкладах") Тогда Возврат; КонецЕсли;

	СтруктураШД.Вставить("Отказ", Отказ);
	СтруктураШД.Вставить("ТаблицаСписания", Движения.СписанныеТовары.Выгрузить());
	УправлениеЗапасамиПартионныйУчет.ДвижениеПартийТоваров(Ссылка, СтруктураШД);
КонецПроцедуры

Процедура ДвижениеПоРегистру_РозничнаяВыручка(СтруктураШД, СтруктураТД, Отказ)
	НаборДвижений = Движения.РозничнаяВыручка;
	ТаблицаДвижений=НаборДвижений.ВыгрузитьКолонки();

	СуммаОплатыПлатежнымиКартами=0;
	Для каждого СтрокаКоллекции Из СтруктураТД.ПлатежныеКарты Цикл
		Если НЕ СтрокаКоллекции.ВидОплаты.ТипОплаты=Перечисления.ТипыОплатЧекаККМ.ПодарочныйСертификат Тогда
			СуммаОплатыПлатежнымиКартами=СуммаОплатыПлатежнымиКартами+СтрокаКоллекции.Сумма;
		КонецЕсли; 
	КонецЦикла; 
	
	СтрокаДвижений=ТаблицаДвижений.Добавить();
	СтрокаДвижений.РозничнаяТочка=?(КассаККМ.Пустая(), Склад, КассаККМ);
	//СтрокаДвижений.Сумма=СуммаДокумента - СтруктураТД.ПлатежныеКарты.Итог("Сумма")-СтруктураТД.БанковскиеКредиты.Итог("Сумма");
	СтрокаДвижений.Сумма=СуммаДокумента - СуммаОплатыПлатежнымиКартами-СтруктураТД.БанковскиеКредиты.Итог("Сумма");
	СтрокаДвижений.Подразделение=Подразделение;

	НаборДвижений.мПериод             = Дата;
	НаборДвижений.мТаблицаДвижений    = ТаблицаДвижений;
	Движения.РозничнаяВыручка.ВыполнитьПриход();	
КонецПроцедуры

Процедура ДвижениеПоРегистру_ВзаиморасчетыСКонтрагентами(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ВзаиморасчетыСКонтрагентами") Тогда Возврат; КонецЕсли;

	СуммаВзаиморасчетовПоКартам=0;
	Для каждого СтрокаКоллекции Из СтруктураТД.ПлатежныеКарты Цикл
		Если НЕ СтрокаКоллекции.ВидОплаты.ТипОплаты=Перечисления.ТипыОплатЧекаККМ.ПодарочныйСертификат Тогда
			СуммаВзаиморасчетовПоКартам=СуммаВзаиморасчетовПоКартам+СтрокаКоллекции.Сумма;
		КонецЕсли; 
	КонецЦикла; 

	//ЕстьБезналичныеРасчеты=СтруктураТД.БанковскиеКредиты.Количество() > 0 ИЛИ СтруктураТД.ПлатежныеКарты.Количество() > 0;
	ЕстьБезналичныеРасчеты=СтруктураТД.БанковскиеКредиты.Количество() > 0 ИЛИ СуммаВзаиморасчетовПоКартам > 0;
	Если Не ЕстьБезналичныеРасчеты Тогда Возврат; КонецЕсли;

	// По регистрам взаиморасчетов отражаются безналичные расчеты	
	ТаблицаВзаиморасчеты=Движения.ВзаиморасчетыСКонтрагентами.ВыгрузитьКолонки();

	// Взаиморасчеты с эквайрером
	//*** СуммаВзаиморасчетовПоКартам=СтруктураТД.ПлатежныеКарты.Итог("Сумма");	
	Если НЕ СуммаВзаиморасчетовПоКартам=0 Тогда			
		СтрокаВзаиморасчеты=ТаблицаВзаиморасчеты.Добавить();
		СтрокаВзаиморасчеты.ДоговорКонтрагента=ДоговорВзаиморасчетовЭквайрера;
		СтрокаВзаиморасчеты.Контрагент=Эквайрер;
		СтрокаВзаиморасчеты.Организация=Организация;
		СтрокаВзаиморасчеты.СуммаБух=СуммаВзаиморасчетовПоКартам;
		СтрокаВзаиморасчеты.СуммаВал=СуммаВзаиморасчетовПоКартам;
	КонецЕсли;

	// Взаиморасчеты с банками по кредитам (по документам-расчетов не ведется)		
	Для каждого СтрокаКредита Из СтруктураТД.БанковскиеКредиты Цикл
		СтрокаВзаиморасчеты=ТаблицаВзаиморасчеты.Добавить();
		СтрокаВзаиморасчеты.ДоговорКонтрагента=СтрокаКредита.ДоговорВзаиморасчетовБанкаКредитора;
		СтрокаВзаиморасчеты.Контрагент=СтрокаКредита.БанкКредитор;
		СтрокаВзаиморасчеты.Организация=Организация;
		СтрокаВзаиморасчеты.СуммаБух=СтрокаКредита.Сумма;
		СтрокаВзаиморасчеты.СуммаВал=СтрокаКредита.Сумма;
	КонецЦикла;
	
	НаборЗаписей=Движения.ВзаиморасчетыСКонтрагентами;
	НаборЗаписей.мПериод=Дата;
	НаборЗаписей.мТаблицаДвижений=ТаблицаВзаиморасчеты;
	НаборЗаписей.ВыполнитьПриход();	
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетНДС(СтруктураШД, СтруктураТД, Отказ) Экспорт
	Если Не СтруктураШД.УчитыватьНДС Тогда Возврат; КонецЕсли;
	Если СтруктураШД.УчетнаяПолитика.ОрганизацияНеЯвляетсяПлательщикомНДС Тогда Возврат; КонецЕсли;
	
	СтруктураТаблицыВыручки = Новый структура("НомерСтроки, Номенклатура, Услуга,, ВидЦенности, Ценность, Партия,
												  |ВидТабличнойЧасти, СтавкаНДС, Сумма, СуммаВал, НДС, НДСВал, СуммаБезНДС, СуммаБезНДСВал,Комиссионный,Комитент,ДоговорКомиссии ,ВалютаРасчетовСКомитентом,СуммаСписания, Количество");
												  

	//Формируем таблицу выручки с нужной структурой и заполняем по таблице услуг
	ТаблицаВыручки=ОбщегоНазначения.СформироватьТаблицуЗначений(СтруктураТД.Товары, СтруктураТаблицыВыручки,,Истина);
	ТаблицаВыручки.ЗаполнитьЗначения(Ложь, "Комиссионный");
	ТаблицаВыручки.ЗаполнитьЗначения(0,    "Количество");

	ТаблицаВыручкиУслуги = ТаблицаВыручки.Скопировать();
	УчетНДС.СформироватьДвиженияПоРегиструНДСНачисленный_ОтражениеРеализации(СтруктураШД, ТаблицаВыручкиУслуги, Движения, Отказ);
КонецПроцедуры 

//////////////////////////////////////////////////////////////////////////////////
// Проведение по регистрам (по нескольким регистрам одного типа)

Процедура ДвижениеПоРегистру_УчетВзаиморасчетов(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_ВзаиморасчетыСКонтрагентами(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий

Процедура ОбработкаЗаполнения(Основание)
	Если Не ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание) Тогда Возврат; КонецЕсли; 

	Если ТипЗнч(Основание)=Тип("ДокументСсылка.ИнвентаризацияТМЦ") Тогда
		ИнвентаризацияТМЦ=Основание;
		ТипЦен=Склад.ТипЦенРозничнойТорговли;
		ЗаполнитьТоварыПоИнвентаризацииТоваров(Основание);
	КонецЕсли;
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка Тогда Возврат; КонецЕсли;
	ОбщегоНазначения.СинхронизацияПометкиНаУдалениеУСчетаФактуры(ЭтотОбъект);
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	УправлениеДокументамиСервер.ПередПроведением(Отказ, РежимПроведения, ЭтотОбъект);
	Если Отказ Тогда Возврат; КонецЕсли;

	НастройкиПользователяСервер.ПроверитьДопустимостьЦенОтпуска(Ссылка, "Товары", Отказ);
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

	Если ОплатаПлатежнымиКартами.Количество() > 0 Тогда
		ПроверяемыеРеквизиты.Добавить("ДоговорЭквайринга");
		ПроверяемыеРеквизиты.Добавить("Эквайрер");
		ПроверяемыеРеквизиты.Добавить("ДоговорВзаиморасчетовЭквайрера");
	КонецЕсли;

	//Формирование значений реквизитов шапки документа "СтруктураШД"
	СтруктураШД=УправлениеДокументамиСервер.ПолучитьСтруктуруРеквизитовШапки(ЭтотОбъект);

	//Формирование значений реквизитов табличных частей "СтруктураТД"
	СтруктураТД=ПодготовитьТаблицыДокумента(СтруктураШД, Отказ, Заголовок);

	//Инициализация доп.свойств документа	
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства, "Покупка");