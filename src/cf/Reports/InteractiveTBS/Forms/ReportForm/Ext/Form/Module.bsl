&AtServer
Var NP;

&AtServer
Var mFieldsSeparator; 

&AtServer
Var mAccountingRegister; 

&AtServer
Var mDateQuery1;

&AtServer
Var mDateQuery2;

&AtServer
Var mGroups;

&AtServer
Var mSorting;

&AtServer
Var mTotals;

&AtServer
Var mTranscriptStringField;

&AtServer
Var mTranscriptString;

&AtClient
Procedure OnOpen(Failure)

	If NOT ValueIsFilled(Date1) OR NOT ValueIsFilled(Date2) OR 
		NOT _ToCheckValidityOfRestrictionsOnDates(Date1, Date2, False) Then
	
		Date1 = BegOfQuarter(CurrentDate());
		Date2 = EndOfQuarter(CurrentDate());
	
	Endif;
	
	UpdateHeaderText(ThisForm);
	
	If ThisForm.UniqueKey = Undefined Then
		ThisForm.UniqueKey = New UUID();
	Endif;
			
	CompleteInitialSettings();
	
	Items.AccountingRegister.Title = ?(NameAccountingRegister = "Хозрасчетный", "Бухгалтерский", NameAccountingRegister);
	
	Items.DescriptionPeriod.Title = GenerateLineConclusionParametersByDatesAtClient(Date1, Date2);

EndProcedure

&AtClient
Procedure GenerateReport(Command)

	ClearMessages();
	
	RefreshDisplay();
	
	GenerateReportAtServer();
	
EndProcedure

&AtServer
Function GenerateReportAtServer() Export
	
	Generate();
	
	ToEstablishConditionFieldSpreadsheetDocument("DontUse");
	
	HideSettingsWhenFormingReport();
	
EndFunction

&AtServer
Function GetDataResponsiblePerson() Export
	
	DataResponsiblePerson = New Structure("JobTitle,Signature");
	
	
	If ValueIsFilled(NP.Date2) Then
		Period = EndOfDay(NP.Date2);
	Else
		Period = CurrentSessionDate();
	Endif;
	
	If TypeOf(FirstSection) = Type("ValueList") Then
		ParameterFirstSection = FirstSection[0].Value;
	Else	
		ParameterFirstSection = ParameterFirstSection;
	Endif;	
	
	If Not ValueIsFilled(ParameterFirstSection) Then
		Return DataResponsiblePerson;
	Endif;
	
	If Metadata.CommonModules.Find("ОтветственныеЛицаБП") = Undefined Then
		ОтветственныеЛицаБП = Undefined;	
	Endif;
	Try
		AttributesResponsiblePerson 					= ОтветственныеЛицаБП.ОтветственныеЛица(ParameterFirstSection, Period);
		DataResponsiblePerson.JobTitle 			= AttributesResponsiblePerson["ОтветственныйЗаБухгалтерскиеРегистрыДолжностьПредставление"];
		DataResponsiblePerson.Signature = AttributesResponsiblePerson["ОтветственныйЗаБухгалтерскиеРегистрыПредставление"];
	Except
	EndTry;	

	
	Return DataResponsiblePerson;
			
EndFunction

&AtServer
Procedure Generate(Recalculation = True) Export
	Var Identifier, Account;
	
	NP = GetFromTempStorage(AddressStorage);
	
	PageDimensions = GetFirstBalance();
	If PageDimensions <> Undefined  Then
		PageDimensions.Value = FirstSection.Copy();
	Endif;
	
 	If Recalculation Then
		NP.Insert("TVResources", TVResources.Unload());
		LimitAndBreakTVResources();	
		LoadLayoutOformlenieVNP();		
		
		If ((Date1 = BegOfMonth(Date1)) and (Date2 = EndOfMonth(Date1))) or
			((Date1 = BegOfQuarter(Date1)) and (Date2 = EndOfQuarter(Date1))) or
			((Date1 = BegOfYear(Date1)) and (Date2 = EndOfYear(Date1))) or
			((Date1 = BegOfYear(Date1)) and (Date2 = EndOfMonth(Date2)) and (Date2 <= EndOfYear(Date1))) Then
			Vl = Format(Date1, "DF=yyyyMMddHHmmss") + "-" + Format(Date2, "DF=yyyyMMddHHmmss");
			SearchOnList = RepHistoryPeriods.FindByValue(Vl);
			If NOT SearchOnList = Undefined Then 
				RepHistoryPeriods.Delete(SearchOnList) 
			Endif;
			RepHistoryPeriods.Insert(0, Vl);
			For Identifier = -RepHistoryPeriods.Count() + 1 To -8 Do
				RepHistoryPeriods.Delete(-Identifier)
			EndDo;
		Endif;
			
		NP.Insert("Date1", 					BegOfDay(Date1));
		NP.Insert("Date2", 					EndOfDay(Date2));
		NP.Insert("NameAccountingRegister", 	NameAccountingRegister);
		NP.Insert("NameChartOfAccounts", 			NameChartOfAccounts);
		NP.Insert("ExtDimensionTypeName", 			ExtDimensionTypeName);
		NP.Insert("MaxExtDimensionCount", 	MaxExtDimensionCount);
		NP.Insert("OffBalanceAccount", 		OffBalanceAccount);
		
		NP.Insert("_TVDimensions", 			NP.TVDimensions.Copy());
		NP.Insert("TVFilter", 					SelectionOfLayoutInTV());
		NP.Insert("TableTurnBalance", GenerateTableDataSplittedBalance()); 
		NP.TableTurnBalance.Indexes.Add("Account");
		
		NP.Insert("TabNew", Expand(, "Account"));
	Endif;

	TabDocument.Clear();

	mTranscriptString 	= 1;
	mTranscriptStringField 	= 1;
	If NP.TVResourcesFilter.Count() = 1 Then
		Generate_OutputSection("Header|Base");
		Generate_OutputSection("Header|Resources",,, 	 True);
	Else
		Generate_OutputSection("Header|Base");
		Generate_OutputSection("Header|CacheIndicator",,, True);
		Generate_OutputSection("Header|Resources",,, 	 True);
	Endif;
	AreaForCollection = TabDocument.Area(1, 2, 1, TabDocument.TableWidth);
	AreaForCollection.Merge();
	TabDocument.Area("R1:R2").Visible = OutputHeading;
	Generate_OutputTable(NP.TabNew);	
	PBalance 	= ValueFromStringInternal(NP.StrFieldStructure);
	If TypeOf(NP.TabNew) = Type("ValueTable") Then
		For each StrTab in NP.TabNew Do
			Account = StrTab.Value;
			If (StrTab.Indicator <> "Account" OR NOT ValueIsFilled(Account) 
				OR ValueIsFilled(Account.Parent) OR (Account.OffBalance AND NP.NameChartOfAccounts = "Хозрасчетный")) Then
				Continue;
			Endif;
			
			For each Fiel in PBalance Do
				PBalance[Fiel.Key] = PBalance[Fiel.Key] + StrTab[Fiel.Key];
			EndDo;
		EndDo;
	Endif;
	PBalance.Insert("Level", 	5);
	PBalance.Insert("TurnDr", 	"+");
	PBalance.Insert("Address", 		"");
	PBalance.Insert("DetString", 	1);
	PBalance.Insert("TVResources", 	NP.TVResourcesFilter.Copy());//????
	For each Resource in NP.TVResourcesFilter Do
		Generate_OutputSection("Cache_Totals|Base", 		PBalance, Resource,);
		If NP.TVResourcesFilter.Count() > 1 Then
			Generate_OutputSection("Cache_Totals|CacheIndicator", 	PBalance, Resource, True);
		Endif;
		Generate_OutputSection("Cache_Totals|Resources", 	PBalance, Resource, True);
	EndDo;
		
	If OutputCellar Then
		IdConfiguration 			= "";
		If Metadata.CommonModules.Find("РегламентированнаяОтчетностьПереопределяемый") = Undefined Then
			РегламентированнаяОтчетностьПереопределяемый = Undefined;	
		Endif;
		Try
			IdConfiguration 			= РегламентированнаяОтчетностьПереопределяемый.ИДКонфигурации();
		Except
		EndTry;	
			
		If IdConfiguration = "БПКОРП" OR IdConfiguration = "БП" OR IdConfiguration = "УП2" OR IdConfiguration = "КА2" Then
	
			AreaSignature = NP.Template.GetArea("Signature");
	
			AreaSignature.Parameters.Fill(GetDataResponsiblePerson());		

			TabDocument.Put(AreaSignature);
		Endif;
	
	Endif;
	
	ToEstablishHeadlinesByDefault(TabDocument);
	TabDocument.FixedTop 				= 5;
	TabDocument.FixedLeft 				= 1;
	
	TabDocument.ИмяПараметровПечати 		= "PARAMETRS_PRINT_WorkingCapitalBalanceSheet";
	TabDocument.FitToPage					= True;
 	TabDocument.BlackAndWhite			= True;
	TabDocument.RepeatOnRowPrint  	= NP.Template.GetArea("Repeat");
	TabDocument.PrintArea				= TabDocument.Area(1, 2, TabDocument.TableHeight, TabDocument.TableWidth);
	
	PutToTempStorage(NP, AddressStorage);
	
EndProcedure

&AtServer
Procedure ToEstablishHeadlinesByDefault(SpreadsheetDocument)
	
	SpreadsheetDocument.Header.Enabled				= ValueIsFilled(TemplateHeader);
	SpreadsheetDocument.Header.StartPage 		= 1;
	SpreadsheetDocument.Header.VerticalAlign 	= VerticalAlign.Bottom;
	SpreadsheetDocument.Header.LeftText   			= FillTextHeadline(TemplateHeader, "Интерактивная ОСВ", UserName());
	
	SpreadsheetDocument.Footer.Enabled					= ValueIsFilled(TemplateFooter);
	SpreadsheetDocument.Footer.StartPage 		= 1 ;
	SpreadsheetDocument.Footer.VerticalAlign 	= VerticalAlign.Top;
	SpreadsheetDocument.Footer.RightText  			= FillTextHeadline(TemplateFooter, "Интерактивная ОСВ", UserName());
	
EndProcedure

&AtServer
Function FillTextHeadline(Text, NameReport, User)

	ResultText = Text;
	
	ResultText = StrReplace(ResultText, "[&НазваниеОтчета]", 		NameReport);
	ResultText = StrReplace(ResultText, "[&Пользователь]", 		User);
	ResultText = StrReplace(ResultText, "[&НазваниеОрганизации]", 	?(NP._TVDimensions.Count() > 0, NP._TVDimensions[0].Value, ""));
	ResultText = StrReplace(ResultText, "[&Period]", 				GenerateLineConclusionParametersByDatesAtServer(NP.Date1, NP.Date2));
	Return ResultText;

EndFunction

&AtServer
Procedure RemoveAllReversalsByOwner(Filter);
	IndexOf = NP.SettingsTurns.Count() - 1;
	While IndexOf >= 0 Do
		If  NP.SettingsTurns.Count() - 1 >= IndexOf and NP.SettingsTurns[IndexOf].Owner = Filter Then
			RemoveAllReversalsByOwner(NP.SettingsTurns[IndexOf].Value);
			Try
				NP.SettingsTurns.Delete(IndexOf);
			Except
			EndTry;	
		Endif;
		IndexOf = IndexOf - 1;
	EndDo;
EndProcedure

&AtClient
Procedure ToChooseFromMenuListPeriodEnd(Result, AdditionalParameters) Export
	
	If Result = Undefined Then
		Return;
	Endif;
	StructureButton = New Structure("Name", Result.Value);
	
	RunMenu(StructureButton);	
		
EndProcedure

&AtClient
Procedure ProcessingOfDecodingCompletion(Result, AdditionalParameters) Export
	
	If Result = Undefined Then
		Return;
	Endif;
	
	ValueOfDecryption = AdditionalParameters.Details.ValueOfDecryption;
	ParameterStructure = New Structure("CurrentRow",  ValueOfDecryption);
	
	If Result.Value = "<open>" AND ValueIsFilled(ValueOfDecryption) Then
		ShowValue( , ValueOfDecryption);
	Elsif Result.Value = "<accesslist>" AND ValueIsFilled(ValueOfDecryption) Then
		OpenForm("Catalog." + AdditionalParameters.Details.NameOfMetadata + ".ListForm", ParameterStructure);
	Elsif Result.Value = "<accessjournal>" AND ValueIsFilled(ValueOfDecryption) Then
		OpenForm("Document." + AdditionalParameters.Details.NameOfMetadata + ".ListForm", ParameterStructure);
	Else 
		
		ObjectName = Result.Value;
		TemplateFormName = "REPORT.%ObjectName%.Form.ФормаОтчета";
	
		If Result.Value = "ОборотыСчетаПоДням" Then
			ObjectName = "ОборотыСчета";
			AdditionalParameters.Details.UserSettings.AdditionalProperties.Insert("Periodicity", 6);
		Elsif Result.Value = "ОборотыСчетаПоМесяцам" Then
			ObjectName = "ОборотыСчета";
			AdditionalParameters.Details.UserSettings.AdditionalProperties.Insert("Periodicity", 9);
		Elsif Result.Value = "ОтчетПоПроводкам" Then
			
			BasicSelection 		= AdditionalParameters.Details.UserSettings.Items.Find("Отбор"); 
			FilterOnTransactions 	= AdditionalParameters.Details.UserSettings.Items.Find("FilterOnTransactions"); 
			For each FilterItem in FilterOnTransactions.Items Do
				FilterDCS = BasicSelection.Items.Add(Type("DataCompositionFilterItem"));
				FillPropertyValues(FilterDCS, FilterItem);
			EndDo;
			
		Endif;
		NameOfReportForm =  StrReplace(TemplateFormName, "%ObjectName%", ObjectName);
		FillSettings = New Structure("Показатели, Группировка, Отбор, ВыводимыеДанные", False, True, False, True);
		
		ParametersForm = New Structure("ВидРасшифровки, РежимРасшифровки, СформироватьПриОткрытии, ЗаполняемыеНастройки", 2, True, True, FillSettings);
		
		ParametersForm.Insert("ПользовательскиеНастройки", AdditionalParameters.Details.UserSettings);
		
		OpenForm(NameOfReportForm, ParametersForm,, True);
		
	Endif;
		
EndProcedure

&AtClient
Procedure TabDocumentDecryptionProcessing(Element, Details, StandardProcessing)
	
	StandardProcessing 	= False;
	If Details <> Undefined AND Details.Details = "TurnDr" Then
		
		If Details.Type = "+" Then 
			Alert = New NotifyDescription("ToChooseFromMenuListPeriodEnd", ThisForm);
			ShowChooseFromMenu(Alert, ListMenu, Element);
		Elsif Details.Type = "-" Then
			ProcessingTableCell(Details, StandardProcessing);
		Endif;
			
	Else 
		ProcessingTableCell(Details, StandardProcessing);
		
		AdditionalParameters = New Structure;
		AdditionalParameters.Insert("Details", Details);
		Alert = New NotifyDescription("ProcessingOfDecodingCompletion", ThisForm, AdditionalParameters);
		ShowChooseFromMenu(Alert, ListMenu, Element);
		
	Endif;
EndProcedure

&AtServer
Procedure AddValueInSelection(Filter, LeftValue, ComparisonType, RightValue)
	
	FilterItem = Filter.Items.Add(Type("DataCompositionFilterItem"));
	
	FilterItem.LeftValue    = LeftValue;
	FilterItem.ComparisonType     = ComparisonType;
	FilterItem.RightValue   = RightValue;
	FilterItem.Use    = True;
	FilterItem.ViewMode = DataCompositionSettingsItemViewMode.QuickAccess;
	
EndProcedure

&AtServer
Procedure AddSelectionToSettingsDCS(UserSettings, GeneralSelection, NameOfSelection)
	
	FilterDCS = UserSettings.Items.Add(Type("DataCompositionFilter"));
	FilterDCS.UserSettingID = NameOfSelection;
	For each StrToFilter in GeneralSelection Do
		
		If TypeOf(StrToFilter.Value) = Type("ValueList") Then
			ComparisonTypeFilter = DataCompositionComparisonType.InList; 
		Elsif ChartsOfAccounts.AllRefsType().ContainsType(TypeOf(StrToFilter.Value))
			OR Catalogs.AllRefsType().ContainsType(TypeOf(StrToFilter.Value)) AND ValueIsFilled(StrToFilter.Value) AND Groups Then
			ComparisonTypeFilter = DataCompositionComparisonType.InHierarchy; 
		Else	
			ComparisonTypeFilter = DataCompositionComparisonType.Equal;
		Endif;
		
		DataCompositionField = New DataCompositionField(StrToFilter.Key);
		AddValueInSelection(FilterDCS, DataCompositionField, ComparisonTypeFilter, StrToFilter.Value);
	EndDo;
	
EndProcedure

