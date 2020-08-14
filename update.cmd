@chcp 65001

@rem обновление конфигурации основной разработческой ИБ без поддержки. по умолчанию в каталоге build/ib
call vrunner update-dev --src src/cf

@rem обновление конфигурации  основной разработческой ИБ на поддержке. для включения раскомментируйте код ниже
@rem call vrunner compile --src src/cf --out build/1cv8.cf %*
@rem call vrunner load --src build/1cv8.cf %*
@rem call vrunner updatedb %*

@rem обновление конфигурации основной разработческой ИБ из хранилища. для включения раскомментируйте код ниже
@rem call vrunner loadrepo %*
@rem call vrunner updatedb %*

@rem собрать внешние обработчики и отчеты в каталоге build
@rem call vrunner compileepf src/epf/МояВнешняяОбработка build %*
@rem call vrunner compileepf src/erf/МойВнешнийОтчет build %*

@rem собрать расширения конфигурации внутри ИБ
@rem call vrunner compileext src/cfe/МоеРасширение МоеРасширение %*

@rem обновление в режиме Предприятие
call vrunner run --command "ЗапуститьОбновлениеИнформационнойБазы;ЗавершитьРаботуСистемы;" --execute $runnerRoot\epf\ЗакрытьПредприятие.epf %*
