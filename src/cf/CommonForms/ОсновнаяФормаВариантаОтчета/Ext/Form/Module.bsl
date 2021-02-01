﻿////&НаКлиенте
////Процедура ОтборДоступен(ЭлементСтруктуры)
////	Если Отчет.КомпоновщикНастроек.Настройки.НаличиеОтбораУЭлемента(ЭлементСтруктуры) Тогда
////		ЛокальныйОтбор = Истина;
////		Элементы.СтраницыОтбора.ТекущаяСтраница = Элементы.НастройкиОтбора;
////	Иначе
////		ЛокальныйОтбор = Ложь;
////		Элементы.СтраницыОтбора.ТекущаяСтраница = Элементы.ОтключенныеНастройкиОтбора;
////	КонецЕсли;
////	Элементы.ЛокальныйОтбор.ТолькоПросмотр = Ложь;	
////КонецПроцедуры
		
////&НаКлиенте
////Процедура ОтборНедоступен()
////	
////	ЛокальныйОтбор = Ложь;
////	Элементы.ЛокальныйОтбор.ТолькоПросмотр = Истина;
////	Элементы.СтраницыОтбора.ТекущаяСтраница = Элементы.НедоступныеНастройкиОтбора;
////		
////КонецПроцедуры

&НаКлиенте
Процедура КомпоновщикНастроекНастройкиПриАктивизацииПоля(Элемент)
Перем ВыбраннаяСтраница;
	
	Если Элементы.КомпоновщикНастроекНастройки.ТекущийЭлемент.Имя = "КомпоновщикНастроекНастройкиНаличиеВыбора" Тогда
		ВыбраннаяСтраница = Элементы.СтраницаПолейВыбора;
		
	ИначеЕсли Элементы.КомпоновщикНастроекНастройки.ТекущийЭлемент.Имя = "КомпоновщикНастроекНастройкиНаличиеОтбора" Тогда
		ВыбраннаяСтраница = Элементы.СтраницаОтбора;
		
	ИначеЕсли Элементы.КомпоновщикНастроекНастройки.ТекущийЭлемент.Имя = "КомпоновщикНастроекНастройкиНаличиеПорядка" Тогда
		ВыбраннаяСтраница = Элементы.СтраницаПорядка;
		
	ИначеЕсли Элементы.КомпоновщикНастроекНастройки.ТекущийЭлемент.Имя = "КомпоновщикНастроекНастройкиНаличиеУсловногоОформления" Тогда
		ВыбраннаяСтраница = Элементы.СтраницаУсловногоОформления;
		
	ИначеЕсли Элементы.КомпоновщикНастроекНастройки.ТекущийЭлемент.Имя = "КомпоновщикНастроекНастройкиНаличиеПараметровВывода" Тогда
		ВыбраннаяСтраница = Элементы.СтраницаПараметровВывода;
		
	КонецЕсли;
	
	Если ВыбраннаяСтраница <> Неопределено Тогда
		Элементы.СтраницыНастроек.ТекущаяСтраница = ВыбраннаяСтраница;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура КомпоновщикНастроекНастройкиПриАктивизацииСтроки(Элемент)
	////
	////ЭлементСтруктуры = Отчет.КомпоновщикНастроек.Настройки.ПолучитьОбъектПоИдентификатору(Элементы.КомпоновщикНастроекНастройки.ТекущаяСтрока);
	////ТипЭлемента = ТипЗнч(ЭлементСтруктуры); 
	////
	////Если ТипЭлемента = Неопределено  ИЛИ
	////	 ТипЭлемента = Тип("КоллекцияЭлементовСтруктурыДиаграммыКомпоновкиДанных") ИЛИ
	////	 ТипЭлемента = Тип("КоллекцияЭлементовСтруктурыТаблицыКомпоновкиДанных") Тогда
	////	 
	////	ПорядокНедоступен();
	////	УсловноеОформлениеНедоступно();
	////	ПараметрыВыводаНедоступны();
	////	
	////ИначеЕсли ТипЭлемента = Тип("НастройкиКомпоновкиДанных") ИЛИ ТипЭлемента = Тип("НастройкиВложенногоОбъектаКомпоновкиДанных") Тогда
	////	ЛокальныйПорядок = Истина;
	////	Элементы.ЛокальныйПорядок.ТолькоПросмотр = Истина;
	////	Элементы.СтраницыПорядка.ТекущаяСтраница = Элементы.НастройкиПорядка;
	////	
	////	ЛокальноеУсловноеОформление = Истина;
	////	Элементы.ЛокальноеУсловноеОформление.ТолькоПросмотр = Истина;
	////	Элементы.СтраницыУсловногоОформления.ТекущаяСтраница = Элементы.НастройкиУсловногоОформления;
	////	
	////	ЛокальныеПараметрыВывода = Истина;
	////	Элементы.ЛокальныеПараметрыВывода.ТолькоПросмотр = Истина;
	////	Элементы.СтраницыПараметровВывода.ТекущаяСтраница = Элементы.НастройкиПараметровВывода;
	////	
	////ИначеЕсли ТипЭлемента = Тип("ГруппировкаКомпоновкиДанных") ИЛИ
	////	 	  ТипЭлемента = Тип("ГруппировкаТаблицыКомпоновкиДанных") ИЛИ
	////	 	  ТипЭлемента = Тип("ГруппировкаДиаграммыКомпоновкиДанных") Тогда
	////	 		
	////	ПорядокДоступен(ЭлементСтруктуры);
	////	УсловноеОформлениеДоступно(ЭлементСтруктуры);
	////	ПараметрыВыводаДоступны(ЭлементСтруктуры);
	////	
	////ИначеЕсли ТипЭлемента = Тип("ТаблицаКомпоновкиДанных") ИЛИ ТипЭлемента = Тип("ДиаграммаКомпоновкиДанных") Тогда
	////	ПорядокНедоступен();
	////	УсловноеОформлениеДоступно(ЭлементСтруктуры);
	////	ПараметрыВыводаДоступны(ЭлементСтруктуры);
	////КонецЕсли;