&AtServer
Procedure ProcessingTableCell(DetailsCell, StandardProcessing) Export
	Var Account, BalancedAccount;
	
	NP 				= GetFromTempStorage(AddressStorage);
	StringTable 	= ProcessingCellTable_FindStringToDetails(DetailsCell.NumStr, NP.TabNew); 
	If DetailsCell.Details = "TurnDr" Then
		If StringTable <> Undefined Then
			StringTable.TurnDr 			= "+";
			StringTable.TabTurn 			= Undefined;
			StringTable.IndicatorRegister 	= "";
			StringTable.НandTurn 		= False;
			FoundStory = NP.SettingsTurns.Find(StringTable.Filter, "Value");
			If FoundStory <> Undefined Then
				NP.SettingsTurns.Delete(FoundStory);
				RemoveAllReversalsByOwner(StringTable.Filter);
			Endif;
			Generate(False);
		Endif;
	Elsif DetailsCell.Details = "Details" OR DetailsCell.Details = "DetailsTurnoverDr"
		OR DetailsCell.Details = "DetailsTurnoverCr" OR DetailsCell.Details = "DetailsStr" Then
		If StringTable <> Undefined Then
			Filter = ValueFromStringInternal(StringTable.Filter);
			
			If TypeOf(Filter) <> Type("ValueTable") Then
				Filter = ToCreateFilter();
			Endif;           
			GetPresentationFilter(Filter, "Account", 		Account);
			GetPresentationFilter(Filter, "BalancedAccount", 	BalancedAccount);
			
			DetailsCell.Insert("ValueOfDecryption", StringTable.Value);
			If ValueIsFilled(StringTable.Value) AND TypeOf(StringTable.Value) <> Type("String") 
				AND TypeOf(StringTable.Value) <> Type("Boolean") AND TypeOf(StringTable.Value) <> Type("Number") AND TypeOf(StringTable.Value) <> Type("DATE") Then
				NameOfMetadata = StringTable.Value.Metadata().Name;
			Else	
				NameOfMetadata = "";
			Endif;
			DetailsCell.Insert("NameOfMetadata", NameOfMetadata);
		
			IdConfiguration 			= "";
			If Metadata.CommonModules.Find("РегламентированнаяОтчетностьПереопределяемый") = Undefined Then
				РегламентированнаяОтчетностьПереопределяемый = Undefined;	
			Endif;
			Try
				IdConfiguration 			= РегламентированнаяОтчетностьПереопределяемый.ИДКонфигурации();
			Except
			EndTry;	
			ListMenu.Clear();
			
			If IdConfiguration = "БПКОРП" OR IdConfiguration = "БП" OR IdConfiguration = "УП2" OR IdConfiguration = "КА2" OR IdConfiguration = "БухгалтерияДляБеларуси" Then
	
				ListMenu.Add("ОтчетПоПроводкам", 	"Отчет по проводкам " + String(Account),, Items.DecorationReportOnTransactions.Picture);
				If BalancedAccount = Undefined Then
					ListMenu.Add("КарточкаСчета", 						"Карточка счета " + String(Account),, Items.DecorationCardAccount.Picture);
					ListMenu.Add("ОборотноСальдоваяВедомостьПоСчету", 	"ОСВ по счету " + String(Account),, Items.DecorationTBS.Picture);
					ListMenu.Add("АнализСчета",   						"Анализ счета " + String(Account),, Items.DecorationAccountsAnalysis.Picture);
				Endif;
				If NOT (Month(NP.Date1) = Month(NP.Date2) AND Year(NP.Date1) = Year(NP.Date2)) OR (NP.Date1 = '00010101' AND NP.Date2 = '00010101') Then
					ListMenu.Add("ОборотыСчетаПоМесяцам",  				"Оборoты счета " + String(Account) + " по месяцам",, Items.DecorationAccountTurns.Picture);
				Endif;
				ListMenu.Add("ОборотыСчетаПоДням", 	"Оборoты счета " + String(Account) + " по дням",, Items.DecorationAccountTurns.Picture);
					
				DetailsCell.Insert("UserSettings", New DataCompositionUserSettings);
	
				For each StrChange in NP._TVDimensions Do
					If ValueIsFilled(StrChange.Value) Then
						If TypeOf(StrChange.Value) = Type("ValueList") AND StrChange.Value.Count() > 0 Then
							DetailsCell.UserSettings.AdditionalProperties.Insert(StrChange.Name, 	StrChange.Value[0].Value);
						Else
							DetailsCell.UserSettings.AdditionalProperties.Insert(StrChange.Name, 	StrChange.Value);
						Endif;
						FindThecut = Filter.Find(StrChange.Name, "KeySearch");
						If FindThecut<>Undefined AND ValueIsFilled(FindThecut.Value) Then
							DetailsCell.UserSettings.AdditionalProperties.Insert(FindThecut.KeySearch, 	FindThecut.Value);
						Endif;
					Endif;
				EndDo;
				For each Str in Filter Do
					If Find(Str.KeySearch, ".") = 0 AND NOT DetailsCell.UserSettings.AdditionalProperties.Property(Str.KeySearch) AND Find(Str.KeySearch, "ExtDimension") = 0 
						AND Find(Str.KeySearch, "Account") = 0 AND ValueIsFilled(Str.Value) Then
						DetailsCell.UserSettings.AdditionalProperties.Insert(Str.KeySearch, 	Str.Value);
					Endif;
				EndDo;
	
				DetailsCell.UserSettings.AdditionalProperties.Insert("НачалоПериода", 	NP.Date1);
				DetailsCell.UserSettings.AdditionalProperties.Insert("КонецПериода", 	NP.Date2);
				DetailsCell.UserSettings.AdditionalProperties.Insert("счет", 			Account);
				
				DetailsCell.UserSettings.AdditionalProperties.Insert("Поcубсчетам", True);
	
				DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательБУ", 			False);
				DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательНУ", 			False);
				DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательПР",			False);
				DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательВР",			False);
				DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательКонтроль",		False);
				DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательВалютнаяСумма", False);
				DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательКоличество",	False);
				
				For each StrRes in NP.TVResourcesFilter Do
					If StrRes.ShortName = "БУ" OR StrRes.Name = "[Сумма]" Then
						DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательБУ", True);
					Elsif StrRes.ShortName = "НУ" OR StrRes.Name = "[СуммаНУ]" Then
						DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательНУ", True);
					Elsif StrRes.ShortName = "ПР" OR StrRes.Name = "[СуммаПР]" Then
						DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательПР", True);
					Elsif StrRes.ShortName = "ВР" OR StrRes.Name = "[СуммаВР]" Then
						DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательВР", True);
					Elsif StrRes.ShortName = "Контр." Then
						DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательКонтроль", True);
					Elsif StrRes.ShortName = "Вал." OR StrRes.Name = "[ВалютнаяСумма]" Then
						DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательВалютнаяСумма", True);
					Elsif StrRes.ShortName = "Кол." OR StrRes.Name = "[Количество]" Then
						DetailsCell.UserSettings.AdditionalProperties.Insert("ПоказательКоличество", True);
					Endif;	
				EndDo;
				                                                                         
				FilterOnTransactions 	= New Map;
				GeneralSelection 			= New Map;
				
				PrefScore	= "";
				PrefBalancedAccount = "";
				If DetailsCell.Details = "DetailsTurnoverDr" OR DetailsCell.Details = "DetailsTurnoverCr" Then
					PrefScore	= ?(DetailsCell.Details = "DetailsTurnoverDr", "Дт", "Кт");
					PrefBalancedAccount = ?(DetailsCell.Details = "DetailsTurnoverCr", "Дт", "Кт");
					If BalancedAccount <> Undefined Then
						FilterOnTransactions.Insert("счет" + PrefBalancedAccount, BalancedAccount);
					Endif;
				Else	
					If BalancedAccount <> Undefined Then
						FilterOnTransactions.Insert("Корсчет", BalancedAccount);
					Endif;
				Endif;
				
				FilterOnTransactions.Insert("счет" + PrefScore, 	Account);
		
				For each Str in Filter Do
					If Find(Str.KeySearch,"ExtDimension")<>0 Then
						If Find(Str.KeySearch,"BalancedExtDimension")<>0 Then
							If DetailsCell.Details = "DetailsTurnoverDr" OR DetailsCell.Details = "DetailsTurnoverCr" Then
								KeySearch = StrReplace(Str.KeySearch, "BalancedExtDimension", "субконто" + PrefBalancedAccount);
							Else
								KeySearch = StrReplace(Str.KeySearch, "BalancedExtDimension", "Корсубконто");
							Endif;
						Else
							KeySearch = StrReplace(Str.KeySearch, "ExtDimension", "субконто" + PrefScore);
						Endif;
						If FilterOnTransactions[KeySearch] = Undefined Then
							FilterOnTransactions.Insert(KeySearch, Str.Value);
						Endif;
					Elsif Find(Str.KeySearch,"Подразделение")<>0 Then
						KeySearch = StrReplace(Str.KeySearch, "Подразделение", "Подразделение" + PrefScore);
						If FilterOnTransactions[KeySearch] = Undefined Then
							FilterOnTransactions.Insert(KeySearch, Str.Value);
						Endif;
					Elsif Find(Str.KeySearch,"Валюта")<>0 Then
						KeySearch = StrReplace(Str.KeySearch, "Валюта", "Валюта" + PrefScore);
						If FilterOnTransactions[KeySearch] = Undefined Then
							FilterOnTransactions.Insert(KeySearch, Str.Value);
						Endif;
					Endif;
					
					If Find(Str.KeySearch, "Peeriod") > 0 Then
						PeriodType 	= Mid(Str.KeySearch, Find(Str.KeySearch + ".", ".") + 1);
						mDate1 		= BegOfDay(Str.Value);
						mDate2 		= BegOfDay(Str.Value);
						If PeriodType = "Year" 			Then mDate2 = EndOfYear(Str.Value);
						Elsif PeriodType = "Quarter" 	Then mDate2 = EndOfQuarter(Str.Value);
						Elsif PeriodType = "Month" 		Then mDate2 = EndOfMonth(Str.Value); 
						Elsif PeriodType = "TenDays" 	Then mDate2 = PeriodBorder(Str.Value, "TENDAYS", "ENDOFPERIOD"); 
						Elsif PeriodType = "Week" 	Then mDate2 = EndOfWeek(Str.Value); 
						Elsif PeriodType = "Day" 		Then mDate2 = EndOfDay(Str.Value);
						Endif;
						DetailsCell.UserSettings.AdditionalProperties.Insert("НачалоПериода", 	mDate1);
						DetailsCell.UserSettings.AdditionalProperties.Insert("КонецПериода", 	mDate2);
					Elsif Find(Str.KeySearch, "Account") = 0 Then 
						If Find(Str.KeySearch,"BalancedExtDimension")<>0 Then
							KeySearch = StrReplace(Str.KeySearch, "BalancedExtDimension", "Корсубконто");
						Else
							KeySearch = StrReplace(Str.KeySearch, "ExtDimension", "субконто");
						Endif;
						GeneralSelection.Insert(KeySearch, Str.Value);
					Endif;
					
				EndDo;
								
				If ValueIsFilled(BalancedAccount) Then
					GeneralSelection.Insert("Корсчет", BalancedAccount);
				Endif;
				
				AddSelectionToSettingsDCS(DetailsCell.UserSettings, GeneralSelection, "Отбор");
				
				AddSelectionToSettingsDCS(DetailsCell.UserSettings, FilterOnTransactions, "FilterOnTransactions");
		
			Endif;
			If DetailsCell.Details = "DetailsStr" AND ValueIsFilled(StringTable.Value) Then
				If Catalogs.AllRefsType().ContainsType(TypeOf(StringTable.Value)) Then
					ListMenu.Add("<open>", 		"Открыть эл-т """ + String(StringTable.Value) + """",,Items.DecorationElement.Picture);
					ListMenu.Add("<accesslist>", 	"Открыть эл-т """ + String(StringTable.Value) + """ в списке",,Items.DecorationCatalog.Picture);
				Elsif Documents.AllRefsType().ContainsType(TypeOf(StringTable.Value)) Then
					ListMenu.Add("<open>", 		"Открыть док. """ + String(StringTable.Value) + """",,Items.DecorationDocument.Picture);
					ListMenu.Add("<accessjournal>", "Открыть док. """ + String(StringTable.Value) + """ в журнале",,Items.DecorationJournals.Picture);
				Endif;
			Endif;
		Endif;
	Endif;
EndProcedure 

&AtServer
Procedure LimitAndBreakTVResources()

	NP.Insert("TVResourcesFilter", NP.TVResources.Copy());
	NP.TVResourcesFilter.Clear();
	NP.Insert("TVIndicators", NP.TVResourcesFilter.Copy());
	NP.TVIndicators.Columns.Add("NumberOwner", New TypeDescription("String"));
	AccountingReg 				= Metadata.AccountingRegisters[NP.NameAccountingRegister];
	For each Resource in NP.TVResources Do
		If NOT Resource.Use Then
			Continue;	
		Endif;
		NewResource = NP.TVResourcesFilter.Add();
		FillPropertyValues(NewResource, Resource);
		NewResource.NameFormula   	= Resource.Name;
		NewResource.LineNumber 	= "P" + NewResource.LineNumber;
 		ArrayArguments 		= ObtainArrayArguments(NewResource.Name, AccountingReg);
			
		For each Argument in ArrayArguments Do
			NewIndicator 	= NP.TVIndicators.Add();		
			ResourceMeth 		= AccountingReg.Resources.Find(Argument);
			FillPropertyValues(NewIndicator, NewResource);
			If ResourceMeth <> Undefined Then
				NewIndicator.Balance 			= ResourceMeth.Balance;
 				NewIndicator.AccountingFlag 			= ?(ResourceMeth.AccountingFlag <> Undefined, ResourceMeth.AccountingFlag.Name, "");
 				NewIndicator.ExtDimensionAccountingFlag 	= ?(ResourceMeth.ExtDimensionAccountingFlag <> Undefined, ResourceMeth.ExtDimensionAccountingFlag.Name, "");
				NewIndicator.Synonym 				= ResourceMeth.Synonym;
			Endif;
			NewIndicator.Name 				= Argument;
			NewIndicator.NumberOwner	= NewIndicator.LineNumber;
			NewIndicator.LineNumber 		= NewIndicator.LineNumber + NewIndicator.Name;
			NewIndicator.Use 	= True;
		EndDo;
	EndDo;
	
EndProcedure

&AtClient
Procedure TabDocumentWhenYouActivateArea(Element)
	If TypeOf(TabDocument.SelectedAreas) = Type("SpreadsheetDocumentSelectedAreas") Then
		TimeoutInterval = ?(GetClientConnectionSpeed() = ClientConnectionSpeed.Low, 1, 0.2);
		AttachIdleHandler("PlugIn_ResultOfRevitalizationOfAreaOfPlug", TimeoutInterval, True);
	Endif;
	
	DetailsCell = Element.CurrentArea.Details;
	If DetailsCell <> Undefined AND DetailsCell.Details = "TurnDr" Then
		AttachIdleHandler("CreateContextMenuAtClient", 0.1, True);
	Endif;
		
EndProcedure

&AtClient
Procedure CreateContextMenuAtClient() Export
	CreateContextMenu();	
EndProcedure

&AtServer
Procedure CreateContextMenu() Export
	Var Account, BalancedAccount, SearchValues, ValBalanced;
	NP = GetFromTempStorage(AddressStorage);
	
	RemoveMenuItems();
	
	ActivationArea 	= Items.TabDocument.CurrentArea;
	DetailsCell 		= ActivationArea.Details;
	NumStringCurrent	= DetailsCell.NumStr;
	StringTable 		= ProcessingCellTable_FindStringToDetails(NumStringCurrent, NP.TabNew); 
	If StringTable <> Undefined AND DetailsCell.Type = "+" Then
		Filter = ValueFromStringInternal(StringTable.Filter);
		If TypeOf(Filter) <> Type("ValueTable") Then
			Filter = ToCreateFilter();
		Endif;           
		
		TotalTurnover = 0;
		For each ColumnTV in NP.TabNew.Columns Do
			If Find(ColumnTV.Name, "Turnover") <> 0 Then
				TotalTurnover = TotalTurnover + StringTable[ColumnTV.Name];
			Endif;
		EndDo;
		IsRevolution 	= TotalTurnover <> 0;
		
		GetPresentationFilter(Filter, "Account", 		Account);
		GetPresentationFilter(Filter, "BalancedAccount", 	BalancedAccount);
		
		IsExtDimension 		= False;
		IsBalancedExtDimension 	= False;
		IsByTransactional		= False;
		IsByDocuments	= False;
		
		GroupContextMenu 		= Items.Insert("GroupTurn", Type("FormGroup"), Items.TabDocument.ContextMenu);
		GroupContextMenu.Type 	= FormGroupType.ButtonGroup;
		
		For each StrChange in NP._TVDimensions Do
			ValFilter 		= Undefined;
			IsAFilter 		= GetPresentationFilter(Filter, StrChange.Name, ValFilter);
			CommonSymptom 	= (StrChange.AccountingFlag = "" AND (NOT ValueIsFilled(StrChange.Value) 
			OR TypeOf(StrChange.Value) = Type("ValueList")) AND (NOT IsAFilter OR TypeOf(ValFilter) = Type("ValueList")));
			
			If StrChange.Balance Then
				AdditionalSymptom 		= (StrChange.AccountingFlag <> "" AND (NOT IsAFilter OR TypeOf(ValFilter) = Type("ValueList"))) 
				AND ((Account <> Undefined AND IsSlitAccounting(Account, StrChange))OR(BalancedAccount<>Undefined AND IsSlitAccounting(BalancedAccount, StrChange)));	
				
				If CommonSymptom OR AdditionalSymptom Then
					ProcessingCellTable_AddVariantRegister(StrChange.Name, StrChange.Name,,, "Разворот " + StrChange.Name, , GroupContextMenu, Items.DecorationCatalog.Picture);
				Endif;
			Else
				
				AdditionalSymptom 		= (StrChange.AccountingFlag <> "" AND (NOT IsAFilter OR TypeOf(ValFilter) = Type("ValueList"))) 
				AND ((Account <> Undefined AND IsSlitAccounting(Account, StrChange)));	
				
				If CommonSymptom OR AdditionalSymptom Then
					ProcessingCellTable_AddVariantRegister(StrChange.Name, StrChange.Name,,, "Разворот " + StrChange.Name, , GroupContextMenu, Items.DecorationCatalog.Picture);
				Endif;
				
				ValFilter 		= Undefined;
				IsAFilter 		= GetPresentationFilter(Filter, StrChange.Name + "Balanced", ValFilter);
				CommonSymptom 	= (StrChange.AccountingFlag = "" AND (NOT ValueIsFilled(StrChange.Value) 
				OR TypeOf(StrChange.Value) = Type("ValueList")) AND (NOT IsAFilter OR TypeOf(ValFilter) = Type("ValueList")));
				
				AdditionalSymptomBalanced 	= (StrChange.AccountingFlag <> "" AND (NOT IsAFilter OR TypeOf(ValFilter) = Type("ValueList"))) 
				AND ((BalancedAccount <> Undefined AND IsSlitAccounting(BalancedAccount, StrChange)));	
				
				If (CommonSymptom OR AdditionalSymptomBalanced) AND BalancedAccount <> Undefined AND IsRevolution Then
					ProcessingCellTable_AddVariantRegister(StrChange.Name + "Balanced", StrChange.Name,,, "Коp. разворот " + StrChange.Name, , GroupContextMenu, Items.DecorationCatalog.Picture);
				Endif;
				
			Endif;	
		EndDo;
		
		GroupContextMenu 		= Items.Insert("GroupAccount", Type("FormGroup"), Items.TabDocument.ContextMenu);
		GroupContextMenu.Type 	= FormGroupType.ButtonGroup;
		
		If Account = Undefined OR TypeOf(Account) = Type("Array") Then
			ProcessingCellTable_AddVariantRegister("Account", "Account",,, "Разворот Счета/субсчета", , GroupContextMenu, Items.DecorationAccount.Picture)
		Else
			If (NP.TVAccountsOfParents.Find(Account) <> Undefined) AND (NOT DataOnSubAccounts OR StringTable.Indicator <> "Account") Then
				ProcessingCellTable_AddVariantRegister("Account", "Account",,, "Разворот Счета/субсчета", Account, GroupContextMenu, Items.DecorationAccount.Picture)
			Endif;
			If NP.ExtDimensionTypeName <> "" Then
				For Identifier = 0 To Account.ExtDimensionTypes.Count()-1 Do
					IsExtDimension 	= True;
					Vl 				= Undefined;
					GetPresentationFilter(Filter, "ExtDimension" + String(Identifier + 1), 	Vl);
					Res = (Vl = Undefined) OR (TypeOf(Vl) = Type("ValueList"));
					If NOT Res AND ValueIsFilled(Vl) AND Catalogs.AllRefsType().ContainsType(TypeOf(Vl)) Then 
						ValMet = Vl.Metadata();
						Res = Vl.IsFolder OR (ValMet.Hierarchical AND ValMet.HierarchyType = Metadata.ObjectProperties.HierarchyType.HierarchyOfItems); 
					Endif;    
					If Res Then
						TypeIndicator 	= Account.ExtDimensionTypes[Identifier].ExtDimensionType.Description;
						ProcessingCellTable_AddVariantRegister("ExtDimension" + String(Identifier + 1), TypeIndicator,,, "Разворот субконто «" + Account.ExtDimensionTypes[Identifier].ExtDimensionType.Description + "»", Vl, GroupContextMenu, Items.DecorationExtDimension.Picture);
					Endif;
				EndDo;
			Endif;
		Endif;
		
		If IsRevolution AND BalancedAccount = Undefined OR TypeOf(Account) = Type("Array") Then
			ProcessingCellTable_AddVariantRegister("BalancedAccount", "Account",,, "Коp. разворот Счета/субсчета", , GroupContextMenu, Items.DecorationAccount.Picture);
		Elsif IsRevolution Then
			If (NP.TVAccountsOfParents.Find(BalancedAccount) <> Undefined) AND (NOT DataOnSubAccounts OR (StringTable.Indicator <> "BalancedAccount")) Then
				ProcessingCellTable_AddVariantRegister("BalancedAccount", "Account",,, "Коp. разворот Счета/субсчета", BalancedAccount, GroupContextMenu, Items.DecorationAccount.Picture);
			Endif; 				
			
			If NP.ExtDimensionTypeName <> "" Then
				For Identifier = 0 To BalancedAccount.ExtDimensionTypes.Count()-1 Do
					IsBalancedExtDimension = True;
					ValBalanced = Undefined;
					GetPresentationFilter(Filter, "BalancedExtDimension" + String(Identifier + 1), ValBalanced);
					Res = (ValBalanced = Undefined) OR (TypeOf(ValBalanced) = Type("ValueList"));
					If NOT Res AND ValueIsFilled(ValBalanced) AND Catalogs.AllRefsType().ContainsType(TypeOf(ValBalanced)) Then 
						Res = ValBalanced.IsFolder; 
					Endif;    
					If Res Then
						TypeIndicator 	= BalancedAccount.ExtDimensionTypes[Identifier].ExtDimensionType.Description;
						ProcessingCellTable_AddVariantRegister("BalancedExtDimension" + String(Identifier + 1), TypeIndicator,,, "Коp. разворот субконто «" + BalancedAccount.ExtDimensionTypes[Identifier].ExtDimensionType.Description + "»", ValBalanced, GroupContextMenu, Items.DecorationExtDimension.Picture);
					Endif;
				EndDo;
			Endif;
		Endif;
		
		GroupContextMenu 		= Items.Insert("PeriodsGroup", Type("FormGroup"), Items.TabDocument.ContextMenu);
		GroupContextMenu.Type 	= FormGroupType.ButtonGroup;
		
		If IsRevolution Then
			
			IsByDocuments 	= GetPresentationFilter(Filter, "Recorder");
			IsByTransactional 	= GetPresentationFilter(Filter, "Еntry.Briefly");
			IsByTransactional 	= GetPresentationFilter(Filter, "Еntry.Detail") OR IsByTransactional;
			
			IsByDays 			= NOT GetPresentationFilter(Filter, "Peeriod.Day");
			IsByWeeks 		= NOT GetPresentationFilter(Filter, "Peeriod.Week") 	AND IsByDays;
			IsByDecades 		= NOT GetPresentationFilter(Filter, "Peeriod.TenDays") 	AND IsByWeeks 	AND IsByDays;
			IsByMonths 		= NOT GetPresentationFilter(Filter, "Peeriod.Month") 	AND IsByDecades 	AND IsByWeeks AND IsByDays;
			IsByQuarterly		= NOT GetPresentationFilter(Filter, "Peeriod.Quarter") 	AND IsByMonths 	AND IsByDecades AND IsByWeeks AND IsByDays;
			IsByYears 		= NOT GetPresentationFilter(Filter, "Peeriod.Year") 		AND IsByQuarterly 	AND IsByMonths AND IsByDecades AND IsByWeeks AND IsByDays;
			IsByProperties     = False;
			For each StrFilter in Filter Do
				If Find(StrFilter.KeySearch, "ExtDimension")<>0 AND Find(StrFilter.KeySearch, "Value")<>0 Then
					IsByProperties     = True;
					Break;
				Endif;	
			EndDo;
			If IsByTransactional OR IsByDocuments Then
				RemoveMenuItems(Items.TabDocument.ContextMenu);
			Endif;
			
			GroupContextMenu 		= Items.Insert("PeriodsGroupTurnover", Type("FormGroup"), Items.TabDocument.ContextMenu);
			GroupContextMenu.Type 	= FormGroupType.ButtonGroup;
			
			Popup 			= Items.Insert("GroupUnderMenuPeriod", Type("FormGroup"), GroupContextMenu);
			Popup.Type 		= FormGroupType.Popup;
			Popup.Title 	= "Периoд";
			Popup.Picture 	= Items.DecorationPeriod.Picture;
			
			If BegOfYear(NP.Date2) > EndOfYear(NP.Date1) AND IsByYears Then 
				ProcessingCellTable_AddVariantRegister("Peeriod.Year", "Period",,, "Разворот Годы", SearchValues, Popup, Items.DecorationYear.Picture);
			Endif;
			If BegOfQuarter(NP.Date2)>EndOfQuarter(NP.Date1) AND IsByQuarterly Then 
				ProcessingCellTable_AddVariantRegister("Peeriod.Quarter", "Period",,, "Разворот Кварталы", SearchValues, Popup, Items.DecorationQuarter.Picture);
			Endif;
			If BegOfMonth(NP.Date2) > EndOfMonth(NP.Date1) AND IsByMonths Then	
				ProcessingCellTable_AddVariantRegister("Peeriod.Month", "Period",,, "Разворот Месяцы", SearchValues, Popup, Items.DecorationMonth.Picture);
			Endif;
			If (BegOfMonth(NP.Date2) > EndOfMonth(NP.Date1) OR 
				(Min(Int((Day(NP.Date2)-1)/10),2) > Min(Int((Day(NP.Date1)-1)/10),2)))AND IsByDecades Then 
				ProcessingCellTable_AddVariantRegister("Peeriod.TenDays", "Period",,, "Разворот Декады", SearchValues, Popup, Items.DecorationDecade.Picture);
			Endif;
			If BegOfWeek(NP.Date2) > EndOfWeek(NP.Date1) AND IsByWeeks Then	
				ProcessingCellTable_AddVariantRegister("Peeriod.Week", "Period",,, "Разворот Недели", SearchValues, Popup, Items.DecorationWeek.Picture);
			Endif;
			If BegOfDay(NP.Date2) > EndOfDay(NP.Date1) AND IsByDays Then 
				ProcessingCellTable_AddVariantRegister("Peeriod.Day", "Period",,, "Разворот Дни", SearchValues, Popup, Items.DecorationDay.Picture);
			Endif;
			
			If IsByTransactional Then
				RemoveMenuItems(Popup);
				ListMenu.Clear();
			Elsif IsByDocuments Then
				RemoveMenuItems(Popup);
				
				ListMenu.Clear();
				If NOT IsByProperties Then
					ProcessingCellTable_AddVariantRegister("Еntry.Briefly", "Еntry",,, "Разворот Проводки", SearchValues, Popup, Items.DecorationEntry.Picture);
					ProcessingCellTable_AddVariantRegister("Еntry.Detail", "Еntry",,, "Разворот Проводки (подробно)", SearchValues, Popup, Items.DecorationEntry.Picture);
				Endif;
			Else
				GroupUnderMenu 		= Items.Insert("GroupUnderMenu", Type("FormGroup"), Popup);
				GroupUnderMenu.Type 	= FormGroupType.ButtonGroup;
				ProcessingCellTable_AddVariantRegister("Recorder", "Recorder",,, "Разворот Документы", SearchValues, GroupUnderMenu, Items.DecorationDocument.Picture);
				If NOT IsByProperties Then
					ProcessingCellTable_AddVariantRegister("Еntry.Briefly", "Еntry",,, "Разворот Проводки", SearchValues, GroupUnderMenu, Items.DecorationEntry.Picture);
					ProcessingCellTable_AddVariantRegister("Еntry.Detail", "Еntry",,, "Разворот Проводки (подробно)", SearchValues, GroupUnderMenu, Items.DecorationEntry.Picture);
				Endif;
			Endif;
			If Popup.ChildItems.Count() = 0 Then
				Items.Delete(Popup);	
			Endif;
			
		Endif;
		
		If (IsExtDimension OR IsBalancedExtDimension) AND (NOT IsByTransactional AND NOT IsByDocuments) Then
			GroupContextMenu 		= Items.Insert("GroupMenuControl", Type("FormGroup"), Items.TabDocument.ContextMenu);
			GroupContextMenu.Type 	= FormGroupType.ButtonGroup;
			
			Command 			= Commands.Add("MultilevelReversal");
			Button 				= Items.Insert("MultilevelReversal", Type("FormButton"), GroupContextMenu);
			Command.Action 	= "RunMenu";
			Button.Title 	= "Многоуровневый разворот ...";
			Button.CommandName 	= "MultilevelReversal";
			Button.Picture 	= Items.DecorationMultilevelReversal.Picture;
			
			ListMenu.Add("MultilevelReversal", "Многоуровневый разворот ...",,Items.DecorationMultilevelReversal.Picture);
		Endif;
		
		If (IsExtDimension OR IsBalancedExtDimension) AND (NOT IsByTransactional AND NOT IsByDocuments) Then
			Command 			= Commands.Add("SettingsTurns");
			Button 				= Items.Insert("SettingsTurns", Type("FormButton"), GroupContextMenu);
			Command.Action 	= "RunMenu";
			Button.Title 	= "< настройка ... >";
			Button.CommandName 	= "SettingsTurns";
			Button.Picture 	= Items.DecorationSetup.Picture;
			
			ListMenu.Add("SettingsTurns", "< настройка ... >",,Items.DecorationMultilevelReversal.Picture);
		Endif;
		
	Endif;
 	AddressNum								= Number(Mid(StringTable.Address, 2, Find(StringTable.Address, "C")-2));
	Items.TabDocument.CurrentArea 	= TabDocument.Area(AddressNum, Min(StringTable.Level, 7) + 1);
	
EndProcedure

&AtServer
Procedure RemoveMenuItems(Val Menu = Undefined)
	
	If Menu = Undefined Then
		Menu = Items.TabDocument.ContextMenu;
	Endif;
	ListMenu.Clear();
	IndexOf = Menu.ChildItems.Count() - 1; 
	While IndexOf >= 0 Do 
		
		MenuButton = Menu.ChildItems[IndexOf];
		If TypeOf(MenuButton) = Type("FormGroup") Then
			RemoveMenuItems(MenuButton);
		Endif;
		
		CommandToRemove = Commands.Find(MenuButton.Name);
		If CommandToRemove<>Undefined Then
			Commands.Delete(CommandToRemove);	
		Endif;
		
		Items.Delete(MenuButton);
		IndexOf = IndexOf - 1; 
		
	EndDo;
	
EndProcedure

&AtServer
Function ProcessingCellTable_FindStringToDetails(NumString, Tab) Export
	If TypeOf(Tab) = Type("ValueTable") Then
		For each StrTab in Tab Do
			If StrTab.DetString = NumString Then
				Return StrTab
			Endif;
			If StrTab.TurnDr = "-" Then
			    Res = ProcessingCellTable_FindStringToDetails(NumString, StrTab.TabTurn);
				If Res <> Undefined Then
					Return Res
				Endif;
			Endif;
		EndDo;
	Endif;
	Return Undefined
EndFunction

&AtServer
Procedure ProcessingCellTable_AddVariantRegister(Indicator, TypeIndicator, Attribute = Undefined, Custom = False, Text, Value = Undefined, GroupContextMenu, Icon)
	
	CommandName 			= Indicator + ?(ValueIsFilled(Attribute), "." + Attribute, "");
	CommandName 			= StrReplace(CommandName, ".", "WW");
	Command 			= Commands.Add(CommandName);
	Button 				= Items.Insert(CommandName, Type("FormButton"), GroupContextMenu);
	Command.Action 	= "RunMenu";
	Button.Title 	= Text;
	Button.CommandName 	= CommandName;
	Button.Picture 	= Icon;

	ListMenu.Add(Indicator + ?(ValueIsFilled(Attribute), "." + Attribute, ""), Text,,Icon);
	
EndProcedure

&AtClient
Function GetForbiddenFields() Export
	
	FieldList = New Array;
	
	FieldList.Add("UserFields");
	FieldList.Add("DataParameters");
	FieldList.Add("SystemFields");
	
	Return New FixedArray(FieldList);
	
EndFunction

&AtClient
Procedure RunMenu(Button)
	
	ButtonName = Button.Name;	
	
	If ButtonName <> "SettingsTurns" AND ButtonName <> "MultilevelReversal" Then
		
		MenuToRunAtServer(ButtonName);	
		
	Elsif ButtonName = "SettingsTurns" Then
		
		ParametersForm = New Structure;
		ParametersForm.Insert("Mode"					, "Выбор");
		ParametersForm.Insert("ExcludedFields"		, GetForbiddenFields());
		ParametersForm.Insert("AddressStorage"		, AddressStorage);
		ParametersForm.Insert("NumStringCurrent" 		, NumStringCurrent);
	
		NotificationOfClosure = New NotifyDescription("SettingsTurnEnd", ThisForm);
	
		OpenForm("Отчет.InteractiveTBS.Форма.FormSelectAvailableFields", ParametersForm, ThisForm,,,,NotificationOfClosure);
	
	Elsif ButtonName = "MultilevelReversal" Then
				
		ParametersForm = New Structure;
		ParametersForm.Insert("ExcludedFields"      	, GetForbiddenFields());
		ParametersForm.Insert("AddressStorage"       	, AddressStorage);
		ParametersForm.Insert("NumStringCurrent" 		, NumStringCurrent);
	
		NotificationOfClosure = New NotifyDescription("MultilevelReversalCompletion", ThisForm);
	
		OpenForm("Отчет.InteractiveTBS.Форма.FormMultiLevelReversalMgmt", ParametersForm, ThisForm,,,,NotificationOfClosure);
				
	Else
		Return;
	Endif;
	
EndProcedure

&AtServer
Procedure AfterRunMenuOnAtServer(StringTable)
	
	FoundStory = NP.SettingsTurns.Find(StringTable.Filter, "Value");
	If FoundStory <> Undefined Then
		NP.SettingsTurns.Delete(FoundStory);
	Endif;
	If (StringTable.TurnDr = "-") and StringTable.НandTurn Then
		NewString 				= NP.SettingsTurns.Add();
		NewString.Value 		= StringTable.Filter;
		TVFilter 					= ValueFromStringInternal(StringTable.Filter);
		If TVFilter.Count() <=1 Then
			TVFilter = Undefined;
		Else
			TVFilter.Delete(0);
			TVFilter = TVFilter.Copy();
		Endif;
		NewString.Owner 		= ValueToStringInternal(TVFilter);
		NewString.Presentation 	= StringTable.IndicatorRegister;
	Endif;
	Generate(False);	
	
EndProcedure

&AtServer
Procedure MenuToRunAtServer(ButtonName)
	Var Account, BalancedAccount;
	
	NP 				= GetFromTempStorage(AddressStorage);
	ButtonName 		= StrReplace(ButtonName, "WW", ".");
	StringTable 	= ProcessingCellTable_FindStringToDetails(NumStringCurrent, NP.TabNew); 
	
	Filter 			= ValueFromStringInternal(StringTable.Filter);
	If TypeOf(Filter) <> Type("ValueTable") Then
		Filter = ToCreateFilter();
	Endif;
	
	GetPresentationFilter(Filter, "Account", 		Account);
	GetPresentationFilter(Filter, "BalancedAccount", 	BalancedAccount);
	
	IsAttribute 	= Find(ButtonName, ".");
	Indicator 		= "";
	Attribute 		= "";
	If IsAttribute = 0 Then
		Indicator 	= ButtonName;
	Else
		Indicator 	= Left(ButtonName, IsAttribute - 1);
		Attribute 	= Mid(ButtonName, IsAttribute + 1);
	Endif;
	If Find(Indicator, "BalancedExtDimension")<>0 Then
		Number			= StrReplace(Indicator, "BalancedExtDimension", "");
		TypeIndicator 	= BalancedAccount.ExtDimensionTypes[Number(Number)-1].ExtDimensionType.Description;
	Elsif Find(Indicator, "ExtDimension")<>0 Then
		Number			= StrReplace(Indicator, "ExtDimension", "");
		TypeIndicator 	= Account.ExtDimensionTypes[Number(Number)-1].ExtDimensionType.Description;
	Else
		TypeIndicator 	= Indicator;
	Endif;
	StrSearch 		= New Structure("TypeIndicator, Attribute", TypeIndicator, Attribute);
	TypeTurn 	= Undefined;
	Expand(StringTable, ButtonName,, True,, TypeTurn);
	AfterRunMenuOnAtServer(StringTable);
	
EndProcedure

&AtServer
Procedure SettingsTurnAtServer(DevelopOn) Export
		
	If DevelopOn = Undefined Then 
		Return;
	Endif;
	
	If ValueIsFilled(DevelopOn.Field) AND Find(DevelopOn.Field, "[") = 0 AND Find(DevelopOn.Field, "]") = 0 Then
		NP 				= GetFromTempStorage(AddressStorage);
		StringTable 	= ProcessingCellTable_FindStringToDetails(DevelopOn.NumStringCurrent, NP.TabNew); 
		Expand(StringTable, DevelopOn.Field,, True,, DevelopOn.ValueType);
		AfterRunMenuOnAtServer(StringTable);	
	Else	
		Return;
	Endif;
	
EndProcedure

&AtClient
Procedure SettingsTurnEnd(ResultClosure, AdditionalParameters) Export
	
	ResultClosure = ?(ResultClosure	= DialogReturnCode.Cancel, Undefined, ResultClosure);
	SettingsTurnAtServer(ResultClosure);	
		
EndProcedure

&AtServer
Procedure MultilevelReversalOnAtServer(DevelopOn) Export
	
	
	If DevelopOn = Undefined Then 
		Return;
	Endif;
	
	If DevelopOn.ArrayOfSelectedFields.Count() > 0 Then
		NP 				= GetFromTempStorage(AddressStorage);
		StringTable 	= ProcessingCellTable_FindStringToDetails(DevelopOn.NumStringCurrent, NP.TabNew); 
		
		AdditionalTurn = New ValueList;
		AdditionalTurn.LoadValues(DevelopOn.ArrayOfSelectedFields);
		AdditionalTurn.Delete(0);
		Expand(StringTable, DevelopOn.ArrayOfSelectedFields[0].DataPath,, True, ?(AdditionalTurn.Count() = 0, Undefined, AdditionalTurn), DevelopOn.ArrayOfSelectedFields[0].ValueType);
		
		AfterRunMenuOnAtServer(StringTable);	
	Else	
		Return;
	Endif;
	
EndProcedure

&AtClient
Procedure MultilevelReversalCompletion(ResultClosure, AdditionalParameters) Export
	
	ResultClosure = ?(ResultClosure	= DialogReturnCode.Cancel, Undefined, ResultClosure);
	MultilevelReversalOnAtServer(ResultClosure);	
		
EndProcedure

&AtServer
Function СalculateAmountSpreadsheetDocumentSelectedAreas(Val Result, CacheSelectedAreas) Export
	
	SumCell = 0;
	For Each KeyAndValue in CacheSelectedAreas Do
		StructureAddressAllocatedArea = KeyAndValue.Value;
		For IndexOfString = StructureAddressAllocatedArea.Top To StructureAddressAllocatedArea.Bottom Do
			For IndexColumn = StructureAddressAllocatedArea.Left To StructureAddressAllocatedArea.Right Do
				Try
					Cell = Result.Area(IndexOfString, IndexColumn, IndexOfString, IndexColumn);
					If Cell.Visible = True Then
						If Cell.ContainsValue AND TypeOf(Cell.Value) = Type("Number") Then
							SumCell = SumCell + Cell.Value;
						Elsif ValueIsFilled(Cell.Text) Then
							SumCell = SumCell + Number(StrReplace(Cell.Text, " ", ""));
						Endif;
					Endif;
				Except
				EndTry;
			EndDo;
		EndDo;
	EndDo;
	
	CacheSelectedAreas.Insert("SumCell", SumCell);
	
	Return SumCell;
	
EndFunction

&AtServer
Procedure СalculateAmountSpreadsheetDocumentSelectedAreasAtServerInContext()
	
	AmountField = СalculateAmountSpreadsheetDocumentSelectedAreas(TabDocument, CacheAreas);
	
EndProcedure

&AtClient
Procedure PlugIn_ResultOfRevitalizationOfAreaOfPlug()
	
	YouMustCalculateAtServer = False;
	СalculateAmountSpreadsheetDocumentSelectedAreasAtClient(AmountField, TabDocument, CacheAreas, YouMustCalculateAtServer);
	
	If YouMustCalculateAtServer Then
		СalculateAmountSpreadsheetDocumentSelectedAreasAtServerInContext();
	Endif;
	
	DetachIdleHandler("PlugIn_ResultOfRevitalizationOfAreaOfPlug");
	
EndProcedure

&AtClient
Function NecessaryUpdateSum(Result, CacheSelectedAreas)
	Var StructureAddressAllocatedArea;
	
	SelectedAreas    = Result.SelectedAreas;
	NumberOfAllocated = SelectedAreas.Count();
	
	If NumberOfAllocated = 0 Then
		CacheSelectedAreas = New Structure();
		Return True;
	Endif;
	
	ReturnValue = False;
	If TypeOf(CacheSelectedAreas) <> Type("Structure") Then
		CacheSelectedAreas = New Structure();
		ReturnValue = True;
	Elsif SelectedAreas.Count() <> CacheSelectedAreas.Count() Then
		CacheSelectedAreas = New Structure();
		ReturnValue = True;
	Else
		For IndexOfArea = 0 To NumberOfAllocated - 1 Do
			SelectedArea = SelectedAreas[IndexOfArea];
			NameOfArea = StrReplace(SelectedArea.Name, ":", "_");
			CacheSelectedAreas.Property(NameOfArea, StructureAddressAllocatedArea);
			
			If TypeOf(StructureAddressAllocatedArea) <> Type("Structure") Then
				CacheSelectedAreas = New Structure();
				ReturnValue = True;
				Break;
			Endif;
		EndDo;
	Endif;
	
	For IndexOfArea = 0 To NumberOfAllocated - 1 Do
		SelectedArea = SelectedAreas[IndexOfArea];
		NameOfArea = StrReplace(SelectedArea.Name, ":", "_");
		
		If TypeOf(SelectedArea) <> Type("SpreadsheetDocumentRange") Then
			StructureAddressAllocatedArea = New Structure("Top, Bottom, Left, Right", 0, 0, 0, 0);
			CacheSelectedAreas.Insert(NameOfArea, StructureAddressAllocatedArea);
			ReturnValue = True;
			Continue;
		Endif;
		
		CacheSelectedAreas.Property(NameOfArea, StructureAddressAllocatedArea);
		If TypeOf(StructureAddressAllocatedArea) <> Type("Structure") Then
			StructureAddressAllocatedArea = New Structure("Top, Bottom, Left, Right", 0, 0, 0, 0);
			CacheSelectedAreas.Insert(NameOfArea, StructureAddressAllocatedArea);
			ReturnValue = True;
		Endif;
		
		If StructureAddressAllocatedArea.Top <> SelectedArea.Top
			OR StructureAddressAllocatedArea.Bottom <> SelectedArea.Bottom
			OR StructureAddressAllocatedArea.Left <> SelectedArea.Left
			OR StructureAddressAllocatedArea.Right <> SelectedArea.Right Then
				StructureAddressAllocatedArea = New Structure("Top, Bottom, Left, Right",
					SelectedArea.Top, SelectedArea.Bottom, SelectedArea.Left, SelectedArea.Right);
				CacheSelectedAreas.Insert(NameOfArea, StructureAddressAllocatedArea);
				ReturnValue = True;
		Endif;
		
	EndDo;
	
	Return ReturnValue;
	
EndFunction

&AtClient
Procedure СalculateAmountSpreadsheetDocumentSelectedAreasAtClient(AmountField, Result, CacheSelectedAreas, YouMustCalculateAtServer) Export
	
	If NecessaryUpdateSum(Result, CacheSelectedAreas) Then
		AmountField = 0;
		NumberOfAllocatedAreas = CacheSelectedAreas.Count();
		If NumberOfAllocatedAreas = 0
			OR CacheSelectedAreas.Property("T")
			Then
			CacheSelectedAreas.Insert("SumCell", 0);
		Elsif NumberOfAllocatedAreas = 1 Then
		
			For each KeyAndValue in CacheSelectedAreas Do
				StructureAddressAllocatedArea = KeyAndValue.Value;
			EndDo;
			
			SizeOfAreaVertically   = StructureAddressAllocatedArea.Bottom   - StructureAddressAllocatedArea.Top;
			SizeOfAreaHorizontally = StructureAddressAllocatedArea.Right - StructureAddressAllocatedArea.Left;
			
			EvalAtClient = (SizeOfAreaVertically + SizeOfAreaHorizontally) < 12;
			If EvalAtClient Then
				AmountInCells = 0;
				For IndexOfString = StructureAddressAllocatedArea.Top To StructureAddressAllocatedArea.Bottom Do
					For IndexColumn = StructureAddressAllocatedArea.Left To StructureAddressAllocatedArea.Right Do
						Try
							Cell = Result.Area(IndexOfString, IndexColumn, IndexOfString, IndexColumn);
							If Cell.Visible = True Then
								If Cell.ContainsValue AND TypeOf(Cell.Value) = Type("Number") Then
									AmountInCells = AmountInCells + Cell.Value;
								Elsif ValueIsFilled(Cell.Text) Then
									NumberInCell  = Eval("Number(StrReplace(Cell.Text, Char(32), Char(0)))");
									AmountInCells = AmountInCells + NumberInCell;
								Endif;
							Endif;
						Except
						EndTry;
					EndDo;
				EndDo;
				
				AmountField = AmountInCells;
				CacheSelectedAreas.Insert("SumCell", AmountField);
			Else
				YouMustCalculateAtServer = True;
			Endif;
		Else
			YouMustCalculateAtServer = True;
		Endif;
	Else	
		AmountField = CacheSelectedAreas.SumCell;
	Endif;
	
EndProcedure

&AtServer
Procedure HideSettingsWhenFormingReport() Export
	
	PanelSettings       = ThisForm.Items.GroupPanelSettings;
	ButtonSettingsPanel = ThisForm.Items.PanelSettings;
	
	If HideSettingsWhenGeneratingReport Then
		PanelSettings.Visible = False;
		If ButtonSettingsPanel <> Undefined Then
			ChangeButtonHeadingPanelSettings(ButtonSettingsPanel, False);
		Endif;
	Endif;
	                                                                                              
EndProcedure

&AtServer
Procedure ToEstablishConditionFieldSpreadsheetDocument(State = "DontUse") Export
	SpreadsheetDocumentField = Items.TabDocument;
	If TypeOf(SpreadsheetDocumentField) = Type("FormField") 
		AND SpreadsheetDocumentField.Type = FormFieldType.SpreadsheetDocumentField Then
		StatePresentation = SpreadsheetDocumentField.StatePresentation;
		If Upper(State) = "DONTUSE" Then
			StatePresentation.Visible                      = False;
			StatePresentation.AdditionalShowMode = AdditionalShowMode.DontUse;
			StatePresentation.Picture                       = New Picture;
			StatePresentation.Text                          = "";
		Elsif Upper(State) = "IRRELEVANCE" Then
			StatePresentation.Visible                      = True;
			StatePresentation.AdditionalShowMode = AdditionalShowMode.Irrelevance;
			StatePresentation.Picture                       = New Picture;
			StatePresentation.Text                          = NStr("ru = 'Отчет не сформирован. Нажмите ""Сформировaть"" для получения отчета.'");;
		Elsif Upper(State) = "ФОРМИРОВАНИЕОТЧЕТА" Then  
			StatePresentation.Visible                      = True;
			StatePresentation.AdditionalShowMode = AdditionalShowMode.Irrelevance;
			StatePresentation.Picture                       = PictureLib.ДлительнаяОперация48;
			StatePresentation.Text                          = NStr("ru = 'Отчет формируется...'");
		Else
			Raise(NStr("ru = 'Недопустимое значение параметра (параметр номер ''2'')'"));
		Endif;
	Else
		Raise(NStr("ru = 'Недопустимое значение параметра (параметр номер ''1'')'"));
	Endif;
	
EndProcedure

&AtServer
Procedure CreateAddResourcesColumn(VT, Prefix = "")
	For each StrResource  in NP.TVIndicators Do
		VT.Columns.Add(StrResource.LineNumber + Prefix + "OpeningBalanceDr",	New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + Prefix + "OpeningBalanceCr",	New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + Prefix + "TurnoverDr",			New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + Prefix + "TurnoverCr",			New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + Prefix + "BalancedTurnoverDr",		New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + Prefix + "BalancedTurnoverCr",		New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + Prefix + "ClosingBalanceDr",	New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + Prefix + "ClosingBalanceCr",	New TypeDescription("Number"));
	EndDo;
EndProcedure 

&AtServer
Function CreateStructureOfTV()
	VT = New ValueTable;
	VT.Columns.Add("Description");
	FieldStructure = New Structure;
	For each StrResource  in NP.TVIndicators Do
		VT.Columns.Add(StrResource.LineNumber + "OpeningBalanceDr",	New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + "OpeningBalanceCr",	New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + "TurnoverDr",				New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + "TurnoverCr",				New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + "BalancedTurnoverDr",			New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + "BalancedTurnoverCr",			New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + "ClosingBalanceDr",	New TypeDescription("Number"));
		VT.Columns.Add(StrResource.LineNumber + "ClosingBalanceCr",	New TypeDescription("Number"));
		FieldStructure.Insert(StrResource.LineNumber + "OpeningBalanceDr", 	0);
		FieldStructure.Insert(StrResource.LineNumber + "OpeningBalanceCr", 	0);
		FieldStructure.Insert(StrResource.LineNumber + "TurnoverDr", 				0);
		FieldStructure.Insert(StrResource.LineNumber + "TurnoverCr", 				0);
		FieldStructure.Insert(StrResource.LineNumber + "BalancedTurnoverDr", 			0);
		FieldStructure.Insert(StrResource.LineNumber + "BalancedTurnoverCr", 			0);
		FieldStructure.Insert(StrResource.LineNumber + "ClosingBalanceDr", 	0);
		FieldStructure.Insert(StrResource.LineNumber + "ClosingBalanceCr", 	0);
	EndDo;
	NP.Insert("StrFieldStructure", ValueToStringInternal(FieldStructure));
	
	VT.Columns.Add("TVResources");
	VT.Columns.Add("Level");
	VT.Columns.Add("Sort");
	VT.Columns.Add("Indicator");
	VT.Columns.Add("Value");
	VT.Columns.Add("Filter");
	VT.Columns.Add("TurnDr");
	VT.Columns.Add("НandTurn"); 
	VT.Columns.Add("IndicatorRegister");
	VT.Columns.Add("TabTurn");
	VT.Columns.Add("DetString");
	VT.Columns.Add("Address");
	Return VT;
EndFunction 

&AtServer
Procedure Generate_OutputTable(Tab)
	If TypeOf(Tab) = Type("ValueTable") Then
		For each StrTab in Tab Do
			mTranscriptString 			= mTranscriptString + 1;
			StrTab.DetString 		= mTranscriptString;
			If (StrTab.Indicator = "Account") and (StrTab.Level = 1) Then
				For each Resource in StrTab.TVResources Do
					Generate_OutputSection("Cache_Account|Base", 			StrTab, Resource,);
					If NP.TVResourcesFilter.Count() > 1 Then
						Generate_OutputSection("Cache_Account|CacheIndicator", 	StrTab, Resource, True);
					Endif;
					Generate_OutputSection("Cache_Account|Resources", 			StrTab, Resource, True);
					mTranscriptStringField = mTranscriptStringField + 1;
				EndDo;
			Else
				For each Resource in StrTab.TVResources Do
					Generate_OutputSection("Cache_String" + Min(StrTab.Level ,7) + "|Base", 			StrTab, Resource,);
					If NP.TVResourcesFilter.Count() > 1 Then
						Generate_OutputSection("Cache_String" + Min(StrTab.Level ,7) + "|CacheIndicator", StrTab, Resource, True);
					Endif;
					Generate_OutputSection("Cache_String" + Min(StrTab.Level ,7) + "|Resources", 		StrTab, Resource, True);
					mTranscriptStringField = mTranscriptStringField + 1;
				EndDo;
			Endif;
			If StrTab.TurnDr = "-" Then
				Generate_OutputTable(StrTab.TabTurn);
			Endif;
		EndDo;
	Endif;
	NP.Sections.Clear();
EndProcedure 

&AtServer
Function GenerateLineConclusionParametersByDatesAtServer(Val DateBeg, Val DateEnd)Export

	If DateBeg = '00010101000000' AND DateEnd = '00010101000000' Then

		DescriptionPeriod     = " без ограничения.";

	Else

		If DateBeg = '00010101000000' OR DateEnd = '00010101000000' Then

			DescriptionPeriod = " " + Format(DateBeg, "DF = ""dd.MM.yyyy""; DE = ""без ограничения""") 
							+ " - "      + Format(DateEnd, "DF = ""dd.MM.yyyy""; DE = ""без ограничения""");

		Else

			DescriptionPeriod = " " + PeriodPresentation(BegOfDay(DateBeg), EndOfDay(DateEnd), "FP = True");

		Endif;

	Endif;

	Return DescriptionPeriod;

EndFunction

&AtServer
Procedure Generate_OutputSection(SectionName, StrTab = Undefined, Column = Undefined, Join = False)
	
	If Left(SectionName, StrLen("Cache_")) <> "Cache_" Then
		Section  					= NP.Template.GetArea(SectionName);
		Section.Area("R1C1:R3C"+String(Section.TableWidth)).TextColor 	= NP.StructureAppearance.Z.TextColor;
		Section.Area("R4C1:R5C"+String(Section.TableWidth)).TextColor 	= NP.StructureAppearance.W.TextColor;
		Section.Area("R4C1:R5C"+String(Section.TableWidth)).BorderColor 	= NP.StructureAppearance.W.BorderColor;
		If SectionName = "Header|Resources" Then 
			Section.Area("R4C1:R5C"+String(Section.TableWidth)).BackColor 	= NP.StructureAppearance.W.BackColor;
			Section.Parameters._Period 					= GenerateLineConclusionParametersByDatesAtServer(NP.Date1, NP.Date2);
		Elsif SectionName = "Header|Base" Then 
			Section.Area("R4C2:R5C"+String(Section.TableWidth)).BackColor 	= NP.StructureAppearance.W.BackColor;
			Section.Parameters.Title 					= "Оборотно-сальдовая ведомость " + ?(NP._TVDimensions.Count() > 0, NP._TVDimensions[0].Value, "");
			Section.Parameters.NameAccountingRegister 	= ?(NP.NameAccountingRegister = "Хозрасчетный", "Бухгалтерский", NP.NameAccountingRegister);
		Else	
			Section.Area("R4C1:R5C"+String(Section.TableWidth)).BackColor 	= NP.StructureAppearance.W.BackColor;
		Endif;
	Else 
		StrSearch = NP.Sections.Find(lower(TrimAll(SectionName)), "SectionName");
		If StrSearch <> Undefined Then
			StrSections = StrSearch;
		Else
			Section 						= NP.Template.GetArea(SectionName);
			Section.Area().TextColor = NP.StructureAppearance["N" + String(StrTab.Level)].TextColor;
			Section.Area().BorderColor 	= NP.StructureAppearance["N" + String(StrTab.Level)].BorderColor;
			If Join Then
				Section.Area().BackColor 	= NP.StructureAppearance["N" + String(StrTab.Level)].BackColor;
			Elsif SectionName = "Cache_Totals|Base" Then
				Section.Area("R1C2:R1C" + Section.TableWidth).BackColor 	= NP.StructureAppearance["N" + String(StrTab.Level)].BackColor;
			Else	
				TurnPlus 				= Section.Drawings.Add(SpreadsheetDocumentDrawingType.Picture);
				TurnPlus.Hyperlink 	= False;
				TurnPlus.TopBorder 	= False;
				TurnPlus.LeftBorder 	= False;
				TurnPlus.BottomBorder 	= False;
				TurnPlus.RightBorder 	= False;
				TurnPlus.PictureSize = PictureSize.RealSize;
				TurnPlus.Details 	= NP.FieldDecoding.TurnDr;
				TurnPlus.BackColor 		= New Color();
				TurnPlus.Pattern	 		= SpreadsheetDocumentPatternType.WithoutPattern;
				EndE = String(Section.TableWidth);
				For K = 1 To Min(StrTab.Level ,7) Do
					EndB = K; 	
					Section.Area("R1C" + String(EndB + 1) + ":R1C" + String(EndB + 1)).BackColor 	= NP.StructureAppearance["N" + String(EndB)].BackColor;
				EndDo;	
				
				Section.Area("R1C" + String(EndB + 1) + ":R1C" + EndE).BackColor 	= NP.StructureAppearance["N" + String(StrTab.Level)].BackColor;
			Endif;
			Section.Parameters.Fill(NP.FieldDecoding);
			StrSections 				= NP.Sections.Add();
			StrSections.SectionName 	= lower(TrimAll(SectionName));
			StrSections.Section 		= Section;
			StrSections.SectionWidth 	= ?(Section.TableWidth = 0, NP.Template.TableWidth, Section.TableWidth);
			Fields 					= New ValueTable;
			Fields.Columns.Add("Field");
			Fields.Columns.Add("Type",		New TypeDescription("String"));
			Fields.Columns.Add("Formula",	New TypeDescription("String"));
			Fields.Columns.Add("Composite",	New TypeDescription("Boolean"));
			For Num = 1 To StrSections.SectionWidth Do
				Field 			= Section.Area(1, Num, 1, Num);
				Text 			= Field.Text;                                    
				If Text = "" OR Text = Undefined Then
					Continue;	
				Endif;                                
				StrField 		= Fields.Add();
				StrField.Field 	= Field;
				If lower(Left(Text, StrLen("field:"))) = "field:" Then
					StrField.Type 	= "P";
					StrField.Formula = TrimL(Mid(Text, StrLen("field:") + 1));
				Elsif lower(Left(Text, StrLen("template:"))) = "template:" Then
					StrField.Type 	= "W";
					StrField.Formula = Mid(Text, StrLen("template:") + 1);
				Elsif lower(Left(Text, StrLen("resource:"))) = "resource:" Then
					StrField.Type 	= "R";
					StrField.Formula = Mid(Text, StrLen("resource:") + 1);
				Endif;
			EndDo;
			StrSections.Fields = ?(Fields.Count() = 0, Undefined, Fields.Copy())
		Endif;
		Section 			= StrSections.Section;
		For each StrTransc in Section.Parameters Do
			If TypeOf(StrTransc) = Type("Structure") AND StrTransc.Property("NumStr") Then 
				NewStructure = New Structure();
				For each KeySearch in StrTransc Do
					NewStructure.Insert(KeySearch.Key, KeySearch.Value);	
				EndDo;
				NewStructure.NumStr 						= mTranscriptString;
				NewStructure.Type 							= StrTab.TurnDr;
				Section.Parameters[NewStructure.Details] 	= NewStructure; 
			Endif;	
		EndDo;
		For each ImgDet in Section.Drawings Do
			If TypeOf(ImgDet.Details) = Type("Structure") AND ImgDet.Details.Property("NumStr") Then 
				NewStructure = New Structure();
				For each KeySearch in ImgDet.Details Do
					NewStructure.Insert(KeySearch.Key, KeySearch.Value);	
				EndDo;
				NewStructure.NumStr = mTranscriptString;
				NewStructure.Type 	= StrTab.TurnDr;
				ImgDet.Details 	= NewStructure; 
			Endif;	
		EndDo;
		TurnImg 	= Undefined;
		If StrSections.Fields <> Undefined Then
			Fields = StrSections.Fields;
			For each StrField in Fields Do
				If StrField.Type = "P" Then
					StrField.Field.Text 	= "";
					If StrTab[StrField.Formula] = "+" Then
						TurnImg 				= Section.Drawings[0];
					    TurnImg.Picture 		= NP.StructureAppearance.Plus;
						TurnImg.Place(StrField.Field);
						TurnImg.Name 			= "Y" + String(mTranscriptStringField);
						TurnImg.Hyperlink 	= False;
					Elsif StrTab[StrField.Formula] = "-" Then
						TurnImg 				= Section.Drawings[0];
					    TurnImg.Picture 		= NP.StructureAppearance.Mminus;
						TurnImg.Place(StrField.Field);
						TurnImg.Name 			= "Y" + String(mTranscriptStringField);
						TurnImg.Hyperlink 	= False;
					Endif
				Elsif StrField.Type = "R" Then
					StrField.Field.Format 	= Column.FormatP; 
					Formula 			= StrReplace(Column.NameFormula, "[", "StrTab." + Column.LineNumber);
					Formula 			= StrReplace(Formula, "]", StrField.Formula);
					Formula 			= ?(Find(StrField.Formula, "Balance") = 0, Formula, StrReplace(Formula, "Balanced", ""));
					If Find(Formula, "/") = 0 Then
						StrField.Field.Text 	= Eval(Formula);
					Else
						Try
							StrField.Field.Text 	= Eval(Formula);
						Except
							StrField.Field.Text 	= 0;
						EndTry;	
					Endif;
				Else	
					StrField.Field.Text 	= Eval(StrField.Formula);
				Endif;
			EndDo;
		Endif;
	Endif;
	If Join Then
		TabDocument.Join(Section);	
	Else
		ResArea = TabDocument.Put(Section); 
		If StrTab <> Undefined Then
			If StrTab.TurnDr = "-" Then 
				TabDocument.Area(TabDocument.TableHeight, 0).BottomBorder = New Line(SpreadsheetDocumentDrawingLineType.None,0);
			Endif; 
			Number = StrTab.TVResources.IndexOf(Column);
			If NP.TVResourcesFilter.Count() > 1 AND Number + 1 = StrTab.TVResources.Count() Then
				For K = 1 To Number Do
					Img = TabDocument.Areas.Find("Y" + String(mTranscriptStringField - K));
					If Img <> Undefined Then
						TabDocument.Drawings.Delete(Img);
					Endif;
				EndDo;
				ImgPlus = TabDocument.Areas.Find("Y" + String(mTranscriptStringField));
				For K = ResArea.Left To Min(StrTab.Level ,7) Do
					Area = TabDocument.Area(ResArea.Top - Number, K, ResArea.Bottom, K);
					Area.Merge();
					If K = ResArea.Left AND ImgPlus <> Undefined Then
						ImgPlus.Place(Area);
					Endif;
				EndDo;
				If SectionName = "Cache_Account|Base" Then
					NewArea 	= TabDocument.Area(ResArea.Top - Number, 2,ResArea.Bottom, 5);
					NewArea.Merge();
					If StrTab.Value.Level() = 0 Then
						NewArea.Font 	= New Font(Area.Font,,, True);
					Else
						Indent 				= ?(StrTab.Value.Level() > 3, 3, StrTab.Value.Level());
						NewArea.Indent 	= Indent;
						If Indent = 2 Then
							NewArea.Font 	= New Font(Area.Font,,8);
						Endif;
					Endif;
					
					Area = TabDocument.Area(ResArea.Top - Number, 6,ResArea.Bottom, 8);
					Area.Merge();
				Else
					Area = TabDocument.Area(ResArea.Top - Number, Min(StrTab.Level ,7) + 1, ResArea.Bottom, 8);
					Area.Merge();
				Endif;
			Else
				If SectionName = "Cache_Account|Base" Then
					Area = TabDocument.Area(ResArea.Top, 2,ResArea.Bottom, 5);
					If StrTab.Value.Level() = 0 Then
						Area.Font 	= New Font(Area.Font,,, True);
					Else
						Indent 				= ?(StrTab.Value.Level() > 3, 3, StrTab.Value.Level());
						Area.Indent 		= Indent;
						If Indent = 2 Then
							Area.Font 	= New Font(Area.Font,,8);
						Endif;
					Endif;
				Endif;
			Endif;
			
			StrTab.Address = ?(Area = Undefined, ResArea.Name, Area.Name);
			
		Endif;
	Endif;
