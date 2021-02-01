﻿////////////////////////////////////////////////////////////////////////////////
//Управление печатными формами

Процедура СтруктураПечатныхФорм(Структура) Экспорт
	Структура.Вставить("ИнкассовоеПоручение", "Инкассовое поручение");
КонецПроцедуры

Функция ИнициализацияМакета(СтруктураПараметров, стрМакет)
	Если СтруктураПараметров.Свойство("Макет") Тогда
		Возврат СтруктураПараметров.Макет;
	КонецЕсли;
	Макет=СтруктураПараметров.МакетШаблон;
	Если Макет=Неопределено Тогда
		Если Метаданные.ОбщиеМакеты.Найти(стрМакет)=Неопределено Тогда
			Макет=ПолучитьМакет(стрМакет);
		Иначе
			Макет=ПолучитьОбщийМакет(стрМакет);
		КонецЕсли;
	КонецЕсли;
	Возврат Макет;
КонецФункции

Функция ФорматироватьСуммуПрописи(СчетОрганизации, СуммаДок, СуммаБезКопеек)
	
	Результат     = СуммаДок;
	ЦелаяЧасть    = Цел(СуммаДок);
	ФорматСтрока  = "Л=ru_RU; ДП=Ложь";
	ПарамПредмета = СчетОрганизации.ВалютаДенежныхСредств.ПараметрыПрописиНаРусском;
	
	Если (Результат - ЦелаяЧасть) = 0 Тогда
		Если СуммаБезКопеек Тогда
			Результат = ЧислоПрописью(Результат,ФорматСтрока,ПарамПредмета);
			Результат = Лев(Результат,Найти(Результат,"0")-1);
		Иначе
			Результат = ЧислоПрописью(Результат,ФорматСтрока,ПарамПредмета);
		КонецЕсли;
	Иначе
		Результат = ЧислоПрописью(Результат,ФорматСтрока,ПарамПредмета);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ФорматироватьСумму(СуммаДок, СуммаБезКопеек)
	
	Результат  = СуммаДок;
	ЦелаяЧасть = Цел(СуммаДок);
	
	Если (Результат - ЦелаяЧасть) = 0 Тогда
		Если СуммаБезКопеек Тогда
			Результат = Формат(Результат,"ЧДЦ=2; ЧРД='='; ЧГ=0");
			Результат = Лев(Результат,Найти(Результат,"="));
		Иначе
			Результат = Формат(Результат,"ЧДЦ=2; ЧРД='-'; ЧГ=0");
		КонецЕсли;
	Иначе
		Результат = Формат(Результат,"ЧДЦ=2; ЧРД='-'; ЧГ=0");
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ВернутьРасчетныйСчет(СчетКонтрагента)
	БанкДляРасчетов = СчетКонтрагента.БанкДляРасчетов;
	Возврат ?(БанкДляРасчетов.Пустая(), СчетКонтрагента.НомерСчета, СчетКонтрагента.Банк.КоррСчет);
КонецФункции

Функция ПолучитьРеквизитыШапки(СсылкаНаОбъект, стрРеквизиты="")
	Если НЕ ПустаяСтрока(стрРеквизиты) Тогда стрРеквизиты=","+стрРеквизиты; КонецЕсли; 
	Для каждого мдРеквизит Из СсылкаНаОбъект.Метаданные().Реквизиты Цикл
		стрРеквизиты=стрРеквизиты+","+Символы.ПС+мдРеквизит.Имя;
	КонецЦикла;	

	Запрос=Новый ПостроительЗапроса;
	Запрос.Параметры.Вставить("ТекущийДокумент", СсылкаНаОбъект);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	Дата,
	|	Номер,
	|	Проведен,
	|	Контрагент,
	|	Организация
	|	"+стрРеквизиты+"
	|ИЗ
	|	Документ.ПлатежныйОрдерПоступлениеДенежныхСредств КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.Ссылка = &ТекущийДокумент
	|";
	
	#Если НаСервере Тогда
	Запрос.Выполнить();
	#КонецЕсли
	РеквизитыШапки=Запрос.Результат.Выбрать();
	РеквизитыШапки.Следующий();

	Возврат РеквизитыШапки;
КонецФункции 	

