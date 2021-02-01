﻿Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	СуммаНДС1=Товары.Итог("СуммаНДС");
	СуммаНДС2=РаспределяемыеУслуги.Итог("СуммаНДС");
	Если НЕ СуммаНДС1=0 И НЕ СуммаНДС2=0 И НЕ Товары.Количество()=0 Тогда
		Если СуммаНДС1 > СуммаНДС2 Тогда
			Товары[0].СуммаНДС=Товары[0].СуммаНДС-(СуммаНДС1-СуммаНДС2);
			
		ИначеЕсли СуммаНДС1 < СуммаНДС2 Тогда
			Товары[0].СуммаНДС=Товары[0].СуммаНДС+(СуммаНДС2-СуммаНДС1);
		КонецЕсли;
	КонецЕсли;

	СуммаДокумента=РаспределяемыеУслуги.Итог("Сумма")+?(СуммаВключаетНДС, 0, (РаспределяемыеУслуги.Итог("СуммаНДС")));
	СуммаНДС=РаспределяемыеУслуги.Итог("СуммаНДС");

	Для каждого СтрокаКоллекции Из Товары Цикл
		Если СтрокаКоллекции.Склад.Пустая() Тогда
			СтрокаКоллекции.Склад=Склад;
		КонецЕсли;
	КонецЦикла;
	Для каждого СтрокаКоллекции Из РаспределяемыеУслуги Цикл
		Если НЕ ЗначениеЗаполнено(СтрокаКоллекции.Сделка) Тогда
			СтрокаКоллекции.Сделка=Сделка;
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

Процедура ЗаполнитьТоварыПоПоступлениюТоваров(ДокументОснование, тчСсылка, ID_РаспределяемыеУслуги=Неопределено) Экспорт
	Если ID_РаспределяемыеУслуги=Неопределено Тогда
		ID_РаспределяемыеУслуги=Строка(Новый УникальныйИдентификатор);
		НоваяСтрока=РаспределяемыеУслуги.Добавить();
		НоваяСтрока.ID=ID_РаспределяемыеУслуги;
		НоваяСтрока.Содержание="Заполнено по поступлению товаров";
	КонецЕсли;

	КурсДокумента      = ЗаполнениеДокументов.КурсДокумента(ЭтотОбъект, ДополнительныеСвойства.ВалютаБухУчета);
	КурсОснования      = ЗаполнениеДокументов.КурсДокумента(ДокументОснование, ДополнительныеСвойства.ВалютаБухУчета);
	КратностьДокумента = ЗаполнениеДокументов.КратностьДокумента(ЭтотОбъект, ДополнительныеСвойства.ВалютаБухУчета);
	КратностьОснования = ЗаполнениеДокументов.КратностьДокумента(ДокументОснование, ДополнительныеСвойства.ВалютаБухУчета);
	
	ИмяДокумента = ДокументОснование.Метаданные().Имя;

	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДокументОснование", ДокументОснование);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	Док.Номенклатура,
	|	Док.СтавкаНДС,
	|	Док.Ссылка,
	|	Док.Ссылка.ВалютаДокумента,
	|	Док.Сумма,
	|	Док.СуммаНДС,
	|	Док.Ссылка.УчитыватьНДС УчитыватьНДС,
	|	Док.Ссылка.СуммаВключаетНДС СуммаВключаетНДС,
	|	Док.Количество,
	|	Док.ЕдиницаИзмерения,
	|	Док.ЕдиницаИзмерения.Коэффициент Как Коэффициент,
	|	Док.ХарактеристикаНоменклатуры,
	|	Док.СерияНоменклатуры
	|ИЗ
	|	Документ."+ИмяДокумента+".Товары КАК Док
	|ГДЕ
	|	Док.Ссылка = &ДокументОснование
	|УПОРЯДОЧИТЬ ПО
	|	Док.НомерСтроки
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		СтрокаТабличнойЧасти=тчСсылка.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТабличнойЧасти, Выборка,,"Сумма, СуммаНДС");
		СтрокаТабличнойЧасти.ДокументПартии=ДокументОснование;
        СтрокаТабличнойЧасти.ID_РаспределяемыеУслуги=ID_РаспределяемыеУслуги;
		СтрокаТабличнойЧасти.СуммаТовара=ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(Выборка.Сумма+?(Выборка.УчитыватьНДС И НЕ Выборка.СуммаВключаетНДС, Выборка.СуммаНДС, 0), Выборка.ВалютаДокумента, ВалютаДокумента, КурсОснования, КурсДокумента,КратностьОснования, КратностьДокумента);
	КонецЦикла;