EndProcedure 

&AtServer
Function SelectionOfLayoutInTV() 
	
	TVFilter 				= New ValueTable;
	TVFilter.Columns.Add("ComparisonType",	New TypeDescription("DataCompositionComparisonType"));	
	TVFilter.Columns.Add("Value",		);	
	TVFilter.Columns.Add("Use",	New TypeDescription("Boolean"));	
	TVFilter.Columns.Add("DataPath",		New TypeDescription("String"));	
	
	For each StrFilter in InteractiveTBS.SettingsComposer.Settings.Filter.Items Do
		StrCopy	 			= TVFilter.Add();
		FillPropertyValues(StrCopy, StrFilter); 
		StrCopy.Value 		= StrFilter.RightValue;
		StrCopy.DataPath 	= String(StrFilter.LeftValue);
	EndDo;
	
	Return TVFilter;
	
EndFunction 

&AtServer
Procedure AddTVSelectionRegister(Val StringFilterCD) 
	
	StringsFilter = TVFiltersOnRegisters.FindRows(New Structure("DataPath, Register", String(StringFilterCD.LeftValue), NameAccountingRegister));
	
	RightValue 	= Undefined;
	                                             
	For each FilterItem In InteractiveTBS.SettingsComposer.Settings.Filter.Items Do
		
		If ТипЗнч(FilterItem) = Тип("DataCompositionFilterItem") И FilterItem.Use 
			AND FilterItem.LeftValue = StringFilterCD.LeftValue Then				
			RightValue = FilterItem.RightValue;	
			Break;
		Endif;
	EndDo;
	
	If StringsFilter.Count() = 0 Then
		StrToFilter	 			= TVFiltersOnRegisters.Add();
		FillPropertyValues(StrToFilter, StringFilterCD); 
		StrToFilter.Value 		= RightValue;
		StrToFilter.DataPath 	= String(StringFilterCD.LeftValue);
	    StrToFilter.Register 		= NameAccountingRegister;
	Else 
		For each StrToFilter In StringsFilter Do
			FillPropertyValues(StrToFilter, StringFilterCD); 
			StrToFilter.Value 		= RightValue;
		EndDo;
	Endif;
	
EndProcedure 

&AtServer
Procedure RemoveTVFiltersOnRegisters(Val StringFilterCD) 
	
	StringsFilter = TVFiltersOnRegisters.FindRows(New Structure("DataPath, Register", String(StringFilterCD.LeftValue), NameAccountingRegister));
	
	If StringsFilter.Count() <> 0 Then
		For each StrToFilter In StringsFilter Do
			TVFiltersOnRegisters.Delete(StrToFilter);		
		EndDo;
	Endif;
	
EndProcedure 

&AtServer
Function ToCreateFilter() Export
	
	VT = New ValueTable;
	VT.Columns.Add("KeySearch", New TypeDescription("String"));
	VT.Columns.Add("Value");
	VT.Columns.Add("ComparisonType", New TypeDescription("DataCompositionComparisonType"));
	VT.Columns.Add("Section", New TypeDescription("Number"));
	
	Return VT;
	
EndFunction 

&AtServer
Function FindAndPasteItInFilter(VT, KeySearch = "", Value = Undefined, Comparison = Undefined)
	
	Result = False;
	FindStr = VT.Find(KeySearch, "KeySearch");
	If FindStr = Undefined Then
		AddToFilter(VT, KeySearch, Value, Comparison);		
	Endif;
	Return Result;
	
EndFunction

&AtServer
Function GetPresentationFilter(VT, KeySearch = "", Value = Undefined, Comparison = Undefined) Export
	
	Comparison = ?(Comparison = Undefined, DataCompositionComparisonType.Equal, Comparison);
	Result = False;
	FindStr = VT.Find(KeySearch, "KeySearch");
	If FindStr <> Undefined Then
		Value 	= FindStr.Value;
		Comparison	= FindStr.ComparisonType;
		Result 	= True;
	Endif;
	
	Return Result;
	
EndFunction 

&AtServer
Function AddToFilter(VT, KeySearch = "", Value = Undefined, Comparison = Undefined);
	
	If ValueIsFilled(Value) AND ChartsOfAccounts.AllRefsType().ContainsType(TypeOf(Value)) Then
		Comparison = DataCompositionComparisonType.InHierarchy;
	Elsif Comparison = Undefined Then 
		Comparison = DataCompositionComparisonType.Equal;
	Endif;
	
	StrTV 				= VT.Insert(0);
	StrTV.KeySearch 	= KeySearch;
	StrTV.Value 		= Value;
	StrTV.ComparisonType  = Comparison;
	
	BasicIndicator 	= Left(KeySearch, Find(KeySearch + ".", ".") - 1);
	
	If Upper(TrimAll(BasicIndicator)) = Upper("Account") Then
		StrTV.Section = 1;
	Elsif Upper(TrimAll(BasicIndicator)) = Upper("BalancedAccount") Then
		StrTV.Section = 2;
	Endif;
	
EndFunction 

&AtServer
Function PeriodBorder(DateOfPeriod, TypePeriod = "DAY", BoundaryType) Export
	
	StandPer = "SECOND MINUTE HOUR DAY WEEK TENDAYS MONTH QUARTER YEAR";
	
	If Find(StandPer,TypePeriod) = 0 Then 
		TypePeriod = "DAY"; 
	Endif;
	
	If Find(Upper(BoundaryType),"НАЧ") <> 0 Then
		Boundary = "BEGINOFPERIOD";
	Elsif Find(Upper(BoundaryType),"КОН") <> 0 Then
		Boundary = "ENDOFPERIOD";
	Else
		Return DateOfPeriod;
	Endif;
	
	Query 			= New Query();
	Query.Text 	= "SELECT " + Boundary + " (&ConditionDate, " + TrimAll(TypePeriod) + ") AS ResDate";

	Query.SetParameter("ConditionDate",DateOfPeriod);
	
	Result = Query.Execute().Unload(QueryResultIteration.Linear).Get(0).ResDate;

	If TypeOf(Result) <> Type("DATE") Then 
		Return Date(1,1,1); 
	Else 
		Return Result; 
	Endif;
EndFunction 

&AtServer
Procedure AddField(String, Separator, Supplement)
	If IsBlankString(String) Then
		String = Supplement;
	Else
		String = String + Separator + Supplement;
	Endif;
EndProcedure

&AtServer
Function GetStringFilter(SelectComparisonType, ValueItself = Undefined) Export
		
	StringReturn = "";
	If SelectComparisonType = DataCompositionComparisonType.Equal Then
		StringReturn =  String(" = ");
		If TypeOf(ValueItself) = Type("Array")OR TypeOf(ValueItself) = Type("ValueList") Then
			StringReturn = String(" IN HIERARCHY ");
		Endif;
	Elsif SelectComparisonType = DataCompositionComparisonType.NotEqual Then  
		StringReturn = String(" <> ");
	Elsif SelectComparisonType = DataCompositionComparisonType.InList Then
		StringReturn = String(" IN ");
	Elsif SelectComparisonType = DataCompositionComparisonType.InListByHierarchy 
		OR SelectComparisonType = DataCompositionComparisonType.InHierarchy Then
		StringReturn = String(" IN HIERARCHY ");
	Elsif SelectComparisonType = DataCompositionComparisonType.NotInList Then
		StringReturn = String(" NOT IN ");
	Elsif SelectComparisonType = DataCompositionComparisonType.NotInListByHierarchy 
		OR SelectComparisonType = DataCompositionComparisonType.NotInHierarchy Then
		StringReturn = String(" NOT IN HIERARCHY ");
	Elsif SelectComparisonType = DataCompositionComparisonType.Greater Then
		StringReturn = String(" > ");
	Elsif SelectComparisonType = DataCompositionComparisonType.GreaterOrEqual Then
		StringReturn = String(" >= ");
	Elsif SelectComparisonType = DataCompositionComparisonType.Less Then
		StringReturn = String(" < ");
	Elsif SelectComparisonType = DataCompositionComparisonType.LessOrEqual Then
		StringReturn = String(" <= ");
	Elsif SelectComparisonType = DataCompositionComparisonType.Contains Then
		StringReturn = String(" LIKE ");
	Elsif SelectComparisonType = DataCompositionComparisonType.NotContains Then
		StringReturn = "NOT " + String(" LIKE ");
	Elsif SelectComparisonType = DataCompositionComparisonType.Filled Then
		StringReturn =  String(" = ");
	Elsif SelectComparisonType = DataCompositionComparisonType.NotFilled Then  
		StringReturn = String(" <> ");
	Else 
		StringReturn =  String(" = ");
	Endif;

	Return StringReturn;
	
EndFunction 

&AtServer
Procedure DefineConditionOnFields(Query, ConditionOnFields, StructureConditions, Section, ConditionWhere = "")

	If TypeOf(StructureConditions) = Type("ValueTable") Then
		Num = 0;
		For each Element in StructureConditions Do
			
			If Element.Section <> Section Then
				Continue;	
			Endif;
			
			Num 			= Num + 1;
			FieldName      	= Element.KeySearch;
			ValueOfField 	= Element.Value;
			
			Query.SetParameter(StrReplace(FieldName, ".", "") + String(Num), ValueOfField);

			Try
				ConditionsOfEquality = Element.ComparisonType;

				ValMet 	= ValueOfField.Metadata();
				If Groups AND ValueIsFilled(ValueOfField) AND (ValueOfField.IsFolder OR (ValMet.Hierarchical AND ValMet.HierarchyType = Metadata.ObjectProperties.HierarchyType.HierarchyOfItems)) Then
					ConditionsOfEquality = DataCompositionComparisonType.InHierarchy;
				Endif;

			Except

				ConditionsOfEquality = Element.ComparisonType;

			EndTry;
			
			TextOfConditions = GetStringFilter(ConditionsOfEquality, ValueOfField);
				
			AddField(ConditionOnFields, " AND ", FieldName + TextOfConditions + "(&" + StrReplace(FieldName, ".", "") + String(Num) + ")");

		EndDo;

	Endif;

EndProcedure

&AtServer
Function GetSootvetvySubordinatedAccounts(Val ChartOfAccounts = "", Val Account) Export
	
	MatchingAccounts = New Map;
	
	Query = New Query();
	
	Query.Text =
		"SELECT ALLOWED ChartOfAccountsToRegister.Ref AS Ref
		|FROM	ChartOfAccounts." + ChartOfAccounts + " AS ChartOfAccountsToRegister
		|WHERE	ChartOfAccountsToRegister.Ref IN HIERARCHY(&Ref)";
		
	Query.SetParameter("Ref", Account);
	
	Sample = Query.Execute().Select();
	
	While Sample.Next() Do
		
		MatchingAccounts.Insert(Sample.Ref, -1);
		
	EndDo;

	Return MatchingAccounts;
	
EndFunction

&AtServer
Function DefineForAccountOnComplianceNumberExtDimension(Val Account, MatchingAccounts) Export
	
	If NP.MaxExtDimensionCount <> 0 Then
		
		NumberOfSubcontoAccount = MatchingAccounts[Account];
		If NumberOfSubcontoAccount = Undefined Then
			NumberOfSubcontoAccount = Account.ExtDimensionTypes.Count();
			MatchingAccounts[Account] = NumberOfSubcontoAccount;
		Endif;
		
	Else	
		NumberOfSubcontoAccount = 0;
	Endif;

	Return NumberOfSubcontoAccount;
	
EndFunction

&AtServer
Function СalculateRecordsWithExtDimensions(mFilters, mAccount, mBalanceAccount = Undefined, ResultingBalance = Undefined)
	
	ConditionOnFields    	= " (Active = TRUE) ";
	
	QueryOnTransactions 	= New Query();
	DefineConditionOnFields(QueryOnTransactions, ConditionOnFields, mFilters, 0);
	DefineConditionOnFields(QueryOnTransactions, ConditionOnFields, mFilters, 1);
	DefineConditionOnFields(QueryOnTransactions, ConditionOnFields, mFilters, 2);
	
	QueryOnTransactions.Text = "SELECT ALLOWED
	|	AccountDr AS AccountDr,
	|	AccountCr AS AccountCr,
	|	AccountDr.Presentation AS AccountDrPresentation,
	|	AccountCr.Presentation AS AccountCrPresentation,
	|	PRESENTATION(Recorder)AS PresentationOperation,
	|	LineNumber AS LineNumber,
	|	Period           AS DateTransaction,
	|	Recorder      AS Еntry";
	
	For each Dimension in NP._TVDimensions Do
		If Dimension.Balance Then
			AddField(QueryOnTransactions.Text, mFieldsSeparator, Dimension.Name + " AS " + Dimension.Name);
			QueryOnTransactions.Text = QueryOnTransactions.Text + mFieldsSeparator + "PRESENTATION(" + Dimension.Name + ") AS " + Dimension.Name + "Presentation";
		Else
			AddField(QueryOnTransactions.Text, mFieldsSeparator, Dimension.Name + "DR AS " + Dimension.Name + "DR");
			QueryOnTransactions.Text = QueryOnTransactions.Text + mFieldsSeparator + "PRESENTATION(" + Dimension.Name + "DR) AS " + Dimension.Name + "DrPresentation";
			AddField(QueryOnTransactions.Text, mFieldsSeparator, Dimension.Name + "CR AS " + Dimension.Name + "CR");
			QueryOnTransactions.Text = QueryOnTransactions.Text + mFieldsSeparator + "PRESENTATION(" + Dimension.Name + "CR) AS " + Dimension.Name + "CrPerformance";
		Endif;
	EndDo;
	
	For each Resource in NP.TVIndicators Do
		If Resource.Balance Then
			AddField(QueryOnTransactions.Text,   mFieldsSeparator, Resource.Name + " AS " + Resource.LineNumber);
		Else
			AddField(QueryOnTransactions.Text,   mFieldsSeparator, Resource.Name + "DR AS " + Resource.LineNumber + "DR");			
			AddField(QueryOnTransactions.Text,   mFieldsSeparator, Resource.Name + "CR AS " + Resource.LineNumber + "CR");
		Endif;
	EndDo;
	
	ArrayDetails = New Array;
	For each Attribute in mAccountingRegister.Attributes Do
		If Attribute.Type.StringQualifiers.Length > 29 Then
			AddField(QueryOnTransactions.Text,   mFieldsSeparator, Attribute.Name + " AS " + Attribute.Name);
			ArrayDetails.Add(Attribute.Name);
		Endif;
	EndDo;
	
	For IndexOf = 1 To NP.MaxExtDimensionCount Do
		QueryOnTransactions.Text = QueryOnTransactions.Text + ",
		|	ExtDimensionDr"+ String(IndexOf) + " AS ExtDimensionDr" + String(IndexOf) + ", 
		|	PRESENTATION(ExtDimensionDr"+ String(IndexOf) + ") AS ExtDimensionDr" + String(IndexOf) + "Presentation, 
		|	ExtDimensionCr"+ String(IndexOf) + " AS ExtDimensionCr" + String(IndexOf) + ", 
		|	PRESENTATION(ExtDimensionCr"+ String(IndexOf) + ") AS ExtDimensionCr" + String(IndexOf) + "Presentation";
	EndDo;

	QueryOnTransactions.Text = QueryOnTransactions.Text + "
	|FROM
	|	AccountingRegister." + NP.NameAccountingRegister + ".RecordsWithExtDimensions(&_Date1, &_Date2," + ConditionOnFields + ") AS MainRecordsWithExtDimensions
	|ORDER BY DateTransaction";
	
	QueryOnTransactions.SetParameter("_Date1", 	mDateQuery1);
	QueryOnTransactions.SetParameter("_Date2", 	mDateQuery2);
	
	ResultTransaction 	= QueryOnTransactions.Execute().Unload();
	MapUnderAccount 	= GetSootvetvySubordinatedAccounts(NP.NameChartOfAccounts, mAccount);
	
	ResultTransaction.Columns.Add("ЕntryBriefly", 		New TypeDescription("String"));	
	ResultTransaction.Columns.Add("ЕntryDetail", 	New TypeDescription("String"));	
	ResultTransaction.Columns.Add("Period", 			New TypeDescription("Number"));	
	
	StructureBalance = New Structure;
	For each StrResource  in NP.TVIndicators Do
		StructureBalance.Insert(StrResource.LineNumber + "BalanceDr", 0);
		StructureBalance.Insert(StrResource.LineNumber + "BalanceCr", 0);
	EndDo;
	
	For each StrColumn in StructureBalance Do
		StructureBalance[StrColumn.Key] = ResultingBalance[StrReplace(StrColumn.Key, "Balance", "OpeningBalance")];
	EndDo;
	
	CreateAddResourcesColumn(ResultTransaction);	
	MapAccountsCache = New Map; 
	
	For each StrIndicator in ResultTransaction Do
		StrIndicator.Period 			= ResultTransaction.IndexOf(StrIndicator);
		StrIndicator.ЕntryBriefly 	= StrIndicator.PresentationOperation;
		StrIndicator.ЕntryDetail 	= StrIndicator.PresentationOperation + Chars.LF +
		"Д" + StrIndicator.AccountDrPresentation + " К" + StrIndicator.AccountCrPresentation;
		
		For each StrArrRequis in ArrayDetails Do
			StrIndicator.ЕntryDetail 	= StrIndicator.ЕntryDetail + Chars.LF + StrIndicator[StrArrRequis];
			StrIndicator.ЕntryBriefly 	= StrIndicator.ЕntryBriefly + Chars.LF + StrIndicator[StrArrRequis];
		EndDo;
		
		NumberOfExtDimensionAccount = DefineForAccountOnComplianceNumberExtDimension(StrIndicator.AccountDr, MapAccountsCache);
		For IndexOf = 0 To NumberOfExtDimensionAccount - 1 Do
			StrIndicator.ЕntryDetail = StrIndicator.ЕntryDetail + Chars.LF + ?(NOT ValueIsFilled(StrIndicator["ExtDimensionDr" + String(IndexOf + 1)])
			, "<...>", StrIndicator["ExtDimensionDr" + String(IndexOf + 1) + "Presentation"]);
		EndDo;
		
		NumberOfExtDimensionAccount = DefineForAccountOnComplianceNumberExtDimension(StrIndicator.AccountCr, MapAccountsCache);
		For IndexOf = 0 To NumberOfExtDimensionAccount - 1 Do
			StrIndicator.ЕntryDetail = StrIndicator.ЕntryDetail + Chars.LF + ?(NOT ValueIsFilled(StrIndicator["ExtDimensionCr" + String(IndexOf + 1)])
			, "<...>", StrIndicator["ExtDimensionCr" + String(IndexOf + 1) + "Presentation"]);
		EndDo;
		
		
		For each Resource in NP.TVIndicators Do
			If MapUnderAccount[StrIndicator.AccountDr] <> Undefined Then
				StrIndicator[Resource.LineNumber + "TurnoverDr"] =  StrIndicator[Resource.LineNumber + ?(Resource.Balance, "", "DR")];
				If NOT Resource.Balance Then
					StrIndicator[Resource.LineNumber + "BalancedTurnoverDr"] =  StrIndicator[Resource.LineNumber + ?(Resource.Balance, "", "CR")];
				Endif;
			Endif;
		
			If MapUnderAccount[StrIndicator.AccountCr] <> Undefined Then
				StrIndicator[Resource.LineNumber + "TurnoverCr"] =  StrIndicator[Resource.LineNumber + ?(Resource.Balance, "", "CR")];
			If NOT Resource.Balance Then
					StrIndicator[Resource.LineNumber + "BalancedTurnoverCr"] =  StrIndicator[Resource.LineNumber + ?(Resource.Balance, "", "DR")];
				Endif;
			Endif;
			
			If NOT ValueIsFilled(mBalanceAccount) Then
				StrIndicator[Resource.LineNumber + "OpeningBalanceDr"] = StructureBalance[Resource.LineNumber + "BalanceDr"];	
				StrIndicator[Resource.LineNumber + "OpeningBalanceCr"] = StructureBalance[Resource.LineNumber + "BalanceCr"];	
				
				If TypeOf(mAccount) = Type("Array") OR mAccount.Type = AccountType.ActivePassive Then
					DesiredResult 	= ?(StructureBalance[Resource.LineNumber + "BalanceCr"]<>0, -StructureBalance[Resource.LineNumber + "BalanceCr"], StructureBalance[Resource.LineNumber + "BalanceDr"]);
					AmountOfTurnover			= (StrIndicator[Resource.LineNumber + "TurnoverDr"]-StrIndicator[Resource.LineNumber + "TurnoverCr"]);
					DesiredResult 	= DesiredResult + AmountOfTurnover;
					StructureBalance[Resource.LineNumber + "BalanceCr"] = ?(DesiredResult > 0, 0, -DesiredResult);
					StructureBalance[Resource.LineNumber + "BalanceDr"] = ?(DesiredResult < 0, 0, DesiredResult);
				Elsif mAccount.Type = AccountType.Active Then
					StructureBalance[Resource.LineNumber + "BalanceDr"] = StructureBalance[Resource.LineNumber + "BalanceDr"] + 
					(StrIndicator[Resource.LineNumber + "TurnoverDr"]-StrIndicator[Resource.LineNumber + "TurnoverCr"]);
				Elsif mAccount.Type = AccountType.Passive Then
					StructureBalance[Resource.LineNumber + "BalanceCr"] = StructureBalance[Resource.LineNumber + "BalanceCr"] + 
					(StrIndicator[Resource.LineNumber + "TurnoverCr"]-StrIndicator[Resource.LineNumber + "TurnoverDr"]);
				Endif;
				
				StrIndicator[Resource.LineNumber + "ClosingBalanceDr"] = StructureBalance[Resource.LineNumber + "BalanceDr"];	
				StrIndicator[Resource.LineNumber + "ClosingBalanceCr"] = StructureBalance[Resource.LineNumber + "BalanceCr"];	
			Endif;
		EndDo;	
	EndDo;
	
	Return ResultTransaction;

EndFunction

&AtServer
Function StructureContainsNames(Struct, Val Names)

	Names = StrReplace(Names, " ", "");
	Names = StrReplace(Names, ",", Chars.LF);

	For Number = 1 To StrLineCount(Names) Do

		Name = StrGetLine(Names, Number);
		If Struct.Property(Name) Then
			Return True;
		Endif;

	EndDo;

	Return False;

EndFunction

&AtServer
Procedure CreateFieldGroups(FieldsQuery, SortFields, GroupsTotals, Balanced = "")
	
	Plan = mAccountingRegister.ChartOfAccounts;
	
	If Plan = Undefined OR Plan.ExtDimensionTypes = Undefined Then
		NumberExtDimension = 0;
	Else
		NumberExtDimension = NP.MaxExtDimensionCount;
	Endif;
	
	For each StrMGroup in mGroups Do
		Checked 			= False;
		KeySearch 				= StrReplace(StrMGroup.Key, "_WW", ".");
		BasicIndicator 	= Left(KeySearch, Find(KeySearch + ".", ".") - 1);
		Attribute 			= Mid(KeySearch, Find(KeySearch + ".", ".") + 1);
		HIERARCHY 			= ?(KeySearch = "Account" OR KeySearch = "BalancedAccount" OR (Groups AND Attribute = ""), " HIERARCHY", "");
		If NOT Plan = Undefined Then
			Checked = (BasicIndicator = "Recorder") OR (BasicIndicator = "Account") OR (BasicIndicator = "BalancedAccount");
		Endif;
		For each Dimension in mAccountingRegister.Dimensions Do
			If Dimension.Name = BasicIndicator Then
				Checked = True;
			Elsif Dimension.Name + "Balanced" = BasicIndicator AND NOT Dimension.Balance  Then
				Checked = True;
			Endif;
		EndDo;
		
		For Number = 1 To NumberExtDimension Do
			Checked = ("ExtDimension" + Number = BasicIndicator) OR ("BalancedExtDimension" + Number = BasicIndicator)OR Checked;
		EndDo;
		
		If Find(KeySearch, "ExtDimension")<>0  AND Find(KeySearch, "Value")<>0 Then
			If StructureContainsNames(mSorting, KeySearch) Then
				AddField(SortFields, mFieldsSeparator, KeySearch);
			Endif;
			KeySearch = StrReplace(KeySearch, "Value", ".Value");
			Checked = True;
		Endif;
		
		If Checked Then
			AdditionalBeg = ""; 
			AdditionalEnd = "";
			
			If StrMGroup.Value = New TypeDescription("String") Then
				AdditionalBeg = "SUBSTRING("; 
				AdditionalEnd = ", 1, 300)";
			Endif;
			
			AddField(FieldsQuery,       mFieldsSeparator, AdditionalBeg + KeySearch + AdditionalEnd + " AS " + StrReplace(KeySearch, ".", ""));
			FieldsQuery = FieldsQuery + mFieldsSeparator + "PRESENTATION(" + AdditionalBeg + KeySearch + AdditionalEnd + ") AS " + StrReplace(KeySearch, ".", "") + "Presentation";
			AddField(GroupsTotals, mFieldsSeparator, AdditionalBeg + KeySearch + AdditionalEnd + HIERARCHY);
			If StructureContainsNames(mSorting, StrReplace(KeySearch, ".", "_WW")) Then
				AddField(SortFields, mFieldsSeparator, AdditionalBeg + KeySearch + AdditionalEnd + ?(KeySearch = "Account" OR KeySearch = "BalancedAccount", ".Code", ""));
			Endif;
		Endif;
	EndDo;
	
EndProcedure

&AtServer
Procedure GenerateFieldsResource(FieldsQuery, FunctionsResults, NameOfTotal, AliasOfTotal)

	If StructureContainsNames(mTotals, NameOfTotal) Then
		For each Resource in NP.TVIndicators Do
			If Left(NameOfTotal, StrLen("Balanced")) = "Balanced" AND Resource.Balance Then
				Continue;	
			Endif;
			AddField(FieldsQuery,   mFieldsSeparator, Resource.Name + NameOfTotal + " AS " + Resource.LineNumber + AliasOfTotal);
			AddField(FunctionsResults, mFieldsSeparator, "SUM(" + Resource.LineNumber + AliasOfTotal + ")");
		EndDo;
	Endif;

EndProcedure

