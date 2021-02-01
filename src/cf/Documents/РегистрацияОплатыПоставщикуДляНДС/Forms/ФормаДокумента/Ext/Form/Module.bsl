﻿&НаКлиенте
Процедура ВыполнитьДействие(Команда)
	Если Команда.Имя="УправлениеШапкой" Тогда
		Видимость=НЕ Элементы.ШапкаПанель1.Видимость;		
		Элементы.ШапкаПанель1.Видимость=Видимость;
		Элементы.ШапкаПанель2.Видимость=Видимость;
		Элементы[Команда.Имя].Картинка=?(Видимость, БиблиотекаКартинок.СтрелкаВнизСплошная, БиблиотекаКартинок.СтрелкаВправоКрасная);
		Элементы.ШапкаИнфо.Видимость=Не Видимость;

		МассивДанных=Новый Массив;
		МассивДанных.Добавить(Новый ФорматированнаяСтрока(" Организация: ", Новый Шрифт(,,Истина), Новый Цвет(0,0,255)));
		МассивДанных.Добавить(СокрЛП(Объект.Организация));
		
		МассивДанных.Добавить(Новый ФорматированнаяСтрока(" | Куратор: ", Новый Шрифт(,,Истина), Новый Цвет(0,0,255)));
		МассивДанных.Добавить(СокрЛП(Объект.Ответственный));

		МассивДанных.Добавить(Новый ФорматированнаяСтрока(" | Комментарий: ", Новый Шрифт(,,Истина), Новый Цвет(0,0,255)));
		МассивДанных.Добавить(СокрЛП(Объект.Комментарий));

		Элементы.ШапкаИнфо.Заголовок=Новый ФорматированнаяСтрока(МассивДанных);		
	Иначе
		УправлениеДиалогамиКлиент.ВыполнитьДействие(Команда.Имя, ЭтаФорма, Объект);
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьРеквизитыФормы(стрРеквизиты)
	МассивРеквизитов=СтрРазделить(стрРеквизиты, ",");
	Для каждого ИмяРеквизита Из МассивРеквизитов Цикл
		Если ИмяРеквизита="УчетнаяПолитика" Тогда
			УчетнаяПолитика=ОбщегоНазначенияСервер.ПараметрыУчетнойПолитики(Объект.Организация, Объект.Дата);
		КонецЕсли;
	КонецЦикла; 
КонецПроцедуры

&НаСервере
Функция ПолучитьРасшифровкуПлатежа(Документ, РасшифровкаПлатежаПоДокументам)
	Если РасшифровкаПлатежаПоДокументам[Документ] = Неопределено Тогда
		СтруктураШД=ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(Документ);

		НаборЗаписей=РегистрыНакопления.ВзаиморасчетыСКонтрагентами.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Регистратор.Установить(Документ);
		НаборЗаписей.Прочитать();

		Расшифровка=НаборЗаписей.Выгрузить();
		Расшифровка.Колонки.СуммаБух.Имя="СуммаВзаиморасчетов";
		Расшифровка.Индексы.Добавить("ДоговорКонтрагента");

		РасшифровкаПлатежаПоДокументам.Вставить(Документ, Расшифровка);
	КонецЕсли; 
	
	Возврат РасшифровкаПлатежаПоДокументам[Документ];
КонецФункции

&НаСервере
Функция ПолучитьДокументыРасчетовСКонтрагентом(Документ, ДокументыРасчетовСКонтрагентомПоДокументам)
	Если ДокументыРасчетовСКонтрагентомПоДокументам[Документ]=Неопределено Тогда
		МетаданныеДокумента=Документ.Метаданные(); Расшифровка=Ложь;
		Если НЕ МетаданныеДокумента.ТабличныеЧасти.Найти("ДокументыРасчетовСКонтрагентом")=Неопределено Тогда
			Расшифровка=Документ.ДокументыРасчетовСКонтрагентом.Выгрузить();
		КонецЕсли;
		ДокументыРасчетовСКонтрагентомПоДокументам.Вставить(Документ, Расшифровка);
	КонецЕсли; 
	
	Возврат ДокументыРасчетовСКонтрагентомПоДокументам[Документ];
КонецФункции
 
