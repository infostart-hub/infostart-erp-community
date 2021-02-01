&AtServer
Function ToCreateFilter() Export
	VT = New ValueTable;
	VT.Columns.Add("KeySearch",			New TypeDescription("String"));
	VT.Columns.Add("Value");
	VT.Columns.Add("ComparisonType", New TypeDescription("DataCompositionComparisonType"));
	Return VT;
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
Function ProcessingCellTable_FindStringToDetails(NumString, Tab)
	If TypeOf(Tab) = Type("ValueTable") Then
		For each StrTab In Tab Do
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
Function AddFieldDataSet(DataSet, Field, Title, DataPath = Undefined, TextFieldsQuery = "", ValueType = Undefined)
	
	If DataPath = Undefined Then
		DataPath = Field;
	Endif;
	
	TextFieldsQuery 				= TextFieldsQuery + ", Turnovers." + Field + " AS " + Field; 
	
	FieldDataSet 				= DataSet.Fields.Add(Type("DataCompositionSchemaDataSetField"));
	FieldDataSet.Field			= Field;
	FieldDataSet.Title   	= Title;
	FieldDataSet.DataPath 	= DataPath;   
	If ValueType <> Undefined Then
		FieldDataSet.ValueType    = ValueType;
	Endif;
	
	Return FieldDataSet;
	
EndFunction

&AtServer
Function SampleAdditionalTurn(OptionsOpen)
	Var Account, BalancedAccount;
	
	NP 				= GetFromTempStorage(OptionsOpen.AddressStorage);
	StringTable 	= ProcessingCellTable_FindStringToDetails(OptionsOpen.NumStringCurrent, NP.TabNew); 
	
	Filter 			= ValueFromStringInternal(StringTable.Filter);
	If TypeOf(Filter) <> Type("ValueTable") Then
		Filter = ToCreateFilter();
	Endif;
	
	GetPresentationFilter(Filter, "Account", 		Account);
	GetPresentationFilter(Filter, "BalancedAccount", 	BalancedAccount);
		
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
		
	For each StrChange In NP.TVDimensions Do		
		If (NOT ValueIsFilled(StrChange.Value)OR TypeOf(StrChange.Value) = Type("ValueList")) AND (StrChange.AccountingFlag = "" OR (ValueIsFilled(Account) AND IsSlitAccounting(Account, StrChange))) Then
			AddFieldDataSet(DCS.DataSets[0], StrChange.Name, "Измерениe " + StrChange.Synonym,, TextFieldsQuery);
			TextSelectedFields 	= TextSelectedFields + ", Turnovers." + StrChange.Name + ".*";
		Endif;
		If NOT StrChange.Balance Then
			If (NOT ValueIsFilled(StrChange.Value)OR TypeOf(StrChange.Value) = Type("ValueList")) AND (StrChange.AccountingFlag = "" OR (ValueIsFilled(BalancedAccount) AND IsSlitAccounting(BalancedAccount, StrChange))) Then
				AddFieldDataSet(DCS.DataSets[0], StrChange.Name + "Balanced", "Измерениe " + "Коp " + StrChange.Synonym,, TextFieldsQuery);
				TextSelectedFields 	= TextSelectedFields + ", Turnovers." + StrChange.Name + "Balanced.*";
			Endif;
		Endif;
		
	EndDo;
	
	ArrayExtDimension		= New Array;
	ArrayBalancedExtDimension	= New Array;
	
	If ValueIsFilled(Account) Then
		If NP.ExtDimensionTypeName <> "" Then
			For N = 1 To Account.ExtDimensionTypes.Count() Do
				AddFieldDataSet(DCS.DataSets[0], "ExtDimension" + N, "Субконтo " + Account.ExtDimensionTypes[N-1].ExtDimensionType.Description,, TextFieldsQuery, Account.ExtDimensionTypes[N-1].ExtDimensionType.ValueType);
				TextSelectedFields 	= TextSelectedFields + ", Turnovers.ExtDimension" + N + ".* ";
			EndDo;
			ArrayExtDimension		= Account.ExtDimensionTypes.UnloadColumn("ExtDimensionType");
		Endif;
	Endif;
	
	If ValueIsFilled(BalancedAccount) Then
		If NP.ExtDimensionTypeName <> "" Then
			For N = 1 To BalancedAccount.ExtDimensionTypes.Count() Do
				AddFieldDataSet(DCS.DataSets[0], "BalancedExtDimension" + N, "Коp.Субконтo " + BalancedAccount.ExtDimensionTypes[N-1].ExtDimensionType.Description,, TextFieldsQuery, BalancedAccount.ExtDimensionTypes[N-1].ExtDimensionType.ValueType);
				TextSelectedFields 	= TextSelectedFields + ", Turnovers.BalancedExtDimension" + N + ".* ";
			EndDo;
			ArrayBalancedExtDimension 	= BalancedAccount.ExtDimensionTypes.UnloadColumn("ExtDimensionType");
		Endif;
	Endif;
			
	TextSelectedFields 	= Mid(TextSelectedFields, 3);
	TextFieldsQuery 	= Mid(TextFieldsQuery, 3);
	
	QueryText = 
	"SELECT ALLOWED
	|	" + TextFieldsQuery + " 
	|" + ?(ValueIsFilled(TextSelectedFields), "{SELECT " + StrReplace(TextSelectedFields, "Turnovers.", "") + "}", "") + "
	|FROM
	|	AccountingRegister." + NP.NameAccountingRegister + ".Turnovers( , , , Account IN HIERARCHY (&Account), &ArrayExtDimension, , BalancedAccount IN HIERARCHY (&BalancedAccount), &ArrayBalancedExtDimension)  AS Turnovers
	|" + ?(ValueIsFilled(TextSelectedFields), "{WHERE " + TextSelectedFields + "}", "");
	
	DCS.DataSets[0].Query = QueryText;
	
	DataCompositionSchema = PutToTempStorage(DCS, UUID);	
	
	SettingsComposer.Initialize(New DataCompositionAvailableSettingsSource(DataCompositionSchema));
	
	SettingsDCS 	= DCS.DefaultSettings;
    GroupDCS 	= SettingsDCS.Structure.Add(Type("DataCompositionGroup"));
    AutoField 		= GroupDCS.Selection.Items.Add(Type("DataCompositionAutoSelectedField"));
    AutoField.Use = True;
	
	SettingsComposer.Refresh(); 
	SettingsComposer.Settings.Structure.Clear();
	
	SettingsComposer.Settings.Selection.Items.Clear();
	
	SettingsComposer.LoadSettings(DCS.DefaultSettings);
	