&AtServer
Function CalculateBalancesAndTransactions(mFilters, mBalanceAccount = Undefined, Periodicity = "")

	Query = New Query();
	
	FieldsQuery       	= "";
	FunctionsResults     	= "";
	GroupsTotals 	= "";
	ConditionOnAccount    	= "";
	ConditionOnBalancedAccount 	= "";
	ConditionOnFields    	= "";
	ConditionWhere    	= "";
	SortFields 		= "";
	
	If NOT Periodicity = "Period" Then
		AdditionPeriodsTable 	= "RegisterRecords";
		FieldsQuery 				= "SelfSustainingTurnover.Period";
		FunctionsResults 				= "MAX(SelfSustainingTurnover.Period)";
		SortFields 				= "SelfSustainingTurnover.Period";
	Endif;

	CreateFieldGroups(FieldsQuery, SortFields, GroupsTotals);
	
	DefineConditionOnFields(Query, ConditionOnFields, mFilters, 0);
	DefineConditionOnFields(Query, ConditionOnAccount, mFilters, 1);
	ConditionByTypeOfSubconto = ",";
	If NP.ExtDimensionTypeName = "" Then
		ConditionByTypeOfSubconto = "";
	Endif;

	If NOT mBalanceAccount = Undefined Then
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "TurnoverDr", 	"TurnoverDr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "TurnoverCr", 	"TurnoverCr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "BalancedTurnoverDr", "BalancedTurnoverDr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "BalancedTurnoverCr", "BalancedTurnoverCr");
		
		DefineConditionOnFields(Query, ConditionOnBalancedAccount, mFilters, 2);
		
		SourceRequest = "AccountingRegister." + NP.NameAccountingRegister + ".Turnovers(&_Date1, &_Date2, " + Periodicity + ", " + ConditionOnAccount + ConditionByTypeOfSubconto + ", " + ConditionOnFields + ", " + ConditionOnBalancedAccount + ConditionByTypeOfSubconto + ") AS SelfSustainingTurnover";
	Else
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "OpeningBalanceDr", 				"OpeningBalanceDr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "OpeningBalanceCr", 				"OpeningBalanceCr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "OpeningSplittedBalanceDr", 	"OpeningSplittedBalanceDr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "OpeningSplittedBalanceCr", 	"OpeningSplittedBalanceCr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "ClosingBalanceDr", 				"ClosingBalanceDr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "ClosingBalanceCr", 				"ClosingBalanceCr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "ClosingSplittedBalanceDr", 	"ClosingSplittedBalanceDr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "ClosingSplittedBalanceCr", 	"ClosingSplittedBalanceCr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "TurnoverDr", 						"TurnoverDr");
		GenerateFieldsResource(FieldsQuery, FunctionsResults, "TurnoverCr", 						"TurnoverCr");
		
		SourceRequest = "AccountingRegister." + NP.NameAccountingRegister + ".BalanceAndTurnovers(&_Date1, &_Date2, " + Periodicity + ", " + AdditionPeriodsTable + ", " + ConditionOnAccount + ConditionByTypeOfSubconto + ", " + ConditionOnFields + ") AS SelfSustainingTurnover";
		
	Endif;
	
	//Plan 	= mAccountingRegister.ChartOfAccounts;
	//NumberExtDimension 	= ?(Plan = Undefined OR Plan.ExtDimensionTypes = Undefined,0, NP.MaxExtDimensionCount);
	//For each StrMGroup in mGroups Do
	//	AddDataTab(StrMGroup.Key, Query, SourceRequest, NumberExtDimension);
	//EndDo;
	//For each Element in mFilters Do
	//	AddDataTab(Element.KeySearch, Query, SourceRequest, NumberExtDimension);
	//EndDo;
//&AtServer
//Procedure AddDataTab(KeySearch, Query, SourceRequest, NumberExtDimension)
//	If Find(KeySearch, "ExtDimension")<>0 AND Find(KeySearch, "Value")<>0 Then
//		Field 		= "";
//		PrExtDimension 	= GetPropertyOnID(KeySearch, NumberExtDimension, Field);
//		If ValueIsFilled(PrExtDimension) Then
//			If NP.PropertiesOfPeriodic Then
//				SourceRequest = SourceRequest + Chars.LF + 
//				"	LEFT JOIN InformationRegister.ValuesOfPropertiesOfObjects.SliceLast(&_Date2, Property = &Parameter" + KeySearch + ") AS " + StrReplace(KeySearch, "Value", "") + "
//				|	ON " + StrReplace(KeySearch, "Value", "")  + ".Object = " + Field;
//			Else    
//				SourceRequest = SourceRequest + Chars.LF + 
//				"	LEFT JOIN InformationRegister.ValuesOfPropertiesOfObjects AS " + StrReplace(KeySearch, "Value", "")  + "
//				|	ON " + KeySearch + ".Object = " + Field + "
//				|	AND " + StrReplace(KeySearch, "Value", "")  + ".Property = &Parameter" + KeySearch;
//				
//			Endif;
//			Query.SetParameter("Parameter" + KeySearch, PrExtDimension);
//		Endif;
//	Endif;
//EndProcedure

		
	Query.SetParameter("_Date1", mDateQuery1);
	Query.SetParameter("_Date2", mDateQuery2);
	
	Query.Text = 
	"SELECT ALLOWED
	|	" + FieldsQuery + "
	|FROM
	|	" + SourceRequest;
	
	If NOT TrimAll(ConditionWhere) = "" Then
		Query.Text = 	Query.Text + 
		"
		|WHERE
		|	" + ConditionWhere ;
	Endif;
	
	If NOT TrimAll(GroupsTotals) = "" Then
		Query.Text = 	Query.Text + 
		"
		|ORDER BY
		|	" + SortFields + "
		|TOTALS
		|	" + FunctionsResults + "
		|BY
		|	" + GroupsTotals;
	Endif;

	Return Query.Execute();

EndFunction

&AtServer
Function GetAT(Turn = "Account", pFilter = Undefined, StrOwner = Undefined, TypeTurn = Undefined)
	Var Account,BalancedAccount;
	
	If TypeOf(pFilter) = Type("ValueTable") Then
		Filter = pFilter.Copy();
	Elsif TypeOf(pFilter) = Type("String") Then
		Filter = ValueFromStringInternal(pFilter);
		If TypeOf(Filter) <> Type("ValueTable") Then
			Filter = ToCreateFilter();
		Endif;           
	Else
		Filter = ToCreateFilter();
	Endif;
	GetPresentationFilter(Filter, "Account", 		Account);
	GetPresentationFilter(Filter, "BalancedAccount", 	BalancedAccount);
	BalancedAccount 	= ?(Turn = "BalancedAccount" AND BalancedAccount = Undefined, "", BalancedAccount);
	
	mAccountingRegister = Metadata.AccountingRegisters[NP.NameAccountingRegister];
	OpeningBalancec 	= "OpeningBalanceDr, OpeningBalanceCr, OpeningSplittedBalanceDr, OpeningSplittedBalanceCr";
	ClosingBalances  	= "ClosingBalanceDr,  ClosingBalanceCr,  ClosingSplittedBalanceDr,  ClosingSplittedBalanceCr";
	Balance  			= "BalanceDr, BalanceCr, SplittedBalanceDr, SplittedBalanceCr";
	Turnovers				= "TurnoverDr, TurnoverCr";
	BalancedTurnover			= "BalancedTurnoverDr, BalancedTurnoverCr"; 
	mTotals 				= New Structure(Balance + ", " + OpeningBalancec + ", " + ClosingBalances + ", " + Turnovers + ", " + BalancedTurnover);
	mGroups 		= New Structure(StrReplace(Turn, ".", "_WW"), TypeTurn);
	mSorting 		= New Structure(StrReplace(Turn, ".", "_WW"), TypeTurn);
									   
	mFilters 			= ToCreateFilter();

	If Find(Turn, "Peeriod") <> 0 Then
		mGroups 		= New Structure();	
		mSorting 		= New Structure();	
		mFrequency 		= StrReplace(Turn, "Peeriod.", "");
	Else
		mFrequency 		= "Period";
		mFrequency 		= ?(Find(Turn, "Recorder") = 0, mFrequency, "Recorder");
		mFrequency 		= ?(Find(Turn, "Еntry") = 0, mFrequency, "Еntry");
	Endif;
	
	DatesAreSet 		= False;
	mDateQuery1 	= NP.Date1;
	mDateQuery2 	= NP.Date2;
	For each Element in Filter Do
		If Find(Element.KeySearch, "Peeriod") > 0 Then
			If NOT DatesAreSet Then
				PeriodType 		= Mid(Element.KeySearch, Find(Element.KeySearch + ".", ".") + 1);
				mDateQuery1 	= BegOfDay(Element.Value);
				DatesAreSet 		= True;
				If PeriodType = "Year" 			Then mDateQuery2 = EndOfYear(mDateQuery1);
				Elsif PeriodType = "Quarter" 	Then mDateQuery2 = EndOfQuarter(mDateQuery1);
				Elsif PeriodType = "Month" 		Then mDateQuery2 = EndOfMonth(mDateQuery1); 
				Elsif PeriodType = "TenDays" 	Then mDateQuery2 = PeriodBorder(mDateQuery1, "TENDAYS", "ENDOFPERIOD"); 
				Elsif PeriodType = "Week" 	Then mDateQuery2 = EndOfWeek(mDateQuery1); 
				Elsif PeriodType = "Day" 		Then mDateQuery2 = EndOfDay(mDateQuery1);
				Endif;
			Endif;
			Continue;	
		Endif;
		
		AddToFilter(mFilters, Element.KeySearch, ?(Element.Value = "", Undefined, Element.Value), Element.ComparisonType);
	EndDo; 
	For each StrChange in NP.TVFilter Do
		If NOT GetPresentationFilter(mFilters,  StrChange.DataPath) AND StrChange.Use Then
			AddToFilter(mFilters, StrChange.DataPath, StrChange.Value, StrChange.ComparisonType);
		Endif;
	EndDo;
	
	If mFrequency = "Еntry" Then
		DataQuery 	= СalculateRecordsWithExtDimensions(mFilters, Account, BalancedAccount, StrOwner);
	Else
		DataQuery   = CalculateBalancesAndTransactions(mFilters, BalancedAccount, mFrequency);
	Endif;
	
	Return DataQuery;
EndFunction 

&AtServer
Function GetParentAccount()
	Query = New Query();
	Query.Text = "SELECT
	|	PlanOfParent.Ref AS Ref
	|FROM
	|	ChartOfAccounts.Хозрасчетный AS PlanOfParent
	|		INNER JOIN ChartOfAccounts.Хозрасчетный AS PlanChildren
	|		ON PlanOfParent.Ref = PlanChildren.Parent
	|
	|GROUP BY
	|	PlanOfParent.Ref
	|
	|ORDER BY
	|	PlanOfParent.Code";
	Query.Text = StrReplace(Query.Text, "Хозрасчетный", NP.NameChartOfAccounts);			   
	Return Query.Execute().Unload();

EndFunction

&AtServer
Function GetFilterValue(VT, KeySearch = "", Value = Undefined, Comparison = Undefined);
	Comparison = ?(Comparison = Undefined, DataCompositionComparisonType.Equal, Comparison);
	Result = False;
	FindStr = VT.Find(Value, "Value");
	If FindStr <> Undefined Then
		KeySearch 		= FindStr.KeySearch;
		Comparison	= FindStr.ComparisonType;
		Result 	= True;
	Endif;
	Return Result;
EndFunction

&AtServer
Procedure ToIssueRecursivelyAccount(Filter, Sample, Tab, BasicIndicator, IsBalancedAccount, Level, All = False, Prefix = "")
	ValSelect 			= Sample.Select(QueryResultIteration.ByGroupsWithHierarchy, BasicIndicator,);
	While ValSelect.Next() Do
		KeySearch = "";
		If GetFilterValue(Filter, KeySearch, ValSelect[BasicIndicator]) AND (KeySearch = BasicIndicator) AND CompareSelection(Filter, ValSelect[BasicIndicator], BasicIndicator) Then
			ToIssueRecursivelyAccount(Filter, ValSelect, Tab, BasicIndicator, IsBalancedAccount, Level, All, Prefix);
		Else	
			Presentation = Prefix + ?(ValueIsFilled(ValSelect[BasicIndicator]), TrimR(ValSelect[BasicIndicator].Code), "<...>") + ?(Prefix <> "", "","   " + ValSelect[BasicIndicator].Description);
			Deploy_ToHandleTotal(Tab, ValSelect, BasicIndicator, ValSelect[BasicIndicator], Presentation, Level, IsBalancedAccount,, ValSelect[BasicIndicator]);
			If All Then
				ToIssueRecursivelyAccount(Filter, ValSelect, Tab, BasicIndicator, IsBalancedAccount, Level, All, Prefix);
			Endif;
		Endif;
	EndDo;
EndProcedure

&AtServer
Procedure Deploy_ToHandleTotal(Tab, IT, Indicator, Value, Description, Level, TurnoversOnly = False, Filter = Undefined, Sort = Undefined)
	StrTab						= Tab.Add();
	StrTab.Level 				= Level;
	StrTab.Indicator			= Indicator;
	StrTab.Value				= Value;
	StrTab.Description			= Description;
	StrTab.TurnDr			= "+";
	FillPropertyValues(StrTab, IT,,);
	If Filter <> Undefined Then
		StrTab.Filter 	= ValueToStringInternal(Filter);
	Endif;
	
	If ValueIsFilled(Sort) AND ChartsOfAccounts.AllRefsType().ContainsType(TypeOf(Sort)) Then 
		StrTab.Sort 	= Sort.Order;
	Elsif Indicator = "Recorder" OR Indicator = "Еntry" Then
		StrTab.Sort 	= IT.Period;
	Elsif ValueIsFilled(Sort) AND Documents.AllRefsType().ContainsType(TypeOf(Sort)) Then 
		StrTab.Sort 	= Sort.Date;
	Else	
		StrTab.Sort 	= Sort;
	Endif;
	
EndProcedure 

&AtServer
Function CompareSelection(Filter, Value, Name)
	StrSearch = NP.TVFilter.FindRows(New Structure("DataPath, Value", Name, Value));
	If StrSearch.Count() = 1 Then
		StringBrace = Filter.FindRows(New Structure("KeySearch, Value", Name, Value));
		If StringBrace.Count() = 1 Then
			Return False;	
		Endif;
	Endif;
	Return True;	
EndFunction

&AtServer
Procedure ToIssueRecursivelyExtDimension(Filter, Sample, Tab, Indicator, IsBalancedAccount, Level)
	ValSelect 			= Sample.Select(QueryResultIteration.ByGroupsWithHierarchy, StrReplace(Indicator,".",""),);
	While ValSelect.Next() Do
		Vl 			= ?(ValSelect[StrReplace(Indicator,".","")] = Undefined, "", ValSelect[StrReplace(Indicator,".","")]);
		KeySearch 		= "";
		If GetFilterValue(Filter, KeySearch, Vl) AND (KeySearch = Indicator) Then
			ToIssueRecursivelyExtDimension(Filter, ValSelect, Tab, Indicator, IsBalancedAccount, Level);
		Else	
			Presentation 	= ?(ValueIsFilled(ValSelect[StrReplace(Indicator,".","")]),ValSelect[StrReplace(Indicator,".","") + "Presentation"], "<...>");
			If ValueIsFilled(Vl) AND Catalogs.AllRefsType().ContainsType(TypeOf(Vl)) AND Vl.IsFolder Then 
				Presentation = "[" + UPPER(Presentation) + "]" 
			Endif;
			Deploy_ToHandleTotal(Tab, ValSelect, Indicator, Vl, Presentation, Level, IsBalancedAccount,, Vl)
		Endif;
	EndDo;
EndProcedure

&AtServer
Function GetResourcesSection(VT, TVFilter, Indicator)
	_TV = VT.Copy();
	_TV.Clear();

	For each StrResource in VT Do 

		IndexOf = TVFilter.Count() - 1;
		While IndexOf >= 0 Do
			StrFilter 		= TVFilter[IndexOf];
			FindIndicators = NP.TVIndicators.FindRows(New Structure("NumberOwner",StrResource.LineNumber));
			
			If StrFilter.KeySearch = "Account" Then
				Add = True;
				For each StrIndicator in FindIndicators Do
					Add = Add AND (StrIndicator.AccountingFlag = "" OR StrFilter.Value[StrIndicator.AccountingFlag]); 	
				EndDo;
				If Add Then
					StrAlreadyHave = _TV.Find(StrResource.LineNumber, "LineNumber");
					If StrAlreadyHave = Undefined Then
						NewResource = _TV.Add();
						FillPropertyValues(NewResource, StrResource);
					Endif;
				Endif;
			Elsif Find(StrFilter.KeySearch, "ExtDimension")<>0 Then
				IdNum 		= Number(Mid(StrFilter.KeySearch, Find(StrFilter.KeySearch, "ExtDimension") + StrLen("ExtDimension"), 1))-1;
				Delete 	= False;
				Account 		= Undefined;
				GetPresentationFilter(TVFilter, ?(Find(StrFilter.KeySearch, "Balanced") = 0, "", "Balanced") + "Account", Account);
				
				For each StrIndicator in FindIndicators Do
					Delete = Delete  OR (StrIndicator.ExtDimensionAccountingFlag <> "" AND Account.ExtDimensionTypes.Count() > 0 AND Account.ExtDimensionTypes.Count() >= IdNum + 1 AND NOT Account.ExtDimensionTypes.Get(IdNum)[StrIndicator.ExtDimensionAccountingFlag]); 	
				EndDo;
				
				If Delete Then
					StrRemoval = _TV.Find(StrResource.LineNumber, "LineNumber");
					If StrRemoval <> Undefined Then
						_TV.Delete(StrRemoval);
					Endif;
				Endif;
			Elsif StrFilter.KeySearch = "BalancedAccount" Then
				Add = True;
				For each StrIndicator in FindIndicators Do
					Add = Add AND (StrIndicator.AccountingFlag = "" OR StrFilter.Value[StrIndicator.AccountingFlag]); 	
				EndDo;
				If Add Then
					StrAlreadyHave = _TV.Find(StrResource.LineNumber, "LineNumber");
					If StrAlreadyHave = Undefined Then
						NewResource = _TV.Add();
						FillPropertyValues(NewResource, StrResource);
						For each StrIndicator in FindIndicators Do
							If NOT StrIndicator.Balance Then
								NewResource.NameFormula = StrReplace(NewResource.NameFormula, StrIndicator.Name, StrIndicator.Name + "Balanced");
							Endif;
						EndDo;
					Endif;
				Endif;
			Endif;
			
			IndexOf = IndexOf - 1;
		EndDo;
	EndDo;
	
	Return _TV;
	
EndFunction

&AtServer
Function CalculateSB_ToSelectRule(Account)
	RuleNumber 		= Undefined; 
	If TypeOf(Account) = Type("Array") Then
		Return RuleNumber
	Endif;
	Vl 					= Account;
	While ValueIsFilled(Vl) Do
		RuleNumber = NP.TableTurnBalance.Find(Vl, "Account");
		If RuleNumber <> Undefined Then 
			Break 
		Endif;
		Vl = Vl.Parent;
	EndDo;
	
	Return RuleNumber
EndFunction 

&AtServer
Function CalculateSB(Account, FieldsBalance, FilterOwner, RuleNumber)
	
	QueryBuilder 					= New QueryBuilder;
	QueryBuilder.DataSource 	= New DataSourceDescription(RuleNumber.Result);
	For each StFilter in FilterOwner Do
		If StFilter.KeySearch = "Account.OffBalance" Then
			Continue;			
		Elsif Find(StFilter.KeySearch,".")<>0 Then
			Return False;
		Endif;
		If QueryBuilder.AvailableFields.Find(StFilter.KeySearch) = Undefined Then
			KeySelection = False;
			Return KeySelection;
		Endif;
		FilterItem 					= QueryBuilder.Filter.Add(StFilter.KeySearch);
		TypeSelection 						= TypeOf(StFilter.Value);
		FilterItem.Use 	= True;
		If Catalogs.AllRefsType().ContainsType(TypeSelection)
			OR ChartsOfAccounts.AllRefsType().ContainsType(TypeSelection) Then
			FilterItem.ComparisonType 		= ComparisonType.InHierarchy;
			FilterItem.Value 			= StFilter.Value;
		Elsif TypeSelection = Type("Array") Then
			FilterItem.ComparisonType 		= ComparisonType.InListByHierarchy;
			FilterItem.Value.LoadValues(StFilter.Value);
		Elsif TypeSelection = Type("ValueList") Then
			FilterItem.ComparisonType 		= ComparisonType.InListByHierarchy;
			FilterItem.Value.LoadValues(StFilter.Value.UnloadValues());
		Else
			FilterItem.ComparisonType 		= ComparisonType.Equal;
			FilterItem.Value 			= StFilter.Value;
		Endif;
	EndDo;
	QueryBuilder.Execute();
	FindResult = QueryBuilder.Result.Unload();
	
	For each StrRes in FindResult Do
		For each StrBalance in FieldsBalance Do
			If Find(StrBalance.Key, "Turnover")>0 Then
				Continue;				
			Endif;
			FieldsBalance[StrBalance.Key] = FieldsBalance[StrBalance.Key] + StrRes[StrReplace(StrBalance.Key,"Balance","SplittedBalance")];
		EndDo;
	EndDo;
	
	Return True
EndFunction 

&AtServer
Function IsSlitAccounting(Account, StrChange)
	If StrChange.AccountingFlag = "" Then
		Return True;	
	Endif;
	fUUID 		= New UUID;
	TemporaryStructure 	= New Structure(StrChange.AccountingFlag, fUUID);
	FillPropertyValues(TemporaryStructure, Account);
	
	If TemporaryStructure[StrChange.AccountingFlag] <> fUUID Then
		Return Account[StrChange.AccountingFlag];	
	Endif;
	Return False;    
EndFunction 

