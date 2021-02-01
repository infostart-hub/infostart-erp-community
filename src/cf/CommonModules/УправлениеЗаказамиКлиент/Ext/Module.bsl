﻿Процедура ВыполнитьДействие(СтруктураПараметров, Владелец, стрКоманда="Заполнить") Экспорт
	Если стрКоманда="Заполнить" Тогда
		Если НЕ СтруктураПараметров.Объект.Сделки.Количество()=0 Тогда
			ОписаниеОповещения=Новый ОписаниеОповещения("ОбработчикОповещения_Заполнить_Начало", ЭтотОбъект, Новый Структура("Команда, Параметры", стрКоманда, СтруктураПараметров));
			ПоказатьВопрос(ОписаниеОповещения, "Очистить табличную часть перед заполнением?", РежимДиалогаВопрос.ДаНетОтмена, 20, КодВозвратаДиалога.Отмена, "Внимание", КодВозвратаДиалога.Отмена);
		Иначе
			Заполнить(СтруктураПараметров, стрКоманда);
		КонецЕсли;

	ИначеЕсли стрКоманда="Изменить" Тогда
		ОписаниеОповещения=Новый ОписаниеОповещения("ОбработчикОповещения_Заполнить_Завершение", ЭтотОбъект, Новый Структура("Команда, Параметры", стрКоманда, СтруктураПараметров));
		ОткрытьФорму("ОбщаяФорма.ПодборЗаказов", СтруктураПараметров, Владелец,,,,ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	КонецЕсли; 
КонецПроцедуры

Процедура Заполнить(СтруктураПараметров, стрКоманда)
	Если стрКоманда="Заполнить" Тогда
		Если СтруктураПараметров.Свойство("Сделки") Тогда
			СтруктураПараметров.Удалить("Сделки");
		КонецЕсли;
		Если НЕ СтруктураПараметров.Объект.Сделки.Количество()=0 Тогда
		    МассивСделки=Новый Массив;
			Для каждого СтрокаКоллекции Из СтруктураПараметров.Объект.Сделки Цикл
				МассивСделки.Добавить(СтрокаКоллекции.Сделка);
			КонецЦикла;
			СтруктураПараметров.Вставить("Сделки", МассивСделки);
		КонецЕсли;		
		ОписаниеОповещения=Новый ОписаниеОповещения("ОбработчикОповещения_Заполнить_Завершение", ЭтотОбъект, Новый Структура("Команда, Параметры", стрКоманда, СтруктураПараметров));
		ОткрытьФорму("ОбщаяФорма.ПодборЗаказов", СтруктураПараметров,,,,,ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	КонецЕсли;
КонецПроцедуры

Процедура ОбработчикОповещения_Заполнить_Начало(Параметр1, Параметр2) Экспорт
	Если Параметр1=КодВозвратаДиалога.Отмена Тогда Возврат; КонецЕсли; 

	Если Параметр1=КодВозвратаДиалога.Да Тогда
		Параметр2.Параметры.Объект.Сделки.Очистить();
	КонецЕсли;

	Заполнить(Параметр2.Параметры, Параметр2.Команда);
КонецПроцедуры

Процедура ОбработчикОповещения_Заполнить_Завершение(Параметр1, Параметр2) Экспорт
	Если Параметр2.Команда="Заполнить" Тогда
		Если ТипЗнч(Параметр1)=Тип("Массив") Тогда
			Для каждого Сделка Из Параметр1 Цикл
				НоваяСтрока=Параметр2.Параметры.Объект.Сделки.Добавить();	
				НоваяСтрока.Сделка=Сделка;
			КонецЦикла;
		КонецЕсли;
	//ИначеЕсли Параметр2.Команда="Изменить" Тогда
	КонецЕсли;
КонецПроцедуры
