@chcp 65001

@rem обновление конфигурации без поддержки
call vrunner update-dev --src src/cf

@rem обновление конфигурации на поддержки. для включения раскомментируйте код ниже
REM call vrunner compile --src src/cf --out build/1cv8.cf %*
REM call vrunner load --src build/1cv8.cf %*
REM call vrunner updatedb %*

@rem обновление в режиме Предприятие
call vrunner run --command "ЗапуститьОбновлениеИнформационнойБазы;ЗавершитьРаботуСистемы;" --execute $runnerRoot\epf\ЗакрытьПредприятие.epf %*