&AtServer
Function Expand(Owner = Undefined, Indicator = "Account", Level = 0, НandTurn = False, AdditionalTurn = Undefined, TypeTurn = Undefined) Export
	Var Filter, Account, BalancedAccount;
	
	If Owner <> Undefined Then
		Level 			= ?(Level = 0, Owner.Level + ?(((Indicator = "Account") and (Owner.Indicator = "Account")) or ((Indicator = "BalancedAccount") and (Owner.Indicator = "BalancedAccount")), 0, 1), Level);
		Filter 				= ValueFromStringInternal(Owner.Filter);
	Endif;
	If TypeOf(Filter) <> Type("ValueTable") Then
		Filter = ToCreateFilter();
	Endif;
	Level 			= ?(Level = 0, 1, Level);
	BasicIndicator 	= Left(Indicator, Find(Indicator + ".", ".") - 1);
	Attribute 			= Mid(Indicator, Find(Indicator + ".", ".") + 1);
	IsAccount 			= GetPresentationFilter(Filter, "Account", 	Account);
	IsBalancedAccount 		= GetPresentationFilter(Filter, "BalancedAccount", BalancedAccount);
	
	mFieldsSeparator 	= "," + Chars.LF + Chars.Tab;
	
	Tab = CreateStructureOfTV();
	
	For each StrAdditionalReversal in NP.TVFilter Do
		If StrAdditionalReversal.Use Then
			FindAndPasteItInFilter(Filter, StrAdditionalReversal.DataPath, StrAdditionalReversal.Value, StrAdditionalReversal.ComparisonType);
		Endif;
	EndDo;
	
	If BasicIndicator = "Account" Then
		Result 	= GetAT(BasicIndicator, Filter,, TypeTurn);
		IT 			= Result.Select(QueryResultIteration.ByGroupsWithHierarchy, ,);
		While IT.Next() Do
			If IsAccount AND TypeOf(Account) <> Type("Array") Then
				KeySearch = "";
				If GetFilterValue(Filter, KeySearch, IT.Account) AND (KeySearch = Indicator) Then
					ToIssueRecursivelyAccount(Filter, IT, Tab, BasicIndicator, IsBalancedAccount, Level, False);
				Endif
			Elsif DataOnSubAccounts Then
				Deploy_ToHandleTotal(Tab, IT, BasicIndicator, IT[BasicIndicator], TrimR(IT.Account.Code) + "    " + IT.Account.Description, Level, IsBalancedAccount,, IT.Account);
				ToIssueRecursivelyAccount(Filter, IT, Tab, BasicIndicator, IsBalancedAccount, Level, True);
			Else
				Deploy_ToHandleTotal(Tab, IT, BasicIndicator, IT[BasicIndicator], TrimR(IT.Account.Code) + "    " + IT.Account.Description, Level, IsBalancedAccount,, IT.Account);
			Endif;
		EndDo;
	Elsif BasicIndicator = "BalancedAccount" Then
		Result 	= GetAT(BasicIndicator, Filter,, TypeTurn);
		IT 			= Result.Select(QueryResultIteration.ByGroupsWithHierarchy, ,);
		While IT.Next() Do
			If IsBalancedAccount Then 
				If GetFilterValue(Filter, KeySearch, IT.BalancedAccount) AND (KeySearch = Indicator) Then
					ToIssueRecursivelyAccount(Filter, IT, Tab, BasicIndicator, True, Level, False,"в корреспонденции со сч. ");
				Endif
			Elsif DataOnSubAccounts Then 
				Deploy_ToHandleTotal(Tab, IT, BasicIndicator, IT[BasicIndicator], "в корреспонденции со сч. " + ?(ValueIsFilled(IT.BalancedAccount), TrimR(IT.BalancedAccount.Code), "<...>"), Level, True,, IT.BalancedAccount);
				ToIssueRecursivelyAccount(Filter, IT, Tab, BasicIndicator, True, Level, True, "в корреспонденции со сч. ");	
			Else
				Deploy_ToHandleTotal(Tab, IT, BasicIndicator, IT[BasicIndicator], "в корреспонденции со сч. " + ?(ValueIsFilled(IT.BalancedAccount), TrimR(IT.BalancedAccount.Code), "<...>"), Level, True,, IT.BalancedAccount);
			Endif
		EndDo;
	Elsif BasicIndicator = "Еntry" Then	
		Result 		= GetAT(BasicIndicator, Filter, Owner, TypeTurn);
		For each StrResult in Result Do
			Vl 			= ?(StrResult[BasicIndicator] = Undefined, "", StrResult[StrReplace(BasicIndicator,".","")]);
			Deploy_ToHandleTotal(Tab, StrResult, BasicIndicator, Vl, StrResult[StrReplace(Indicator,".","")], Level, IsBalancedAccount, Filter, Vl);				
		EndDo;
	Elsif BasicIndicator = "Peeriod" Then
		Result 		= GetAT(Indicator, Filter,, TypeTurn);
		IT 				= Result.Select(QueryResultIteration.ByGroupsWithHierarchy, ,);
		While IT.Next() Do
			Vl 				= IT.Period;
			If Attribute = "Year" 			Then Presentation = PeriodPresentation(BegOfDay(Vl), EndOfYear(Vl));
			Elsif Attribute = "Quarter" 	Then Presentation = PeriodPresentation(BegOfDay(Vl), EndOfQuarter(Vl));
			Elsif Attribute = "Month" 	Then Presentation = PeriodPresentation(BegOfDay(Vl), EndOfMonth(Vl));
			Elsif Attribute = "TenDays" 	Then 
				D1 = Vl;
				D2 = PeriodBorder(Vl, "TENDAYS", "ENDOFPERIOD"); 
				Presentation = PeriodPresentation(BegOfDay(D1), EndOfDay(D2));
			Elsif Attribute = "Week" 	Then Presentation = PeriodPresentation(BegOfDay(Vl), EndOfWeek(Vl));
			Elsif Attribute = "Day" 	Then Presentation = PeriodPresentation(BegOfDay(Vl), EndOfDay(Vl));
			Endif;
			Deploy_ToHandleTotal(Tab, IT, Indicator, Vl, Presentation, Level, IsBalancedAccount,, Vl)
		EndDo;
		
	Else
		Result 		= GetAT(Indicator, Filter,, TypeTurn);
		IT 				= Result.Select(QueryResultIteration.ByGroupsWithHierarchy, ,);
		While IT.Next() Do
			Vl 			= ?(IT[StrReplace(Indicator, ".", "")] = Undefined, "", IT[StrReplace(Indicator,".","")]);
			KeySearch 		= "";
			If GetFilterValue(Filter, KeySearch, Vl) AND (KeySearch = Indicator) Then
				ToIssueRecursivelyExtDimension(Filter, IT, Tab, Indicator, IsBalancedAccount, Level);
			Else
				Presentation 	= ?(ValueIsFilled(IT[StrReplace(Indicator,".","")]),IT[StrReplace(Indicator,".","") + "Presentation"], "<...>");
				If ValueIsFilled(Vl) AND Catalogs.AllRefsType().ContainsType(TypeOf(Vl)) AND Vl.IsFolder Then 
					Presentation = "[" + UPPER(Presentation) + "]" 
				Endif;
				Deploy_ToHandleTotal(Tab, IT, Indicator, Vl, Presentation, Level, IsBalancedAccount,, Vl)
			Endif;
		EndDo;
	Endif;
	
	//Tab.Sort("Sort");
	For each StrTab in Tab Do
		TemporaryFilter 		= Filter.Copy();
		AddToFilter(TemporaryFilter, Indicator, ?(StrTab.Value = Undefined, "", StrTab.Value));
		TemporaryFilter 		= TemporaryFilter.Copy();
		StrTab.Filter 	= ValueToStringInternal(TemporaryFilter);
		
		StrTab.TVResources = GetResourcesSection(NP.TVResourcesFilter, TemporaryFilter, BasicIndicator);
		
		GetPresentationFilter(TemporaryFilter, "Account", Account);
		RuleNumber 	= CalculateSB_ToSelectRule(Account);

		If ApplyDetailedBalance AND (RuleNumber <> Undefined) AND BalancedAccount = Undefined AND Attribute = "" Then
			FieldsBalance = ValueFromStringInternal(NP.StrFieldStructure);
			If CalculateSB(Account, FieldsBalance, TemporaryFilter, RuleNumber) Then
				
				For each Resource in NP.TVIndicators Do
					OpeningBalance = (FieldsBalance[Resource.LineNumber+"OpeningBalanceDr"]-FieldsBalance[Resource.LineNumber+"OpeningBalanceCr"])
										-(StrTab[Resource.LineNumber+"OpeningBalanceDr"]-StrTab[Resource.LineNumber+"OpeningBalanceCr"]); 
					ClosingBalance = (FieldsBalance[Resource.LineNumber+"ClosingBalanceDr"]-FieldsBalance[Resource.LineNumber+"ClosingBalanceCr"])
										-(StrTab[Resource.LineNumber+"ClosingBalanceDr"]-StrTab[Resource.LineNumber+"ClosingBalanceCr"]); 
					
					If OpeningBalance = 0 AND ClosingBalance = 0 Then
						StrTab[Resource.LineNumber+"OpeningBalanceDr"] = FieldsBalance[Resource.LineNumber+"OpeningBalanceDr"];
						StrTab[Resource.LineNumber+"OpeningBalanceCr"] = FieldsBalance[Resource.LineNumber+"OpeningBalanceCr"];
						StrTab[Resource.LineNumber+"ClosingBalanceDr"] 	= FieldsBalance[Resource.LineNumber+"ClosingBalanceDr"];
						StrTab[Resource.LineNumber+"ClosingBalanceCr"] 	= FieldsBalance[Resource.LineNumber+"ClosingBalanceCr"];
					Else
						Message("Ошибка расчета развернутого сальдо по сч." + Account);
					Endif;
				EndDo;
			Endif;
		Endif;
		
		CopyOfSupplementaryPivot = Undefined;
		If AdditionalTurn <> Undefined AND AdditionalTurn.Count() > 0 Then
			NewString 				= NP.SettingsTurns.Add();
			NewString.Value 		= StrTab.Filter;
			NewString.ValueType		= AdditionalTurn[0].Value.ValueType;
			NewString.Presentation 	= AdditionalTurn[0].Value.DataPath;
			If Owner <> Undefined Then
				NewString.Owner = Owner.Filter;
			Endif;
			If AdditionalTurn.Count() > 1 Then
				CopyOfSupplementaryPivot = AdditionalTurn.Copy();
				CopyOfSupplementaryPivot.Delete(0);
			Endif;
		Endif;
		FoundStory = NP.SettingsTurns.Find(StrTab.Filter, "Value");
		If FoundStory <> Undefined Then
			Expand(StrTab, FoundStory.Presentation,, True, CopyOfSupplementaryPivot, FoundStory.ValueType);
		Else
			For each StrChange in NP._TVDimensions Do
				SetValue 	= Undefined;
				Found 		= GetPresentationFilter(TemporaryFilter, StrChange.Name, SetValue);
				
				If (StrChange.Todeploy AND (NOT Found OR (TypeOf(SetValue) = Type("ValueList") AND SetValue.Count()>1)))
					AND ((Account <> Undefined AND IsSlitAccounting(Account, StrChange)) OR (BalancedAccount<>Undefined AND IsSlitAccounting(BalancedAccount, StrChange))) Then
					Expand(StrTab, StrChange.Name) 
				Endif;
			EndDo;
		Endif;
	EndDo;
	
	If Owner <> Undefined Then
		Owner.TurnDr 			= "-";
		Owner.НandTurn 		= НandTurn;
		Owner.TabTurn 			= Tab.Copy();
		Owner.IndicatorRegister 	= Indicator;
	Endif;
	
	Return Tab
	
EndFunction 

&AtClient
Procedure AccountingRegister(Command)
	
	RegisterButton 			= Items.Find(NameAccountingRegister);
	RegisterButton.Check 	= False;
	
	RegisterButton 			= Items.Find(Command.Name);
	RegisterButton.Check 	= True;
	
	Items.AccountingRegister.Title = ?(Command.Name = "Хозрасчетный", "Бухгалтерский", Command.Name);
	
	AccountingRegisterAtServer(Command.Name);
	
EndProcedure

&AtServer
Procedure AccountingRegisterAtServer(NameOfRegister)
	NP = GetFromTempStorage(AddressStorage);
	
	If NP.PlansAndRegisters.Count()>0 Then
		StrSearch = NP.PlansAndRegisters.Find(NameOfRegister, "AccountingRegister");	
		If StrSearch = Undefined Then
			StrSearch = NP.PlansAndRegisters[0];	
		Endif;	
		NameAccountingRegister 	= StrSearch.AccountingRegister;
		NameChartOfAccounts 			= StrSearch.ChartOfAccounts;
		ExtDimensionTypeName 			= StrSearch.ExtDimensionType;
	Endif;
	NP.Insert("NameAccountingRegister", 	NameAccountingRegister);
	NP.Insert("NameChartOfAccounts", 			NameChartOfAccounts);
	NP.Insert("ExtDimensionTypeName", 			ExtDimensionTypeName);
	
	DetailedBalanceTV = SplittedBalance.Unload();	
	ColumnTurnsNew();
	PopulateListOfRulesEA(DetailedBalanceTV);
	
	AccountingReg 			= Metadata.AccountingRegisters[NameAccountingRegister];
	MaxExtDimensionCount 	= AccountingReg.ChartOfAccounts.MaxExtDimensionCount;	
	NP.Insert("MaxExtDimensionCount", MaxExtDimensionCount);
	NP.TVDimensions.Clear();
	For each Dimension in AccountingReg.Dimensions Do
		StrTVDimensions 				= NP.TVDimensions.Add();
		StrTVDimensions.Name 			= Dimension.Name;
 		StrTVDimensions.AccountingFlag	= ?(Dimension.AccountingFlag<>Undefined, Dimension.AccountingFlag.Name, "");
		StrTVDimensions.Value 	= Dimension.Type.AdjustValue();
		StrTVDimensions.Balance 	= Dimension.Balance;
		StrTVDimensions.Synonym 		= Dimension.Synonym;
 	EndDo;	
	
	NP.Insert("TVAccountsOfParents", 		GetParentAccount());
	
	FirstSection = New ValueList;
		
	CompleteTVResources(AccountingReg);	
		
	IndicatorsReport();	
	
	CreateSelection();
	
	If GetFirstBalance() = Undefined Then
		Items.fFirstSection.Visible = False;	
	Else
		Items.fFirstSection.Visible = True;	
	Endif;
	
	PutToTempStorage(NP, AddressStorage);
	
EndProcedure

&AtServer
Procedure CompleteInitialSettings() Export
	
	NP = New Structure(); 
	
	NP.Insert("SettingsTurns", 							New ValueTable);
	NP.SettingsTurns.Columns.Add("Value",			New TypeDescription("String"));
	NP.SettingsTurns.Columns.Add("Presentation", 	New TypeDescription("String"));
	NP.SettingsTurns.Columns.Add("Owner",			New TypeDescription("String"));
	NP.SettingsTurns.Columns.Add("ValueType",);
	
	NP.Insert("StructureAppearance", 	New Structure);
	NP.Insert("Sections", 				New ValueTable);
	
	NP.Sections.Columns.Add("SectionName", 	New TypeDescription("String"));
	NP.Sections.Columns.Add("Section");
	NP.Sections.Columns.Add("SectionWidth", 	New TypeDescription("Number"));
	NP.Sections.Columns.Add("Fields"); 
	
	NP.Insert("PlansAndRegisters", 		New ValueTable);
	
	NP.PlansAndRegisters.Columns.Add("AccountingRegister",	New TypeDescription("String"));
	NP.PlansAndRegisters.Columns.Add("ChartOfAccounts",			New TypeDescription("String"));	
	NP.PlansAndRegisters.Columns.Add("ExtDimensionType",		New TypeDescription("String"));	
	
	For each Restr in Metadata.AccountingRegisters Do
		NewStr 					= NP.PlansAndRegisters.Add();	
		NewStr.AccountingRegister = Restr.Name;
		NewStr.ChartOfAccounts 		= Restr.ChartOfAccounts.Name;
		NewStr.ExtDimensionType 		= ?(Restr.ChartOfAccounts.ExtDimensionTypes = Undefined, "", Restr.ChartOfAccounts.ExtDimensionTypes.Name);
		
		NewTeam = Commands.Add(NewStr.AccountingRegister);
		NewTeam.Title 	= NewStr.AccountingRegister;
		NewTeam.Action 	= "AccountingRegister";
		
		FormButton 			= Items.Add(NewStr.AccountingRegister, Type("FormButton"), Items.AccountingRegister);
		FormButton.Type 		= FormButtonType.UsualButton;
		FormButton.CommandName 	= NewStr.AccountingRegister;
		FormButton.Title   = ?(NewStr.AccountingRegister = "Хозрасчетный", "Бухгалтерский", NewStr.AccountingRegister);
		
	EndDo;

	If NP.PlansAndRegisters.Count() < 2 Then
		 Items.AccountingRegister.Visible = False;
	Endif;
	
	If NP.PlansAndRegisters.Count()>0 Then
		If ValueIsFilled(NameAccountingRegister) Then
			StrSearch = NP.PlansAndRegisters.Find(NameAccountingRegister, "AccountingRegister");	
		Else	
			StrSearch = NP.PlansAndRegisters.Find("Хозрасчетный", "AccountingRegister");	
		Endif;
		If StrSearch = Undefined Then
			StrSearch = NP.PlansAndRegisters[0];	
		Endif;	
		NameAccountingRegister 	= StrSearch.AccountingRegister;
		NameChartOfAccounts 			= StrSearch.ChartOfAccounts;
		ExtDimensionTypeName 			= StrSearch.ExtDimensionType;
		FormButton 			= Items.Find(NameAccountingRegister);
		FormButton.Check 	= True;
	Endif;
	NP.Insert("NameAccountingRegister", 	NameAccountingRegister);
	NP.Insert("NameChartOfAccounts", 			NameChartOfAccounts);
	NP.Insert("ExtDimensionTypeName", 			ExtDimensionTypeName);
	
	NP.Insert("TVAccountsOfParents", 		GetParentAccount());
	
	NP.Insert("TVResources", 								New ValueTable);
	NP.TVResources.Columns.Add("LineNumber",			New TypeDescription("String"));	
	NP.TVResources.Columns.Add("Use",			New TypeDescription("Boolean"));	
	NP.TVResources.Columns.Add("Name",					New TypeDescription("String"));	
	NP.TVResources.Columns.Add("NameFormula",				New TypeDescription("String"));	
	NP.TVResources.Columns.Add("Balance",				New TypeDescription("Boolean"));	
	NP.TVResources.Columns.Add("FormatP",				New TypeDescription("String"));	
	NP.TVResources.Columns.Add("ShortName",				New TypeDescription("String"));	
	NP.TVResources.Columns.Add("Synonym",				New TypeDescription("String"));	
	NP.TVResources.Columns.Add("AccountingFlag",			New TypeDescription("String"));	
	NP.TVResources.Columns.Add("ExtDimensionAccountingFlag",	New TypeDescription("String"));	
	
	If IndicatorRegister.Count() = 0 Then
		FillPerformanceRegisters();
	Endif;
	
	AccountingReg 		= Metadata.AccountingRegisters[NameAccountingRegister];
	MaxExtDimensionCount 	= AccountingReg.ChartOfAccounts.MaxExtDimensionCount;	
	NP.Insert("MaxExtDimensionCount", MaxExtDimensionCount);
	
	NP.Insert("TVDimensions", 								New ValueTable);
	NP.TVDimensions 			= New ValueTable;
	NP.TVDimensions.Columns.Add("Name",				New TypeDescription("String"));	
	NP.TVDimensions.Columns.Add("Todeploy",	New TypeDescription("Boolean"));	
	NP.TVDimensions.Columns.Add("Balance",		New TypeDescription("Boolean"));	
	NP.TVDimensions.Columns.Add("AccountingFlag",	New TypeDescription("String"));	
	NP.TVDimensions.Columns.Add("FullName",		New TypeDescription("String"));	
	NP.TVDimensions.Columns.Add("Synonym",			New TypeDescription("String"));	
	NP.TVDimensions.Columns.Add("Value");	
	NP.TVDimensions.Columns.Add("Picture");
	
	For each Dimension in AccountingReg.Dimensions Do
		StrTVDimensions 				= NP.TVDimensions.Add();
		StrTVDimensions.Name 			= Dimension.Name;
 		StrTVDimensions.AccountingFlag	= ?(Dimension.AccountingFlag<>Undefined, Dimension.AccountingFlag.Name, "");
		StrTVDimensions.Value 	= Dimension.Type.AdjustValue();
		StrTVDimensions.Balance 	= Dimension.Balance;
		StrTVDimensions.Synonym 		= Dimension.Synonym;
 	EndDo;	
		
	NP.Insert("FieldDecoding", Undefined);
	NP.FieldDecoding 		= New Structure("TurnDr,DetailsStr,Details,DetailsTurnoverDr,DetailsTurnoverCr", 
	New Structure("Details, NumStr, Type", "TurnDr", 0, ""), 
	New Structure("Details, NumStr, Type", "DetailsStr", 0, ""),
	New Structure("Details, NumStr, Type", "Details", 0, ""),
	New Structure("Details, NumStr, Type", "DetailsTurnoverDr", 0, ""),
	New Structure("Details, NumStr, Type", "DetailsTurnoverCr", 0, ""));
	
	ObjectReport = FormAttributeToValue("InteractiveTBS");	

	NP.Insert("Template", ObjectReport.GetTemplate("Table"));	

	CompleteTVResources(AccountingReg);	

	IndicatorsReport();	
	
	ColumnTurnsNew();                                             
	
	NP.Insert("NumberLayoutDesign", Undefined);
	LoadLayoutOformlenieVNP();
	
	CreateSelection();
	
	If GetFirstBalance() = Undefined Then
		Items.fFirstSection.Visible = False;	
	Else
		Items.fFirstSection.Visible = True;	
	Endif;
	
	PutToTempStorage(NP, AddressStorage);
		
EndProcedure

&AtServer
Procedure ToUpdateSelectionAtServer() Export
	
	NP = GetFromTempStorage(AddressStorage);
	UpdateSelection();
	
EndProcedure

&AtServer
Procedure CreateSelection() Export
	
	DCS 				= New DataCompositionSchema;
	DataSource 		= DCS.DataSources.Add();
	DataSource.Name 	= "MainDataSource";
	DataSource.DataSourceType = "Local";
	
	DataSet 				= DCS.DataSets.Add(Type("DataCompositionSchemaDataSetQuery"));
	DataSet.Name 			= "MainDataset";
	DataSet.DataSource 	= DataSource.Name;
	
	DCS.TotalFields.Clear();
			
	TextSelectedFields 	= "";
	TextFieldsQuery 	= "";
	
	For each StrChange in NP.TVDimensions Do
		TextSelectedFields 				= TextSelectedFields + ", Turnovers." + StrChange.Name + ".*";
		AddFieldDataSet(DCS.DataSets[0], StrChange.Name, StrChange.Synonym,, TextFieldsQuery);
	EndDo;
	
	TextSelectedFields 		= TextSelectedFields + ", Turnovers.Account.*";
	TextFieldsQuery 		= TextFieldsQuery + ", Turnovers.Account AS Account";
	For N = 1 To NP.MaxExtDimensionCount Do
		TextSelectedFields 	= TextSelectedFields + ", Turnovers.ExtDimension" + N + ".* ";
		TextFieldsQuery 	= TextFieldsQuery + ", Turnovers.ExtDimension" + N + " AS ExtDimension" + N + " ";
	EndDo;
		
	//For each Resource in NP.TVIndicators Do
	//
	//	AddFieldDataSet(DCS.DataSets[0], Resource.Name + "OpeningBalance", Resource.Synonym + " нач. остаток", Resource.Name + "OpeningBalance", TextFieldsQuery);
	//	AddFieldDataSet(DCS.DataSets[0], Resource.Name + "OpeningSplittedBalanceDr", Resource.Synonym + " нач. развернутый остаток Дт", Resource.Name + "OpeningSplittedBalanceDr", TextFieldsQuery);
	//	AddFieldDataSet(DCS.DataSets[0], Resource.Name + "OpeningSplittedBalanceCr", Resource.Synonym + " нач. развернутый остаток Кт", Resource.Name + "OpeningSplittedBalanceCr", TextFieldsQuery);
	//	AddFieldDataSet(DCS.DataSets[0], Resource.Name + "Turnover", Resource.Synonym + " оборот", Resource.Name + "Turnover", TextFieldsQuery);
	//	AddFieldDataSet(DCS.DataSets[0], Resource.Name + "ClosingBalance", Resource.Synonym + " кон. остаток", Resource.Name + "ClosingBalance", TextFieldsQuery);
	//	AddFieldDataSet(DCS.DataSets[0], Resource.Name + "ClosingSplittedBalanceDr", Resource.Synonym + " кон. развернутый остаток Дт", Resource.Name + "ClosingSplittedBalanceDr", TextFieldsQuery);
	//	AddFieldDataSet(DCS.DataSets[0], Resource.Name + "ClosingSplittedBalanceCr", Resource.Synonym + " кон. развернутый остаток Кт", Resource.Name + "ClosingSplittedBalanceCr", TextFieldsQuery);
	//	                        FilterAvailableFields    Parameters	ПараметрыСхемыКомпоновкиДанных	ПараметрыСхемыКомпоновкиДанных
	//EndDo;
	TextSelectedFields 	= Mid(TextSelectedFields, 3);
	TextFieldsQuery 	= Mid(TextFieldsQuery, 3);
	
	QueryText = 
	"SELECT ALLOWED
	|	" + TextFieldsQuery + " 
	|" + ?(ValueIsFilled(TextSelectedFields), "{SELECT " + StrReplace(TextSelectedFields, "Turnovers.", "") + "}", "") + "
	|FROM
	|	AccountingRegister." + NP.NameAccountingRegister + ".BalanceAndTurnovers AS Turnovers
	|" + ?(ValueIsFilled(TextSelectedFields), "{WHERE " + TextSelectedFields + "}", "");
	
	DCS.DataSets[0].Query = QueryText;
	
	ParameterDCS 							= DCS.Parameters.Add();
	ParameterDCS.Name 						= "НачалоПериода";
	ParameterDCS.ValueType 				= New TypeDescription("Дата");
	ParameterDCS.IncludeInAvailableFields 		= False;
	ParameterDCS.UseRestriction 	= True;
	
	ParameterDCS 							= DCS.Parameters.Add();
	ParameterDCS.Name 						= "КонецПериода";
	ParameterDCS.ValueType 				= New TypeDescription("Дата");
	ParameterDCS.IncludeInAvailableFields 		= False;
	ParameterDCS.UseRestriction 	= True;
	
	DataCompositionSchema = PutToTempStorage(DCS, UUID);	
		
 	InteractiveTBS.SettingsComposer.Initialize(New DataCompositionAvailableSettingsSource(DataCompositionSchema));
	
	InteractiveTBS.SettingsComposer.Refresh(); 
	InteractiveTBS.SettingsComposer.Settings.Structure.Clear();
	
	InteractiveTBS.SettingsComposer.Settings.Selection.Items.Clear();
	InteractiveTBS.SettingsComposer.LoadSettings(DCS.DefaultSettings);
	
	StringsFilter = TVFiltersOnRegisters.FindRows(New Structure("Register", NP.NameAccountingRegister));
	
	SetupSelection = InteractiveTBS.SettingsComposer.Settings;
	
	For each StrToFilter In StringsFilter Do
		
		CompositionField 	= New DataCompositionField(StrToFilter.DataPath);
		NewSelection 		= SetupSelection.Filter.Items.Add(Type("DataCompositionFilterItem"));
		
		FillPropertyValues(NewSelection, StrToFilter); 
		NewSelection.LeftValue  = CompositionField;
		NewSelection.RightValue = StrToFilter.Value;
		
		FirstBalance = GetFirstBalance();	
		If FirstBalance <>  Undefined AND FirstBalance.Name = StrToFilter.DataPath Then
			If TypeOf(StrToFilter.Value) = Type("ValueList") Then
				FirstSection = StrToFilter.Value.Copy();	
			Else	
				FirstSection = StrToFilter.Value;	
			Endif;
		Endif;
		
		If StrToFilter.DataPath = "Account.OffBalance" Then
			OffBalanceAccount = StrToFilter.Value;	
		Endif;
		
	EndDo;
	
	UpdateSelection();
	
EndProcedure

&AtServer
Procedure UpdateSelection()
	
	FirstBalance = GetFirstBalance();	
	If FirstBalance <>  Undefined  Then
		
		StringFilter = GetCompositionFilter(FirstBalance.Name);
		If StringFilter <> Undefined Then
			
			StringFilter.ComparisonType   = DataCompositionComparisonType.InList;
			StringFilter.RightValue = FirstSection.Copy();
			
			If FirstSection.Count() = 0 AND TypeOf(FirstBalance.Value) <> Type("ValueList") Then
				FirstSection.Add(FirstBalance.Value);
			Endif;
			AddTVSelectionRegister(StringFilter);			
			
		Endif;
	Endif;
	
	If NOT OffBalanceAccount Then
	
		StringFilter = GetCompositionFilter("Account.OffBalance");
		If StringFilter <> Undefined Then
			StringFilter.RightValue = False;
			AddTVSelectionRegister(StringFilter);			
		Endif;
		
	Else 
		
		StringFilter = GetCompositionFilter("Account.OffBalance", False);
		If StringFilter <> Undefined Then
			RemoveTVFiltersOnRegisters(StringFilter);
			InteractiveTBS.SettingsComposer.Settings.Filter.Items.Delete(StringFilter);
		Endif;
		
	Endif;
	
EndProcedure

&AtServer
Function GetFirstBalance()
	
	Result = Undefined;
			
	RowTVMeasurement = NP.TVDimensions.FindRows(New Structure("Balance", True));
	
	For each Str In RowTVMeasurement Do
	
		StringFilter = GetCompositionFilter(Str.Name);
		If StringFilter <> Undefined Then
		
			Result = Str;
			Break;
		
		Endif;
	
	EndDo;
	
	Return Result;
	
EndFunction

&AtServer
Function GetCompositionFilter(FieldName, Create = True) Export
	
	Result 		= Undefined;
	SetupSelection = InteractiveTBS.SettingsComposer.Settings;
	
	CompositionField = New DataCompositionField(FieldName);
	Field = SetupSelection.FilterAvailableFields.FindField(CompositionField);
	If Field <> Undefined Then
		
		For each FilterItem In SetupSelection.Filter.Items Do
			If FilterItem.LeftValue = CompositionField Then
				Result = FilterItem;
				Break;
			Endif;		
		EndDo;
		
		If Create AND Result = Undefined Then
			Result = SetupSelection.Filter.Items.Add(Type("DataCompositionFilterItem"));
			Result.Use  = True;
			Result.LeftValue  = CompositionField;
			Result.ComparisonType   = DataCompositionComparisonType.Equal;
		Endif;
		
	Endif;

	Return Result;
	
EndFunction

&AtServer
Function AddFieldDataSet(DataSet, Field, Title, DataPath = Undefined, TextFieldsQuery = "")
	
	If DataPath = Undefined Then
		DataPath = Field;
	Endif;
	TextFieldsQuery 				= TextFieldsQuery + ", Turnovers." + Field + " AS " + Field; 
	FieldDataSet 				= DataSet.Fields.Add(Type("DataCompositionSchemaDataSetField"));
	FieldDataSet.Field        	= Field;
	FieldDataSet.Title   	= Title;
	FieldDataSet.DataPath 	= DataPath;
	Return FieldDataSet;
	
EndFunction

&AtClient
Procedure UpdateHeaderText(Form)

	If _ToCheckValidityOfRestrictionsOnDates(Date1, Date2) Then
		ReportTitle = ?(ValueIsFilled(Date1), "Интерактивная ОСВ: " + PeriodPresentation(Date1, Date2, "FP = True"), "Оборотно-сальдовая ведомость");
	Endif;		
	
	Form.Title = ReportTitle;

EndProcedure

&AtServer
Procedure IndicatorsReport()
	
	ThisForm.TVResources.Load(NP.TVResources);
	
EndProcedure

