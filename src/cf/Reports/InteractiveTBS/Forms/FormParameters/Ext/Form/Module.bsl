&AtServer
Var NP;

&AtServer
Procedure OnCreateAtServer(Failure, StandardProcessing)
	
	OutputHeading 		= Parameters.OutputHeading;
	OutputCellar 			= Parameters.OutputCellar;
	NumberLayoutDesign 	= Parameters.NumberLayoutDesign;
	Groups 				= Parameters.Groups;
	TemplateHeader = Parameters.TemplateHeader;
	TemplateFooter 	= Parameters.TemplateFooter;
	
	MigratingAnalytics 		= Parameters.MigratingAnalytics;
	
	IndicatorRegister.Load(Parameters.IndicatorsReg.Unload());
	NameAccountingRegister = Parameters.NameAccountingRegister;
	AddressStorage = Parameters.AddressStorage;
	NP = GetFromTempStorage(AddressStorage);
		
	For each NewStr in NP.PlansAndRegisters Do
		
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
	
	FormButton 			= Items.Find(NameAccountingRegister);
	FormButton.Check 	= True;
	
	Items.IndicatorRegister.RowFilter = New FixedStructure("Register", NameAccountingRegister);
	
	Items.TemplateHeader.ChoiceList.Add("", "< нет >");
	Items.TemplateHeader.ChoiceList.Add("[&НазваниеОрганизации]");
	Items.TemplateHeader.ChoiceList.Add("[&НазваниеОтчета] ([&Period])   Страница [&НомерСтраницы]");
	Items.TemplateHeader.ChoiceList.Add("[&НазваниеОтчета] ([&Period]) [&НазваниеОрганизации]   Страница [&НомерСтраницы]");
	Items.TemplateHeader.ChoiceList.Add("[&НазваниеОтчета] ([&Period]) [&НазваниеОрганизации]   Страница [&НомерСтраницы] из [&СтраницВсего]");
	
	Items.TemplateFooter.ChoiceList.Add("", "< нет >");
	Items.TemplateFooter.ChoiceList.Add("Страница [&НомерСтраницы]");
	Items.TemplateFooter.ChoiceList.Add("[&НазваниеОрганизации]");
	Items.TemplateFooter.ChoiceList.Add("Отчет сформирован [&Дата] [&Время]");
	Items.TemplateFooter.ChoiceList.Add("Отчет сформирован [&Дата] [&Время] Пользователь: [&Пользователь]");
	Items.TemplateFooter.ChoiceList.Add("Отчет сформирован [&Дата] [&Время] Пользователь: [&Пользователь]  Страница [&НомерСтраницы] из [&СтраницВсего]");
	
EndProcedure

&AtClient
Procedure CommandOK(Command)
	
	UpdateNumberOfIndicatorsOfRegisters();
	Structure = New Structure();
	Structure.Insert("IndicatorsReg"			, IndicatorRegister);
	Structure.Insert("TemplateHeader", TemplateHeader);
	Structure.Insert("TemplateFooter"	, TemplateFooter);
	Structure.Insert("Groups" 				, Groups);
	Structure.Insert("NumberLayoutDesign" 	, NumberLayoutDesign);
	Structure.Insert("OutputCellar" 		, OutputCellar);
	Structure.Insert("OutputHeading" 		, OutputHeading);
	NotifyChoice(Structure);

EndProcedure

&AtClient
Procedure AccountingRegister(Command)
	
	RegisterButton 			= Items.Find(NameAccountingRegister);
	RegisterButton.Check 	= False;
	
	RegisterButton 			= Items.Find(Command.Name);
	RegisterButton.Check 	= True;
	NameAccountingRegister 	= Command.Name;
	Items.AccountingRegister.Title = ?(Command.Name = "Хозрасчетный", "Бухгалтерский", Command.Name);
	
	Items.IndicatorRegister.RowFilter = New FixedStructure("Register", NameAccountingRegister);
	
EndProcedure

&AtClient
Procedure OnOpen(Failure)
	
	Items.AccountingRegister.Title = ?(NameAccountingRegister = "Хозрасчетный", "Бухгалтерский", NameAccountingRegister);
	
EndProcedure

&AtClient
Procedure Update(Command)
	FillPerformanceRegisters();
EndProcedure

&AtServer
Procedure FillPerformanceRegisters() Export
	
	NP = GetFromTempStorage(AddressStorage);
	
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

&AtClient
Procedure IndicatorsRegistersFormatOfPBeginningOfSelection(Element, DataChoice, StandardProcessing)
	
	Designer 				= New FormatStringWizard(Items.IndicatorRegister.CurrentData.FormatP);
	Designer.AvailableTypes 	= New TypeDescription("Number" , , New NumberQualifiers(15,2));
	
	AdditionalParameters = New Structure("Designer", 	Designer);
	AdditionalParameters = New Structure("Element", 		Items.IndicatorRegister.CurrentData);
	NotifyDescription = New NotifyDescription("ChooseFormatCompletion", ThisForm, AdditionalParameters);
		
	Designer.Show(NotifyDescription);
		
EndProcedure

&AtClient
Procedure ChooseFormatCompletion(FormatP, AdditionalParameters) Export
	
	Element = AdditionalParameters.Element;
			
	If ValueIsFilled(FormatP) Then
		
	    Element.FormatP = FormatP;
		
	Endif;
	
EndProcedure

&AtClient
Procedure IndicatorsRegistersAtBeginningOfEdit(Element, NewString, Copy)
	
	If NewString Then
		Element.CurrentData.Register = NameAccountingRegister;
	Endif;
	
EndProcedure

&AtClient
Procedure IndicatorsOutputRegistersWhenChanging(Element)
	
	If Items.IndicatorRegister.CurrentData.Output Then
		StructureString = New Structure("Name, FormatP, Output", Items.IndicatorRegister.CurrentData.Name, Items.IndicatorRegister.CurrentData.FormatP, True);
		CheckIndicator(StructureString);
		FillPropertyValues(Items.IndicatorRegister.CurrentData, StructureString); 
	Endif;
	
EndProcedure

&AtServer
Procedure CheckIndicator(StructureString)

	RegMethod 		= Metadata.AccountingRegisters[NameAccountingRegister];
	ArrayArguments = ObtainArrayArguments(StructureString.Name, RegMethod);
	If ArrayArguments = False Then
		StructureString.FormatP 	= "";
		StructureString.Output 		= False;
		Return;
	Endif;
	If TrimAll(StructureString.FormatP) = "" Then
		Digits 	= 10;
		FractionalPart 	= 0;
		For each ResourceStr In ArrayArguments Do
			Resource = RegMethod.Resources.Find(ResourceStr);
			If Resource <> Undefined Then
				Digits 	= ?(Digits < Resource.Type.NumberQualifiers.Digits, Resource.Type.NumberQualifiers.Digits, Digits);
				FractionalPart	= ?(FractionalPart < Resource.Type.NumberQualifiers.Digits, Resource.Type.NumberQualifiers.FractionDigits, FractionalPart);
			Endif;
		EndDo;
		StructureString.FormatP = "ND = " + String(Digits + 3) + " ; NFD = " + String(FractionalPart);
	Endif;

EndProcedure




