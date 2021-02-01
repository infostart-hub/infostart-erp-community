﻿Перем мУчетнаяПолитикаНУ Экспорт;
Перем мВестиУчетНДС Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ АВТОЗАПОЛНЕНИЯ СТРОК ДОКУМЕНТА

Процедура ЗаполнитьДокумент(ОшибкаЗаполнения = Ложь, Сообщать = Истина, СтрокаСообщения = "", ОтменитьПроведение = Ложь) Экспорт
	
	Если Проведен Тогда
		Если ОтменитьПроведение Тогда
			Записать(РежимЗаписиДокумента.ОтменаПроведения);
		Иначе
			ОшибкаЗаполнения = Истина;
			СтрокаСообщения = " перед заполнением требуется отменить проведение документа";
			Если Сообщать Тогда
				ОбщегоНазначения.СообщитьОбОшибке("Документ не заполнен:" + СтрокаСообщения, , Строка(Ссылка));
			КонецЕсли; 
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ЗаполнитьСтроки_СМРхозспособом();

	Если Не (СМРхозспособом.Количество() > 0) Тогда
		ОшибкаЗаполнения = Истина;
		СтрокаСообщения = СтрокаСообщения+Символы.ПС+" - не обнаружены расходы на строительство хоз. способом, начисление НДС не требуется"
	КонецЕсли;	

   Если ОшибкаЗаполнения Тогда
		Если Сообщать Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Документ не заполнен:"+СтрокаСообщения,,Строка(Ссылка));
		КонецЕсли; 
		Возврат;
	КонецЕсли; 
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Заполнение табличной части "СМР хозспособом"

Процедура ЗаполнитьСтроки_СМРхозспособом() Экспорт
	
	// Если учетная политика не заполнена
	Если не ?(НЕ ЗначениеЗаполнено(мУчетнаяПолитикаНУ), Ложь, мУчетнаяПолитикаНУ.Свойство("НДСНалоговыйПериод")) тогда
		ОшибкаПолученияУчетнойПолитики = Ложь;
		мУчетнаяПолитикаНУ = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(Дата, ОшибкаПолученияУчетнойполитики, Организация);
		Если ОшибкаПолученияУчетнойПолитики Тогда Возврат; КонецЕсли;
	КонецЕсли; 
	
	ТаблицаРезультатов = СМРхозспособом.ВыгрузитьКолонки();
	
	ЗаполнениеПоТекущемуНалоговомуПериоду = ( не НачалоДня(Дата) < '20060101');
	
	Если ЗаполнениеПоТекущемуНалоговомуПериоду Тогда
		НачалоПериода	= УчетНалоговСервер.НачалоПериодаПоУчетнойПолитике(Организация, Дата, Ложь, мУчетнаяПолитикаНУ);
		КонецПериода	= УчетНалоговСервер.КонецПериодаПоУчетнойПолитике(Организация, Дата, Ложь, мУчетнаяПолитикаНУ);	
	Иначе
		НачалоПериода	= '20050101';
		КонецПериода	= '20051231235959';	
	КонецЕсли; 
	
	ТаблицаРезультатов = ЗаполнитьСМРхозспособомПоУказаномуПериоду(НачалоПериода, КонецПериода, ЗаполнениеПоТекущемуНалоговомуПериоду);
		
	СМРхозспособом.Загрузить(ТаблицаРезультатов);

КонецПроцедуры