&AtServer
Procedure LoadLayoutOformlenieVNP()
	
	If NumberLayoutDesign = NP.NumberLayoutDesign Then
		Return;	
	Endif;
	
	NP.Insert("NumberLayoutDesign", NumberLayoutDesign);
	
	_AppearanceTemplate	= FormAttributeToValue("InteractiveTBS").GetTemplate("AppearanceTemplates");
	TypeDesignMac	= _AppearanceTemplate.GetArea("Type" + String(NumberLayoutDesign) + "|Base");
	TypeDesignPic	= _AppearanceTemplate.GetArea("Type" + String(NumberLayoutDesign) + "|Figure");
	
	Sec = TypeDesignMac.Area("R1C1");
	NP.StructureAppearance.Insert("Plus", 	TypeDesignPic.Drawings["Plus" + String(NumberLayoutDesign)].Picture); 
	NP.StructureAppearance.Insert("Mminus", 	TypeDesignPic.Drawings["Mminus" + String(NumberLayoutDesign)].Picture); 
	NP.StructureAppearance.Insert("Z", New Structure("TextColor,BackColor,BorderColor", Sec.TextColor, Sec.BackColor, Sec.BorderColor));
	Sec = TypeDesignMac.Area("R2C1");
	NP.StructureAppearance.Insert("W", New Structure("TextColor, BackColor, BorderColor", Sec.TextColor, Sec.BackColor, Sec.BorderColor));
	For K = 3 To 9 Do
		Sec = TypeDesignMac.Area("R" + String(K) + "C1");
		NP.StructureAppearance.Insert("N" + String(K - 2), New Structure("TextColor, BackColor, BorderColor", Sec.TextColor, Sec.BackColor, Sec.BorderColor));
	EndDo;
	NP.Sections.Clear();

EndProcedure

&AtClient
Procedure PanelSettings(Command)

	Items.GroupPanelSettings.Visible = Not Items.GroupPanelSettings.Visible;
	ChangeButtonHeadingPanelSettings(
		Items.PanelSettings, Items.GroupPanelSettings.Visible);

EndProcedure

&AtClientAtServerNoContext
Procedure ChangeButtonHeadingPanelSettings(Button, VisiblePanelSettings) Export
	
	If VisiblePanelSettings Then
		Button.Title = NStr("ru = 'Скрыть настройки'");
	Else
		Button.Title = NStr("ru = 'Показать настройки'");
	Endif;
		
EndProcedure	

&AtServer
Procedure CompleteTVResources(AccountingReg) Export
	TVOldResources = NP.TVResources.Copy();
	NP.TVResources.Clear();
	FoundIndicators = IndicatorRegister.FindRows(New Structure("Register, Output", AccountingReg.Name, True));
	For each Resource in FoundIndicators Do
		StrTVResources 				= NP.TVResources.Add();
		StrTVResources.Name 			= Resource.Name;
 		StrTVResources.Synonym 		= Resource.PresentationFull;
 		StrTVResources.LineNumber 	= String(Resource.LineNumber);
		StrTVResources.ShortName     = Resource.PresentationBrief;
		StrTVResources.FormatP 		= Resource.FormatP;
		StrTVResources.Use	= False;
		ResourceMeth = AccountingReg.Resources.Find(StrReplace(StrReplace(StrTVResources.Name, "[", ""),  "]", ""));
		If ResourceMeth <> Undefined Then
			StrTVResources.Balance 			= ResourceMeth.Balance;
 			StrTVResources.AccountingFlag 			= ?(ResourceMeth.AccountingFlag<>Undefined, ResourceMeth.AccountingFlag.Name, "");
 			StrTVResources.ExtDimensionAccountingFlag 	= ?(ResourceMeth.ExtDimensionAccountingFlag<>Undefined, ResourceMeth.ExtDimensionAccountingFlag.Name, "");
		Endif;
	EndDo;
	AlreadySelected = TVOldResources.FindRows(New Structure("Use", True));
	IsOne 	= False;
	For each StrAlready in AlreadySelected Do
		StringFound = NP.TVResources.Find(StrAlready.Name, "Name");
		If StringFound <> Undefined Then
			StringFound.Use = True;
			IsOne 					= True;
		Endif;
	EndDo;
	If NOT IsOne Then
		Try
			NP.TVResources[0].Use = True;
		Except
			IndicatorRegister.Clear();
			UpdateIndicesOfRegisters();	
		EndTry;
	Endif;
	LimitAndBreakTVResources();	
EndProcedure

&AtServer
Procedure FillPerformanceRegisters() Export
	
	IndicatorRegister.Clear();
	StrSearch = NP.PlansAndRegisters.Find("Хозрасчетный", "AccountingRegister");	
	If StrSearch = Undefined Then
		UpdateIndicesOfRegisters();	
		Return;
	Endif;	
	AccountingReg 		= Metadata.AccountingRegisters[StrSearch.AccountingRegister];
	AddIndicator(True, IndicatorRegister.Add(), AccountingReg, "Хозрасчетный", "[Сумма]", 			"БУ (данные бухгалтерского учета)", 		"БУ");
	AddIndicator(True, IndicatorRegister.Add(), AccountingReg, "Хозрасчетный", "[СуммаНУ]", 			"НУ (данные налогового учета)", 			"НУ");
	AddIndicator(True, IndicatorRegister.Add(), AccountingReg, "Хозрасчетный", "[СуммаПР]", 			"ПР (данные по учету постоянных разниц)", 	"ПР");
	AddIndicator(True, IndicatorRegister.Add(), AccountingReg, "Хозрасчетный", "[СуммаВР]", 			"ВР (данные по учету временных разниц)", 	"ВР");
	Control = AddIndicator(True, IndicatorRegister.Add(), AccountingReg, "Хозрасчетный", "[Сумма]-([СуммаНУ]+[СуммаПР]+[СуммаВР])", 	"Контроль (БУ - (НУ + ПР + ВР))", 			"Контр.");
	If NOT Control.Output Then
		IndicatorRegister[0].PresentationFull = "Сумма";
		IndicatorRegister[0].PresentationBrief = "∑";
	Endif;
	AddIndicator(True, IndicatorRegister.Add(), AccountingReg, "Хозрасчетный", "[Количество]", 			"Количество", 								"Кол.");
	AddIndicator(True, IndicatorRegister.Add(), AccountingReg, "Хозрасчетный", "[ВалютнаяСумма]", 		"Валютная сумма", 							"Вал.");
	AddIndicator(False,   IndicatorRegister.Add(), AccountingReg, "Хозрасчетный", "[Сумма]/[Количество]", 	"Цена", 									"Цена");
	
	UpdateIndicesOfRegisters();	
EndProcedure

&AtServer
Procedure UpdateIndicesOfRegisters() Export
	
	For each StrRegister in NP.PlansAndRegisters Do
		AccountingReg 		= Metadata.AccountingRegisters[StrRegister.AccountingRegister];
		For each StrResource in AccountingReg.Resources Do
			FoundIndicator = IndicatorRegister.FindRows(New Structure("Register, Name", StrRegister.AccountingRegister, "[" + StrResource.Name + "]"));
			If FoundIndicator.Count() = 0 Then
				If StrResource.AccountingFlag = Undefined Then
					StrNew = IndicatorRegister.Insert(0);
				Else	
					StrNew = IndicatorRegister.Add();
				Endif;
				AddIndicator(True, StrNew, AccountingReg, StrRegister.AccountingRegister, "[" + StrResource.Name + "]", ?(StrResource.Synonym = "", StrResource.Name, StrResource.Synonym), GetReduction(StrResource.Name));
			Endif;
		EndDo;
	EndDo;
	UpdateNumberOfIndicatorsOfRegisters();
EndProcedure

&AtServer
Procedure UpdateNumberOfIndicatorsOfRegisters()
	For each StrIndicator in IndicatorRegister Do
		StrIndicator.LineNumber = IndicatorRegister.IndexOf(StrIndicator);
	EndDo;
EndProcedure

&AtServer
Function GetReduction(FullName)
	Abbr = FullName; 
	If Find(Upper(FullName), "ВАЛЮТ") <> 0 Then
		Abbr = "Вал.";
	Elsif Find(Upper(FullName), "КОЛИЧ") <> 0 Then
		Abbr = "Кол.";
	Elsif Find(Upper(FullName), "СУММАУПР") <> 0 Then
		Abbr = "Упр.";
	Elsif Find(Upper(FullName), "СУММАУПР") <> 0 Then
		Abbr = "Упр.";
	Elsif Find(Upper(FullName), "СЦЕНАР") <> 0 Then
		Abbr = "Сцен.";
	Endif;
	Return Abbr;
	
EndFunction

&AtServer
Function AddIndicator(Output, NewIndicator, RegMethod, Register, Name, Full, Short)
	
	NewIndicator.Register 				= Register;
	NewIndicator.Name 					= Name;
	NewIndicator.PresentationFull	= Full;
	NewIndicator.PresentationBrief 	= Short;
	NewIndicator.Output 				= Output;
	
	ArrayArguments = ObtainArrayArguments(Name, RegMethod);
	If ArrayArguments = False Then
		NewIndicator.Output = False;
		Return NewIndicator;
	Endif;
	
	Digits 	= 10;
	FractionalPart 	= 0;
	For each ResourceStr in ArrayArguments Do
		Resource = RegMethod.Resources.Find(ResourceStr);
		If Resource <> Undefined Then
			Digits 	= ?(Digits < Resource.Type.NumberQualifiers.Digits, Resource.Type.NumberQualifiers.Digits, Digits);
			FractionalPart	= ?(FractionalPart < Resource.Type.NumberQualifiers.Digits, Resource.Type.NumberQualifiers.FractionDigits, FractionalPart);
		Endif;
	EndDo;
	NewIndicator.FormatP = "ND = " + String(Digits + 3) + " ; NFD = " + String(FractionalPart);
	
	Return NewIndicator;
	
EndFunction

&AtServer
Function ObtainArrayArguments(Formula, RegMethod) Export
	FormulaStr 	= Formula;
	ArgArray 	= New Array();
	While 1 = 1 Do
		Beg = Find(FormulaStr, "[");
		mEnd = Find(FormulaStr, "]");
		If Beg = 0 or mEnd = 0 Then
			Break;	
		Endif;
		Argument = Mid(FormulaStr, Beg+1, (mEnd-Beg)-1);
		If RegMethod.Resources.Find(Argument) <> Undefined Then
			ArgArray.Add(Argument);
		Endif;
		FormulaStr 	= Mid(FormulaStr, mEnd+1);
	EndDo;
	Check = Formula;
	For each StrArgument in ArgArray Do
		Check = StrReplace(Check, "["+StrArgument+"]", "5");	
	EndDo;
	
	Try
		SummaryH = Eval(Check);
	Except
	    Return False;
	EndTry;
	
	Return ArgArray;
	
EndFunction

&AtClient
Procedure FirstSectionStartChoice(Element, DataChoice, StandardProcessing)
	
	ParametersForm = New Structure;
	ParametersForm.Insert("NameAccountingRegister", 		NameAccountingRegister);
	ParametersForm.Insert("SampleFirstSection", 			FirstSection);
	OpenForm("Отчет.InteractiveTBS.Форма.FormSelectingSection", ParametersForm, ThisForm);
	
	StandardProcessing = False;

EndProcedure

&AtClient
Procedure FirstSectionClearing(Element, StandardProcessing)
	FirstSection = New ValueList;
	ToUpdateSelectionAtServer();	
EndProcedure

&AtServer
Procedure OnCreateAtServer(Failure, StandardProcessing)
		
	AddressStorage = PutToTempStorage(Undefined, UUID);  
		
	ChangeButtonHeadingPanelSettings(ThisForm.Items.PanelSettings, ThisForm.Items.GroupPanelSettings.Visible);
	
EndProcedure

&AtClient
Procedure PeriodAhead(Button)
	
	pDate1 = Date1; 
	pDate2 = Date2;
	Recalculation_ToMoveBetween(1, pDate1, pDate2);
	If CheckPeriod(pDate1, pDate2) Then
		Date1 	= pDate1;	
		Date2 	= pDate2;
		Items.DescriptionPeriod.Title = GenerateLineConclusionParametersByDatesAtClient(Date1, Date2);
		GenerateReportAtServer();
		RefreshDisplay();
	Endif;
	
EndProcedure

&AtClient
Procedure PeriodAgo(Command)
	
	pDate1 = Date1; 
	pDate2 = Date2;
	Recalculation_ToMoveBetween(-1, pDate1, pDate2);
	If CheckPeriod(pDate1, pDate2) Then
		Date1 	= pDate1;	
		Date2 	= pDate2;
		Items.DescriptionPeriod.Title = GenerateLineConclusionParametersByDatesAtClient(Date1, Date2);
		GenerateReportAtServer();
		RefreshDisplay();
	Endif;
	
EndProcedure

&AtClient
Procedure Recalculation_ToMoveBetween(Step = 0, pDate1, pDate2)
	Var Vl;
	If (pDate1 = BegOfYear(pDate1)) AND (pDate1 = BegOfYear(pDate2)) AND (pDate2 = EndOfMonth(pDate2)) 
		AND ((StandardPeriodIsMonthWithBeginningOfYear) OR ((Month(pDate2) <> 1) AND (Month(pDate2) <> 3) 
		AND (Month(pDate2) <> 6) AND (Month(pDate2) <> 12))) Then 
		StandardPeriodIsMonthWithBeginningOfYear = True;
		pDate2 = AddMonth(pDate2 + 86400, Step) - 86400;
		pDate1 = BegOfYear(pDate2);
	Elsif (pDate1 = BegOfMonth(pDate1)) AND (pDate2 = EndOfMonth(pDate2)) Then 
		StandardPeriodIsMonthWithBeginningOfYear = False;
		Vl 		= Step * (Year(pDate2)*12 + Month(pDate2) - Year(pDate1)*12 - Month(pDate1) + 1);
		pDate1 	= AddMonth(pDate1, Vl);
		pDate2 	= AddMonth(pDate2 + 86400, Vl) - 86400;
	Elsif (pDate2 - pDate1 < 15*86400) AND (pDate2 - pDate1 > 5*86400) AND (Day(pDate1) % 10 = 1) 
		AND ((Day(pDate2) % 10 = 0) OR (pDate2 = EndOfMonth(pDate2))) Then
		For Identifier = 1 To Max(Step, -Step) Do
			pDate1 = pDate1 + ?(Step > 0, 10, -10)*86400;
			If Day(pDate1) = 31 Then 
				pDate1 = pDate1 + 86400 
			Endif; 
			If Day(pDate1) % 10 <> 1 Then
				pDate1 = Date(Year(pDate1), Month(pDate1), Round(Day(pDate1),-1) + 1); 
			Endif; 
			pDate2 = ?(Day(pDate1) = 21, EndOfMonth(pDate1), pDate1 + 9*86400);
		EndDo
	Else 
		Vl = Step * (pDate2 - pDate1 + 1);
		pDate1 = pDate1 + Vl;
		pDate2 = pDate2 + Vl;
	Endif;
EndProcedure 

&AtClient
Function CheckPeriod(pDate1, pDate2, Quiet = False) Export
	Var Error;
	If NOT ValueIsFilled(pDate1) Then
		Error = "Не указана дата начала периода отчета!"
	Elsif pDate1 > pDate2 Then
		Error = "Неправильно задан период отчета!" + Chars.LF + "Дата начала больше даты окончания периода."
	Endif;
	If Quiet AND Error <> Undefined Then  
		Message(Error, MessageStatus.Information); 
	Endif;
	Return Error = Undefined
EndFunction 

&AtClient
Function GenerateLineConclusionParametersByDatesAtClient(Val DateBeg, Val DateEnd)Export

	If DateBeg = '00010101000000' AND DateEnd = '00010101000000' Then

		DescriptionPeriod     = " без ограничения.";

	Else

		If DateBeg = '00010101000000' OR DateEnd = '00010101000000' Then

			DescriptionPeriod = " " + Format(DateBeg, "DF = ""dd.MM.yyyy""; DE = ""без ограничения""") 
							+ " - "      + Format(DateEnd, "DF = ""dd.MM.yyyy""; DE = ""без ограничения""");

		Else

			DescriptionPeriod = " " + PeriodPresentation(BegOfDay(DateBeg), EndOfDay(DateEnd), "FP = True");

		Endif;

	Endif;

	Return DescriptionPeriod;

EndFunction

&AtClient
Procedure RefreshDisplay()
	UpdateHeaderText(ThisForm);	
EndProcedure

&AtClient
Procedure DescriptionPeriod(Command)
	
	HandlerControlPeriodPressing(Date1, Date2);
	If _ToCheckValidityOfRestrictionsOnDates(Date1, Date2) Then
		Items.DescriptionPeriod.Title = GenerateLineConclusionParametersByDatesAtClient(Date1, Date2);
	Endif;		
			
EndProcedure

&AtClient
Procedure ToChooseAnyPeriodEnd(Period, AdditionalParameters) Export
	
	Dialogue = AdditionalParameters.Dialogue;
	
	If Period <> Undefined Then
		
		If _ToCheckValidityOfRestrictionsOnDates(Dialogue.Period.StartDate, Dialogue.Period.EndDate) Then
		
			Date1 = BegOfDay(Dialogue.Period.StartDate);
			Date2  = EndOfDay(Dialogue.Period.EndDate);
			
		Endif;		
		
		Items.DescriptionPeriod.Title = GenerateLineConclusionParametersByDatesAtClient(Date1, Date2);
		ToEstablishConditionFieldSpreadsheetDocument("Irrelevance");
		
	Endif;
	
EndProcedure

&AtClient
Function _ToCheckValidityOfRestrictionsOnDates(Val Date1, Val Date2, Val ToGiveAWarning = True) Export
	
	If Date1 > Date2 AND Date2 <> '00010101000000' Then
		
		SpreadsheetDocumentField = Items.TabDocument;
		If ToGiveAWarning AND TypeOf(SpreadsheetDocumentField) = Type("FormField") 
			AND SpreadsheetDocumentField.Type = FormFieldType.SpreadsheetDocumentField Then
			StatePresentation = SpreadsheetDocumentField.StatePresentation;
			StatePresentation.Visible                      = True;
			StatePresentation.AdditionalShowMode = AdditionalShowMode.Irrelevance;
			StatePresentation.Picture                       = PictureLib.ПометитьНаУдаление;
			StatePresentation.Text                          = "Датa началa периодa нe можeт быть большe дaты концa периодa!";
			
		Endif;
		
		Return False;
		
	Endif;
	
	Return True;
	
EndFunction

&AtClient
Procedure AddPeriodToList(D1,D2,List) Export
	Vl = Format(D1, "DF=yyyyMMddHHmmss") + "-" + Format(D2, "DF=yyyyMMddHHmmss");
	If List.FindByValue(Vl) = Undefined Then 
		List.Add(Vl);
	Endif;
EndProcedure

&AtClient
Procedure HandlerControlPeriodPressing(Date1, Date2)
	
	History = New ValueList;
	If RepHistoryPeriods.Count() <> 0 Then
		History = RepHistoryPeriods.Copy();
	Endif;
	
	pDate1 	= BegOfMonth(CurrentDate());
	pDate2 	= EndOfMonth(CurrentDate());
	AddPeriodToList(pDate1,pDate2, History);	
	
	pDate1 = BegOfYear(pDate1);
	AddPeriodToList(pDate1,pDate2, History);	
	
	pDate1 = BegOfMonth(AddMonth(CurrentDate(),-1));
	pDate2 = EndOfMonth(AddMonth(CurrentDate(),-1));
	AddPeriodToList(pDate1,pDate2, History);	
	
	pDate1 = BegOfYear(pDate1);
	AddPeriodToList(pDate1,pDate2, History);	
	
	pDate1 = BegOfQuarter(CurrentDate());
	pDate2 = EndOfQuarter(CurrentDate());
	AddPeriodToList(pDate1,pDate2, History);	
	
	pDate1 = BegOfQuarter(AddMonth(CurrentDate(),-3));
	pDate2 = EndOfQuarter(AddMonth(CurrentDate(),-3));
	AddPeriodToList(pDate1,pDate2, History);	
	
	pDate1 = BegOfYear(CurrentDate());
	pDate2 = EndOfYear(CurrentDate());
	AddPeriodToList(pDate1,pDate2, History);	
		
	pDate1 = BegOfYear(AddMonth(CurrentDate(), -12));
	pDate2 = EndOfYear(AddMonth(CurrentDate(),  -12));
	AddPeriodToList(pDate1,pDate2, History);	
		
	For each StrHistory in History Do
		Vl 		= StrHistory.Value;
		pDate1 	= Date(Mid(Vl, 1, 14));
		pDate2 	= Date(Mid(Vl, 16, 14));
		Str = PeriodPresentation(pDate1, pDate2, "FP = True");
		If (pDate1 = BegOfMonth(pDate1)) and (pDate2 = EndOfMonth(pDate1)) Then
			TypePeriodReport = "1" 
		Elsif (pDate1 = BegOfQuarter(pDate1)) and (pDate2 = EndOfQuarter(pDate1)) Then
			TypePeriodReport = "2" 
		Elsif (pDate1 = BegOfYear(pDate1)) and (pDate2 = EndOfYear(pDate1)) Then
			TypePeriodReport = "4" 
		Elsif (pDate1 = BegOfYear(pDate1)) and (pDate2 = EndOfMonth(pDate2)) and (pDate2 <= EndOfYear(pDate1)) Then
			TypePeriodReport = "3";
			Str = "" + Month(pDate2) + " месяц" + ?(Month(pDate2)<5,"а ","ев ") + Year(pDate2) + " года";
		Else
			TypePeriodReport = "9" 
		Endif;
	
		StrHistory.Presentation 	= Str;
		StrHistory.Value 		= ""+ TypePeriodReport + " " + Format(pDate1, "DF=ddMMyyyy") + " " + Format(pDate2, "DF=ddMMyyyy") + Vl;
		
	EndDo;
	History.SortByValue();
	History.Insert(0, "< выбор >", "< выбрать другой период ...>");
	
	AdditionalParameters = New Structure;
	AdditionalParameters.Insert("Element", Items.DescriptionPeriod);
	Alert = New NotifyDescription("ToChooseFromMenuPeriodEnd", ThisForm, AdditionalParameters);
	ShowChooseFromMenu(Alert, History, ThisForm.Items.PeriodGroup);
	
EndProcedure

&AtClient
Procedure ToChooseFromMenuPeriodEnd(Result, AdditionalParameters) Export
	
	If Result = Undefined Then
		Return;
	Endif;
	
	If Result.Value <> "< выбор >" Then
		Date1 	= Date(Mid(Result.Value, 20, 14));
		Date2 	= Date(Mid(Result.Value, 35, 14));
		If _ToCheckValidityOfRestrictionsOnDates(Date1, Date2) Then
			Items.DescriptionPeriod.Title = GenerateLineConclusionParametersByDatesAtClient(Date1, Date2);
			ToEstablishConditionFieldSpreadsheetDocument("Irrelevance");
		Endif;		
	Else	
		Dialogue = New StandardPeriodEditDialog();
		
		Dialogue.Period.StartDate    = Date1;
		Dialogue.Period.EndDate = Date2;
		
		AdditionalParameters = New Structure("Dialogue", Dialogue);
		NotifyDescription = New NotifyDescription("ToChooseAnyPeriodEnd", ThisForm, AdditionalParameters);
		Dialogue.Show(NotifyDescription);
		
	Endif;
		
EndProcedure

&AtClient
Procedure DetailedBalanceToRemoveBoxes(Command)

	For Each StringTable in SplittedBalance Do
		StringTable.Use = False;
	EndDo;

	ToEstablishConditionFieldSpreadsheetDocument("Irrelevance");

EndProcedure

&AtClient
Procedure DetailedBalanceCheck(Command)

	For Each StringTable in SplittedBalance Do
		StringTable.Use = True;
	EndDo;

	ToEstablishConditionFieldSpreadsheetDocument("Irrelevance");

EndProcedure

&AtServer
Function GetPropertiesAccount(Val Account) Export

	NP = GetFromTempStorage(AddressStorage);
	
	DataAccounts = New Structure;
	DataAccounts.Insert("Ref");
	DataAccounts.Insert("Description"			, "");
	DataAccounts.Insert("Code"					, "");
	DataAccounts.Insert("Parent");
	DataAccounts.Insert("Type"					, Undefined);
	DataAccounts.Insert("OffBalance"			, False);
	DataAccounts.Insert("NumberExtDimension"	, 0);
	
	ChartOfAccounts 		= Metadata.ChartsOfAccounts[NP.NameChartOfAccounts];
	TextDetails = "";
	For each AccountingFlag in ChartOfAccounts.AccountingFlags Do
		DataAccounts.Insert(AccountingFlag.Name);
		TextDetails = TextDetails + "	ChartOfAccounts." + AccountingFlag.Name + ", ";
	EndDo;
		
	For IndexExtDimension = 1 To NP.MaxExtDimensionCount Do
		DataAccounts.Insert("ExtDimensionType" + IndexExtDimension,					Undefined);
		DataAccounts.Insert("ExtDimensionType" + IndexExtDimension + "Description",  Undefined);
		DataAccounts.Insert("ExtDimensionType" + IndexExtDimension + "ValueType",   Undefined);
		DataAccounts.Insert("ExtDimensionType" + IndexExtDimension + "TurnoversOnly", False);
	EndDo;
	
	If NOT ValueIsFilled(Account) Then
		Return DataAccounts;
	Endif;
	
	If NP.MaxExtDimensionCount = 0 Then
		Return DataAccounts;
	Endif;
	
	Query = New Query;
	Query.SetParameter("Account", Account);
	
	Query.Text = 
	"SELECT
	|	ChartOfAccounts.Ref AS Ref,
	|	ChartOfAccounts.Parent AS Parent,
	|	ChartOfAccounts.Code AS Code,
	|	ChartOfAccounts.Description AS Description,
	|	ChartOfAccounts.Type AS Type, " 
	+ TextDetails + "
	|	ChartOfAccounts.OffBalance AS OffBalance
	|FROM
	|	ChartOfAccounts." + NP.NameChartOfAccounts + " AS ChartOfAccounts
	|WHERE
	|	ChartOfAccounts.Ref = &Account
	|;
	|
	|SELECT
	|	ChartOfAccountsExtDimensionTypes.LineNumber AS LineNumber,
	|	ChartOfAccountsExtDimensionTypes.ExtDimensionType AS ExtDimensionType,
	|	ChartOfAccountsExtDimensionTypes.ExtDimensionType.Description AS Description,
	|	ChartOfAccountsExtDimensionTypes.ExtDimensionType.ValueType AS ValueType,
	|	ChartOfAccountsExtDimensionTypes.TurnoversOnly AS TurnoversOnly
	|FROM
	|	ChartOfAccounts." + NP.NameChartOfAccounts + ".ExtDimensionTypes AS ChartOfAccountsExtDimensionTypes
	|WHERE
	|	ChartOfAccountsExtDimensionTypes.Ref = &Account
	|
	|ORDER BY
	|	ChartOfAccountsExtDimensionTypes.LineNumber";
	
	ArrayOfResults	= Query.ExecuteBatch();
	
	Sample = ArrayOfResults[0].Select();
	If Sample.Next() Then
		FillPropertyValues(DataAccounts, Sample);
	Endif;
		
	SampleExtDimension	= ArrayOfResults[1].Select();
		
	DataAccounts.NumberExtDimension	= SampleExtDimension.Count();
		
	IndexExtDimension	= 0;
		
	While SampleExtDimension.Next() Do
		
		IndexExtDimension	= IndexExtDimension + 1;
		
		DataAccounts.Insert("ExtDimensionType" + IndexExtDimension,					SampleExtDimension.ExtDimensionType);
		DataAccounts.Insert("ExtDimensionType" + IndexExtDimension + "Description",	SampleExtDimension.Description);
		DataAccounts.Insert("ExtDimensionType" + IndexExtDimension + "ValueType",	SampleExtDimension.ValueType);
		DataAccounts.Insert("ExtDimensionType" + IndexExtDimension + "TurnoversOnly",	SampleExtDimension.TurnoversOnly);
		
	EndDo;
	
	Return DataAccounts;
	
