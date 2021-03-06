﻿Функция ПараметрыУчетнойПолитики(Переписать=Ложь) Экспорт
	Если Переписать=Ложь Тогда
		Переписать=?(ДополнительныеСвойства.УчетнаяПолитика=Неопределено, Истина, Ложь);
	КонецЕсли;

	Если Переписать Тогда
		ДополнительныеСвойства.УчетнаяПолитика=ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(?(ЭтоНовый(), ТекущаяДата(), Дата), Ложь, Организация);
	КонецЕсли;

	Возврат ДополнительныеСвойства.УчетнаяПолитика;
КонецФункции

Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	СуммаДокумента=РасшифровкаПлатежа.Итог("СуммаПлатежа");
	СуммаДокументаУСН=РасшифровкаПлатежа.Итог("СуммаУСН");

	Для каждого СтрокаКоллекции Из РасшифровкаПлатежа Цикл
		Если СтрокаКоллекции.Подразделение.Пустая() Тогда
			СтрокаКоллекции.Подразделение=Подразделение;
		КонецЕсли;
	КонецЦикла;

	
КонецПроцедуры

Функция ПолучитьСписокСтатусовОтправителя() Экспорт
	Список=Новый СписокЗначений;
	Список.Добавить("01", "01 - налогоплательщик (плательщик сборов) - юридическое лицо");
	Список.Добавить("02", "02 - налоговый агент");
	Список.Добавить("03", "03 - организация федеральной почтовой связи, составившая распоряжение по каждому платежу физического лица");
	//Список.Добавить("03", "03 - сборщик налогов и сборов");
	Список.Добавить("04", "04 - налоговый орган");
	Список.Добавить("05", "05 - территориальные органы Федеральной службы судебных приставов");
	Список.Добавить("06", "06 - участник внешнеэкономической деятельности");
	Список.Добавить("07", "07 - таможенный орган");
	//Список.Добавить("08", "08 - плательщик иных платежей, осуществляющий перечисление платежей в бюджетную систему Российской Федерации (кроме платежей, администрируемых налоговыми органами)");
	Список.Добавить("08", "08 - юридическое лицо (индивидуальный предприниматель), уплачивающее страховые взносы и иные платежи");
	Список.Добавить("09", "09 - налогоплательщик (плательщик сборов) – индивидуальный предприниматель");
	Список.Добавить("10", "10 - налогоплательщик (плательщик сборов) – частный нотариус");
	Список.Добавить("11", "11 - налогоплательщик (плательщик сборов) – адвокат, учредивший адвокатский кабинет");
	Список.Добавить("12", "12 - налогоплательщик (плательщик сборов) – глава крестьянского (фермерского) хозяйства");
	Список.Добавить("13", "13 - налогоплательщик (плательщик сборов) – иное физическое лицо – клиент банка (владелец счета)");
	//Список.Добавить("14", "14 - налогоплательщик, производящий выплаты физическим лицам (п.п. 1 п.1 ст. 235 Налогового кодекса Российской Федерации)");
	Список.Добавить("14", "14 - налогоплательщик, производящий выплаты физическим лицам");
	Список.Добавить("15", "15 - кредитная организация (филиал кредитной организации), платежный агент, организация федеральной почтовой связи, составившие платежное поручение на общую сумму с реестром");
	//Список.Добавить("15", "15 - кредитная организация, оформившая расчетный документ на общую сумму на перечисление налогов, сборов и иных платежей в бюджетную систему Российской Федерации, уплачиваемых физическими лицами без открытия банковского счета");
	Список.Добавить("16", "16 - участник внешнеэкономической деятельности - физическое лицо");
	Список.Добавить("17", "17 - участник внешнеэкономической деятельности - индивидуальный предприниматель");
	Список.Добавить("18", "18 - плательщик таможенных платежей, не являющийся декларантом, на которого законодательством Российской Федерации возложена обязанность по уплате таможенных платежей");
	Список.Добавить("19", "19 - организации, переводящие средства, удержанные из заработной платы на основании исполнительного документа");
	//Список.Добавить("19", "19 - организации, оформившие расчетный документ на перечисление на счет органа Федерального казначейства денежных средств, удержанных из заработка (дохода) должника - физического лица в счет погашения задолженности по таможенным платежам");
	//Список.Добавить("20", "20 - кредитная организация, оформившая расчетный документ по каждому платежу физического лица на перечисление таможенных платежей, уплачиваемых физическими лицами без открытия банковского счета");
	Список.Добавить("20", "20 - кредитная организация (филиал кредитной организации), платежный агент, составившие распоряжение по каждому платежу физического лица");
	Список.Добавить("21", "21 - ответственный участник консолидированной группы налогоплательщиков");
	Список.Добавить("22", "22 - участник консолидированной группы налогоплательщиков");
	Список.Добавить("23", "23 - органы контроля за уплатой страховых взносов");
	Список.Добавить("24", "24 - физическое лицо, уплачивающее страховые взносы и иные платежи");
	Список.Добавить("25", "25 - банки – гаранты, составившие распоряжение о переводе денежных средств в бюджетную систему Российской Федерации за плательщика суммы налога на добавленную стоимость, излишне полученной им (зачтенной ему) в результате возмещения налога на добавленную стоимость в заявительном порядке, а также по уплате акцизов, исчисленных по операциям реализации подакцизных товаров за пределы территории Российской Федерации, и акцизов в размере авансового платежа акцизов по алкогольной и (или) подакцизной спиртосодержащей продукции");
	Список.Добавить("26", "26 - учредители (участники) должника, собственники имущества должника – унитарного предприятия или третьи лица, составившие распоряжение на погашение задолженности по обязательным платежам, включенным в реестр требований кредиторов, в ходе процедур, применяемых в деле о банкротстве");
	
	Возврат Список;