Функция Печать_ИнкассовогоПоручения(СтруктураПараметров)
    РеквизитыШапки=ПолучитьРеквизитыШапки(СтруктураПараметров.СсылкаНаОбъект);
	
	Если РеквизитыШапки.Организация.Пустая() Тогда
		Сообщить("Не указана организация.", СтатусСообщения.Важное);
		Возврат Неопределено;
	КонецЕсли;

	Если РеквизитыШапки.Контрагент.Пустая() Тогда
		Сообщить("Не указан контрагент.", СтатусСообщения.Важное);
		Возврат Неопределено;
	КонецЕсли;
	
	НомерПечать=ОбщегоНазначенияСервер.НомерНаПечать(СтруктураПараметров.СсылкаНаОбъект);
	
	Если Прав(НомерПечать,3)="000" Тогда
		Сообщить("Номер инкассового поручения не может оканчиваться на ""000""!", СтатусСообщения.Важное);
		Возврат Неопределено;
	КонецЕсли;

	ТабДокумент=Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ПлатежныйОрдерПоступлениеДенежныхСредств_ИнкассовоеПоручение";
	
	Макет=ИнициализацияМакета(СтруктураПараметров, "ИнкассовоеПоручение");
	Обл=Макет.ПолучитьОбласть("ЗаголовокТаблицы");

	Контрагент=РеквизитыШапки.Контрагент;
	Организация=РеквизитыШапки.Организация;
	СчетОрганизации=РеквизитыШапки.СчетОрганизации;
	СчетКонтрагента=РеквизитыШапки.СчетКонтрагента;

	МесяцПрописью   = СчетОрганизации.МесяцПрописью;
	СуммаБезКопеек  = СчетОрганизации.СуммаБезКопеек;
	ФорматДаты      = "ДФ=" + ?(МесяцПрописью = 1,"'дд ММММ гггг'","'дд.ММ.гггг'");
	БанкОрганизации = ?(НЕ ЗначениеЗаполнено(СчетОрганизации.БанкДляРасчетов), СчетОрганизации.Банк, СчетОрганизации.БанкДляРасчетов);
	БанкКонтрагента = ?(НЕ ЗначениеЗаполнено(СчетКонтрагента.БанкДляРасчетов), СчетКонтрагента.Банк, СчетКонтрагента.БанкДляРасчетов);

	Обл.Параметры.НаименованиеНомер       = "ИНКАССОВОЕ ПОРУЧЕНИЕ № " + НомерПечать;
	Обл.Параметры.ДатаДокумента           = Формат(РеквизитыШапки.Дата, ФорматДаты);
	Обл.Параметры.ВидПлатежа              = "Электронно";
	Обл.Параметры.СуммаЧислом             = ФорматироватьСумму(РеквизитыШапки.СуммаДокумента,СуммаБезКопеек);
	Обл.Параметры.СуммаПрописью           = ФорматироватьСуммуПрописи(СчетОрганизации, РеквизитыШапки.СуммаДокумента,СуммаБезКопеек);

	Обл.Параметры.ПлательщикИНН           = "ИНН " + Контрагент.ИНН;
	Обл.Параметры.ПлательщикКПП           = "КПП " + Контрагент.КПП;

	Обл.Параметры.Плательщик              = Контрагент.НаименованиеПолное;
	Обл.Параметры.БанкПлательщика         = "" + БанкКонтрагента + " " + БанкКонтрагента.Город;

	Обл.Параметры.НомерСчетаПлательщика   = ВернутьРасчетныйСчет(СчетКонтрагента);

	Обл.Параметры.БикБанкаПлательщика     = БанкКонтрагента.Код;
	Обл.Параметры.СчетБанкаПлательщика    = БанкКонтрагента.КоррСчет;

	Обл.Параметры.ПолучательИНН           = "ИНН " + Организация.ИНН;
	Обл.Параметры.ПолучательКПП           = "КПП " + Организация.КПП;
	Обл.Параметры.Получатель              = Организация.НаименованиеПолное;

	Обл.Параметры.БанкПолучателя          = "" + БанкОрганизации + " " + БанкОрганизации.Город;
	Обл.Параметры.БикБанкаПолучателя      = БанкОрганизации.Код;
	Обл.Параметры.СчетБанкаПолучателя     = БанкОрганизации.КоррСчет;

    Обл.Параметры.НомерСчетаПолучателя    = ВернутьРасчетныйСчет(СчетОрганизации);

	Обл.Параметры.НазначениеПлатежа       = СокрЛП(РеквизитыШапки.НазначениеПлатежа);
	Обл.Параметры.Очередность             = "6";

	ТабДокумент.Вывести(Обл);

	Возврат ТабДокумент;
КонецФункции

Функция Печать(СтруктураПараметров, КоличествоЭкземпляров=1, НаПринтер=Ложь) Экспорт
    ТабДокумент=Неопределено;
	ИмяМакета=СтруктураПараметров.ИмяМакета;
	СсылкаНаОбъект=СтруктураПараметров.СсылкаНаОбъект;

	Если ИмяМакета="ИнкассовоеПоручение" Тогда
		ТабДокумент=Печать_ИнкассовогоПоручения(СтруктураПараметров);
	КонецЕсли;

	Возврат ТабДокумент;
КонецФункции
