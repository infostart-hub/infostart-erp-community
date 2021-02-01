&AtServer
Procedure OnCreateAtServer(Failure, StandardProcessing)
	
	List = Parameters.ListTypeExtDimension;
	
EndProcedure

&AtClient
Procedure CommandOK(Command)

	NotifyChoice(List);

EndProcedure