Функция ЗаполнитьСМРхозспособомПоУказаномуПериоду(НачалоПериода, КонецПериода, ЗаполнениеПоТекущемуНалоговомуПериоду)

	Запрос = Новый Запрос;
	Если ЗаполнениеПоТекущемуНалоговомуПериоду Тогда
		Запрос.Текст="
		|ВЫБРАТЬ
		|	СтроительствоХозспособом.Объект КАК ОбъектСтроительства,
		|	СтроительствоХозспособом.СтатьяЗатрат КАК СтатьяЗатрат,
		|	СтроительствоХозспособом.СпособСтроительства КАК СпособСтроительства,
		|	СУММА(СтроительствоХозспособом.Сумма) КАК СуммаБезНДС,
		|	&СтавкаНДС КАК СтавкаНДС,
		|	СУММА(СтроительствоХозспособом.Сумма * &СтавкаНДС_Значение / 100) КАК НДС
		|ИЗ
		|	(ВЫБРАТЬ
		|		ХозрасчетныйОбороты.Субконто1 КАК Объект,
		|		ХозрасчетныйОбороты.Субконто2 КАК СтатьяЗатрат,
		|		ХозрасчетныйОбороты.Субконто3 КАК СпособСтроительства,
		|		ХозрасчетныйОбороты.СуммаОборотДт КАК Сумма
		|	ИЗ		
		|		РегистрБухгалтерии.Хозрасчетный.Обороты(&НачалоПериода,	&КонецПериода, Период, Счет В ИЕРАРХИИ (&СчетУчетаСтроительства), ,
		|			Организация = &Организация И Субконто3=&ВидСтроительства_Хозспособом) КАК ХозрасчетныйОбороты
		//|	ГДЕ
		|		) Как СтроительствоХозспособом
		|
		|СГРУППИРОВАТЬ ПО
		|	СтроительствоХозспособом.Объект,
		|	СтроительствоХозспособом.СтатьяЗатрат,
		|	СтроительствоХозспособом.СпособСтроительства
		|
		//|ИМЕЮЩИЕ
		//|	СУММА(СтроительствоХозспособом.Сумма) > 0
		|";   //И Субконто3=&ВидСтроительства_Хозспособом
	Иначе
		Запрос.Текст="
		|ВЫБРАТЬ
		|	СтроительствоХозспособом.Объект КАК ОбъектСтроительства,
		|	СтроительствоХозспособом.СтатьяЗатрат КАК СтатьяЗатрат,
		|	СтроительствоХозспособом.СпособСтроительства КАК СпособСтроительства,
		|	СУММА(СтроительствоХозспособом.Сумма) КАК СуммаБезНДС,
		|	&СтавкаНДС КАК СтавкаНДС,
		|	СУММА(СтроительствоХозспособом.Сумма * &СтавкаНДС_Значение / 100) КАК НДС
		|ИЗ
		|	(ВЫБРАТЬ
		|		ХозрасчетныйОбороты.Субконто1 КАК Объект,
		|		ХозрасчетныйОбороты.Субконто2 КАК СтатьяЗатрат,
		|		ХозрасчетныйОбороты.Субконто3 КАК СпособСтроительства,
		|		ХозрасчетныйОбороты.СуммаОборотДт КАК Сумма
		|	ИЗ
		|		РегистрБухгалтерии.Хозрасчетный.Обороты(&НачалоПериода, &КонецПериода, Период, Счет В ИЕРАРХИИ (&СчетУчетаСтроительства), ,
		|			Организация = &Организация И Субконто3=&ВидСтроительства_Хозспособом) КАК ХозрасчетныйОбороты
		//|	ГДЕ
		|		) Как СтроительствоХозспособом
		|
		|СГРУППИРОВАТЬ ПО
		|	СтроительствоХозспособом.Объект,
		|	СтроительствоХозспособом.СтатьяЗатрат,
		|	СтроительствоХозспособом.СпособСтроительства
		|
		//|ИМЕЮЩИЕ
		//|	СУММА(СтроительствоХозспособом.Сумма) > 0
		|";
	КонецЕсли; 

	ВидыСубконто = Новый Массив();
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.ОбъектыСтроительства);
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.СпособыСтроительства);

	Запрос.УстановитьПараметр("Организация"		, Организация);
	Запрос.УстановитьПараметр("НачалоПериода"	, новый граница(НачалоПериода,ВидГраницы.Включая));
	Запрос.УстановитьПараметр("КонецПериода"	, новый граница(КонецПериода,ВидГраницы.Включая));
	Запрос.УстановитьПараметр("СчетУчетаСтроительства", ПланыСчетов.Хозрасчетный.СтроительствоОбъектовОсновныхСредств);
	Запрос.УстановитьПараметр("ВидыСубконто"	, ВидыСубконто);
	Запрос.УстановитьПараметр("ВидСтроительства_Хозспособом"	, Перечисления.СпособыСтроительства.Хозспособ);
	Запрос.УстановитьПараметр("СтавкаНДС"						, Перечисления.СтавкиНДС.НДС18);
	Запрос.УстановитьПараметр("СтавкаНДС_Значение"				, УчетНалоговСервер.СтавкаНДС(Перечисления.СтавкиНДС.НДС18));
	
	ТаблицаРезультатов = Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.Прямой);
	МассивСтрокДляУдаления=Новый Массив;
	Для Каждого СтрокаТз ИЗ ТаблицаРезультатов Цикл
		Если СтрокаТз.СпособСтроительства=Перечисления.СпособыСтроительства.Хозспособ Тогда Продолжить; КонецЕсли;
		Если НЕ ЗначениеЗаполнено(СтрокаТз.СпособСтроительства) Тогда Продолжить; КонецЕсли;
		МассивСтрокДляУдаления.Добавить(СтрокаТз);
	КонецЦикла;
	Для Каждого СтрокаМ ИЗ МассивСтрокДляУдаления Цикл
		ТаблицаРезультатов.Удалить(СтрокаМ);	
	КонецЦикла;	
	
	Возврат ТаблицаРезультатов;
	
