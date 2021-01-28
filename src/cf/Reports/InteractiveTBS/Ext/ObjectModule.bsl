//Copyright (c) 2015 Leonov Aleksandr

//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
//documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
//the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
//and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all copies or substantial portions 
//of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
//TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
//OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//DEALINGS IN THE SOFTWARE.

Function СведенияОВнешнейОбработке() Export
    RegistrationSettings = New Structure;
    RegistrationSettings.Insert("вид", "ДополнительныйОтчет");

    RegistrationSettings.Insert("наименование", "Интерактивная ОСВ");
    RegistrationSettings.Insert("версия", "3.0.13");
    RegistrationSettings.Insert("безопасныйРежим", True);
    RegistrationSettings.Insert("информация", "Интерактивная ОСВ");
 	RegistrationSettings.Insert("версияБСП", "2.2.2.0");
 	TableTeams = GetCommandTable();
    AddCommand(TableTeams,
    "Интерактивная ОСВ",
    "Интерактивная ОСВ",
    "ОткрытиеФормы",
    True,""

    );
    RegistrationSettings.Insert("Команды", TableTeams);
    Return RegistrationSettings;
EndFunction

Function GetCommandTable()
    Commands = New ValueTable;
    Commands.Columns.Add("представление", New TypeDescription("String"));
    Commands.Columns.Add("идентификатор", New TypeDescription("String"));
    Commands.Columns.Add("использование", New TypeDescription("String"));
    Commands.Columns.Add("показыватьОповещение", New TypeDescription("Boolean"));
    Commands.Columns.Add("модификатор", New TypeDescription("String"));
    Return Commands;
EndFunction

Procedure AddCommand(TableTeams, Presentation, CID, Use, ShowAlert = False, Modifier = "")
    NewTeam = TableTeams.Add();
    NewTeam.представление = Presentation;
    NewTeam.идентификатор = CID;
    NewTeam.использование = Use;
    NewTeam.показыватьОповещение = ShowAlert;
    NewTeam.модификатор = Modifier;
EndProcedure

