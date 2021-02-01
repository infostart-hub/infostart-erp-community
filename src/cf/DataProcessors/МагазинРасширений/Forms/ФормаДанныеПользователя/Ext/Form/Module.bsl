﻿////////////////////////////////////////////////////////////////////////////////
// Общие назначения

&НаСервере
Функция ДанныеУпаковать(Данные)
	СтрокаBase64=СериализаторXDTO.XMLСтрока(Новый ХранилищеЗначения(Данные, Новый СжатиеДанных(9)));
	Возврат Base64Значение(СтрокаBase64); //Возвращаем сжатые двоичные данные
КонецФункции

&НаСервере
Функция ДанныеРаспаковать(Данные)
	СтрокаBase64=Base64Строка(Данные);
    Возврат СериализаторXDTO.XMLЗначение(Тип("ХранилищеЗначения"), СтрокаBase64).Получить();
КонецФункции

&НаКлиенте
Функция СоединениеHTTP()
	Возврат Новый HTTPСоединение("84.201.247.51", 8181, "Пользователь", "1",,600); //Новый ЗащищенноеСоединениеOpenSSL
КонецФункции

&НаСервере
Процедура УстановитьДанныеПользователя(ДанныеПользователя)
	Если ДанныеПользователя.Свойство("ФИО") Тогда
		ФИО=ДанныеПользователя.ФИО;
	КонецЕсли;
	Если ДанныеПользователя.Свойство("Информация") Тогда
		Информация=ДанныеПользователя.Информация.Получить();
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ПрочитатьДанныеПользователя()
	Запрос=Новый HTTPЗапрос("HTTP/hs/ExtStore/ПрочитатьДанныеПользователя?Логин="+СокрЛП(Логин)+"&Пароль="+СокрЛП(Пароль)+"&ЛогинПользователя="+СокрЛП(Пользователь));

	Ответ=СоединениеHTTP().ВызватьHTTPМетод("GET", Запрос);
	Если НЕ Ответ.КодСостояния=200 Тогда
		Сообщить("Чтение данных пользователя, ошибка: "+Ответ.КодСостояния);
		Возврат; 
	КонецЕсли;

	ДанныеПользователя=ДанныеРаспаковать(Ответ.ПолучитьТелоКакДвоичныеДанные());
	Если НЕ ТипЗнч(ДанныеПользователя)=Тип("Структура") Тогда
		Сообщить("Чтение данных пользователя, ошибка структуры возвращаемых данных...");
		Возврат;
	КонецЕсли; 

	УстановитьДанныеПользователя(ДанныеПользователя);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)	
	ЗаполнитьЗначенияСвойств(ЭтаФорма, Параметры, "Логин,Пароль,Пользователь");
	Если ПустаяСтрока(Пользователь) Тогда Отказ=Истина; Возврат; КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПрочитатьДанныеПользователя();
КонецПроцедуры
