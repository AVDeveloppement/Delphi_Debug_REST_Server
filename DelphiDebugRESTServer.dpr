Program DelphiDebugRESTServer;

Uses
  System.StartUpCopy,
  FMX.Forms,
  Main In 'Main.pas' {fmMain} ,
  SendFile In 'SendFile.pas' {fmSendFile} ,
  OrderModel In 'OrderModel.pas' {fmOrderModel} ,
  SendModel In 'SendModel.pas';

{$R *.res}


Begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TFmMain, FmMain);
  Application.Run;

End.