КонецПроцедуры
 
Процедура ЗаполнитьТоварыПоПереработке(ДокументОснование, тчСсылка, ID_РаспределяемыеУслуги=Неопределено) Экспорт
	Если ID_РаспределяемыеУслуги=Неопределено Тогда
		ID_РаспределяемыеУслуги=Строка(Новый УникальныйИдентификатор);
		НоваяСтрока=РаспределяемыеУслуги.Добавить();
		НоваяСтрока.ID=ID_РаспределяемыеУслуги;
		НоваяСтрока.Содержание="Заполнено по переработке";
	КонецЕсли; 
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДокументОснование", ДокументОснование);
	Запрос.Текст ="
	|ВЫБРАТЬ
	|	Док.Номенклатура,
	|	Док.Ссылка,
	|	Док.Количество,
	|	Док.ЕдиницаИзмерения,
	|	Док.ЕдиницаИзмерения.Коэффициент Как Коэффициент,
	|	Док.ХарактеристикаНоменклатуры,
	|	Док.СерияНоменклатуры
	|ИЗ
	|	Документ."+ДокументОснование.Метаданные().Имя+".Товары КАК Док
	|ГДЕ
	|	Док.Ссылка = &ДокументОснование
	|УПОРЯДОЧИТЬ ПО
	|	Док.НомерСтроки
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		СтрокаТабличнойЧасти=тчСсылка.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТабличнойЧасти, Выборка);
		СтрокаТабличнойЧасти.ДокументПартии=ДокументОснование;
		СтрокаТабличнойЧасти.ID_РаспределяемыеУслуги=ID_РаспределяемыеУслуги;
	КонецЦикла;
КонецПроцедуры

Процедура Распределить(СтрокаТабличнойЧасти, тзДанные) Экспорт
	Если СтрокаТабличнойЧасти.СпособРаспределения = Перечисления.СпособыРаспределенияДопРасходов.ПоВесу Тогда 
		стрИсходнаяКолонка="Вес";
	ИначеЕсли СтрокаТабличнойЧасти.СпособРаспределения = Перечисления.СпособыРаспределенияДопРасходов.ПоКоличеству Тогда 
		стрИсходнаяКолонка="Количество";
	ИначеЕсли СтрокаТабличнойЧасти.СпособРаспределения = Перечисления.СпособыРаспределенияДопРасходов.ПоСумме Тогда 
		стрИсходнаяКолонка="СуммаТовара";
	Иначе
		стрИсходнаяКолонка="Объем";
	КонецЕсли;
	МассивСтрок=тзДанные.НайтиСтроки(Новый Структура("ID_РаспределяемыеУслуги", СтрокаТабличнойЧасти.ID));
	УправлениеКоллекциямиЗначенийСервер.РаспределитьПоТаблицеЗначений(МассивСтрок, СтрокаТабличнойЧасти.Сумма, стрИсходнаяКолонка, 1, "Сумма");
	УправлениеКоллекциямиЗначенийСервер.РаспределитьПоТаблицеЗначений(МассивСтрок, СтрокаТабличнойЧасти.СуммаНДС, стрИсходнаяКолонка, 1, "СуммаНДС");	
КонецПроцедуры	

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
	СтруктураРеквизитов.Вставить("Подразделение", Подразделение);
	СтруктураРеквизитов.Вставить("Период", Дата);
	СтруктураРеквизитов.Вставить("Активность", Истина);
	СтруктураРеквизитов.Вставить("ВидТабличнойЧасти", стрВидТабличнойЧасти);
	Для каждого СтрокаКоллекции Из СтруктураРеквизитов Цикл
		Если тзСсылка.Колонки.Найти(СтрокаКоллекции.Ключ)=Неопределено Тогда
			тзСсылка.Колонки.Добавить(СтрокаКоллекции.Ключ);
			тзСсылка.ЗаполнитьЗначения(СтрокаКоллекции.Значение, СтрокаКоллекции.Ключ);		
		КонецЕсли; 
	КонецЦикла;
КонецПроцедуры
 