EndFunction

&AtServer
Procedure PopulateListOfRulesEA(Param) Export
	If Param.Count() = 0 Then
		Return;
	Endif;
	SplittedBalance.Clear();
	Account 		= ChartsOfAccounts[NP.NameChartOfAccounts];
	
	For each StrEA in Param Do
		If NOT ValueIsFilled(StrEA.Account) Then
			Continue;
		Endif;
		
		FoundAccount 	= Account.FindByCode(StrEA.Account.Code);
		If ValueIsFilled(FoundAccount) Then
			StrRulesEA				= SplittedBalance.Add();
			StrRulesEA.Account 			= FoundAccount;
			StrRulesEA.OnSubAccounts 	= StrEA.OnSubAccounts;
			StrRulesEA.Use 	= StrEA.Use;
			
			DataAccounts = GetPropertiesAccount(FoundAccount);
			
			StringExtDimension    = "";
			StrPresentation = "";
			
			If DataAccounts.NumberExtDimension > 0 Then
				For IndexOf = 1 To DataAccounts.NumberExtDimension Do
					StringExtDimension    = StringExtDimension + "+" + IndexOf;
					StrPresentation = StrPresentation + DataAccounts["ExtDimensionType" + IndexOf + "Description"] + ", ";
				EndDo;
				StrPresentation = Left(StrPresentation, StrLen(StrPresentation) - 2);
			Endif;
			StrRulesEA.ToExtDimension    = StringExtDimension;
			StrRulesEA.Presentation = StrPresentation;
			
		Endif;
	EndDo;
	
EndProcedure 

&AtServer
Procedure ColumnTurnsNew() Export
	
	If NP.PlansAndRegisters.Count() = 0 Then
		Return;	
	Endif;
	
	ArrayAccount = New Array;
	ArrayAccount.Add(TypeOf(ChartsOfAccounts[NP.NameChartOfAccounts].EmptyRef()));
	DescriptionOfAccountTypes  = New TypeDescription(ArrayAccount);
	
	Items.SplittedBalance.ChildItems.DetailedAccountBalances.TypeRestriction = DescriptionOfAccountTypes;
	
EndProcedure 

&AtClient
Procedure DetailedBalanceOfAccountIfYouChange(Element)
	
	CurrentData = Items.SplittedBalance.CurrentData;
	
	If CurrentData <> Undefined Then
		If ValueIsFilled(CurrentData.Account) Then
			DataAccounts = GetPropertiesAccount(CurrentData.Account);
			CurrentData.OnSubAccounts = DataAccounts.NumberExtDimension = 0;

			StringExtDimension    = "";
			StrPresentation = "";
			
			If DataAccounts.NumberExtDimension > 0 Then
				For IndexOf = 1 To DataAccounts.NumberExtDimension Do
					StringExtDimension    = StringExtDimension + "+" + IndexOf;
					StrPresentation = StrPresentation + DataAccounts["ExtDimensionType" + IndexOf + "Description"] + ", ";
				EndDo;
				StrPresentation = Left(StrPresentation, StrLen(StrPresentation) - 2);
			Endif;
			CurrentData.ToExtDimension    = StringExtDimension;
			CurrentData.Presentation = StrPresentation;

		Endif;
	Endif;
	
	CurrentData.Use = True;
	
EndProcedure

&AtClient
Procedure DetailedBalanceRepresentationOfBeginningOfSelection(Element, DataChoice, StandardProcessing)
	
	StringExtDimension 	= Items.SplittedBalance.CurrentData.ToExtDimension;
	Account 				= Items.SplittedBalance.CurrentData.Account;
	DataAccounts 		= GetPropertiesAccount(Account);
	ListTypeExtDimension = New ValueList;
	
	If IsBlankString(StringExtDimension) Then		
		For IndexOf = 1 To DataAccounts.NumberExtDimension Do
			ListTypeExtDimension.Add(DataAccounts["ExtDimensionType" + IndexOf], DataAccounts["ExtDimensionType" + IndexOf + "Description"]);
		EndDo;
	Else
		NumberExtDimension = StrLen(StringExtDimension) / 2;
		For IndexOf = 1 To NumberExtDimension Do
			IndexExtDimension = Mid(StringExtDimension, IndexOf*2, 1);
			ListTypeExtDimension.Add(DataAccounts["ExtDimensionType" + IndexExtDimension], DataAccounts["ExtDimensionType" + IndexExtDimension + "Description"], ?(Mid(StringExtDimension, IndexOf * 2 - 1, 1) = "+", True, False));
		EndDo;
	Endif;	
	OpenForm("Отчет.InteractiveTBS.Форма.SetupFormForExtDimension", New Structure("ListTypeExtDimension", ListTypeExtDimension), Element);
	
EndProcedure

&AtClient
Procedure DetailedBalanceOfCleaningPerformance(Element, StandardProcessing)
	
	Items.SplittedBalance.CurrentData.ToExtDimension    = StrReplace(Items.SplittedBalance.CurrentData.ToExtDimension, "+", "-");
	Items.SplittedBalance.CurrentData.Presentation = "";
	
EndProcedure

&AtClient
Procedure DetailedBalanceOfPresentationIsTreatmentOfChoice(Element, ChosenValue, StandardProcessing)
	
	StandardProcessing = False;
	
	CurrentData = Items.SplittedBalance.CurrentData;
	DataAccounts = GetPropertiesAccount(CurrentData.Account);
	If TypeOf(ChosenValue) = Type("ValueList") Then 
		StringExtDimension = "";
		StrPresentation = "";
		For Each ListItem in ChosenValue Do
			If ListItem.Check Then
				StringExtDimension    = StringExtDimension + "+";
				StrPresentation = StrPresentation + String(ListItem.Value) + ", ";
			Else
				StringExtDimension = StringExtDimension + "-";
			Endif;
			
			For IndexOf = 1 To DataAccounts.NumberExtDimension Do 
				If DataAccounts["ExtDimensionType" + IndexOf] = ListItem.Value Then
					StringExtDimension = StringExtDimension + IndexOf;
				Endif;
			EndDo;
		EndDo;
		StrPresentation = Left(StrPresentation, StrLen(StrPresentation) - 2);
		
		CurrentData.ToExtDimension    = StringExtDimension;
		CurrentData.Presentation = StrPresentation;
		
		CurrentData.OnSubAccounts = IsBlankString(StrPresentation);
	Endif;

	
EndProcedure

&AtServer
Function GenerateTableDataSplittedBalance()
	
	TableBalance = New ValueTable;
	TableBalance.Columns.Add("Account");
	TableBalance.Columns.Add("Result");
	
	If NOT ApplyDetailedBalance OR (SplittedBalance.Count() = 0) Then
		Return TableBalance;
	Endif;

	Query = New Query;
	Query.SetParameter("BeginningPeriod", 	Date1);
	Query.SetParameter("LatePeriod", 	Date2);
	For each StrChange in NP.TVFilter Do
		If StrChange.Use Then
			Query.SetParameter(StrReplace(StrChange.DataPath, ".", "_WW"), StrChange.Value);
		Endif;
	EndDo;
	
	For Each RulesAccount in SplittedBalance Do
		
		If RulesAccount.Account.IsEmpty()
			OR (NOT RulesAccount.OnSubAccounts
				AND NOT ValueIsFilled(RulesAccount.ToExtDimension)) Then
			Continue;
		Endif;
		                            
		QueryText 		= "";
		TextSelectedFields 	= "";
			
		Query.SetParameter("Account", RulesAccount.Account);
			
		QueryText =  
		"SELECT ALLOWED
		|	Account AS Account ";
			
		For each StrChange in NP._TVDimensions Do    
			If StrChange.Balance Then
				QueryText = QueryText + ",
				|	" + StrChange.Name + " AS " + StrChange.Name;
			Endif;
		EndDo;
		
		DataAccounts 		= GetPropertiesAccount(RulesAccount.Account);
		
		If NOT IsBlankString(RulesAccount.ToExtDimension) Then		
			NumberExtDimension = StrLen(RulesAccount.ToExtDimension) / 2;
			For IndexOf = 1 To NumberExtDimension Do
				IndexExtDimension = Mid(RulesAccount.ToExtDimension, IndexOf*2, 1);
				If Mid(RulesAccount.ToExtDimension, IndexOf * 2 - 1, 1) = "+" Then
					TextSelectedFields = TextSelectedFields + ",
					|	ExtDimension" + IndexExtDimension + " AS ExtDimension" + IndexExtDimension;
				Endif;
			EndDo;
		Endif;	
		
		QueryText = QueryText + TextSelectedFields;
		
		For Each IndexName in NP.TVIndicators Do
			QueryText = QueryText + ",
			|	" + IndexName.Name + "OpeningSplittedBalanceDr AS " + IndexName.LineNumber + "OpeningSplittedBalanceDr,
			|	" + IndexName.Name + "OpeningSplittedBalanceCr AS " + IndexName.LineNumber + "OpeningSplittedBalanceCr,
			|	" + IndexName.Name + "ClosingSplittedBalanceDr AS "  + IndexName.LineNumber + "ClosingSplittedBalanceDr,
			|	" + IndexName.Name + "ClosingSplittedBalanceCr AS "  + IndexName.LineNumber + "ClosingSplittedBalanceCr";
				
		EndDo;
			
		StringTextSampleFromTable = GenerateTextSelectionOfTablesBalanceAndTurnoversAccountingRegisters( ,
			"Account IN HIERARCHY (&Account)");
			
		QueryText = QueryText + StringTextSampleFromTable;
	 		
		Query.Text = QueryText;

		NewString 			= TableBalance.Add();
		NewString.Account      	= RulesAccount.Account;
		NewString.Result 	= Query.Execute().Unload();
			
	EndDo;

	Return TableBalance;

EndFunction

&AtServer
Function GenerateTextSelectionOfTablesBalanceAndTurnoversAccountingRegisters(Val NameOfAliasTable = "BalanceAndTurnovers", 
	Val AdditionalRestrictionOnAccount = "" )
	
	StringOfRestrictionsOnDetails = "";
	For each StrAdditionalReversal in NP.TVFilter Do
		If Find(StrAdditionalReversal.DataPath, "Account") <> 0 Then
			Continue;	
		Endif;
		
		If StrAdditionalReversal.Use Then
			ToAddLineRestrictionsRequisites(StringOfRestrictionsOnDetails, StrAdditionalReversal.DataPath, StrAdditionalReversal.Value);
		Endif;
	EndDo;
	
	StringBundlesAdditionalRestrictionsOnAccount = ?(IsBlankString(AdditionalRestrictionOnAccount), "", " AND ");
	
	StringPartOfRequest = "
			|FROM
			|	AccountingRegister." + NP.NameAccountingRegister + ".BalanceAndTurnovers( "
			+ ?(Date1 = '00010101000000', "", "&BeginningPeriod") + ", "
			+ ?(Date2 = '00010101000000', "", "&LatePeriod") 
			+ ", , , " + AdditionalRestrictionOnAccount  
			+ ?(NP.OffBalanceAccount, "", StringBundlesAdditionalRestrictionsOnAccount + " NOT Account.OffBalance ") + ", "
			+ ", "
			+ StringOfRestrictionsOnDetails + ") AS " + NameOfAliasTable;
			
	Return StringPartOfRequest;		
	
EndFunction

&AtServer
Procedure ToAddLineRestrictionsRequisites(StringLimits, Val ConstraintNameForProps, Val LimitationOnAttribute)
	
	If NOT ValueIsFilled(LimitationOnAttribute) Then
		Return;
	Endif;
	
	Try
		IsFolder    = LimitationOnAttribute.IsFolder;
		TextOfConditions = ?(TypeOf(LimitationOnAttribute) = Type("Array")OR TypeOf(LimitationOnAttribute) = Type("ValueList")OR IsFolder, " IN HIERARCHY ", " = ");
		
	Except
		
		TextOfConditions = ?(TypeOf(LimitationOnAttribute) = Type("Array")OR TypeOf(LimitationOnAttribute) = Type("ValueList"), " IN HIERARCHY ", " = ")
		
	EndTry;
	
	StringOfNewRestrictions = ConstraintNameForProps + TextOfConditions+ "(&" + StrReplace(ConstraintNameForProps, ".", "_WW") + ") ";
	
	StringLimits = UnionRestrictions(StringLimits, StringOfNewRestrictions);
    
EndProcedure

&AtServer
Function UnionRestrictions(Val Constraint1, Val Constraint2, Val StringJoinRestrictions = "AND")
	
	If IsBlankString(Constraint1) Then
		Return Constraint2;
	Endif;
	
	If IsBlankString(Constraint2) Then
		Return Constraint1;
	Endif;
	
	StringLimits = Constraint1 + " " + StringJoinRestrictions + " " + Constraint2;
	
	Return StringLimits;
	
EndFunction

&AtServer
Procedure Defaultsettingof1CCompletionOntheServer()
	
	BalanceSetup	= FormAttributeToValue("InteractiveTBS").GetTemplate("ConfigureDeployedBalances").GetArea("Область_1С");
	
	SplittedBalance.Clear();
	
	Account 		= ChartsOfAccounts[NameChartOfAccounts];
	LineNumber	= 2;
	While ValueIsFilled(TrimAll(BalanceSetup.Area(LineNumber, 1).Text)) Do
		AccountCode 	= BalanceSetup.Area(LineNumber, 1).Text;
		FoundAccount 	= Account.FindByCode(AccountCode);
		If ValueIsFilled(FoundAccount) Then
			StrRulesEA				= SplittedBalance.Add();
			StrRulesEA.Account 			= FoundAccount;
			StrRulesEA.OnSubAccounts 	= ?(Upper(TrimAll(BalanceSetup.Area(LineNumber, 2).Text)) = "ДА", True, False);
			StrRulesEA.Use  = True;
			
			DataAccounts = GetPropertiesAccount(FoundAccount);
			
			StringExtDimension    = "";
			StrPresentation = "";
			
			If DataAccounts.NumberExtDimension > 0 Then
				For IndexOf = 1 To DataAccounts.NumberExtDimension Do
					If ?(Upper(TrimAll(BalanceSetup.Area(LineNumber, 3 + IndexOf).Text)) = "ДА", True, False) Then
						StringExtDimension    = StringExtDimension + "+" + IndexOf;
						StrPresentation = StrPresentation + DataAccounts["ExtDimensionType" + IndexOf + "Description"] + ", ";
					Endif;
				EndDo;
				StrPresentation = Left(StrPresentation, StrLen(StrPresentation) - 2);
			Endif;
			
			StrRulesEA.ToExtDimension    = StringExtDimension;
			StrRulesEA.Presentation = StrPresentation;
			
		Endif;
		LineNumber = LineNumber + 1;
		
	EndDo;
	
EndProcedure

&AtClient
Procedure Defaultsettingof1CCompletion(Аnswer, AdditionalParameters) Export
	
	If Аnswer <> DialogReturnCode.Yes Then
		Return;
	Endif;
	
	Defaultsettingof1CCompletionOntheServer();
		
EndProcedure

&AtClient
Procedure DefaultSettingOf1C(Command)
	
	QuestionText = "Восстановить исходный список счетов?";
	Alert = New NotifyDescription("Defaultsettingof1CCompletion", ThisForm);				
	ShowQueryBox(Alert, QuestionText, QuestionDialogMode.YesNo, , DialogReturnCode.Yes);
	
EndProcedure

&AtClient
Procedure DefaultSettingFromRayCon(Command)
	
	QuestionText = "Восстановить список счетов от RayCon?";
	Alert = New NotifyDescription("DefaultSettingFromRayConCompletion", ThisForm);				
	ShowQueryBox(Alert, QuestionText, QuestionDialogMode.YesNo, , DialogReturnCode.Yes);
	
EndProcedure

&AtClient
Procedure DefaultSettingFromRayConCompletion(Аnswer, AdditionalParameters) Export
	
	If Аnswer <> DialogReturnCode.Yes Then
		Return;
	Endif;
	
	DefaultSettingFromRayConCompletionOnServer();
		
EndProcedure

&AtServer
Procedure DefaultSettingFromRayConCompletionOnServer()
	
	BalanceSetup	= FormAttributeToValue("InteractiveTBS").GetTemplate("ConfigureDeployedBalances").GetArea("RayCon");
	
	SplittedBalance.Clear();
	
	Account 		= ChartsOfAccounts[NameChartOfAccounts];
	LineNumber	= 2;
	While ValueIsFilled(TrimAll(BalanceSetup.Area(LineNumber, 1).Text)) Do
		AccountCode 	= BalanceSetup.Area(LineNumber, 1).Text;
		FoundAccount 	= Account.FindByCode(AccountCode);
		If ValueIsFilled(FoundAccount) Then
			StrRulesEA				= SplittedBalance.Add();
			StrRulesEA.Account 			= FoundAccount;
			StrRulesEA.OnSubAccounts 	= ?(Upper(TrimAll(BalanceSetup.Area(LineNumber, 2).Text)) = "ДА", True, False);
			StrRulesEA.Use  = True;
			
			DataAccounts = GetPropertiesAccount(FoundAccount);
			
			StringExtDimension    = "";
			StrPresentation = "";
			
			If DataAccounts.NumberExtDimension > 0 Then
				For IndexOf = 1 To DataAccounts.NumberExtDimension Do
					If ?(Upper(TrimAll(BalanceSetup.Area(LineNumber, 3 + IndexOf).Text)) = "ДА", True, False) Then
						StringExtDimension    = StringExtDimension + "+" + IndexOf;
						StrPresentation = StrPresentation + DataAccounts["ExtDimensionType" + IndexOf + "Description"] + ", ";
					Endif;
				EndDo;
				StrPresentation = Left(StrPresentation, StrLen(StrPresentation) - 2);
			Endif;
			
			StrRulesEA.ToExtDimension    = StringExtDimension;
			StrRulesEA.Presentation = StrPresentation;
			
		Endif;
		LineNumber = LineNumber + 1;
		
	EndDo;
	
EndProcedure

&AtClient
Procedure WithdrawBalanceSheetWhenChanging(Element)
	ToUpdateSelectionAtServer();	    
EndProcedure

&AtClient
Procedure AccessSettings(Command)
	
	ParametersForm = New Structure;
	ParametersForm.Insert("IndicatorsReg"				, IndicatorRegister);
	ParametersForm.Insert("AddressStorage"			, AddressStorage);
	ParametersForm.Insert("NameAccountingRegister" 	, NameAccountingRegister);
	ParametersForm.Insert("TemplateHeader" 	, TemplateHeader);
	ParametersForm.Insert("TemplateFooter" 	, TemplateFooter);
	ParametersForm.Insert("Groups" 				, Groups);
	ParametersForm.Insert("NumberLayoutDesign" 	, NumberLayoutDesign);
	ParametersForm.Insert("OutputCellar" 			, OutputCellar);
	ParametersForm.Insert("OutputHeading" 		, OutputHeading);
	ParametersForm.Insert("MigratingAnalytics" 			, MigratingAnalytics);
	
	NotificationOfClosure = New NotifyDescription("AccessOptionsCompletion", ThisForm);
	
	OpenForm("Отчет.InteractiveTBS.Форма.FormParameters", ParametersForm, ThisForm,,,,NotificationOfClosure);
	
EndProcedure

&AtClient
Procedure AccessOptionsCompletion(ResultClosure, AdditionalParameters) Export
	
	If ResultClosure = DialogReturnCode.Cancel OR ResultClosure = Undefined Then
		Return;	
	Endif;
	AccessSettingsOnServer(ResultClosure);	
		
EndProcedure
		
&AtServer
Procedure AccessSettingsOnServer(ResultClosure) Export
	
	NP = GetFromTempStorage(AddressStorage);
		
	FillPropertyValues(ThisForm, ResultClosure);
	
	IndicatorRegister.Load(ResultClosure.IndicatorsReg.Unload());
		
	AccountingReg = Metadata.AccountingRegisters[NameAccountingRegister];
	
	CompleteTVResources(AccountingReg);	

	IndicatorsReport();	
	
	PutToTempStorage(NP, AddressStorage);
	
EndProcedure

&AtClient
Procedure BeforeClose(Failure, StandardProcessing)
	
	ThisForm.VariantModified = False;
	
EndProcedure

&AtClient
Procedure BeforeRowChange(Element, Failure)
	
	CheckFilterBeforeChanging(Element, Failure);		
	
	If NOT Failure AND (Find(Element.CurrentItem.Name, "LeftmostValueFilter") > 0 AND TypeOf(Element.CurrentData.LeftValue) = Type("DataCompositionField")) Then
		
		ParametersForm = New Structure;
		ParametersForm.Insert("Mode"					, "Отбор");
		ParametersForm.Insert("DataCompositionSchema", DataCompositionSchema);
		ParametersForm.Insert("ExcludedFields"		, GetForbiddenFields());
		ParametersForm.Insert("AddressStorage"		, AddressStorage);
		
		AdditionalParameters = New Structure;
		AdditionalParameters.Insert("Element", Element);
		
		NotificationOfClosure = New NotifyDescription("SelectionsBeforeProceedingToChangeEnd", ThisForm, AdditionalParameters);
	
		OpenForm("Отчет.InteractiveTBS.Форма.FormSelectAvailableFields", ParametersForm, ThisForm,,,,NotificationOfClosure);
		
		Failure = True;
		
	Endif;	
	
EndProcedure

&AtClient
Procedure SelectionsBeforeProceedingToChangeEnd(ResultClosure, AdditionalParameters) Export
	
	Element = AdditionalParameters.Element;
	
	ParametersOfSelectedField = ResultClosure;
	
	If TypeOf(ParametersOfSelectedField) = Type("Structure") Then
		
		CurrentRow = InteractiveTBS.SettingsComposer.Settings.Filter.GetObjectByID(Element.CurrentRow);
		
		If Find(Element.CurrentItem.Name, "LeftmostValueFilter") > 0 Then 
			CurrentRow.LeftValue = New DataCompositionField(ParametersOfSelectedField.Field);
		Endif;
		
	Endif;
	
EndProcedure

&AtClient
Procedure CheckFilterBeforeChanging(Element, Failure)
	
	CompositionField = New DataCompositionField("Account.OffBalance");
	If Element.CurrentData.LeftValue = 	CompositionField Then
		Failure = True;
	Else	
		CheckFilterBeforeChangingOnServer(Element.CurrentData.LeftValue, Failure);	
	Endif;
		
EndProcedure

&AtServer
Procedure CheckFilterBeforeChangingOnServer(LeftValue, Failure)
	
	NP = GetFromTempStorage(AddressStorage);
	
	FirstBalance = GetFirstBalance();	
	If FirstBalance <> Undefined Then
		CompositionField = New DataCompositionField(FirstBalance.Name);
	
		If LeftValue = CompositionField Then
			Failure = True;
			Return;
		Endif;
	Endif;
	
EndProcedure

&AtClient
Procedure FilterBeforeDeleting(Element, Failure)
	
	CheckFilterBeforeChanging(Element, Failure);		
	
	If NOT Failure Then
		RemoveTVFiltersOnRegisters(Element.CurrentData);
	Endif;
	
EndProcedure

&AtClient
Procedure BeforeAddRow(Element, Failure, Copy, Parent, Group, Option)
	
	If Copy Then
		CheckFilterBeforeChanging(Element, Failure);		
	Else 
		
		ParametersForm = New Structure;
		ParametersForm.Insert("Mode"					, "Отбор");
		ParametersForm.Insert("DataCompositionSchema", DataCompositionSchema);
		ParametersForm.Insert("ExcludedFields"		, GetForbiddenFields());
		ParametersForm.Insert("AddressStorage"		, AddressStorage);
		
		AdditionalParameters = New Structure;
		AdditionalParameters.Insert("Element", Element);
		
		NotificationOfClosure = New NotifyDescription("SelectionsBeforeYouAddEnd", ThisForm, AdditionalParameters);
	
		OpenForm("Отчет.InteractiveTBS.Форма.FormSelectAvailableFields", ParametersForm, ThisForm,,,,NotificationOfClosure);
		
		Failure = True;
		
	Endif;		
	
EndProcedure

&AtServer
Function GetNameOfFirstBalanceAtServer()
	
	NP 					= GetFromTempStorage(AddressStorage);
	
	FirstBalance 	= GetFirstBalance();	
	
	Result 			= ?(FirstBalance <> Undefined, FirstBalance.Name, "");
	
	Return Result;
	
EndFunction

&AtClient
Procedure SelectionsBeforeYouAddEnd(ResultClosure, AdditionalParameters) Export
	
	Element = AdditionalParameters.Element;
	
	ParametersOfSelectedField = ResultClosure;
	
	If TypeOf(ParametersOfSelectedField) = Type("Structure") Then
		
		If Element.CurrentRow = Undefined Then
			CurrentRow = Undefined;
		Else
			CurrentRow = InteractiveTBS.SettingsComposer.Settings.Filter.GetObjectByID(Element.CurrentRow);
		Endif;
		
		If Upper(ParametersOfSelectedField.Field) = Upper("Account.ЗАБАЛАНСОВЫЙ") OR 
			GetNameOfFirstBalanceAtServer() = ParametersOfSelectedField.Field Then
			Return;	
		Endif;
		
		If TypeOf(CurrentRow) = Type("DataCompositionFilterItemGroup") Then
			FilterItem = CurrentRow.Items.Add(Type("DataCompositionFilterItem"));
		Elsif TypeOf(CurrentRow) = Type("DataCompositionFilterItem") Then
			If CurrentRow.Parent <> Undefined Then
				FilterItem = CurrentRow.Parent.Items.Add(Type("DataCompositionFilterItem"));
			Else
				FilterItem = InteractiveTBS.SettingsComposer.Settings.Filter.Items.Add(Type("DataCompositionFilterItem"));
			Endif;
		Else
			FilterItem = InteractiveTBS.SettingsComposer.Settings.Filter.Items.Add(Type("DataCompositionFilterItem"));
		Endif;
		
		FilterItem.LeftValue  = New DataCompositionField(ParametersOfSelectedField.Field);
		FilterItem.ComparisonType = ParametersOfSelectedField.ComparisonType;
		
		AddTVSelectionRegister(FilterItem);			
		
		Element.CurrentRow = InteractiveTBS.SettingsComposer.Settings.Filter.ПолучитьИдентификаторПоОбъекту(FilterItem);
		
	Endif;
	
EndProcedure

&AtClient
Procedure FilterWhenYouAreFinishedEditing(Element, NewString, CancelEditing)
	
	If Element.CurrentData <> Undefined Then
	
		AddTVSelectionRegister(Element.CurrentData);			
	
	Endif;

EndProcedure