&НаСервере
Процедура ЗаполнитьСтрокиРаспределенияОплат() Экспорт 
	ТаблицаРезультатов=Объект.Состав.Выгрузить();
	
	НераспределенныеРасчеты = ПолучитьИнформациюПоНепогашеннойЗадолженностиИНераспределеннымОплатам();
	Если НераспределенныеРасчеты.Строки.Количество()=0 Тогда
		// Дальнейшая обработка не требуется, не обнаружены нераспределенные расчеты.
		Объект.Состав.Очистить(); Возврат;
	КонецЕсли;
	
	НепогашеннаяЗадолженность=новый ТаблицаЗначений();
	НепогашеннаяЗадолженность.Колонки.Добавить("ДатаДокумента", ОбщегоНазначения.ПолучитьОписаниеТиповДаты(ЧастиДаты.ДатаВремя));
	НепогашеннаяЗадолженность.Колонки.Добавить("Документ", 		Документы.ТипВсеСсылки());
	НепогашеннаяЗадолженность.Колонки.Добавить("Сумма",			ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,2));
	НепогашеннаяЗадолженность.Индексы.Добавить("Документ");
	
	НераспределенныеОплаты=НепогашеннаяЗадолженность.Скопировать();
	
	// Временное хранение расшифровок платежа по документа оплаты (при ведении расчетов по документам)
	РасшифровкаПлатежаПоДокументам = новый Соответствие;
	ДокументыРасчетовСКонтрагентомПоДокументам = новый Соответствие;
	
	Для каждого РасчетыПоТипуДоговору Из НераспределенныеРасчеты.Строки Цикл
		Для каждого РасчетыПоДоговору Из РасчетыПоТипуДоговору.Строки Цикл
			КолонкаЗачета="Сумма"; //КолонкаРаспределения="Сумма";
			Если РасчетыПоДоговору[КолонкаЗачета] = 0 или РасчетыПоДоговору["Оплата"+КолонкаЗачета] = 0 Тогда
				Продолжить; // Не обнаружена непогашенная задолженность или нераспределенная оплата
			КонецЕсли; 
			НепогашеннаяЗадолженность.Очистить();
			НераспределенныеОплаты.Очистить();
			
			ПроводитьОтборПоДокументуРасчетов = Ложь; ///РасчетыПоДоговору.ВестиПоДокументамРасчетовСКонтрагентом;
			
			Для каждого СтрокаРасчетов  Из РасчетыПоДоговору.Строки Цикл
				Если СтрокаРасчетов.ЭтоОплата Тогда
					Если не НепогашеннаяЗадолженность.Итог(КолонкаЗачета) = 0 Тогда
						
						РасшифровкаПлатежа = Ложь;
						Если ПроводитьОтборПоДокументуРасчетов Тогда
							РасшифровкаПлатежа = ПолучитьРасшифровкуПлатежа(СтрокаРасчетов.Документ, РасшифровкаПлатежаПоДокументам);
						КонецЕсли;
						Если не РасшифровкаПлатежа = Ложь Тогда
							СтруктураОтбораРасшифровки = Новый Структура("ДоговорКонтрагента",СтрокаРасчетов.ДоговорКонтрагента);

							СтрокиПоДоговору = РасшифровкаПлатежа.НайтиСтроки(СтруктураОтбораРасшифровки);
							Для каждого СтрокаПоДоговору Из СтрокиПоДоговору Цикл
								Если СтрокаПоДоговору.СуммаВзаиморасчетов = 0  Тогда Продолжить; КонецЕсли; 
								Если НЕ ЗначениеЗаполнено(СтрокаПоДоговору.ДокументРасчетов) Тогда Продолжить; КонецЕсли; 
								
								СтруктураОтбораЗадолженности = Новый структура("Документ",СтрокаПоДоговору.ДокументРасчетов);
								
								СтрокиЗадолженностиПоОтбору = НепогашеннаяЗадолженность.НайтиСтроки(СтруктураОтбораЗадолженности);
								Для каждого СтрокаЗадолженности Из СтрокиЗадолженностиПоОтбору Цикл
									//СуммаЗачета = Макс(0, Мин(СтрокаПоДоговору.СуммаВзаиморасчетов, СтрокаЗадолженности.ВалютнаяСумма,СтрокаРасчетов.ОплатаВалютнаяСумма));
									СуммаЗачета = Макс(0, Мин(СтрокаПоДоговору.СуммаВзаиморасчетов, СтрокаЗадолженности.Сумма, СтрокаРасчетов.ОплатаСумма));
									Если СуммаЗачета = 0 Тогда Продолжить; КонецЕсли; 
									
									СтрокаРаспределения=ТаблицаРезультатов.Добавить();
									СтрокаРаспределения.Поставщик			= СтрокаРасчетов.Поставщик;
									СтрокаРаспределения.ДоговорКонтрагента	= СтрокаРасчетов.ДоговорКонтрагента;
									СтрокаРаспределения.ТипДоговораКонтрагента	= СтрокаРасчетов.ТипДоговораКонтрагента;
									СтрокаРаспределения.СчетФактура			= СтрокаЗадолженности.Документ;
									СтрокаРаспределения.ЗачетАванса			= Ложь;
									СтрокаРаспределения.ДатаОплаты			= СтрокаРасчетов.ДатаДокумента;
									СтрокаРаспределения.ДокументОплаты		= СтрокаРасчетов.Документ;
									СтрокаРаспределения[КолонкаЗачета] 		= СуммаЗачета;
									СтрокаРасчетов["Оплата"+КолонкаЗачета]	= СтрокаРасчетов["Оплата"+КолонкаЗачета] - СуммаЗачета;
									СтрокаЗадолженности[КолонкаЗачета]		= СтрокаЗадолженности[КолонкаЗачета] - СуммаЗачета;
									
									СтрокаПоДоговору.СуммаВзаиморасчетов = СтрокаПоДоговору.СуммаВзаиморасчетов - СуммаЗачета;
								КонецЦикла; 
							КонецЦикла; 
							
						Иначе
							Для каждого СтрокаЗадолженности Из НепогашеннаяЗадолженность Цикл
								Если СтрокаЗадолженности[КолонкаЗачета]=0 Тогда Продолжить; КонецЕсли;
								
								СуммаЗачета = Макс(0,мин(СтрокаЗадолженности[КолонкаЗачета], СтрокаРасчетов["Оплата"+КолонкаЗачета]));
								Если СуммаЗачета = 0 Тогда Продолжить; КонецЕсли; 
								
								СтрокаРаспределения = ТаблицаРезультатов.Добавить();
								СтрокаРаспределения.Поставщик			= СтрокаРасчетов.Поставщик;
								СтрокаРаспределения.ДоговорКонтрагента	= СтрокаРасчетов.ДоговорКонтрагента;
								СтрокаРаспределения.ТипДоговораКонтрагента	= СтрокаРасчетов.ТипДоговораКонтрагента;
								СтрокаРаспределения.СчетФактура			= СтрокаЗадолженности.Документ;
								СтрокаРаспределения.ЗачетАванса			= Ложь;
								СтрокаРаспределения.ДатаОплаты			= СтрокаРасчетов.ДатаДокумента;
								СтрокаРаспределения.ДокументОплаты		= СтрокаРасчетов.Документ;
								СтрокаРаспределения[КолонкаЗачета] 		= СуммаЗачета;
								СтрокаРасчетов["Оплата"+КолонкаЗачета]	= СтрокаРасчетов["Оплата"+КолонкаЗачета] - СуммаЗачета;
								СтрокаЗадолженности[КолонкаЗачета]		= СтрокаЗадолженности[КолонкаЗачета] - СуммаЗачета;
							КонецЦикла; 
						КонецЕсли;
					КонецЕсли; 
					Если не СтрокаРасчетов["Оплата"+КолонкаЗачета] = 0 Тогда
						НераспределеннаяСтрока = НераспределенныеОплаты.Добавить();
						НераспределеннаяСтрока.ДатаДокумента	= СтрокаРасчетов.ДатаДокумента;
						НераспределеннаяСтрока.Документ			= СтрокаРасчетов.Документ;
						НераспределеннаяСтрока.Сумма			= СтрокаРасчетов.ОплатаСумма;
					КонецЕсли; 
					
				Иначе	
					Если не НераспределенныеОплаты.Итог(КолонкаЗачета)=0 Тогда
						
						РасшифровкаПлатежа = Ложь;
						Если ПроводитьОтборПоДокументуРасчетов Тогда
							РасшифровкаПлатежа = ПолучитьДокументыРасчетовСКонтрагентом(СтрокаРасчетов.Документ, ДокументыРасчетовСКонтрагентомПоДокументам);
						КонецЕсли;
						Если не РасшифровкаПлатежа = Ложь Тогда
							СтрокиПоДоговору = РасшифровкаПлатежа;	
							
							Для каждого СтрокаПоДоговору Из СтрокиПоДоговору Цикл
								Если СтрокаПоДоговору.СуммаВзаиморасчетов = 0  Тогда Продолжить; КонецЕсли; 
								
								СтруктураОтбораОплат = новый структура("Документ",СтрокаПоДоговору.ДокументРасчетовСКонтрагентом);

								СтрокиОплатПоОтбору = НераспределенныеОплаты.НайтиСтроки(СтруктураОтбораОплат);
								Для каждого СтрокаОплаты Из СтрокиОплатПоОтбору Цикл
									Если СтрокаОплаты[КолонкаЗачета] = 0 Тогда Продолжить; КонецЕсли; 
									
									//СуммаЗачета = Макс(0,мин(СтрокаПоДоговору.СуммаВзаиморасчетов, СтрокаОплаты.ВалютнаяСумма,СтрокаРасчетов.ВалютнаяСумма));
									СуммаЗачета = Макс(0,мин(СтрокаПоДоговору.СуммаВзаиморасчетов, СтрокаОплаты.Сумма,СтрокаРасчетов.Сумма));
									Если СуммаЗачета = 0 Тогда Продолжить; КонецЕсли; 
									
									СтрокаРаспределения = ТаблицаРезультатов.Добавить();
									СтрокаРаспределения.Поставщик			= СтрокаРасчетов.Поставщик;
									СтрокаРаспределения.ДоговорКонтрагента	= СтрокаРасчетов.ДоговорКонтрагента;
									СтрокаРаспределения.ТипДоговораКонтрагента	= СтрокаРасчетов.ТипДоговораКонтрагента;
									СтрокаРаспределения.СчетФактура			= СтрокаРасчетов.Документ;
									СтрокаРаспределения.ЗачетАванса			= Истина;
									СтрокаРаспределения.ДатаОплаты			= СтрокаОплаты.ДатаДокумента;
									СтрокаРаспределения.ДокументОплаты		= СтрокаОплаты.Документ;
									СтрокаРаспределения[КолонкаЗачета] 		= СуммаЗачета;
									СтрокаРасчетов[КолонкаЗачета]			= СтрокаРасчетов[КолонкаЗачета] - СуммаЗачета;
									СтрокаОплаты[КолонкаЗачета]				= СтрокаОплаты[КолонкаЗачета] - СуммаЗачета;
									
									СтрокаПоДоговору.СуммаВзаиморасчетов = СтрокаПоДоговору.СуммаВзаиморасчетов - СуммаЗачета;
								КонецЦикла;
							КонецЦикла;
						Иначе
							Для каждого СтрокаОплаты Из НераспределенныеОплаты Цикл
								Если СтрокаОплаты[КолонкаЗачета]=0 Тогда Продолжить; КонецЕсли;
								
								СуммаЗачета = Макс(0,мин(СтрокаОплаты[КолонкаЗачета], СтрокаРасчетов[КолонкаЗачета]));
								Если СуммаЗачета = 0 Тогда Продолжить; КонецЕсли; 
								
								СтрокаРаспределения = ТаблицаРезультатов.Добавить();
								СтрокаРаспределения.Поставщик			= СтрокаРасчетов.Поставщик;
								СтрокаРаспределения.ДоговорКонтрагента	= СтрокаРасчетов.ДоговорКонтрагента;
								СтрокаРаспределения.ТипДоговораКонтрагента	= СтрокаРасчетов.ТипДоговораКонтрагента;
								СтрокаРаспределения.СчетФактура			= СтрокаРасчетов.Документ;
								СтрокаРаспределения.ЗачетАванса			= Истина;
								СтрокаРаспределения.ДатаОплаты			= СтрокаОплаты.ДатаДокумента;
								СтрокаРаспределения.ДокументОплаты		= СтрокаОплаты.Документ;
								СтрокаРаспределения[КолонкаЗачета] 		= СуммаЗачета;
								СтрокаРасчетов[КолонкаЗачета]			= СтрокаРасчетов[КолонкаЗачета] - СуммаЗачета;
								СтрокаОплаты[КолонкаЗачета]				= СтрокаОплаты[КолонкаЗачета] - СуммаЗачета;
							КонецЦикла; 
						КонецЕсли;
					КонецЕсли; 
					
					Если не СтрокаРасчетов[КолонкаЗачета] = 0 Тогда
						НераспределеннаяСтрока = НепогашеннаяЗадолженность.Добавить();
						НераспределеннаяСтрока.ДатаДокумента = СтрокаРасчетов.ДатаДокумента;
						НераспределеннаяСтрока.Документ		 = СтрокаРасчетов.Документ;
						НераспределеннаяСтрока.Сумма		 = СтрокаРасчетов.Сумма;
					КонецЕсли; 
				КонецЕсли; 
			КонецЦикла; 
		КонецЦикла;
	КонецЦикла;
	
	Объект.Состав.Загрузить(ТаблицаРезультатов);	