КонецФункции

Процедура ПроверитьСуществованиеДругихДокументовВТекущемПериоде(СтруктураШД, Отказ,Заголовок)
	ЗаполнениеПоТекущемуНалоговомуПериоду = ( не НачалоДня(Дата) < '20060101');

	Если ЗаполнениеПоТекущемуНалоговомуПериоду Тогда
	    НачалоПериода	= УчетНалоговСервер.НачалоПериодаПоУчетнойПолитике(Организация, Дата, Отказ, мУчетнаяПолитикаНУ);
		КонецПериода	= УчетНалоговСервер.КонецПериодаПоУчетнойПолитике(Организация, Дата, Отказ, мУчетнаяПолитикаНУ);
	Иначе
	    НачалоПериода	= '20050101';
		КонецПериода	= '20051231235959';	
	КонецЕсли; 
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("НачалоПериода",	НачалоДня(НачалоПериода));
	Запрос.УстановитьПараметр("КонецПериода",	КонецДня(КонецПериода));
	Запрос.УстановитьПараметр("Организация",	СтруктураШД.Организация);
	Запрос.УстановитьПараметр("ТекущийДокумент",СтруктураШД.Ссылка);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.Ссылка,
	|	ИсточникДанных.Представление
	|ИЗ
	|	Документ.НачислениеНДСпоСМРхозспособом КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.Дата >= &НачалоПериода
	|	И ИсточникДанных.Дата <= &КонецПериода
	|	И ИсточникДанных.Организация = &Организация
	|	И (НЕ ИсточникДанных.Ссылка = &ТекущийДокумент)
	|	И ИсточникДанных.Проведен = ИСТИНА
	|";
	Результат=Запрос.Выполнить();
	Если Результат.Пустой() Тогда Возврат; КонецЕсли; 
	
	СтрокаДокументовПересечений = "";
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если НЕ ПустаяСтрока(СтрокаДокументовПересечений) Тогда
			СтрокаДокументовПересечений = СтрокаДокументовПересечений + Символы.ПС;
		КонецЕсли; 
		СтрокаДокументовПересечений = СтрокаДокументовПересечений + Строка(Выборка.Представление);
	КонецЦикла; 
	
	Если НЕ ПустаяСтрока(СтрокаДокументовПересечений) Тогда
		Отказ=Истина;
		Сообщить("Найдены документы по начислению НДС по СМР хозспособом, которые действуют в выбранном периоде("+ПредставлениеПериода(НачалоДня(НачалоПериода), КонецДня(КонецПериода), "ФП = Истина")+"):" + Символы.ПС + СтрокаДокументовПересечений);
	КонецЕсли; 	
КонецПроцедуры
 
Функция ПодготовитьТаблицуПоСМРхозспособом(РезультатЗапросаПоСМРхозспособом, СтруктураШД)

	ТаблицаСМРхозспособом = РезультатЗапросаПоСМРхозспособом.Выгрузить();
	
	ТаблицаСМРхозспособом.Колонки.Добавить("ВидЦенности", Новый ОписаниеТипов("ПеречислениеСсылка.ВидыЦенностей"));
	ТаблицаСМРхозспособом.ЗаполнитьЗначения(Перечисления.ВидыЦенностей.СМРСобственнымиСилами, "ВидЦенности");
	
	ТаблицаСМРхозспособом.Колонки.Добавить("Состояние");
	////ТаблицаСМРхозспособом.Колонки.Добавить("Состояние", Новый ОписаниеТипов("ПеречислениеСсылка.НДССостоянияОСНМА"));
	////ТаблицаСМРхозспособом.ЗаполнитьЗначения(Перечисления.НДССостоянияОСНМА.ОжидаетсяПринятиеКУчетуОбъектаСтроительства, "Состояние");
	
	ТаблицаСМРхозспособом.Колонки.Добавить("СчетУчетаНДС", Новый ОписаниеТипов("ПланСчетовСсылка.Хозрасчетный"));
	ТаблицаСМРхозспособом.ЗаполнитьЗначения(ПланыСчетов.Хозрасчетный.НДСприСтроительствеОсновныхСредств, "СчетУчетаНДС");
	
	ТаблицаСМРхозспособом.Колонки.Добавить("СчетУчетаНДСПоРеализации", Новый ОписаниеТипов("ПланСчетовСсылка.Хозрасчетный"));
	ТаблицаСМРхозспособом.ЗаполнитьЗначения(ПланыСчетов.Хозрасчетный.НДСприСтроительствеОсновныхСредств, "СчетУчетаНДСПоРеализации");
	
	ТаблицаСМРхозспособом.Колонки.Добавить("НеВлияетНаВычет", Новый ОписаниеТипов("Булево"));
	ТаблицаСМРхозспособом.ЗаполнитьЗначения(Истина, "НеВлияетНаВычет");

	ТаблицаСМРхозспособом.Колонки.Добавить("Сумма", ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15, 2));
	ТаблицаСМРхозспособом.ЗагрузитьКолонку(ТаблицаСМРхозспособом.ВыгрузитьКолонку("СуммаБезНДС"), "Сумма");
	
	Возврат ТаблицаСМРхозспособом;

