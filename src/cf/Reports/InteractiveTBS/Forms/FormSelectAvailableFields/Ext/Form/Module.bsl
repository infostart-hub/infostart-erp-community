&AtServer
Procedure OnCreateAtServer(Failure, StandardProcessing)
	
	Mode = Parameters.Mode;
	
	If Mode = "Выбор" Then
		SampleAdditionalTurn(Parameters);
		Items.GroupAvailableFieldsFilter.Visible       = False;
		Title = NStr("ru = 'Выбор поля'");
		
		For Each Field In Parameters.ExcludedFields Do
			Constraint = Items.SelectionAvailableFields.UseRestrictions.Add();
			Constraint.Enabled = False;
			Constraint.Field = New DataCompositionField(Field);
		EndDo;		
		NumStringCurrent = Parameters.NumStringCurrent;
	Elsif Mode = "Отбор" Then
		SettingsComposer.Initialize(New DataCompositionAvailableSettingsSource(Parameters.DataCompositionSchema));
		Items.GroupAvailableFieldsSelection.Visible       = False;
		Title = NStr("ru = 'Выбор поля отбора'");
		
		For Each Field In Parameters.ExcludedFields Do
			Constraint = Items.FilterAvailableFields.UseRestrictions.Add();
			Constraint.Enabled = False;
			Constraint.Field = New DataCompositionField(Field);
		EndDo;		
	Endif;		
	
EndProcedure

&AtClient
Procedure CommandOK(Command)
	
	CurrentData = Undefined;
	If Mode = "Выбор" Then
		CurrentData = Items.SelectionAvailableFields.CurrentRow;
		AvailableField = SettingsComposer.Settings.SelectionAvailableFields.GetObjectByID(CurrentData);
	Elsif Mode = "Отбор" Then
		CurrentData = Items.FilterAvailableFields.CurrentRow;
		AvailableField = SettingsComposer.Settings.FilterAvailableFields.GetObjectByID(CurrentData);
	Endif;
	
	If Not AvailableField.Folder Then
		ParametersOfSelectedField = New Structure;
		ParametersOfSelectedField.Insert("Field"     , 			String(AvailableField.Field));
		ParametersOfSelectedField.Insert("Caption", 			AvailableField.Title);
		ParametersOfSelectedField.Insert("ValueType", 		AvailableField.ValueType);
		ParametersOfSelectedField.Insert("NumStringCurrent", 	NumStringCurrent);
		If Mode = "Отбор" Then
			If AvailableField.AvailableCompareTypes.Count() > 0 Then
				ParametersOfSelectedField.Insert("ComparisonType", AvailableField.AvailableCompareTypes[0].Value);
			Else
				ParametersOfSelectedField.Insert("ComparisonType", DataCompositionComparisonType.Equal);
			Endif;
		Endif;
		
		Close(ParametersOfSelectedField);
	Endif;
	
EndProcedure

&AtClient
Procedure AvailableSelectionFieldsSelection(Element, ChosenLine, Field, StandardProcessing)
	
	CommandOK(Undefined);
	
EndProcedure

&AtClient
Procedure AvailableFieldsSelectionSelection(Element, ChosenLine, Field, StandardProcessing)
	
	CommandOK(Undefined);
	
EndProcedure

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
				AddFieldDataSet(DCS.DataSets[0], StrChange.Name + "Balanced", "Измерениe " + "Кop " + StrChange.Synonym,, TextFieldsQuery);
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
	SettingsComposer.Refresh(); 
	SettingsComposer.Settings.Structure.Clear();
	
	SettingsComposer.Settings.Selection.Items.Clear();
	
	SettingsComposer.LoadSettings(DCS.DefaultSettings);

EndFunction