КонецПроцедуры

//////&НаКлиенте
//////Процедура ЛокальныеВыбранныеПоляПриИзменении(Элемент)
//////	Если ЛокальныеВыбранныеПоля Тогда
//////		Элементы.СтраницыПолейВыбора.ТекущаяСтраница = Элементы.НастройкиВыбранныхПолей;
//////	Иначе
//////		Элементы.СтраницыПолейВыбора.ТекущаяСтраница = Элементы.ОтключенныеНастройкиВыбранныхПолей;
//////		ЭлементСтруктуры = Отчет.КомпоновщикНастроек.Настройки.ПолучитьОбъектПоИдентификатору(Элементы.КомпоновщикНастроекНастройки.ТекущаяСтрока);
//////		Отчет.КомпоновщикНастроек.Настройки.ОчиститьВыборЭлемента(ЭлементСтруктуры);
//////	КонецЕсли;
//////КонецПроцедуры

////&НаКлиенте
////Процедура ЛокальныйОтборПриИзменении(Элемент)
////	Если ЛокальныйОтбор Тогда
////		Элементы.СтраницыОтбора.ТекущаяСтраница = Элементы.НастройкиОтбора;
////	Иначе
////		Элементы.СтраницыОтбора.ТекущаяСтраница = Элементы.ОтключенныеНастройкиОтбора;
////		ЭлементСтруктуры = Отчет.КомпоновщикНастроек.Настройки.ПолучитьОбъектПоИдентификатору(Элементы.КомпоновщикНастроекНастройки.ТекущаяСтрока);
////		Отчет.КомпоновщикНастроек.Настройки.ОчиститьОтборЭлемента(ЭлементСтруктуры);
////	КонецЕсли;
////КонецПроцедуры

/////////////////////////////////////////////////////////////////////////
// Обработчики таличного поля "Настройки"

&НаКлиенте
Процедура КомпоновщикНастроек_Настройки_НачалоПеретаскивания(Элемент, ПараметрыПеретаскивания, Выполнение)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура КомпоновщикНастроек_Настройки_ПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	СтандартнаяОбработка=Ложь;
	Элементы.КомпоновщикНастроекНастройки.ТекущаяСтрока=Строка;