КонецФункции

// По результату запроса по шапке документа формируем движения по регистрам.
//
Процедура ДвиженияПоРегистрам(СтруктураШД, ТаблицаПоСМРхозспособом, Отказ, Заголовок)
	Если Отказ Тогда Возврат; КонецЕсли;
	ДвиженияПоРегистрамРегл(СтруктураШД, ТаблицаПоСМРхозспособом, Отказ, Заголовок);
	ДвиженияПоРегистрамНДС_НачислениеСМРхозспособом(СтруктураШД, ТаблицаПоСМРхозспособом, Отказ, Заголовок);	
КонецПроцедуры

Процедура ДвиженияПоРегистрамРегл(СтруктураШД, ТаблицаПоСМРхозспособом, Отказ, Заголовок)
	
	Для Каждого СтрокаНачисления Из ТаблицаПоСМРхозспособом Цикл
		
		Если СтрокаНачисления.НДС <> 0 Тогда
			// Проводка по уплате НДС в бюджет
			ПроводкаБУ = Движения.Хозрасчетный.Добавить();
			ПроводкаБУ.Период = СтруктураШД.Дата;
			ПроводкаБУ.Организация = СтруктураШД.Организация;
			ПроводкаБУ.Содержание = "Начислен НДС по строительству хоз. способом";
			
			ПроводкаБУ.СчетДт = СтрокаНачисления.СчетУчетаНДС;
			БухгалтерскийУчет.УстановитьСубконтоПоСчету(ПроводкаБУ.СчетДт, ПроводкаБУ.СубконтоДт, "ОбъектыСтроительства", СтрокаНачисления.Объект);
			БухгалтерскийУчет.УстановитьСубконтоПоСчету(ПроводкаБУ.СчетДт, ПроводкаБУ.СубконтоДт, "СФПолученные", СтрокаНачисления.СчетФактура, Истина);
			
			ПроводкаБУ.СчетКт = ПланыСчетов.Хозрасчетный.НДС;
			БухгалтерскийУчет.УстановитьСубконтоПоСчету(ПроводкаБУ.СчетКт, ПроводкаБУ.СубконтоКт, "ВидыПлатежейВГосБюджет", Перечисления.ВидыПлатежейВГосБюджет.Налог);

			ПроводкаБУ.Сумма = СтрокаНачисления.НДС;
		КонецЕсли; 
		
	КонецЦикла;
		
КонецПроцедуры

