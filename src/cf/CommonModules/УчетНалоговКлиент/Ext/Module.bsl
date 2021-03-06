﻿Процедура СписокКодовВидовОпераций(ЧастьЖурнала, СписокВыбора, Период) Экспорт
	
	Если Период >= '20160701' Тогда
		Если ЧастьЖурнала = "ПолученныеСчетаФактуры" Тогда
			СписокВыбора.Добавить("01", "01 - Получение товаров, работ, услуг");
			СписокВыбора.Добавить("02", "02 - Авансы выданные");
			СписокВыбора.Добавить("10", "10 - Безвозмездное получение товаров, работ, услуг");
			СписокВыбора.Добавить("13", "13 - Капитальное строительство, модернизация (реконструкция) объектов недвижимости");
			СписокВыбора.Добавить("15", "15 - Совместное приобретение товаров, работ, услуг для собственных нужд и для комитента");
			СписокВыбора.Добавить("16", "16 - Возврат от покупателя-неплательщика НДС");
			СписокВыбора.Добавить("17", "17 - Возврат от покупателя-физического лица");
			СписокВыбора.Добавить("18", "18 - Изменение стоимости полученных товаров (работ, услуг) в сторону уменьшения");
			СписокВыбора.Добавить("19", "19 - Ввоз товаров из Евразийского экономического союза");
			СписокВыбора.Добавить("20", "20 - Ввоз импортных товаров на территорию РФ");
			СписокВыбора.Добавить("22", "22 - Возврат, зачет авансовых платежей, п.5 ст. 171, п.6 ст. 172 НК");
			СписокВыбора.Добавить("23", "23 - Командировочные расходы по бланку строгой отчетности, п.7 ст. 171 НК");
			СписокВыбора.Добавить("24", "24 - Подтверждение ставки 0% после истечения 180 дней");
			СписокВыбора.Добавить("25", "25 - Вычет НДС при подтверждении ставки 0% по ранее восстановленному НДС, а также п.7 ст.172 НК");
			СписокВыбора.Добавить("27", "27 - Сводный комиссионный счет-фактура, п.3.1 ст. 169 НК");
			СписокВыбора.Добавить("28", "28 - Сводный комиссионный счет-фактура на аванс, п.3.1 ст. 169 НК");
			СписокВыбора.Добавить("32", "32 - Вычет НДС в ОЭЗ Калининградской обл., п.14 ст. 171 НК");
			СписокВыбора.Добавить("36", "36 - Вычет НДС при реализации гражданину иностранного государства, п.4.1 ст. 171 НК");
			СписокВыбора.Добавить("41", "41 - Авансы выданные за товары п.8 ст. 161 НК");
			СписокВыбора.Добавить("42", "42 - Получение товаров п.8 ст. 161 НК");
			СписокВыбора.Добавить("43", "43 - Возврат, зачет авансовых платежей за товары п.8 ст. 161 НК");
			СписокВыбора.Добавить("44", "44 - Изменение стоимости полученных товаров п.8 ст. 161 НК в сторону уменьшения");
		ИначеЕсли ЧастьЖурнала = "ВыставленныеСчетаФактуры" Тогда
			СписокВыбора.Добавить("01", "01 - Реализация товаров, работ, услуг и операции, приравненные к ней");
			СписокВыбора.Добавить("02", "02 - Авансы полученные");
			СписокВыбора.Добавить("06", "06 - Налоговый агент, ст. 161 НК");
			СписокВыбора.Добавить("10", "10 - Безвозмездная передача товаров, работ, услуг");
			СписокВыбора.Добавить("13", "13 - Капитальное строительство, модернизация (реконструкция) объектов недвижимости");
			СписокВыбора.Добавить("14", "14 - Реализация прав, пп.1-4 ст. 155 НК");
			СписокВыбора.Добавить("15", "15 - Совместная реализация собственных и комиссионных товаров, работ, услуг");
			СписокВыбора.Добавить("16", "16 - Возврат от покупателя-неплательщика НДС");
			СписокВыбора.Добавить("18", "18 - Изменение стоимости отгруженных товаров (работ, услуг) в сторону уменьшения");
			СписокВыбора.Добавить("21", "21 - Восстановление НДС, п.8 ст. 145, п.3 ст. 170, ст. 171.1 НК, а также при операциях, облагаемых по ставке 0%");
			СписокВыбора.Добавить("26", "26 - Реализация товаров, работ, услуг неплательщикам НДС, получение авансов");
			СписокВыбора.Добавить("27", "27 - Сводный комиссионный счет-фактура, п.3.1 ст. 169 НК");
			СписокВыбора.Добавить("28", "28 - Сводный комиссионный счет-фактура на аванс, п.3.1 ст. 169 НК");
			СписокВыбора.Добавить("29", "29 - Корректировка по п.6 ст. 105.3 НК");
			СписокВыбора.Добавить("30", "30 - Отгрузка товаров в ОЭЗ Калининградской обл., абз.1 пп.1.1 п.1 ст. 151 НК");
			СписокВыбора.Добавить("31", "31 - Уплата НДС в ОЭЗ Калининградской обл., абз.2 пп.1.1 п.1 ст. 151 НК");
			СписокВыбора.Добавить("33", "33 - Авансы полученные за товары п.8 ст. 161 НК");
			СписокВыбора.Добавить("34", "34 - Реализация товаров п.8 ст. 161 НК");
			СписокВыбора.Добавить("35", "35 - Оформление документа для компенсации НДС гражданину иностранного государства");
			СписокВыбора.Добавить("37", "37 - Реализация сырьевых товаров на экспорт по ставке 18%, п.7 ст.164 НК");
			СписокВыбора.Добавить("38", "38 - Реализация несырьевых товаров на экспорт по ставке 18%, п.7 ст.164 НК");
			СписокВыбора.Добавить("39", "39 - Реализация несырьевых товаров на экспорт по ставке 10%, п.7 ст.164 НК");
			СписокВыбора.Добавить("40", "40 - Реализация работ (услуг) в отношении экспортируемых товаров по ставке 18%, пп.2.1-2.5,2.7 и 2.8 п.1, п.7 ст.164 НК");
		КонецЕсли;
	Иначе
		Если ЧастьЖурнала="ПолученныеСчетаФактуры" ИЛИ ЧастьЖурнала="ВыставленныеСчетаФактуры" Тогда
			СписокВыбора.Добавить("01", "01 - реализованные или полученные товары, работы, услуги");
			СписокВыбора.Добавить("02", "02 - авансы выданные или полученные");
			СписокВыбора.Добавить("03", "03 - возврат от покупателя или возврат поставщику");
			СписокВыбора.Добавить("04", "04 - полученные или реализованные товары, работы, услуги от комитента");
			СписокВыбора.Добавить("05", "05 - авансы выданные комитенту или полученные от комитента");
			СписокВыбора.Добавить("06", "06 - налоговый агент, статья 161 НК");
			СписокВыбора.Добавить("07", "07 - списание за счет прибыли, пп.2 п.1 статьи 146 НК");
			СписокВыбора.Добавить("08", "08 - строительно-монтажные работы, пп.3 п.1 статьи 146 НК");
			СписокВыбора.Добавить("09", "09 - суммы, связанные с расчетами по оплате, статья 162 НК");
			СписокВыбора.Добавить("10", "10 - полученные или переданные безвозмездно товары, работы, услуги");
			СписокВыбора.Добавить("11", "11 - полученные или реализованные товары, права, п.3,4,5.1 статьи 154, пп.1-4 статьи 155 НК");
			СписокВыбора.Добавить("12", "12 - авансы выданные или полученные за товары, права, п.3,4,5.1 статьи 154, пп.1-4 статьи 155 НК");
			СписокВыбора.Добавить("13", "13 - капитальное строительство, модернизация (реконструкция) объектов недвижимости");
			СписокВыбора.Добавить("16", "16 - Возврат от покупателя-неплательщика НДС");
			СписокВыбора.Добавить("17", "17 - Возврат от покупателя-физического лица");
			СписокВыбора.Добавить("18", "18 - Изменение стоимости отгруженных и полученных товаров (работ, услуг) в сторону уменьшения");
			СписокВыбора.Добавить("19", "19 - Ввоз товаров из Евразийского экономического союза");
			СписокВыбора.Добавить("20", "20 - Ввоз импортных товаров на территорию РФ");
			СписокВыбора.Добавить("21", "21 - Восстановление НДС, п.8 статьи 145, п.3 статьи 170, статья 171.1 НК, а также при операциях, облагаемых по ставке 0%");
			СписокВыбора.Добавить("22", "22 - Возврат, зачет авансовых платежей, п.5 статьи 171, п.6 статьи 172 НК");
			СписокВыбора.Добавить("23", "23 - Командировочные расходы по бланку строгой отчетности, п.7 статьи 171 НК");
			СписокВыбора.Добавить("24", "24 - Подтверждение ставки 0% после истечения 180 дней");
			СписокВыбора.Добавить("25", "25 - Подтверждение ставки 0%");
			СписокВыбора.Добавить("26", "26 - Счета-фактуры не составляются по письменному согласию сторон");
			СписокВыбора.Добавить("27", "27 - Сводный комиссионный счет-фактура, п.3.1 статьи 169 НК");
			СписокВыбора.Добавить("28", "28 - Сводный комиссионный счет-фактура на аванс, п.3.1 статьи 169 НК");
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры
