﻿Процедура ПередЗаписью(Отказ)

	Если НЕ ОбменДанными.Загрузка
	   И НЕ Владелец.ВестиУчетПоХарактеристикам Тогда
		ОбщегоНазначения.СообщитьОбОшибке(
		"Для номенклатуры """ + Владелец + """ не ведется учет по характеристикам.
		|Характеристика """ + Наименование + """ не может быть записана.", 
		Отказ);

	КонецЕсли;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТИРУЕМЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// Функция устанавливает новое наименование характеристики по значениям свойств.
//
// Параметры:
//  КоллекцияЗначенийСвойств - коллекция значений, имеющая свойство Значение.
//
// Возвращаемое значение:
//  Строка - сформированное наименование.
//
Функция СформироватьНаименование(КоллекцияЗначенийСвойств) Экспорт

	Строка = "";

	Для каждого ЭлементКоллекции Из КоллекцияЗначенийСвойств Цикл
		
		Если ЗначениеЗаполнено(ЭлементКоллекции.Значение) Тогда
			
			Если ТипЗнч(ЭлементКоллекции.Значение) = Тип("Дата") Тогда
				
				Если ЭлементКоллекции.Свойство.ТипЗначения.КвалификаторыДаты.ЧастиДаты = ЧастиДаты.Дата Тогда
					Строка = Строка + Формат(ЭлементКоллекции.Значение, "ДФ=dd.MM.yyyy") + ", ";
				ИначеЕсли ЭлементКоллекции.Свойство.ТипЗначения.КвалификаторыДаты.ЧастиДаты = ЧастиДаты.Время Тогда
					Строка = Строка + Формат(ЭлементКоллекции.Значение, "ДФ=ЧЧ:мм:сс") + ", ";
				Иначе
					Строка = Строка + ЭлементКоллекции.Значение + ", ";
				КонецЕсли;
				
			Иначе
				
				Строка = Строка + ЭлементКоллекции.Значение + ", ";
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;

	Строка = Лев(Строка, СтрДлина(Строка) - 2);

	Если ПустаяСтрока(Строка) Тогда
		Строка = "<Свойства не назначены>";
	КонецЕсли;

	Возврат Строка;

КонецФункции