// По результату запроса по шапке документа формируем движения по регистрам.
// Отрабатывает по табличной части "СМРхозспособом"
//
Процедура ДвиженияПоРегистрамНДС_НачислениеСМРхозспособом(СтруктураШД, ТаблицаПоСМРхозспособом, Отказ, Заголовок)

	Если ТаблицаПоСМРхозспособом.КОличество()=0 Тогда Возврат; КонецЕсли; 
	
	Если мВестиУчетНДС Тогда
		// Отражение по регистру "НДС начисленный"
		ТаблицаДвижений_НДСНачисленный = Движения.НДСНачисленный.ВыгрузитьКолонки();
		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоСМРхозспособом,ТаблицаДвижений_НДСНачисленный);
		ТаблицаДвижений_НДСНачисленный.ЗаполнитьЗначения(ПланыСчетов.Хозрасчетный.НДС,"СчетУчетаНДС");
		ТаблицаДвижений_НДСНачисленный.Свернуть("Период,Активность,Организация,СчетФактура,ВидЦенности,СтавкаНДС,СчетУчетаНДС,Покупатель,ДатаСобытия,Событие,ВидНачисления","СуммаБезНДС,НДС");
		
		ТаблицаДвижений_НДСНачисленный.ЗаполнитьЗначения(Перечисления.СобытияПоНДСПродажи.НДСНачисленКУплате,"Событие");
		ТаблицаДвижений_НДСНачисленный.ЗаполнитьЗначения(Перечисления.НДСВидНачисления.НДСНачисленКУплате,"ВидНачисления");
		
		Движения.НДСНачисленный.мПериод = СтруктураШД.Дата;
		Движения.НДСНачисленный.мТаблицаДвижений = ТаблицаДвижений_НДСНачисленный;
		Движения.НДСНачисленный.ВыполнитьПриход();
		
		// Отражение по регистру "НДС предъявленный"
		ТаблицаДвижений_НДСПредъявленный = Движения.НДСПредъявленный.ВыгрузитьКолонки();
		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоСМРхозспособом,ТаблицаДвижений_НДСПредъявленный);
		ТаблицаДвижений_НДСПредъявленный.Свернуть("Период,Активность,Организация,СчетФактура,ВидЦенности,СтавкаНДС,СчетУчетаНДС,Поставщик,ДатаСобытия,Событие","СуммаБезНДС,НДС");
		ТаблицаДвижений_НДСПредъявленный.ЗаполнитьЗначения(Перечисления.СобытияПоНДСПокупки.ПредъявленНДСПоставщиком,"Событие");

		Движения.НДСПредъявленный.мПериод = СтруктураШД.Дата;
		Движения.НДСПредъявленный.мТаблицаДвижений = ТаблицаДвижений_НДСПредъявленный;
		Движения.НДСПредъявленный.ВыполнитьПриход();

		// Отражение по регистру взаиморасчетов
		Если не ТаблицаПоСМРхозспособом.Итог("НДС") = 0 Тогда
			ТаблицаДвижений_НДСРасчетыСПоставщиками = Движения.НДСРасчетыСПоставщиками.ВыгрузитьКолонки();
			
			СтрокаРасчетов = ТаблицаДвижений_НДСРасчетыСПоставщиками.Добавить();
			СтрокаРасчетов.Организация		= СтруктураШД.Организация;
			СтрокаРасчетов.Документ			= СтруктураШД.Ссылка;
			СтрокаРасчетов.РасчетыСБюджетом = Истина;
			СтрокаРасчетов.Сумма			= ТаблицаПоСМРхозспособом.Итог("НДС");
			
			Движения.НДСРасчетыСПоставщиками.мПериод = СтруктураШД.Дата;
			Движения.НДСРасчетыСПоставщиками.мТаблицаДвижений = ТаблицаДвижений_НДСРасчетыСПоставщиками;
			Движения.НДСРасчетыСПоставщиками.ВыполнитьПриход();
		КонецЕсли; 

	КонецЕсли;

КонецПроцедуры

Процедура ПодготовитьТаблицыДокумента(СтруктураШД, ТаблицаПоСМРхозспособом) Экспорт
	
	// Подготовим данные необходимые для проведения и проверки заполнения табличной части.
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Организация",	"Ссылка.Организация");
	СтруктураПолей.Вставить("СчетФактура",	"Ссылка");
	СтруктураПолей.Вставить("Объект",		"ОбъектСтроительства");
	СтруктураПолей.Вставить("СтавкаНДС",	"СтавкаНДС");
	СтруктураПолей.Вставить("СуммаБезНДС",	"СуммаБезНДС");
	СтруктураПолей.Вставить("НДС",			"НДС");
	СтруктураПолей.Вставить("ДатаСобытия",	"Ссылка.Дата");

	РезультатЗапросаСМРхозспособом	= УправлениеЗапасами.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "СМРхозспособом", СтруктураПолей);
	ТаблицаПоСМРхозспособом			= ПодготовитьТаблицуПоСМРхозспособом(РезультатЗапросаСМРхозспособом,СтруктураШД);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	Перем ТаблицаПоСМРхозспособом;

	УправлениеДокументамиСервер.ПередПроведением(Отказ, РежимПроведения, ЭтотОбъект);
	Если Отказ Тогда Возврат; КонецЕсли; 
	
	Заголовок=ДополнительныеСвойства.Заголовок;

	СтруктураШД=ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	ПроверитьСуществованиеДругихДокументовВТекущемПериоде(СтруктураШД, Отказ,Заголовок);
	ПодготовитьТаблицыДокумента(СтруктураШД, ТаблицаПоСМРхозспособом);

	мВестиУчетНДС=Истина;

	ДвиженияПоРегистрам(СтруктураШД, ТаблицаПоСМРхозспособом, Отказ, Заголовок);
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка Тогда Возврат; КонецЕсли;
	мУчетнаяПолитикаНУ = Неопределено;
	УчетНДС.ПроверитьСоответствиеРеквизитовСчетаФактуры(ЭтотОбъект);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства);