КонецФункции

Функция ПолучитьСписокОснованийПлатежа() Экспорт
	Список=Новый СписокЗначений;
	Список.Добавить("ТП", "ТП - платежи текущего года");
	Список.Добавить("ЗД", "ЗД - добровольное погашение задолженности по истекшим налоговым периодам");
	Список.Добавить("БФ", "БФ - текущие платежи физических лиц – клиентов банка (владельцев счета), уплачиваемые со своего банковского счета");
	Список.Добавить("ТР", "ТР - погашение задолженности по требованию об уплате налогов (сборов) от налогового органа");
	Список.Добавить("РС", "РС - погашение рассроченной задолженности");
	Список.Добавить("ОТ", "ОТ - погашение отсроченной задолженности");
	Список.Добавить("РТ", "РТ - погашение реструктурируемой задолженности");
	Список.Добавить("ВУ", "ВУ - погашение отсроченной задолженности в связи с введением внешнего управления");
	Список.Добавить("ПР", "ПР - погашение задолженности, приостановленной к взысканию");
	Список.Добавить("АП", "АП - погашение задолженности по акту проверки");
	Список.Добавить("АР", "АР - погашение задолженности по исполнительному документу");
	Список.Добавить("0" , "0 - Невозможно указать конкретное значение показателя");

	Возврат Список;
КонецФункции

Функция ПолучитьСписокПоказателейТипа() Экспорт
	Список=Новый СписокЗначений;
	Если Дата>Дата('2014-02-04') Тогда
		Список.Добавить("0", "0 - все, кроме пени и процентов");
		Список.Добавить("ПЕ", "ПЕ - уплата пени");
		Список.Добавить("ПЦ", "ПЦ - уплата процентов");
	Иначе	
		Список.Добавить("НС", "НС - уплата налога или сбора");
		Список.Добавить("ПЛ", "ПЛ - уплата платежа");
		Список.Добавить("ГП", "ГП - уплата пошлины");
		Список.Добавить("ВЗ", "ВЗ - уплата взноса");
		Список.Добавить("АВ", "АВ - уплата аванса или предоплата (в том числе декадные платежи)");
		Список.Добавить("ПЕ", "ПЕ - уплата пени");
		Список.Добавить("ПЦ", "ПЦ - уплата процентов");
		Список.Добавить("СА", "СА - налоговые санкции, установленные Налоговым кодексом РФ");
		Список.Добавить("АШ", "АШ - административные штрафы");
		Список.Добавить("ИШ", "ИШ - иные штрафы, установленные соответствующими нормативными актами");
		Список.Добавить("0" , "0 - Конкретное значение указать невозможно");
    КонецЕсли;
	Возврат Список;
КонецФункции