КонецПроцедуры

&НаСервере
Функция ПолучитьИнформациюПоНепогашеннойЗадолженностиИНераспределеннымОплатам()
	ПриСовпаденииДатыИДатыОплатыИспользоватьВремяДокумента=(УчетнаяПолитика.ОпределениеВремениПроведенияПлатежногоДокумента = перечисления.СпособыОпределенияВремениПроведенияПлатежногоДокумента.ПоВремениРегистрацииДокумента);

    Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("КонецПериода", Новый Граница(КонецДня(Объект.Дата), ВидГраницы.Включая));
	Запрос.УстановитьПараметр("Организация",  Объект.Организация);
	Запрос.УстановитьПараметр("ИспользоватьВремяДокумента",  ПриСовпаденииДатыИДатыОплатыИспользоватьВремяДокумента);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.Поставщик КАК Поставщик,
	|	ИсточникДанных.ДоговорКонтрагента КАК ДоговорКонтрагента,
	|	ИсточникДанных.ТипДоговораКонтрагента Как ТипДоговораКонтрагента,
	|	ИсточникДанных.Документ КАК Документ,
	|	ИсточникДанных.Документ.Дата КАК ДатаДокумента,
	|	СУММА(ИсточникДанных.СуммаОстаток) КАК Сумма,
	|	СУММА(0) КАК ОплатаСумма,
	|	ЛОЖЬ КАК ЭтоОплата,
	|	ИсточникДанных.ДоговорКонтрагента.ВалютаВзаиморасчетов КАК ВалютаВзаиморасчетов
	|ИЗ
	|	РегистрНакопления.НДСРасчетыСПоставщиками.Остатки(&КонецПериода, Организация = &Организация И РасчетыСБюджетом = ЛОЖЬ) КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.СуммаОстаток > 0
	|
	|СГРУППИРОВАТЬ ПО
	|	ИсточникДанных.ДоговорКонтрагента,
	|	ИсточникДанных.ТипДоговораКонтрагента,
	|	ИсточникДанных.Документ,
	|	ИсточникДанных.Поставщик,
	|	ИсточникДанных.Документ.Дата,
	|	ИсточникДанных.ДоговорКонтрагента.ВалютаВзаиморасчетов
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ИсточникДанных.Поставщик,
	|	ИсточникДанных.ДоговорКонтрагента,
	|	ИсточникДанных.ТипДоговораКонтрагента,
	|	ИсточникДанных.Документ,
	|	ВЫБОР
	|		КОГДА ИсточникДанных.Документ.ДатаОплаты ЕСТЬ NULL 
	|			ТОГДА ИсточникДанных.Документ.Дата
	|		ИНАЧЕ ВЫБОР
	|				КОГДА НАЧАЛОПЕРИОДА(ИсточникДанных.Документ.ДатаОплаты, ДЕНЬ) = НАЧАЛОПЕРИОДА(ИсточникДанных.Документ.Дата, ДЕНЬ)
	|						И &ИспользоватьВремяДокумента
	|					ТОГДА ИсточникДанных.Документ.Дата
	|				ИНАЧЕ КОНЕЦПЕРИОДА(ИсточникДанных.Документ.ДатаОплаты, ДЕНЬ)
	|			КОНЕЦ
	|	КОНЕЦ,
	|	СУММА(0),
	|	СУММА(-1 * ИсточникДанных.СуммаОстаток),
	|	ИСТИНА,
	|	ИсточникДанных.ДоговорКонтрагента.ВалютаВзаиморасчетов
	|ИЗ
	|	РегистрНакопления.НДСРасчетыСПоставщиками.Остатки(&КонецПериода, Организация = &Организация И РасчетыСБюджетом = ЛОЖЬ) КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.СуммаОстаток < 0
	|
	|СГРУППИРОВАТЬ ПО
	|	ИсточникДанных.Поставщик,
	|	ИсточникДанных.Документ,
	|	ИсточникДанных.ДоговорКонтрагента,
	|	ИсточникДанных.ТипДоговораКонтрагента,
	|	ВЫБОР
	|		КОГДА ИСточникДанных.Документ.ДатаОплаты ЕСТЬ NULL 
	|			ТОГДА ИСточникДанных.Документ.Дата
	|		ИНАЧЕ ВЫБОР
	|				КОГДА НАЧАЛОПЕРИОДА(ИСточникДанных.Документ.ДатаОплаты, ДЕНЬ) = НАЧАЛОПЕРИОДА(ИСточникДанных.Документ.Дата, ДЕНЬ) И &ИспользоватьВремяДокумента
	|					ТОГДА ИСточникДанных.Документ.Дата
	|				ИНАЧЕ КОНЕЦПЕРИОДА(ИСточникДанных.Документ.ДатаОплаты, ДЕНЬ)
	|			КОНЕЦ
	|	КОНЕЦ,
	|	ИСточникДанных.ДоговорКонтрагента.ВалютаВзаиморасчетов
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаДокумента,
	|	Документ
	|ИТОГИ
	|	СУММА(Сумма),
	|	СУММА(ОплатаСумма)
	|ПО
	|	ТипДоговораКонтрагента,ДоговорКонтрагента
	|";

	Возврат Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Вложения"