КонецПроцедуры

&НаКлиенте
Процедура КомпоновщикНастроек_Настройки_ОкончаниеПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура КомпоновщикНастроек_Настройки_Перетаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	// Вставить содержимое обработчика.
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////
// Обработчики таличного поля "Доступные поля"

&НаКлиенте
Процедура тпДоступныеПоля_ОкончаниеПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка)
	Если Элемент.Имя="ДоступныеПоля" Тогда
		Если Элементы.КомпоновщикНастроекНастройки.ТекущаяСтрока=Неопределено Тогда Возврат; КонецЕсли;
		ЭлементСтруктуры=Отчет.КомпоновщикНастроек.Настройки.ПолучитьОбъектПоИдентификатору(Элементы.КомпоновщикНастроекНастройки.ТекущаяСтрока);
		Если ТипЗнч(ЭлементСтруктуры)=Тип("ТаблицаКомпоновкиДанных") Тогда Возврат; КонецЕсли;
		Если ТипЗнч(ЭлементСтруктуры)=Тип("ДиаграммаКомпоновкиДанных") Тогда Возврат; КонецЕсли;

		Для каждого СтрокаКоллекции Из ПараметрыПеретаскивания.Значение Цикл
			Если ТипЗнч(ЭлементСтруктуры)=Тип("НастройкиКомпоновкиДанных") Тогда
				СтруктураСсылка=Отчет.КомпоновщикНастроек.Настройки.Структура;
				ЭлементСтруктуры=СтруктураСсылка.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
				
			ИначеЕсли ТипЗнч(ЭлементСтруктуры)=Тип("ГруппировкаКомпоновкиДанных") Тогда	
				СтруктураСсылка=ЭлементСтруктуры.Структура;
				ЭлементСтруктуры=СтруктураСсылка.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
				
			ИначеЕсли ТипЗнч(ЭлементСтруктуры)=Тип("ГруппировкаТаблицыКомпоновкиДанных") Тогда	
				ЭлементСтруктуры=ЭлементСтруктуры.Структура.Добавить();
				
			ИначеЕсли ТипЗнч(ЭлементСтруктуры)=Тип("ГруппировкаДиаграммыКомпоновкиДанных") Тогда	
				ЭлементСтруктуры=ЭлементСтруктуры.Структура.Добавить();
				
			ИначеЕсли ТипЗнч(ЭлементСтруктуры)=Тип("КоллекцияЭлементовСтруктурыТаблицыКомпоновкиДанных") Тогда
				ЭлементСтруктуры=ЭлементСтруктуры.Добавить();
				
			ИначеЕсли ТипЗнч(ЭлементСтруктуры)=Тип("КоллекцияЭлементовСтруктурыДиаграммыКомпоновкиДанных") Тогда
				ЭлементСтруктуры=ЭлементСтруктуры.Добавить();
			КонецЕсли;
			
			Если Не ЭлементСтруктуры=Неопределено Тогда
				ЭлементСтруктуры.Выбор.Элементы.Добавить(Тип("АвтоВыбранноеПолеКомпоновкиДанных"));
				ЭлементСтруктуры.Порядок.Элементы.Добавить(Тип("АвтоЭлементПорядкаКомпоновкиДанных"));
				
				ПолеГруппировки=ЭлементСтруктуры.ПоляГруппировки.Элементы.Добавить(Тип("ПолеГруппировкиКомпоновкиДанных"));
				ПолеГруппировки.Использование=Истина;
				ПолеГруппировки.Поле=СтрокаКоллекции.Поле;
			КонецЕсли;
		КонецЦикла;
		
		Элементы.КомпоновщикНастроекНастройки.Развернуть(Элементы.КомпоновщикНастроекНастройки.ТекущаяСтрока);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура тпКомпоновщикНастроекНастройкиОтбор_ПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	//Элемент.ТекущиеДанные.ЛевоеЗначение
	//Отчет.КомпоновщикНастроек.Настройки.Отбор.Элементы
//	Сообщить(111);
КонецПроцедуры