//////////////////////////////////////////////////////////////////////////////////
// Проведение по регистрам

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ)
	//Двидения по регистру "Денежные средства"
	ДвижениеПоРегистру_ДенежныеСредства(СтруктураШД, СтруктураТД, Отказ);

	//Двидения по регистру "Взаиморасчеты с контрагентами"
	ДвижениеПоРегистру_ВзаиморасчетыСКонтрагентами(СтруктураШД, СтруктураТД, Отказ);

	//Двидения по регистру "Взаиморасчеты с подотчетными лицами"
	ДвижениеПоРегистру_ВзаиморасчетыСПодотчетнымиЛицами(СтруктураШД, СтруктураТД, Отказ);

	//Двидения по регистру "Движения денежных средств"
	ДвижениеПоРегистру_ДвиженияДенежныхСредств(СтруктураШД, СтруктураТД, Отказ);

	//Движения по регистру "КУДиР"
	ДвижениеПоРегистру_КУДиР(СтруктураШД, СтруктураТД, Отказ);
	
	//Движения по регистрам "Расходы при УСН"
	ДвижениеПоРегистру_РасходыПриУСН(СтруктураШД, СтруктураТД, Отказ);

	//Движения по регистрам "Учет НДС"
	ДвижениеПоРегистру_УчетНДС(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры
 
Процедура ДвижениеПоРегистру_КУДиР(СтруктураШД, СтруктураТД, Отказ)
	Если Не Оплачено Тогда Возврат; КонецЕсли;
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "КнигаУчетаДоходовИРасходов") Тогда Возврат; КонецЕсли;
	Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ПереводНаДругойСчет Тогда Возврат; КонецЕсли;

	тзУСН=СтруктураТД.РасшифровкаПлатежа.Скопировать();
	Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ВозвратДенежныхСредствПокупателю Тогда 
		Для Каждого СтрокаКоллекции Из тзУСН Цикл
			СтрокаКоллекции.СуммаПлатежа=-СтрокаКоллекции.СуммаПлатежа;
			СтрокаКоллекции.СуммаУСН=-СтрокаКоллекции.СуммаУСН;
			СтрокаКоллекции.СуммаБух=-СтрокаКоллекции.СуммаБух;
		КонецЦикла;
		НалоговыйУчет.ДвиженияДенежныхСредствКУДиР(Ссылка, ДополнительныеСвойства, СтруктураШД, тзУСН, "Доходы");
	Иначе
		Для Каждого СтрокаКоллекции Из тзУСН Цикл
			СтрокаКоллекции.СуммаПлатежа=СтрокаКоллекции.СуммаПлатежа;
			СтрокаКоллекции.СуммаУСН=0;
			СтрокаКоллекции.СуммаБух=СтрокаКоллекции.СуммаБух;
		КонецЦикла;
		НалоговыйУчет.ДвиженияДенежныхСредствКУДиР(Ссылка, ДополнительныеСвойства, СтруктураШД, тзУСН, "Расходы");	
	КонецЕсли;
КонецПроцедуры