&НаКлиенте
Процедура тпВложение_ВыполнитьДействие(Команда)
	Если Команда.Имя="ВложенияПредпросмотр" Тогда
		Элементы.ВложенияПредпросмотр.Пометка=НЕ Элементы.ВложенияПредпросмотр.Пометка;
		Элементы.ВложенияГруппаПросмотр.Видимость=Элементы.ВложенияПредпросмотр.Пометка;
		Если Элементы.ВложенияПредпросмотр.Пометка Тогда
			тпВложения_ОбработчикОжидания();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры	 

&НаКлиенте
Процедура тпВложения_ПриАктивизацииСтроки(Элемент)
	Если Элементы.тпВложения.ТекущиеДанные=Неопределено Тогда Возврат; КонецЕсли;
	Если НЕ Элементы.ВложенияПредпросмотр.Пометка Тогда Возврат; КонецЕсли;
	
	тпВложения_ОбработчикОжидания();
КонецПроцедуры

&НаКлиенте
Процедура тпВложения_ПредпросмотПоказать(СтруктураДанных)
	Модуль=ОбщегоНазначенияКлиент.ОбщийМодуль("ВложенияКлиент");
	Модуль.ПредпросмотрПоказать(ЭтаФорма, СтруктураДанных);
КонецПроцедуры

