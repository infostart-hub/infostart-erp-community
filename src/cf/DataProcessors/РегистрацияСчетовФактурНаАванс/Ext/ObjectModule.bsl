﻿Перем мВалютаРегламентированногоУчета Экспорт; 
Перем Структура_ТипыДокументовАванса;
Перем мПорядокРегистрацииСчетовФактурНаАванс Экспорт;
Перем мКонецНалоговогоПериода Экспорт;
Перем мКонецНалоговогоПериодаПоДатам Экспорт;

//Пересчет суммы НДС и валютной суммы при изменении суммы регл.
мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();


мКонецНалоговогоПериодаПоДатам = Новый Соответствие;