Функция СформироватьТаблицу_Товары(СтруктураШД, Отказ, Заголовок)
	ОписаниеТипаЧисло=ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15, 2);

	КоэффициентПересчета=КоэффициентПересчета(СтруктураШД);
	тзДанные=Товары.Выгрузить();
	
	Если РаспределятьПриПроведении Тогда
		Для каждого СтрокаТабличнойЧасти Из РаспределяемыеУслуги Цикл
			Распределить(СтрокаТабличнойЧасти, тзДанные);
		КонецЦикла;
	КонецЕсли;
	
	тзДанные.Колонки.Добавить("СчетУчетаНДС");
	тзДанные.Колонки.Добавить("Услуга");
	тзДанные.Колонки.Добавить("Набор");
	тзДанные.Колонки.Добавить("Комплект");
	тзДанные.Колонки.Добавить("ВестиУчетПоХарактеристикам");
	тзДанные.Колонки.Добавить("ВестиПартионныйУчетПоСериям");
	тзДанные.Колонки.Добавить("ДокументОприходования");
	тзДанные.Колонки.Добавить("ВидДоговораПартии");
	тзДанные.Колонки.Добавить("ДокументПартииВидОперации");
	тзДанные.Колонки.Добавить("ДокументПартииВидПоступления");
	тзДанные.Колонки.Добавить("НомерСтрокиТабличнойЧасти");
	тзДанные.Колонки.Добавить("СтоимостьНУ",ОписаниеТипаЧисло);
	тзДанные.Колонки.Добавить("Стоимость",ОписаниеТипаЧисло);
	тзДанные.Колонки.Добавить("СтатусПартии");
	тзДанные.Колонки.Добавить("Заказ");	
	тзДанные.Колонки.Добавить("Качество");
	тзДанные.Колонки.Добавить("СтавкаНДС");
	тзДанные.Колонки.Добавить("НДС", ОписаниеТипаЧисло); //СуммаНДС  ---- УДАЛИТЬ
	тзДанные.Колонки.Добавить("СуммаБезНДС");
	тзДанные.Колонки.Добавить("КоличествоДок");
	тзДанные.Колонки.Добавить("ВидЦенности");
	тзДанные.Колонки.Добавить("Ценность");
	тзДанные.Колонки.Добавить("СтоимостьСНДС");
	тзДанные.ЗаполнитьЗначения(Справочники.Качество.Новый, "Качество");

	Для каждого СтрокаКоллекции Из тзДанные Цикл
		СтрокаКоллекции.КоличествоДок=СтрокаКоллекции.Количество;
		СтрокаКоллекции.Количество=СтрокаКоллекции.Количество * СтрокаКоллекции.Коэффициент /СтрокаКоллекции.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент;

		СтрокаКоллекции.Услуга=СтрокаКоллекции.Номенклатура.Услуга;
		СтрокаКоллекции.Набор=СтрокаКоллекции.Номенклатура.Набор;
		СтрокаКоллекции.Комплект=СтрокаКоллекции.Номенклатура.Комплект;
		СтрокаКоллекции.ВестиУчетПоХарактеристикам=СтрокаКоллекции.Номенклатура.ВестиУчетПоХарактеристикам;
		СтрокаКоллекции.ВестиПартионныйУчетПоСериям=СтрокаКоллекции.Номенклатура.ВестиПартионныйУчетПоСериям;
		Если ЗначениеЗаполнено(СтрокаКоллекции.ДокументПартии) Тогда
			СтрокаКоллекции.ДокументОприходования=СтрокаКоллекции.ДокументПартии;
			СтрокаКоллекции.ВидДоговораПартии=СтрокаКоллекции.ДокументПартии.ДоговорКонтрагента.ВидДоговора;

			Если УправлениеМетаданными.ЕстьРеквизит("ВидОперации", СтрокаКоллекции.ДокументПартии.Метаданные()) Тогда
				СтрокаКоллекции.ДокументПартииВидОперации=СтрокаКоллекции.ДокументПартии.ВидОперации;
			КонецЕсли;

			Если УправлениеМетаданными.ЕстьРеквизит("ВидПоступления", СтрокаКоллекции.ДокументПартии.Метаданные()) Тогда
				СтрокаКоллекции.ДокументПартииВидПоступления=СтрокаКоллекции.ДокументПартии.ВидПоступления;		
			КонецЕсли;
		КонецЕсли; 
		СтрокаКоллекции.НомерСтрокиТабличнойЧасти=СтрокаКоллекции.НомерСтроки;

		Если СтрокаКоллекции.Набор Тогда
			стрСообщение="В строке номер """+СокрЛП(СтрокаКоллекции.НомерСтроки)+""" табличной части ""Товары"": ";
			стрСообщение=стрСообщение+"содержится набор-пакет. Наборов-пакетов здесь быть не должно!";
			ОбщегоНазначения.СообщитьОбОшибке(стрСообщение, Отказ, Заголовок);
		КонецЕсли;
		СтрокаКоллекции.Вес = СтрокаКоллекции.Вес * СтрокаКоллекции.Количество;

		// Склад указан либо в документе поступления, либо в приходном ордере
		Если ТипЗнч(СтрокаКоллекции.Склад)=Тип("ДокументСсылка.ПриходныйОрдерНаТовары") Тогда
			СтрокаКоллекции.Склад=СтрокаКоллекции.Склада;
		КонецЕсли;

		СтрокаКоллекции.Сумма=Окр(СтрокаКоллекции.Сумма*КоэффициентПересчета, 2);
		СтрокаКоллекции.СуммаНДС=Окр(СтрокаКоллекции.СуммаНДС*КоэффициентПересчета, 2);		

		СтрокаКоллекции.Стоимость=СтрокаКоллекции.Сумма;
		СтрокаКоллекции.СтоимостьНУ=СтрокаКоллекции.Сумма;
		СтрокаКоллекции.НДС=СтрокаКоллекции.СуммаНДС;
		СтоимостьСНДС=СтрокаКоллекции.Стоимость + ?(УчитыватьНДС И Не СуммаВключаетНДС, СтрокаКоллекции.СуммаНДС, 0);
		
		СтрокаКоллекции.СтоимостьСНДС=СтоимостьСНДС;
		Если СтруктураШД.УчетнаяПолитика.НеВключатьНДСВСтоимостьПартий И НЕ НДСВключенВСтоимость Тогда
			СтрокаКоллекции.Стоимость=СтрокаКоллекции.Стоимость-?(УчитыватьНДС И СуммаВключаетНДС, СтрокаКоллекции.СуммаНДС, 0);
		Иначе
			СтрокаКоллекции.Стоимость=СтоимостьСНДС;
		КонецЕсли;
		СтрокаКоллекции.СтоимостьНУ=СтрокаКоллекции.Стоимость;
		СтрокаКоллекции.СуммаБезНДС=СтрокаКоллекции.Сумма-?(УчитыватьНДС  И СуммаВключаетНДС, СтрокаКоллекции.СуммаНДС, 0);
		СтрокаКоллекции.Заказ=СтрокаКоллекции.ЗаказПокупателя;

		СтрокаКоллекции.СтатусПартии=Перечисления.СтатусыПартийТоваров.Купленный; 
		Если СтрокаКоллекции.ВидДоговораПартии = Перечисления.ВидыДоговоровКонтрагентов.СКомитентом Тогда
			СтрокаКоллекции.СтатусПартии=Перечисления.СтатусыПартийТоваров.НаКомиссию; 
		КонецЕсли;
		
		//Счет учета НДС
		УчетНДС.ЗаполнитьСчетУчета(СтрокаКоллекции);
	КонецЦикла;

	Если Не Константы.ИспользоватьСерииНоменклатуры.Получить() Тогда
		тзДанные.ЗаполнитьЗначения(Неопределено, "СерияНоменклатуры");
	КонецЕсли;
	
	ДополнитьТаблицуАтрибутамиШапки(СтруктураШД, тзДанные, "Товары");
	
	Возврат тзДанные;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Движения по регистрам

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ)
	//Движения по регистрам "Учет партий ТМЦ"
	ДвижениеПоРегистру_УчетПартийТМЦ(СтруктураШД, СтруктураТД, Отказ);

	//Движения по регистрам "Закупки"
	ДвижениеПоРегистру_Закупки(СтруктураШД, СтруктураТД, Отказ);
	
	//Движения по регистрам "Продажи"
	ДвижениеПоРегистру_Продажи(СтруктураШД, СтруктураТД, Отказ);
	
	//Движения по регистрам "Учет НДС"
	ДвижениеПоРегистру_УчетНДС(СтруктураШД, СтруктураТД, Отказ);

	//Движения по регистру "Взаиморасчеты с контрагентами"
	ДвижениеПоРегистру_ВзаиморасчетыСКонтрагентами(СтруктураШД, СтруктураТД, Отказ);

	//Движения по регистру "Расходы при УСН"
	ДвижениеПоРегистру_РасходыПриУСН(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетПартийТМЦ(СтруктураШД, СтруктураТД, Отказ)
	Если ВидОперации=Перечисления.ВидыОперацийПоступлениеДопРасходов.УслугаСтороннейОрганизацииПродажа Тогда Возврат; КонецЕсли;
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ПартииТоваровНаСкладах") Тогда Возврат; КонецЕсли;

	тзДвижения=Движения.ПартииТоваровНаСкладах.ВыгрузитьКолонки();
	Для Каждого СтрокаКоллекции Из СтруктураТД.Товары Цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		Если НЕ СтрокаКоллекции.ВестиПартионныйУчетПоСериям Тогда
			НоваяСтрока.СерияНоменклатуры=Неопределено;
		КонецЕсли;
	КонецЦикла;

	тзДвижения.ЗаполнитьЗначения(Ссылка, "Регистратор");
	тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
	тзДвижения.ЗаполнитьЗначения(Дата, "Период");
	тзДвижения.ЗаполнитьЗначения(0, "Количество");
	тзДвижения.ЗаполнитьЗначения(Перечисления.КодыОперацийПартииТоваров.ПоступлениеДопРасходов, "КодОперации");
	Если СтруктураШД.УчетнаяПолитика.СпособОценкиМПЗ=Перечисления.СпособыОценки.ПоСредней Тогда
		тзДвижения.ЗаполнитьЗначения(Неопределено, "ДокументОприходования");
	КонецЕсли;

	Движения.ПартииТоваровНаСкладах.Загрузить(тзДвижения);
КонецПроцедуры

Процедура ДвижениеПоРегистру_Закупки(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ ВидОперации=Перечисления.ВидыОперацийПоступлениеДопРасходов.УслугаСтороннейОрганизацииПокупка Тогда Возврат; КонецЕсли;

	тзДвижения=Движения.Закупки.ВыгрузитьКолонки();

	Для Каждого СтрокаКоллекции Из СтруктураТД.Товары цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		НоваяСтрока.ДокументЗакупки=СтрокаКоллекции.ДокументОприходования;
		
		РезультатПоиска=РаспределяемыеУслуги.Найти(СтрокаКоллекции.ID_РаспределяемыеУслуги, "ID");
		Если НЕ РезультатПоиска=Неопределено Тогда НоваяСтрока.Услуга=РезультатПоиска.Номенклатура; КонецЕсли;		
	КонецЦикла;

	тзДвижения.ЗаполнитьЗначения(Ссылка, "Регистратор");
	тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
	тзДвижения.ЗаполнитьЗначения(Дата, "Период");
	тзДвижения.ЗаполнитьЗначения(0, "Количество");
	тзДвижения.ЗаполнитьЗначения(Подразделение, "Подразделение");
	тзДвижения.ЗаполнитьЗначения(ДоговорКонтрагента, "ДоговорКонтрагента");
	тзДвижения.ЗаполнитьЗначения(Контрагент, "Контрагент");
	тзДвижения.ЗаполнитьЗначения(Организация, "Организация");
	тзДвижения.ЗаполнитьЗначения(СтруктураШД.Сделка, "ЗаказПоставщику");

	Движения.Закупки.Загрузить(тзДвижения);
КонецПроцедуры

Процедура ДвижениеПоРегистру_Продажи(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ ВидОперации=Перечисления.ВидыОперацийПоступлениеДопРасходов.УслугаСтороннейОрганизацииПродажа Тогда Возврат; КонецЕсли;
	
	тзДвижения=Движения.Продажи.ВыгрузитьКолонки();

	Для Каждого СтрокаКоллекции Из СтруктураТД.Товары цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		Если ЗначениеЗаполнено(СтрокаКоллекции.ДокументПартии) Тогда
			НоваяСтрока.Контрагент=СтрокаКоллекции.ДокументПартии.Контрагент;
			НоваяСтрока.ДоговорКонтрагента=СтрокаКоллекции.ДокументПартии.ДоговорКонтрагента;		
			НоваяСтрока.Себестоимость=НоваяСтрока.Стоимость;
		КонецЕсли;
		РезультатПоиска=РаспределяемыеУслуги.Найти(СтрокаКоллекции.ID_РаспределяемыеУслуги, "ID");
		Если НЕ РезультатПоиска=Неопределено Тогда НоваяСтрока.Услуга=РезультатПоиска.Номенклатура; КонецЕсли;		
	КонецЦикла;

	тзДвижения.ЗаполнитьЗначения(Ссылка, "Регистратор");
	тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
	тзДвижения.ЗаполнитьЗначения(Дата, "Период");
	тзДвижения.ЗаполнитьЗначения(0, "Количество");
	тзДвижения.ЗаполнитьЗначения(Подразделение, "Подразделение");
	//тзДвижения.ЗаполнитьЗначения(ДоговорКонтрагента, "ДоговорКонтрагента");
	//тзДвижения.ЗаполнитьЗначения(Контрагент, "Контрагент");
	тзДвижения.ЗаполнитьЗначения(Организация, "Организация");
	тзДвижения.ЗаполнитьЗначения(СтруктураШД.Сделка, "ЗаказПокупателя");
	тзДвижения.ЗаполнитьЗначения(0, "НДС");
	тзДвижения.ЗаполнитьЗначения(0, "Стоимость");
	тзДвижения.ЗаполнитьЗначения(0, "СтоимостьБезСкидок");

	Движения.Продажи.Загрузить(тзДвижения);
КонецПроцедуры

Процедура ДвижениеПоРегистру_ВзаиморасчетыСКонтрагентами(СтруктураШД, СтруктураТД, Отказ)
	Если ВидОперации=Перечисления.ВидыОперацийПоступлениеДопРасходов.ВнутреннийРасход Тогда Возврат; КонецЕсли;
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ВзаиморасчетыСКонтрагентами") Тогда Возврат; КонецЕсли;	

	тзДвижения=Движения.ВзаиморасчетыСКонтрагентами.ВыгрузитьКолонки();
	ВзаиморасчетыСервер.ОтражениеЗадолженности(СтруктураШД, СтруктураТД, "Расход", тзДвижения, Отказ, ДополнительныеСвойства.Заголовок);
	Движения.ВзаиморасчетыСКонтрагентами.Загрузить(тзДвижения);		
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетНДС(СтруктураШД, СтруктураТД, Отказ) Экспорт
	Если СтруктураШД.УчетнаяПолитика.ОрганизацияНеЯвляетсяПлательщикомНДС тогда Возврат; КонецЕсли;
	ТаблицаАвансов=Новый ТаблицаЗначений();
	
	Если СтруктураТД.Товары.Количество()> 0 Тогда 
		УчетНДС.СформироватьДвиженияПоРегиструНДСРасчетыСПоставщиками_Задолженность(СтруктураШД, СтруктураТД.Товары, "ТаблицаПоТоварам", Движения, Отказ, СтруктураШД.УчетАгентскогоНДС, ТаблицаАвансов);
		Если СтруктураШД.УчитыватьНДС Тогда
			ТаблицаНачисления = СтруктураТД.Товары.Скопировать();
			СтрокиКУдалению = Новый Массив();
			Для каждого СтрокаНачисления Из ТаблицаНачисления Цикл
				Если СтрокаНачисления.ВидДоговораПартии = Перечисления.ВидыДоговоровКонтрагентов.СКомитентом тогда
					СтрокиКУдалению.Добавить(СтрокаНачисления);
				ИначеЕсли СтрокаНачисления.СуммаБезНДС=0 И СтрокаНачисления.НДС=0 тогда
					СтрокиКУдалению.Добавить(СтрокаНачисления);
				КонецЕсли;
			КонецЦикла;
			Для Каждого СтрокаКУдалению Из СтрокиКУдалению Цикл
				ТаблицаНачисления.удалить(СтрокаКУдалению);
			КонецЦикла;
			УчетНДС.СформироватьДвиженияПоРегиструНДСПредъявленный(СтруктураШД, ТаблицаНачисления, "ИдТабЧасти", Движения, Отказ);
		КонецЕсли;
	КонецЕсли;
	
	Если Не СтруктураШД.УчитыватьНДС Тогда Возврат; КонецЕсли; 

	Если СтруктураШД.УчетАгентскогоНДС Тогда
		Движения_НДСПредъявленный=ОбщегоНазначения.ПолучитьНаборЗаписейПоСсылке(СтруктураШД.Ссылка,РегистрыНакопления.НДСПредъявленный, Истина).Выгрузить();
		УчетНДС.СформироватьДвиженияПоРегиструНДСНачисленный_ПоступлениеАгентскогоНДС(СтруктураШД, Движения_НДСПредъявленный, Движения);
	КонецЕсли; 

	Если СтруктураТД.Товары.Количество()=0 Тогда Возврат; КонецЕсли;
	
	ТаблицаДляНДСПартии=ОбщегоНазначения.СформироватьТаблицуЗначений(СтруктураТД.Товары, Новый Структура("ДокументОприходования, ВидДоговораПартии, Склад, ВидЦенности,Номенклатура, ХарактеристикаНоменклатуры, СерияНоменклатуры, Услуга,НДС,СуммаБезНДС,Количество,СтавкаНДС,СчетУчетаНДС", "Партия"));

	СтрокиКУдалению=Новый Массив();
	Для каждого СтрокаТаблицыТоваров Из ТаблицаДляНДСПартии Цикл
		Если СтрокаТаблицыТоваров.Услуга Тогда
			СтрокиКУдалению.Добавить(СтрокаТаблицыТоваров);
		ИначеЕсли СтрокаТаблицыТоваров.ВидДоговораПартии = Перечисления.ВидыДоговоровКонтрагентов.СКомитентом тогда
			СтрокиКУдалению.Добавить(СтрокаТаблицыТоваров);
		КонецЕсли;			
	КонецЦикла;
	Для каждого СтрокаКУдалению Из СтрокиКУдалению Цикл
		ТаблицаДляНДСПартии.Удалить(СтрокаКУдалению);
	КонецЦикла;

	ТаблицаДляНДСПартии.ЗаполнитьЗначения(Истина, "Услуга");
	УчетНДС.СформироватьДвиженияПоступленияПоРегиструНДСПартииТоваров(СтруктураШД, ТаблицаДляНДСПартии, Движения.НДСПартииТоваров, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_РасходыПриУСН(СтруктураШД, СтруктураТД, Отказ)
	УчетнаяПолитика=ПараметрыУчетнойПолитики(Истина);
	Если УчетнаяПолитика.ОбъектНалогообложенияУСН=Перечисления.ОбъектыНалогообложенияПоУСН.Доходы Тогда	Возврат; КонецЕсли;	
	СистемаНалогообложения=УчетнаяПолитика.СистемаНалогообложения;
	ВключитьДвиженияУСН=Ложь;
	Если ДополнительныеСвойства.Свойство("ВключитьДвиженияУСН") Тогда
		ВключитьДвиженияУСН=ДополнительныеСвойства.ВключитьДвиженияУСН;
	КонецЕсли;

	Если СистемаНалогообложения=Перечисления.СистемыНалогообложения.Упрощенная Или СистемаНалогообложения=Перечисления.СистемыНалогообложения.Упрощенная_ЕНВД ИЛИ ВключитьДвиженияУСН Тогда
		тзДвижения=Движения.РасходыПриУСН.ВыгрузитьКолонки();
		
		тзДанные=СтруктураТД.Товары.Скопировать();
		Если УчетнаяПолитика.УчитыватьСписание Тогда
			тзДанные.Свернуть("Номенклатура,НеПринимаетсяУСН,ТОП,НомерСтрокиТабличнойЧасти,ВидТабличнойЧасти","Сумма, НДС");
		Иначе
			тзДанные.Свернуть("НеПринимаетсяУСН,ТОП,НомерСтрокиТабличнойЧасти,ВидТабличнойЧасти","Сумма, НДС");
		КонецЕсли;
		Для Каждого СтрокаКоллекции ИЗ тзДанные Цикл
			НоваяСтрока=тзДвижения.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока,СтрокаКоллекции);
			НоваяСтрока.Сумма=СтрокаКоллекции.Сумма+СтрокаКоллекции.НДС;
			Если УчетнаяПолитика.ПорядокПризнанияРасходовПоНДС=Перечисления.ПорядокПризнанияРасходовПоНДС.ВключатьВСтоимость Тогда
	 			НоваяСтрока.СуммаНДС=СтрокаКоллекции.НДС;
			КонецЕсли;
			НоваяСтрока.ДоговорКонтрагента=ДоговорКонтрагента;
			НоваяСтрока.СтатусыОплатыРасходов=Перечисления.СтатусыРасходовУСН.Куплено;
		КонецЦикла;
		
		тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
		тзДвижения.ЗаполнитьЗначения(Дата, "Период");
		тзДвижения.ЗаполнитьЗначения(ВидДвиженияНакопления.Приход, "ВидДвижения");
		тзДвижения.ЗаполнитьЗначения(Организация, "Организация");
   		тзДвижения.ЗаполнитьЗначения(Ссылка, "РасчетныйДокумент");
		
		Движения.РасходыПриУСН.Загрузить(тзДвижения);
	КонецЕсли;
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////
// Проведение по регистрам (по нескольким регистрам одного типа)

Процедура ДвижениеПоРегистру_УчетВзаиморасчетов(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_ВзаиморасчетыСКонтрагентами(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий модуля

Процедура ОбработкаЗаполнения(Основание)
	Если Не ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание) Тогда Возврат; КонецЕсли; 

	ЗаполнитьТоварыПоПоступлениюТоваров(Основание, Товары);	
	
	ОбработкаТабличныхЧастей.ЗаполнитьТиповыеОперации(ЭтотОбъект);
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
    Если ОбменДанными.Загрузка Тогда Возврат; КонецЕсли;	
	УчетНДС.ПроверитьСоответствиеРеквизитовСчетаФактуры(ЭтотОбъект, "СчетФактураПолученный");
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

	//Проверка
	Если НЕ ВидОперации=Перечисления.ВидыОперацийПоступлениеДопРасходов.ВнутреннийРасход Тогда
		ПроверяемыеРеквизиты.Добавить("Контрагент");
		ПроверяемыеРеквизиты.Добавить("ДоговорКонтрагента");
		ПроверяемыеРеквизиты.Добавить("КурсВзаиморасчетов");
		ПроверяемыеРеквизиты.Добавить("КратностьВзаиморасчетов");
	КонецЕсли;

	//Формирование значений реквизитов шапки документа
	СтруктураШД=УправлениеДокументамиСервер.СформироватьСтруктуруШД(ЭтотОбъект);
	СтруктураШД.Вставить("Направление", "Поступление");
	СтруктураШД.Вставить("ПроводитьПоВзаиморасчетам", НЕ ВидОперации=Перечисления.ВидыОперацийПоступлениеДопРасходов.ВнутреннийРасход);
	Если ДоговорКонтрагента.Пустая() Тогда
		СтруктураШД.Вставить("УчетАгентскогоНДС", Ложь);
	КонецЕсли;

	//Формирование значений реквизитов табличных частей
	тзТовары=СформироватьТаблицу_Товары(СтруктураШД, Отказ, Заголовок);
	
	//ВзаиморасчетыСервер.ПодготовкаТаблицыЗначенийДляЦелейПриобретенияИРеализации(тзТовары, СтруктураШД, СтруктураШД.НДСВключенВСтоимость);
	УчетНДС.ОпределениеДополнительныхПараметровТаблицыПартийДляПодсистемыУчетаНДС(СтруктураШД, тзТовары);

	Для Каждого СтрокаКоллекции ИЗ РаспределяемыеУслуги Цикл
		МассивСтрок=тзТовары.НайтиСтроки(Новый Структура("ID_РаспределяемыеУслуги", СтрокаКоллекции.ID));
		Для каждого СтрокаМассива Из МассивСтрок Цикл
			СтрокаМассива.СтавкаНДС=СтрокаКоллекции.СтавкаНДС;
		КонецЦикла;

		Если СтрокаКоллекции.СпособРаспределения=Перечисления.СпособыРаспределенияДопРасходов.ПоВесу Тогда
			Если тзТовары.Скопировать(МассивСтрок).Итог("Вес")=0 Тогда
				ТекстСообщения="Суммарный вес всех позиций номенклатуры равен нулю!";
				ОбщегоНазначения.СообщитьОбОшибке(ТекстСообщения, Отказ, Заголовок);
			КонецЕсли;
		КонецЕсли;

		Если СтрокаКоллекции.СпособРаспределения=Перечисления.СпособыРаспределенияДопРасходов.ПоОбъему Тогда
			Если тзТовары.Скопировать(МассивСтрок).Итог("Объем")=0 Тогда
				ТекстСообщения="Суммарный Объем всех позиций номенклатуры равен нулю!";
				ОбщегоНазначения.СообщитьОбОшибке(ТекстСообщения, Отказ, Заголовок);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	//Таблица "Взаиморасчеты"
	тзВзаиморасчеты=Новый ТаблицаЗначений;
	тзВзаиморасчеты.Колонки.Добавить("Сделка");
	тзВзаиморасчеты.Колонки.Добавить("СуммаБух");
	тзВзаиморасчеты.Колонки.Добавить("СуммаВал");
	тзВзаиморасчеты.Колонки.Добавить("ДокументРасчетов");
	тзВзаиморасчеты.Колонки.Добавить("ТипДоговораКонтрагента");

	НоваяСтрока=тзВзаиморасчеты.Добавить();
	НоваяСтрока.СуммаБух=тзТовары.Итог("СтоимостьСНДС"); //Стоимость
	Если НЕ ВалютаДокумента=МодульВалютногоУчета.ПолучитьВалюту("Бух") Тогда
		НоваяСтрока.СуммаВал=СуммаДокумента;
	КонецЕсли;	

	СтруктураТД=Новый Структура;
	СтруктураТД.Вставить("Товары", тзТовары);
	СтруктураТД.Вставить("Взаиморасчеты", тзВзаиморасчеты);

	//Инициализация доп.свойств документа	
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства, "Покупка");