&НаСервере
Процедура тпВложения_ПредпросмотСоздать(СтруктураДанных)
	Модуль=ОбщегоНазначенияСервер.ОбщийМодуль("ВложенияСервер");
	Модуль.ПредпросмотрСоздать(ЭтаФорма, СтруктураДанных);
КонецПроцедуры

&НаКлиенте
Процедура тпВложения_ОбработчикОжидания()
	Если Элементы.тпВложения.ТекущиеДанные=Неопределено Тогда Возврат; КонецЕсли;

	СтруктураДанных=Новый Структура("ИмяФайла,Каталог,ТипID,ID,ВариантХранения,ИндексПиктограммы");
	ЗаполнитьЗначенияСвойств(СтруктураДанных, Элементы.тпВложения.ТекущиеДанные);
	СтруктураДанных.Вставить("Ссылка", Объект.Ссылка);
	СтруктураДанных.Вставить("ИмяРеквизита", ОбщегоНазначенияКлиент.ОбщийМодуль("ВложенияОбщий").ИмяРеквизитаПоИндексуПиктограммы(СтруктураДанных.ИндексПиктограммы));

	Если Элементы.Найти("ВложениеПросмотр"+СтруктураДанных.ИмяРеквизита)=Неопределено Тогда	
		тпВложения_ПредпросмотСоздать(СтруктураДанных);
	КонецЕсли;

	тпВложения_ПредпросмотПоказать(СтруктураДанных);
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Обработчики оповещения

