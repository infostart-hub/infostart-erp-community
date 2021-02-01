&AtServer
Procedure OnCreateAtServer(Failure, StandardProcessing)

	ChoiceInitialValue = Parameters.SampleFirstSection;
	
	ChosenValueSection.LoadValues(Parameters.SampleFirstSection.UnloadValues());
	
	AccountingReg 		= Metadata.AccountingRegisters[Parameters.NameAccountingRegister];
	For each Dimension In AccountingReg.Dimensions Do
		TypeOfIncision 			= Dimension.Type.AdjustValue();
		Break;
	EndDo;
	
	ToObtainValuesOfCut(TypeOfIncision);

	For Each Element In ChosenValueSection Do
		
		ArrayOfStrings = ValuesOfIncision.FindRows(New Structure("Ref", Element.Value));	
		
		For Each String In ArrayOfStrings Do
			String.Check = True;
		EndDo;
		
	EndDo;

EndProcedure

&AtServer
Procedure ToObtainValuesOfCut(ValueOfIndex)	

	NameTable = ValueOfIndex.Metadata().FullName();
	
	QueryText = "SELECT ALLOWED 
	|	CASE WHEN DeletionMark THEN 2
	|	ELSE 1 END AS PictureIndex,
	| 	REFPRESENTATION(Ref) AS Description,
	|	Ref AS Ref ";
	QueryText = QueryText + Chars.LF + "FROM" + Chars.LF;
	QueryText = QueryText + "	" + NameTable + " AS _Table" + Chars.LF;
	QueryText = QueryText + "AUTOORDER";
	
	Query = New Query(QueryText);
		
	ValuesOfIncision.Load(Query.Execute().Unload());
	
EndProcedure

&AtClient
Procedure SelectOrClearCheckBoxes(Check)
	
	For Each Element In ValuesOfIncision Do
		Element.Check = Check;
	EndDo;	
	
EndProcedure

&AtClient
Procedure CheckAll(Command)
	
	SelectOrClearCheckBoxes(True);
		
EndProcedure

&AtClient
Procedure UncheckAll(Command)
	
	SelectOrClearCheckBoxes(False);
	
EndProcedure

&AtClient
Procedure Select(Command)
	
	ChooseValueSection();
		
EndProcedure

&AtClient
Procedure ChooseValueSection()
	
	ArrayOfStrings = ValuesOfIncision.FindRows(New Structure("Check", True));
	
	ChosenValueSection.Clear();
	
	For Each String In ArrayOfStrings Do
		ChosenValueSection.Add(String.Ref);
	EndDo;
		
	ChosenValueSection.SortByValue();
	
	FormOwner.FirstSection = ChosenValueSection;
	FormOwner.ToUpdateSelectionAtServer();
	FormOwner.ToEstablishConditionFieldSpreadsheetDocument("Irrelevance");
	Close();
	
EndProcedure

&AtClient
Procedure ValuesOfIncisionOfChoice(Element, ChosenLine, Field, StandardProcessing)
	
	SelectOrClearCheckBoxes(False);
	
	ValuesOfIncision[ChosenLine].Check = True;
	
	ChooseValueSection();
	
EndProcedure

&AtClient
Procedure ValuesOfIncisionBeforeYouAdd(Element, Failure, Copy, Parent, GROUP)
	
	Failure = True;
	
EndProcedure

&AtClient
Procedure ValuesOfIncisionBeforeRemoving(Element, Failure)
	
	Failure = True;
	
EndProcedure