EndFunction

&AtServer
Procedure OnCreateAtServer(Failure, StandardProcessing)
	
	SampleAdditionalTurn(Parameters);
	
	Title = "Выбор многоуровнего разворота";
	
	For Each Field In Parameters.ExcludedFields Do
		Constraint = Items.SelectionAvailableFields.UseRestrictions.Add();
		Constraint.Enabled = False;
		Constraint.Field = New DataCompositionField(Field);
	EndDo;		
	
	NumStringCurrent = Parameters.NumStringCurrent;
	
EndProcedure

&AtClient
Procedure CommandOK(Command)
	
	QueryText = GetRequestLayout();
	
	StructureOfReturn = New Structure("ArrayOfSelectedFields, NumStringCurrent, TextOfQuery", New Array, NumStringCurrent, QueryText);
		
	For each ElementField in SettingsComposer.Settings.Selection.Items Do
		
		AvailableField = SettingsComposer.Settings.Selection.SelectionAvailableFields.FindField(ElementField.Field);
		
		ChosenField = New Structure("DataPath, ValueType");
		ChosenField.DataPath = String(AvailableField.Field);
		ChosenField.ValueType = AvailableField.ValueType;
		StructureOfReturn.ArrayOfSelectedFields.Add(ChosenField);
		
	EndDo;	
	
	Close(StructureOfReturn);
		
EndProcedure

&AtClient
Procedure AvailableSelectionFieldsSelection(Element, ChosenLine, Field, StandardProcessing)
	
	CommandAdd(Undefined);
	
EndProcedure

&AtClient
Procedure CommandAdd(Command)
	
	CurrentData = Items.SelectionAvailableFields.CurrentRow;
	
	If CurrentData = Undefined Then
		Return;
	Endif;
	
	AvailableField = SettingsComposer.Settings.SelectionAvailableFields.GetObjectByID(CurrentData);
	
	AlreadyAdded = False;
	
	For each ElementField In SettingsComposer.Settings.Selection.Items Do
	
		If ElementField.Field = AvailableField.Field Then
			AlreadyAdded = True;
		Endif;
	
	EndDo;
	
	If Not AvailableField.Folder AND NOT AlreadyAdded Then
		ElementOfChoice = SettingsComposer.Settings.Selection.Items.Add(Type("DataCompositionSelectedField"));
		ElementOfChoice.Field =  New DataCompositionField(AvailableField.Field);
	Endif;
		
EndProcedure

&AtServer
Function GetRequestLayout()

	StructureOfQuery = New Structure();
	TemplateComposer = New DataCompositionTemplateComposer;
	
	DCS = GetFromTempStorage(DataCompositionSchema);	

	SettingsComposer.Initialize(New DataCompositionAvailableSettingsSource(DCS));
	TemplateDataComposition = TemplateComposer.Execute(DCS, SettingsComposer.GetSettings(), ,,Type("DataCompositionTemplateGenerator"));

	If TemplateDataComposition.DataSets.Count() > 0 Then
		
		Try
			StructureOfQuery.Insert("TextOfQuery", TemplateDataComposition.DataSets.MainDataset.Query);
			StructureOfQuery.Insert("Settings", New Structure());
			For each OptionRequest In TemplateDataComposition.ParameterValues Do
				StructureOfQuery.Parameters.Insert(OptionRequest.Name, OptionRequest.Value);	
			EndDo;
			
			StructureOfQuery.Insert("Fields", New Structure());
			For each QueryField In TemplateDataComposition.DataSets.MainDataset.Fields Do
				StructureOfQuery.Fields.Insert(QueryField.Name, QueryField.DataPath);	
			EndDo;
			
		Except
		EndTry;	
		
	Endif;
	Return StructureOfQuery;
	
EndFunction

&AtClient
Procedure SelectedFieldsChoiceCase(Element, ChosenLine, Field, StandardProcessing)
	
	DeleteCommand(Undefined);
	
EndProcedure

&AtClient
Procedure DeleteCommand(Command)
	
	CurrentData = Items.SelectedFieldsChoice.CurrentRow;
	
	If CurrentData <> Undefined Then
		SettingsComposer.Settings.Selection.Items.Delete(SettingsComposer.Settings.Selection.GetObjectByID(CurrentData));
	Endif;
	
EndProcedure

&AtClient
Procedure TeamMoveUp(Command)
	
	CommandToMove(1);
	
EndProcedure

&AtClient
Procedure CommandToMove(Offset)
	
	CurrentData = Items.SelectedFieldsChoice.CurrentRow;
	
	If CurrentData <> Undefined Then
		SettingsComposer.Settings.Selection.Items.Move(SettingsComposer.Settings.Selection.GetObjectByID(CurrentData), Offset);
	Endif;                                            
	
EndProcedure

&AtClient
Procedure CommandToMoveDown(Command)
	
	CommandToMove(-1);
	
EndProcedure