Процедура ДвижениеПоРегистру_РасходыПриУСН(СтруктураШД, СтруктураТД, Отказ)
	Если Не Оплачено Тогда Возврат; КонецЕсли;
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "РасходыПриУСН") Тогда Возврат; КонецЕсли;

	УчетнаяПолитика=СтруктураШД.УчетнаяПолитика;
	Если УчетнаяПолитика.ОбъектНалогообложенияУСН=Перечисления.ОбъектыНалогообложенияПоУСН.Доходы Тогда	Возврат; КонецЕсли;	
	Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ВозвратДенежныхСредствПокупателю Тогда Возврат; КонецЕсли;
	Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ВыдачаДенежныхСредствПодотчетнику Тогда Возврат; КонецЕсли;
	Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ПереводНаДругойСчет Тогда Возврат; КонецЕсли;

	ВключитьДвиженияУСН=Ложь;
	Если ДополнительныеСвойства.Свойство("ВключитьДвиженияУСН") Тогда
		ВключитьДвиженияУСН=ДополнительныеСвойства.ВключитьДвиженияУСН;
	КонецЕсли;

	СистемаНалогообложения=УчетнаяПолитика.СистемаНалогообложения;
	Если СистемаНалогообложения=Перечисления.СистемыНалогообложения.Упрощенная Или СистемаНалогообложения=Перечисления.СистемыНалогообложения.Упрощенная_ЕНВД ИЛИ ВключитьДвиженияУСН Тогда
		тзДвижения=Движения.РасходыПриУСН.ВыгрузитьКолонки();
		тзДанные=СтруктураТД.РасшифровкаПлатежа.Скопировать();
		тзДанные.Свернуть("ДоговорКонтрагента,ТОП,НомерСтрокиТабличнойЧасти,ВидТабличнойЧасти","СуммаПлатежа,СуммаУСН");
		Для Каждого СтрокаКоллекции Из тзДанные Цикл
			НоваяСтрока=тзДвижения.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока,СтрокаКоллекции);
			НоваяСтрока.ТОП=СтрокаКоллекции.ТОП;
			Если СтрокаКоллекции.СуммаПлатежа=СтрокаКоллекции.СуммаУСН Тогда
				НоваяСтрока.Сумма=СтрокаКоллекции.СуммаПлатежа;
				НоваяСтрока.СтатусыОплатыРасходов=Перечисления.СтатусыРасходовУСН.КупленоОплаченоПоставщику;
			ИначеЕсли СтрокаКоллекции.СуммаУСН=0 Тогда
				НоваяСтрока.Сумма=СтрокаКоллекции.СуммаПлатежа;
				НоваяСтрока.СтатусыОплатыРасходов=Перечисления.СтатусыРасходовУСН.ПредоплатаПоставщику;
			ИначеЕсли СтрокаКоллекции.СуммаУСН<СтрокаКоллекции.СуммаПлатежа Тогда
				НоваяСтрока.Сумма=СтрокаКоллекции.СуммаПлатежа-СтрокаКоллекции.СуммаУСН;
				НоваяСтрока.СтатусыОплатыРасходов=Перечисления.СтатусыРасходовУСН.ПредоплатаПоставщику;
				
				НоваяСтрока=тзДвижения.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока,СтрокаКоллекции);
				НоваяСтрока.ТОП=СтрокаКоллекции.ТОП;
				НоваяСтрока.Сумма=СтрокаКоллекции.СуммаУСН;
				НоваяСтрока.СтатусыОплатыРасходов=Перечисления.СтатусыРасходовУСН.КупленоОплаченоПоставщику;
			КонецЕсли;
		КонецЦикла;
		тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
		тзДвижения.ЗаполнитьЗначения(ДатаОплаты, "Период");
		тзДвижения.ЗаполнитьЗначения(ВидДвиженияНакопления.Приход, "ВидДвижения");
		тзДвижения.ЗаполнитьЗначения(Организация, "Организация");
   		тзДвижения.ЗаполнитьЗначения(Ссылка, "РасчетныйДокумент");
		
		Движения.РасходыПриУСН.Загрузить(тзДвижения);
	КонецЕсли;
КонецПроцедуры
 