&НаКлиенте
Процедура ОбработчикОповещения_ЗаполнитьСостав(Параметр1, Параметр2=Неопределено) Экспорт
	Если НЕ Параметр1=КодВозвратаДиалога.Да Тогда Возврат; КонецЕсли;
	Объект.Состав.Очистить();
	ЗаполнитьСтрокиРаспределенияОплат();
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Стандартные (универсальные) процедуры\функции

&НаСервере
Процедура ВыполнитьСортировкуТабличнойЧасти(ИмяТабличнойЧасти, стрСортировка) Экспорт
	СортировкаТабличнойЧастиСервер.Сортировать(ИмяТабличнойЧасти, стрСортировка, Объект);
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Обработчики событий атрибутов

&НаКлиенте
Процедура Атрибут_НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СобытияЭлементовФормыКлиент.НачалоВыбора(ЭтаФорма, Элемент, ДанныеВыбора, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура Атрибут_Нажатие(Элемент, СтандартнаяОбработка)
	СобытияЭлементовФормыКлиент.Нажатие(ЭтаФорма, Элемент, СтандартнаяОбработка);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля УНИВЕРСАЛЬНЫЕ

&НаКлиенте
Процедура кпТабличноеПоле_ВыполнитьДействие(Команда)
	стрКоманда=Команда.Имя;
	Если стрКоманда="Сортировать" Тогда
		стрТабличнаяЧасть=стрЗаменить(ЭтаФорма.Элементы.ТабличныеЧасти.ТекущаяСтраница.Имя, "Страница", "");
		СортировкаТабличнойЧастиКлиент.Открыть(стрТабличнаяЧасть, ЭтаФорма, Объект);
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Состав"

&НаКлиенте
Процедура кпСостав_ВыполнитьДействие(Команда)
	стрТабличнаяЧасть="Состав"; стрКоманда=стрЗаменить(Команда.Имя, "кп"+стрТабличнаяЧасть+"_", "");
		
	Если стрКоманда="Заполнить" Тогда
		Если Объект.Проведен Тогда
			ПоказатьПредупреждение(,"Заполнение возможно только в непроведенном документе", 60,);
			Отказ=Истина; Возврат;
		КонецЕсли;
		Если Объект.Состав.Количество() > 0 Тогда
			ПоказатьВопрос(Новый ОписаниеОповещения("ОбработчикОповещения_ЗаполнитьСостав", ЭтотОбъект), "Табличное поле будет очищено. Продолжить?", РежимДиалогаВопрос.ДаНет, 60, КодВозвратаДиалога.Нет);
		Иначе
			ЗаполнитьСтрокиРаспределенияОплат();
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура тпСостав_ПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	Если НоваяСтрока Тогда
		Элемент.ТекущиеДанные.ID=Строка(Новый УникальныйИдентификатор);
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий дополнительных реквизитов табличных частей

&НаКлиенте
Процедура тзРеквизитыТЧ_ПриИзменении_Клиент(Элемент)
	тзРеквизитыТЧ_ПриИзменении_Сервер(Элемент.Имя);
КонецПроцедуры

&НаСервере
Процедура тзРеквизитыТЧ_ПриИзменении_Сервер(стрИмя)
	МетаконфигураторСервер.ДопРеквизиты_ПриИзменении(стрИмя, ЭтаФорма);	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	СобытияФормыСервер.ПриСозданииНаСервере(Отказ, СтандартнаяОбработка, ЭтаФорма, Объект);	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ОбновитьРеквизитыФормы("УчетнаяПолитика");
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