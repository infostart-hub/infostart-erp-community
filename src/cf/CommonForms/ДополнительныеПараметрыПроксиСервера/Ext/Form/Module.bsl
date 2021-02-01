﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("АвтоТест") Тогда Возврат; КонецЕсли;
	
	// Заполнение данных формы
	Сервер      = Параметры.Сервер;
	Порт        = Параметры.Порт;
	
	СерверHTTP  = Параметры.СерверHTTP;
	ПортHTTP    = Параметры.ПортHTTP;
	
	СерверHTTPS = Параметры.СерверHTTPS;
	ПортHTTPS   = Параметры.ПортHTTPS;
	
	СерверFTP   = Параметры.СерверFTP;
	ПортFTP     = Параметры.ПортFTP;
	
	ОдинПроксиДляВсехПротоколов = Параметры.ОдинПроксиДляВсехПротоколов;
	
	ИнициализироватьЭлементыФормы(ЭтотОбъект);
	
	Для каждого ЭлементСпискаИсключений Из Параметры.НеИспользоватьПроксиДляАдресов Цикл
		СтрИсключения = АдресаИсключений.Добавить();
		СтрИсключения.АдресСервера = ЭлементСпискаИсключений.Значение;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОдинПроксиДляВсехПротоколовПриИзменении(Элемент)
	
	ИнициализироватьЭлементыФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура СерверHTTPПриИзменении(Элемент)
	
	// Если сервер не указан, то обнулить соответствующий порт.
	Если ПустаяСтрока(ЭтотОбъект[Элемент.Имя]) Тогда
		ЭтотОбъект[СтрЗаменить(Элемент.Имя, "Сервер", "Порт")] = 0;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КнопкаОК(Команда)
	
	Если Не Модифицированность Тогда
		// Если данные формы не были изменены,
		// то их не требуется возвращать.
		ОповеститьОВыборе(Неопределено);
		Возврат;
	КонецЕсли;
	
	Если Не ПроверитьАдресаСерверовИсключений() Тогда
		Возврат;
	КонецЕсли;
	
	// Если проверка данных формы выполнена успешно, то возвратить дополнительные
	// настройки прокси-сервера в структуре.
	СтруктураВозвращаемыхЗначений = Новый Структура;
	
	СтруктураВозвращаемыхЗначений.Вставить("ОдинПроксиДляВсехПротоколов", ОдинПроксиДляВсехПротоколов);
	
	СтруктураВозвращаемыхЗначений.Вставить("СерверHTTP" , СерверHTTP);
	СтруктураВозвращаемыхЗначений.Вставить("ПортHTTP"   , ПортHTTP);
	СтруктураВозвращаемыхЗначений.Вставить("СерверHTTPS", СерверHTTPS);
	СтруктураВозвращаемыхЗначений.Вставить("ПортHTTPS"  , ПортHTTPS);
	СтруктураВозвращаемыхЗначений.Вставить("СерверFTP"  , СерверFTP);
	СтруктураВозвращаемыхЗначений.Вставить("ПортFTP"    , ПортFTP);
	
	СписокИсключений = Новый СписокЗначений;
	
	Для каждого СтрАдреса Из АдресаИсключений Цикл
		Если НЕ ПустаяСтрока(СтрАдреса.АдресСервера) Тогда
			СписокИсключений.Добавить(СтрАдреса.АдресСервера);
		КонецЕсли;
	КонецЦикла;
	
	СтруктураВозвращаемыхЗначений.Вставить("НеИспользоватьПроксиДляАдресов", СписокИсключений);
	
	ОповеститьОВыборе(СтруктураВозвращаемыхЗначений);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Выполняет инициализацию элементов формы в зависимости от
// настроек прокси-сервера.
//
&НаКлиентеНаСервереБезКонтекста
Процедура ИнициализироватьЭлементыФормы(Форма)
	
	Форма.Элементы.ГруппаПроксиСерверы.Доступность = НЕ Форма.ОдинПроксиДляВсехПротоколов;
	Если Форма.ОдинПроксиДляВсехПротоколов Тогда
		
		Форма.СерверHTTP  = Форма.Сервер;
		Форма.ПортHTTP    = Форма.Порт;
		
		Форма.СерверHTTPS = Форма.Сервер;
		Форма.ПортHTTPS   = Форма.Порт;
		
		Форма.СерверFTP   = Форма.Сервер;
		Форма.ПортFTP     = Форма.Порт;
		
	КонецЕсли;
	
КонецПроцедуры

// Выполняет проверку корректности адресов серверов-исключений.
// Также сообщает пользователю о некорректно заполненных адресах.
//
// Возвращаемое значение: Булево - Истина, если адреса корректны,
//						  Ложь в противном случае.
//
&НаКлиенте
Функция ПроверитьАдресаСерверовИсключений()
	
	АдресаКорректны = Истина;
	Для каждого СтрАдрес Из АдресаИсключений Цикл
		Если НЕ ПустаяСтрока(СтрАдрес.АдресСервера) Тогда
			НедопустимыеСимволы = НедопустимыеСимволыВСтроке(СтрАдрес.АдресСервера,
				"0123456789aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ_-.:*?");
			
			Если НЕ ПустаяСтрока(НедопустимыеСимволы) Тогда
				
				ТекстСообщения = СтрЗаменить(НСтр("ru = 'В адресе найдены недопустимые символы: %1'"),
					"%1",
					НедопустимыеСимволы);
				
				ИндексСтрокой = СтрЗаменить(Строка(АдресаИсключений.Индекс(СтрАдрес)), Символ(160), "");
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,
					,
					"АдресаИсключений[" + ИндексСтрокой + "].АдресСервера");
				АдресаКорректны = Ложь;
				
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Возврат АдресаКорректны;
	
КонецФункции

// Находит и возвращает недопустимые символы в строке, перечисленные через запятую.
//
// Параметры:
//	ПроверяемаяСтрока (Строка) - строка, проверяемая на предмет наличия недопустимых
//								 символов.
//	ДопустимыеСимволы (Строка) - строка допустимых символов.
//
// Возвращаемое значение: Строка - строка недопустимых символов. Пустая строка, если
//						  в проверяемой строке недопустимые символы не обнаружены.
//
&НаКлиенте
Функция НедопустимыеСимволыВСтроке(ПроверяемаяСтрока, ДопустимыеСимволы)
	
	СписокНедопустимыхСимволов = Новый СписокЗначений;
	
	ДлинаСтроки = СтрДлина(ПроверяемаяСтрока);
	Для Итератор = 1 По ДлинаСтроки Цикл
		ТекущийСимвол = Сред(ПроверяемаяСтрока, Итератор, 1);
		Если СтрНайти(ДопустимыеСимволы, ТекущийСимвол) = 0 Тогда
			Если СписокНедопустимыхСимволов.НайтиПоЗначению(ТекущийСимвол) = Неопределено Тогда
				СписокНедопустимыхСимволов.Добавить(ТекущийСимвол);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	НедопустимыеСимволыСтрокой = "";
	Запятая                    = Ложь;
	
	Для каждого ЭлементНедопустимыйСимвол Из СписокНедопустимыхСимволов Цикл
		
		НедопустимыеСимволыСтрокой = НедопустимыеСимволыСтрокой
			+ ?(Запятая, ",", "")
			+ """"
			+ ЭлементНедопустимыйСимвол.Значение
			+ """";
		Запятая = Истина;
		
	КонецЦикла;
	
	Возврат НедопустимыеСимволыСтрокой;
	
КонецФункции

#КонецОбласти