Процедура ДвижениеПоРегистру_ВзаиморасчетыСКонтрагентами(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ВзаиморасчетыСКонтрагентами") Тогда Возврат; КонецЕсли;
	Если Оплачено И ДенежныеСредстваСервер.ЕстьВзаиморасчеты(ВидОперации) Тогда
		Движения.ВзаиморасчетыСКонтрагентами.Загрузить(СтруктураТД.Взаиморасчеты);
	КонецЕсли;	
КонецПроцедуры

Процедура ДвижениеПоРегистру_ВзаиморасчетыСПодотчетнымиЛицами(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ Оплачено Тогда Возврат; КонецЕсли;
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ВзаиморасчетыСПодотчетнымиЛицами") Тогда Возврат; КонецЕсли;

	Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ВыдачаДенежныхСредствПодотчетнику Тогда
		тзДвижения=Движения.ВзаиморасчетыСПодотчетнымиЛицами.ВыгрузитьКолонки();
		Для каждого СтрокаКоллекции Из СтруктураТД.РасшифровкаПлатежа Цикл
			НоваяСтрока=тзДвижения.Добавить();
			НоваяСтрока.ФизЛицо=?(СтрокаКоллекции.Сотрудник.Пустая(), Контрагент, СтрокаКоллекции.Сотрудник);
			НоваяСтрока.Сумма=СтрокаКоллекции.СуммаПлатежа;
		КонецЦикла;
		тзДвижения.ЗаполнитьЗначения(Дата, "Период");
		тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
		тзДвижения.ЗаполнитьЗначения(ВидДвиженияНакопления.Приход, "ВидДвижения");
		тзДвижения.ЗаполнитьЗначения(Ссылка, "Регистратор");
		тзДвижения.ЗаполнитьЗначения(Организация, "Организация");

		Движения.ВзаиморасчетыСПодотчетнымиЛицами.Загрузить(тзДвижения);
	КонецЕсли;	
КонецПроцедуры

Процедура ДвижениеПоРегистру_ДенежныеСредства(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ Оплачено Тогда Возврат; КонецЕсли;
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ДенежныеСредства") Тогда Возврат; КонецЕсли;

	тзДанные=Движения.ДенежныеСредства.ВыгрузитьКолонки();

	НоваяСтрока=тзДанные.Добавить();
	НоваяСтрока.БанковскийСчетКасса=СчетОрганизации;
	НоваяСтрока.ВидДвижения=ВидДвиженияНакопления.Расход;
	Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ПереводНаДругойСчет Тогда
		НоваяСтрока=тзДанные.Добавить();
		НоваяСтрока.БанковскийСчетКасса=СчетКонтрагента;
		НоваяСтрока.ВидДвижения=ВидДвиженияНакопления.Приход;
	КонецЕсли;
	тзДанные.ЗаполнитьЗначения(Истина, "Активность");
	тзДанные.ЗаполнитьЗначения(СтруктураШД.ДатаДвижений, "Период");
	тзДанные.ЗаполнитьЗначения(Организация, "Организация");
	тзДанные.ЗаполнитьЗначения(Перечисления.ВидыДенежныхСредств.Безналичные, "ВидДенежныхСредств");
	тзДанные.ЗаполнитьЗначения(СтруктураТД.РасшифровкаПлатежа.Итог("СуммаПлатежа"), "Сумма");
	тзДанные.ЗаполнитьЗначения(СтруктураТД.РасшифровкаПлатежа.Итог("СуммаВал"), "СуммаУпр");

	Движения.ДенежныеСредства.Загрузить(тзДанные);
КонецПроцедуры

Процедура ДвижениеПоРегистру_ДвиженияДенежныхСредств(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ Оплачено Тогда Возврат; КонецЕсли;
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ДвиженияДенежныхСредств") Тогда Возврат; КонецЕсли;

	тзДвижения=Движения.ДвиженияДенежныхСредств.ВыгрузитьКолонки();	
	Для каждого СтрокаКоллекции Из СтруктураТД.Взаиморасчеты Цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		НоваяСтрока.БанковскийСчетКасса=СчетОрганизации;
		Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ВыдачаДенежныхСредствПодотчетнику Тогда
			НоваяСтрока.Контрагент=СтрокаКоллекции.Сотрудник;
		Иначе
			НоваяСтрока.Контрагент=?(НЕ ЗначениеЗаполнено(Контрагент), Организация, Контрагент);
		КонецЕсли;
		НоваяСтрока.ПриходРасход=Перечисления.ВидыДвиженийПриходРасход.Расход;
		НоваяСтрока.Сумма=СтрокаКоллекции.СуммаБух;
		НоваяСтрока.СуммаУпр=СтрокаКоллекции.СуммаВал;
		Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ПереводНаДругойСчет Тогда
			НоваяСтрока=тзДвижения.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
			НоваяСтрока.БанковскийСчетКасса=СчетКонтрагента;

			НоваяСтрока.Контрагент=Организация;
			НоваяСтрока.ПриходРасход=Перечисления.ВидыДвиженийПриходРасход.Приход;
			НоваяСтрока.Сумма=СтрокаКоллекции.СуммаБух;
			НоваяСтрока.СуммаУпр=СтрокаКоллекции.СуммаВал;
		КонецЕсли;		
	КонецЦикла;

	тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
	тзДвижения.ЗаполнитьЗначения(СтруктураШД.ДатаДвижений, "Период");
	тзДвижения.ЗаполнитьЗначения(Перечисления.ВидыДенежныхСредств.Безналичные, "ВидДенежныхСредств");
	тзДвижения.ЗаполнитьЗначения(Организация, "Организация");
	тзДвижения.ЗаполнитьЗначения(Ссылка, "ДокументДвижения");
	тзДвижения.ЗаполнитьЗначения(Подразделение, "ЦФО");	
	Движения.ДвиженияДенежныхСредств.Загрузить(тзДвижения);
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////
// Проведение по регистрам (по нескольким регистрам одного типа)

Процедура ДвижениеПоРегистру_УчетДенежныхСведств(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_ДенежныеСредства(СтруктураШД, СтруктураТД, Отказ);
	ДвижениеПоРегистру_ДвиженияДенежныхСредств(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетВзаиморасчетов(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_ВзаиморасчетыСКонтрагентами(СтруктураШД, СтруктураТД, Отказ);
	ДвижениеПоРегистру_ВзаиморасчетыСПодотчетнымиЛицами(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетНДС(СтруктураШД, СтруктураТД, Отказ)
	Если Оплачено И ДенежныеСредстваСервер.ЕстьВзаиморасчеты(ВидОперации) Тогда
		УчетНДС.ДвижениеДенежныхСредств(ЭтотОбъект);
	КонецЕсли;	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий модуля

Процедура ОбработкаЗаполнения(Основание)
	Если Не ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание) Тогда Возврат; КонецЕсли; 

	ВалютаДокумента = ДополнительныеСвойства.ВалютаБухУчета;

	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ЗаказПоставщику") Тогда
		ВидОперации=Перечисления.ВидыОперацийППИсходящее.ОплатаПоставщику;

		СтрокаПлатеж=РасшифровкаПлатежа.Добавить();
		СтрокаПлатеж.ДоговорКонтрагента=Основание.ДоговорКонтрагента;
		СтрокаПлатеж.СтавкаНДС=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнаяСтавкаНДС");
		ЗаполнитьЗначенияСвойств(СтрокаПлатеж, МодульВалютногоУчета.КурсВалюты(Основание.ДоговорКонтрагента.ВалютаВзаиморасчетов, Дата));
		Если ЗначениеЗаполнено(Контрагент.ОсновнойБанковскийСчет) Тогда
			СчетКонтрагента=Контрагент.ОсновнойБанковскийСчет;
		КонецЕсли;

		СчетОрганизации=?(ЗначениеЗаполнено(Основание.СтруктурнаяЕдиница), Основание.СтруктурнаяЕдиница, Организация.ОсновнойБанковскийСчет);
		ВалютаДокумента=?(СчетОрганизации.Пустая(), ДополнительныеСвойства.ВалютаБухУчета, СчетОрганизации.ВалютаДенежныхСредств);		

	ИначеЕсли    ТипЗнч(Основание)=Тип("ДокументСсылка.ПоступлениеТоваровУслуг") 
			или (ТипЗнч(Основание)=Тип("ДокументСсылка.ПоступлениеДопРасходов")) 
			или (ТипЗнч(Основание)=Тип("ДокументСсылка.КомиссияОтчетПродажиКомитенту")) 
			или (ТипЗнч(Основание)=Тип("ДокументСсылка.ВозвратТоваровОтПокупателя")) Тогда

		Если ТипЗнч(Основание)=Тип("ДокументСсылка.ВозвратТоваровОтПокупателя") Тогда
			ВидОперации = Перечисления.ВидыОперацийППИсходящее.ВозвратДенежныхСредствПокупателю;
		Иначе
			ВидОперации = Перечисления.ВидыОперацийППИсходящее.ОплатаПоставщику;
		КонецЕсли;

		Контрагент=Основание.Контрагент;

		СтрокаПлатеж=РасшифровкаПлатежа.Добавить();
		СтрокаПлатеж.ДоговорКонтрагента=Основание.ДоговорКонтрагента;
		ЗаполнитьЗначенияСвойств(СтрокаПлатеж, МодульВалютногоУчета.КурсВалюты(Основание.ДоговорКонтрагента.ВалютаВзаиморасчетов, Дата));
        СтрокаПлатеж.СтавкаНДС=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнаяСтавкаНДС");

		СчетОрганизации=Организация.ОсновнойБанковскийСчет;
		Если ЗначениеЗаполнено(Контрагент.ОсновнойБанковскийСчет) И Контрагент.ОсновнойБанковскийСчет.ВалютаДенежныхСредств=СчетОрганизации.ВалютаДенежныхСредств Тогда
			СчетКонтрагента=Контрагент.ОсновнойБанковскийСчет;
		КонецЕсли;

		ВалютаДокумента=?(СчетОрганизации.Пустая(), ДополнительныеСвойства.ВалютаБухУчета, СчетОрганизации.ВалютаДенежныхСредств);
	КонецЕсли;

	Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.РасчетыПоЗаработнойПлате Тогда
		Возврат;
	КонецЕсли; 
	
	// Если основание - отчет комитенту, то надо вычесть вознаграждение
	ОснованиеСуммаДокумента=Основание.СуммаДокумента;
	Если ТипЗнч(Основание)=Тип("ДокументСсылка.КомиссияОтчетПродажиКомитенту") Тогда
		ОснованиеСуммаДокумента=Основание.СуммаДокумента-Основание.СуммаВознаграждения;
	КонецЕсли;

	СтрокаПлатеж.СуммаПлатежа=СуммаДокумента;
	Если СтрокаПлатеж.СуммаНДС=0 Тогда
		СтрокаПлатеж.СуммаНДС=ЦенообразованиеСервер.ПолучитьНДСДокумента(Основание);
	КонецЕсли;

	ДенежныеСредстваСервер.ПересчитатьСуммуНДС(СтрокаПлатеж);	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	УправлениеДокументамиСервер.ПередПроведением(Отказ, РежимПроведения, ЭтотОбъект);
	Если Отказ Тогда Возврат; КонецЕсли; 

	СтруктураШД=ДополнительныеСвойства.СтруктураШД;
	СтруктураТД=ДополнительныеСвойства.СтруктураТД;
	СтруктураТД.Вставить("Взаиморасчеты", ВзаиморасчетыСервер.СформироватьТаблицуОплаты(СтруктураШД, СтруктураТД, ВидДвиженияНакопления.Приход, Движения.ВзаиморасчетыСКонтрагентами.ВыгрузитьКолонки(), Отказ, ДополнительныеСвойства.Заголовок));

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
	
	//Проверка номера документа
	//НомерПечать=ОбщегоНазначенияСервер.НомерНаПечать(ЭтотОбъект);
	//Если Прав(НомерПечать, 3) = "000" Тогда
	//	ТекстОшибки="Номер платежного документа не может оканчиваться на ""000""!" + Символы.ПС
	//	+ "	(Положение Банка России ""О безналичных расчетах в Российской Федерации"""  + Символы.ПС
	//	+ "	от 3 октября 2002 г. No. 2-П в ред. Указания ЦБ РФ от 03.03.2003 No. 1256-У)";
	//	ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ, Заголовок);
	//КонецЕсли;

	Если Оплачено Тогда
		ПроверяемыеРеквизиты.Добавить("СчетОрганизации");
		ПроверяемыеРеквизиты.Добавить("СуммаДокумента");
		ПроверяемыеРеквизиты.Добавить("ДатаОплаты");
	    Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ПереводНаДругойСчет Тогда
			ПроверяемыеРеквизиты.Добавить("СчетКонтрагента");
		КонецЕсли;
	КонецЕсли;

	Если ДенежныеСредстваСервер.ЕстьВзаиморасчеты(ВидОперации) Тогда
		ПроверяемыеРеквизиты.Добавить("РасшифровкаПлатежа.ДоговорКонтрагента");
	КонецЕсли;	

	Если ВидОперации=Перечисления.ВидыОперацийППИсходящее.ПереводНаДругойСчет Тогда
		ПроверяемыеРеквизиты.Добавить("СчетКонтрагента");
	ИначеЕсли ВидОперации=Перечисления.ВидыОперацийППИсходящее.ПрочееСписаниеБезналичныхДенежныхСредств Тогда
		
	ИначеЕсли ВидОперации=Перечисления.ВидыОперацийППИсходящее.РасчетыПоЗаработнойПлате Тогда	
		
	Иначе	
		ПроверяемыеРеквизиты.Добавить("Контрагент");
	КонецЕсли;

	//Автозаполнение ревизитов шапки\табличных частей
	АвтоЗаполнениеРеквизитовДокумента();

	//Формируем структуру шапки документа "СтруктураШД"
	СтруктураШД=УправлениеДокументамиСервер.СформироватьСтруктуруШД(ЭтотОбъект);
	СтруктураШД.Вставить("РасчетыВозврат", ДенежныеСредстваСервер.НаправленияДвижения(ВидОперации));
	СтруктураШД.Вставить("ДатаОплаты", ?(Оплачено, ДенежныеСредстваСервер.ПолучитьДатуДвижений(Дата, ДатаОплаты, Организация), Дата));
	СтруктураШД.Вставить("ДатаДвижений", СтруктураШД.ДатаОплаты);

	//Формируем структуру таблиц документа "СтруктураТД"
	СтруктураТД=Новый Структура();
	СтруктураТД.Вставить("РасшифровкаПлатежа", ДенежныеСредстваСервер.СформироватьТаблицуПлатежей(ЭтотОбъект, Отказ, Заголовок));
	СтруктураТД.Вставить("ОплачиваемыеДокументы", ОплачиваемыеДокументы.Выгрузить());

	ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства);