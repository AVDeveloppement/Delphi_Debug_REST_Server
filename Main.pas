Unit Main;

Interface

Uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, FMX.Edit, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.ListBox, System.IniFiles, REST.Types,
  REST.Client, REST.Authenticator.Basic, Data.Bind.Components, Data.Bind.ObjectScope,
  System.ImageList, FMX.ImgList, System.Rtti, FMX.Grid.Style, FMX.Grid,
  FMX.TabControl, FMX.DialogService.Sync, System.Actions,
  FMX.ActnList, FMX.Menus, SendModel, SendFile, OrderModel;

Type
  TfmMain = Class(TForm)
    pSend: TPanel;
    pAnswer: TPanel;
    gbDataToSend: TGroupBox;
    gbServerAnswer: TGroupBox;
    gbRESTServer: TGroupBox;
    btSend: TButton;
    eRESTServerAdress: TEdit;
    mServerAnswer: TMemo;
    cbModelDataToSend: TComboBox;
    btModelDataToSendAdd: TButton;
    btModelDataToSendMenu: TButton;
    eRESTServerUsername: TEdit;
    eRESTServerPassword: TEdit;
    eDataToSendURI: TEdit;
    cbDataToSendMethod: TComboBox;
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    HTTPBasicAuthenticator: THTTPBasicAuthenticator;
    btModelDataToSendSave: TButton;
    ImageList: TImageList;
    tcDataToSend: TTabControl;
    tiDataToSendJSON: TTabItem;
    tiDataToSendFiles: TTabItem;
    mDataToSend: TMemo;
    sgDataToSendFiles: TStringGrid;
    scName: TStringColumn;
    scFilename: TStringColumn;
    scMimetype: TStringColumn;
    btDataToSendFilesAdd: TButton;
    btDataToSendFilesDelete: TButton;
    PopupMenu: TPopupMenu;
    miAddModel: TMenuItem;
    ActionList: TActionList;
    aAddModel: TAction;
    aSaveModel: TAction;
    aDeleteModel: TAction;
    miSaveModel: TMenuItem;
    miDeleteModel: TMenuItem;
    miSeparator: TMenuItem;
    miRenameModel: TMenuItem;
    aRenameModel: TAction;
    miReorderModel: TMenuItem;
    aOrderModel: TAction;
    Procedure BtSendClick(Sender: TObject);
    Procedure RESTRequestAfterExecute(Sender: TCustomRESTRequest);
    Procedure RESTRequestHTTPProtocolError(Sender: TCustomRESTRequest);
    Procedure FormDestroy(Sender: TObject);
    Procedure aAddModelExecute(Sender: TObject);
    Procedure CbModelDataToSendChange(Sender: TObject);
    Procedure aDeleteModelExecute(Sender: TObject);
    Procedure aSaveModelExecute(Sender: TObject);
    Procedure DataToSendChange(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
    Procedure BtDataToSendFilesAddClick(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure BtDataToSendFilesDeleteClick(Sender: TObject);
    Procedure CbModelDataToSendClick(Sender: TObject);
    Procedure FormClose(Sender: TObject; Var Action: TCloseAction);
    Procedure btModelDataToSendMenuClick(Sender: TObject);
    Procedure aRenameModelExecute(Sender: TObject);
    Procedure aOrderModelExecute(Sender: TObject);
  Private
    ActualSendFileList: TSendFileList;
    Procedure AddFileInStringGrid(ASendFile: TSendFile);
    Procedure DeleteFileInStringGrid(AIdx: Integer);
    Procedure SaveSettings;
    Procedure ClearFileInStringGrid;
    Procedure SetComboBoxDataToSendModel;
  Public
  End;

Var
  fmMain: TfmMain;

Implementation

{$R *.fmx}

Resourcestring
  rsFMMAIN_CAPTION = 'Debug REST Server';
  rsMODEL_NAME_CAPTION = 'Enter a name for the data model';
  rsMODEL_NAME_LABEL = 'Model name:';
  rsMODEL_DELETE = 'Are you sure you want to delete this data model?';
  rsMODEL_SAVE_ON_EXIT = 'Model have been modified, do you want to save it?';
  rsSEND_RESULT = 'Debug REST Server URI: %s Execution time: %d ms';
  rsFIlE_DELETE = 'Are you sure you want to remove this file fom list?';

  { TfmMain }

Procedure TfmMain.AddFileInStringGrid(ASendFile: TSendFile);
Var
  I: Integer;
Begin
  ActualSendFileList.Add(TSendFile.Create(ASendFile));

  With sgDataToSendFiles Do
  Begin
    I        := RowCount;
    RowCount := RowCount + 1;
    BeginUpdate;
    Try
      Cells[0, I] := ASendFile.Name;
      Cells[1, I] := ASendFile.Filename;
      Cells[2, I] := CRESTContentTypeAsString[ASendFile.ContentType];
    Finally
      EndUpdate;
    End;
  End;

  DataToSendChange(Nil);
End;

Procedure TfmMain.aOrderModelExecute(Sender: TObject);
Var
  mrSave: TModalResult;
Begin
  // change in model ? ask user what he want to do
  If aSaveModel.Enabled Then
  Begin
    mrSave := TDialogServiceSync.MessageDialog(rsMODEL_SAVE_ON_EXIT, TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel], TMsgDlgBtn.mbYes, 0);

    // cancel or others stop and exit
    If (mrSave <> mrYes) And (mrSave <> mrNo) Then
      Exit;

    If mrSave = mrYes Then
      aSaveModelExecute(aSaveModel); // Save change before reorder

    If mrSave = mrNo Then
      aSaveModel.Enabled := False; // Disable button for prevent ask save on change
  End;

  With TfmOrderModel.Create(Self) Do
    Try
      OrderedSendModelList.Assign(SendModelList);
      If ShowModal = mrOk Then
      Begin
        SendModelList.Assign(OrderedSendModelList);
        SetComboBoxDataToSendModel;
        cbModelDataToSend.ItemIndex := -1;
      End;
    Finally
      Free;
    End;
End;

Procedure TfmMain.SetComboBoxDataToSendModel;
Begin
  With cbModelDataToSend Do
    Try
      BeginUpdate;
      Clear;
      For Var I := 0 To SendModelList.Count - 1 Do
        Items.Add(StringReplace(SendModelList[I].Name, '&', '&&', [RfReplaceAll]));
    Finally
      EndUpdate;
    End;
End;

Procedure TfmMain.ClearFileInStringGrid;
Begin
  ActualSendFileList.Clear;

  sgDataToSendFiles.RowCount := 0;
End;

Procedure TfmMain.DeleteFileInStringGrid(AIdx: Integer);
Begin
  ActualSendFileList.Delete(AIdx);
  ActualSendFileList.SetToStringGrid(sgDataToSendFiles);

  DataToSendChange(Nil);
End;

Procedure TfmMain.BtDataToSendFilesAddClick(Sender: TObject);
Begin
  With TfmSendFile.Create(Self) Do
    Try
      If ShowModal = mrOk Then
        AddFileInStringGrid(SendFile);
    Finally
      Free;
    End;
End;

Procedure TfmMain.BtDataToSendFilesDeleteClick(Sender: TObject);
Begin
  If sgDataToSendFiles.Selected = -1 Then
    Exit;

  If TDialogServiceSync.MessageDialog(rsFIlE_DELETE, TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0) = mrYes Then
    DeleteFileInStringGrid(sgDataToSendFiles.Selected);
End;

Procedure TfmMain.btModelDataToSendMenuClick(Sender: TObject);
Var
  pt: TPointF;
Begin
  pt.X := 0;
  pt.Y := btModelDataToSendMenu.Height;
  pt   := btModelDataToSendMenu.LocalToAbsolute(pt);
  pt   := ClientToScreen(pt);
  PopupMenu.Popup(pt.X, pt.Y);
End;

Procedure TfmMain.aAddModelExecute(Sender: TObject);
Var
  sName: Array [0 .. 0] Of String;
  SendModel: TSendModel;
Begin
  If TDialogServiceSync.InputQuery(rsMODEL_NAME_CAPTION, [rsMODEL_NAME_LABEL], sName) Then
  Begin
    // create new model
    SendModel := TSendModel.Create(sName[0], TRESTRequestMethod(cbDataToSendMethod.ItemIndex),
      eDataToSendURI.Text, mDataToSend.Text);
    SendModel.FileList.Assign(ActualSendFileList);
    SendModelList.Add(SendModel); // add in list

    cbModelDataToSend.Items.Add(StringReplace(sName[0], '&', '&&', [RfReplaceAll]));
    cbModelDataToSend.ItemIndex := cbModelDataToSend.Count - 1;
  End;
End;

Procedure TfmMain.aDeleteModelExecute(Sender: TObject);
Begin
  If cbModelDataToSend.ItemIndex = -1 Then
    Exit;

  If TDialogServiceSync.MessageDialog(rsMODEL_DELETE, TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0) <> mrYes Then
    Exit;

  SendModelList.Delete(cbModelDataToSend.ItemIndex);
  SetComboBoxDataToSendModel;
  CbModelDataToSendChange(cbModelDataToSend);
End;

Procedure TfmMain.aRenameModelExecute(Sender: TObject);
Var
  sName: Array [0 .. 0] Of String;
Begin
  If cbModelDataToSend.ItemIndex = -1 Then
    Exit;

  sName[0] := SendModelList[cbModelDataToSend.ItemIndex].Name;
  If TDialogServiceSync.InputQuery(rsMODEL_NAME_CAPTION, [rsMODEL_NAME_LABEL], sName) Then
  Begin
    SendModelList[cbModelDataToSend.ItemIndex].Name      := sName[0];
    cbModelDataToSend.Items[cbModelDataToSend.ItemIndex] := StringReplace(sName[0], '&', '&&', [RfReplaceAll]);
    cbModelDataToSend.Repaint;
  End;
End;

Procedure TfmMain.aSaveModelExecute(Sender: TObject);
Var
  iIdx: Integer;
Begin
  If Not aSaveModel.Enabled Then
    Exit;

  iIdx := cbModelDataToSend.ItemIndex;
  If iIdx In [0 .. SendModelList.Count - 1] Then
  Begin
    SendModelList[iIdx].Method := TRESTRequestMethod(cbDataToSendMethod.ItemIndex);
    SendModelList[iIdx].URI    := eDataToSendURI.Text;
    SendModelList[iIdx].Data   := mDataToSend.Text;
    SendModelList[iIdx].FileList.Assign(ActualSendFileList);

    aSaveModel.Enabled := False;

    SaveSettings;
  End;
End;

Procedure TfmMain.BtSendClick(Sender: TObject);
Begin
  fmMain.Caption := rsFMMAIN_CAPTION;
  mServerAnswer.Lines.Clear;
  Application.ProcessMessages;

  RESTClient.BaseURL := eRESTServerAdress.Text;

  RESTRequest.Params.ClearAndResetID;
  RESTRequest.ClearBody;

  RESTRequest.Resource := eDataToSendURI.Text;
  RESTRequest.Method   := TRESTRequestMethod(cbDataToSendMethod.ItemIndex);

  If mDataToSend.Text <> '' Then
    RESTRequest.AddBody(mDataToSend.Text, TRESTContentType.CtAPPLICATION_JSON);

  If ActualSendFileList.Count > 0 Then
    For Var I := 0 To ActualSendFileList.Count - 1 Do
      RESTRequest.AddFile(ActualSendFileList[I].Name, ActualSendFileList[I].Filename,
        ActualSendFileList[I].ContentType);

  HTTPBasicAuthenticator.Username := eRESTServerUsername.Text;
  HTTPBasicAuthenticator.Password := eRESTServerPassword.Text;
  HTTPBasicAuthenticator.Authenticate(RESTRequest);

  RESTRequest.Execute;
End;

Procedure TfmMain.CbModelDataToSendChange(Sender: TObject);
Var
  iIdx: Integer;
Begin
  iIdx := (Sender As TComboBox).ItemIndex;
  If iIdx In [0 .. SendModelList.Count - 1] Then
  Begin
    SendModelList[iIdx].FileList.SetToStringGrid(sgDataToSendFiles);
    // keep actual list for modify
    ActualSendFileList.Assign(SendModelList[iIdx].FileList);

    cbDataToSendMethod.ItemIndex := Integer(SendModelList[iIdx].Method);
    eDataToSendURI.Text          := SendModelList[iIdx].URI;
    mDataToSend.Text             := SendModelList[iIdx].Data;
  End;

  aSaveModel.Enabled              := False;
  aRenameModel.Enabled            := iIdx <> -1;
  aOrderModel.Enabled             := SendModelList.Count > 0;
  aDeleteModel.Enabled            := iIdx <> -1;

  btDataToSendFilesDelete.Enabled := ActualSendFileList.Count > 0;
End;

Procedure TfmMain.CbModelDataToSendClick(Sender: TObject);
Var
  mrSave: TModalResult;
Begin
  If Not aSaveModel.Enabled Then
    Exit;

  mrSave := TDialogServiceSync.MessageDialog(rsMODEL_SAVE_ON_EXIT, TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel], TMsgDlgBtn.mbYes, 0);

  If mrSave = mrYes Then
    aSaveModelExecute(aSaveModel);

  If (mrSave = mrYes) Or (mrSave = mrNo) Then
    cbModelDataToSend.DropDown;
End;

Procedure TfmMain.FormClose(Sender: TObject; Var Action: TCloseAction);
Begin
  SaveSettings;
End;

Procedure TfmMain.SaveSettings;
Var
  MemIniFile: TMemIniFile;
Begin
  MemIniFile := TMemIniFile.Create(IncludeTrailingPathDelimiter(System.SysUtils.GetCurrentDir) + 'configuration.ini');
  Try
    With MemIniFile Do
    Begin
      If WindowState = TWindowState.WsNormal Then
      Begin
        WriteInteger('fmMain', 'Width', Width);
        WriteInteger('fmMain', 'Height', Height);

        WriteInteger('fmMain', 'Left', Left);
        WriteInteger('fmMain', 'Top', Top);
      End;

      WriteInteger('fmMain', 'WindowState', Integer(WindowState));

      WriteString('fmMain', 'eRESTServerAdress.Text', eRESTServerAdress.Text);
      WriteString('fmMain', 'eRESTServerUsername.Text', eRESTServerUsername.Text);
      WriteString('fmMain', 'eRESTServerPassword.Text', eRESTServerPassword.Text);

      WriteString('fmMain', 'eDataToSendURI.Text', eDataToSendURI.Text);
      WriteInteger('fmMain', 'cbDataToSendMethod.ItemIndex', cbDataToSendMethod.ItemIndex);
      WriteString('fmMain', 'mDataToSend.Lines.Text', StringReplace(mDataToSend.Lines.Text, sLineBreak, '#LNBREAK#',
        [RfReplaceAll, RfIgnoreCase]));
      WriteInteger('fmMain', 'tcDataToSend.TabIndex', tcDataToSend.TabIndex);

      SendModelList.SaveTo(MemIniFile);
      WriteInteger('fmMain', 'cbModelDataToSend.ItemIndex', cbModelDataToSend.ItemIndex);

      UpdateFile;
    End;
  Finally
    MemIniFile.Free;
  End;
End;

Procedure TfmMain.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
  mrSave: TModalResult;
Begin
  If aSaveModel.Enabled Then
  Begin
    mrSave := TDialogServiceSync.MessageDialog(rsMODEL_SAVE_ON_EXIT, TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel], TMsgDlgBtn.mbYes, 0);

    If mrSave = mrYes Then
      aSaveModelExecute(aSaveModel)
    Else If mrSave <> mrNo Then
      CanClose := False;
  End;
End;

Procedure TfmMain.FormCreate(Sender: TObject);
Begin
  ActualSendFileList           := TSendFileList.Create(True);

  cbDataToSendMethod.ItemIndex := 2;
  DataToSendChange(Nil);
End;

Procedure TfmMain.FormDestroy(Sender: TObject);
Begin
  ActualSendFileList.Free;
End;

Procedure TfmMain.FormShow(Sender: TObject);
Var
  MemIniFile: TMemIniFile;
Begin
  MemIniFile := TMemIniFile.Create(IncludeTrailingPathDelimiter(System.SysUtils.GetCurrentDir) + 'configuration.ini');
  Try
    With MemIniFile Do
    Begin
      Width       := ReadInteger('fmMain', 'Width', Width);
      Height      := ReadInteger('fmMain', 'Height', Height);

      Left        := ReadInteger('fmMain', 'Left', Left);
      Top         := ReadInteger('fmMain', 'Top', Top);

      WindowState := TWindowState(ReadInteger('fmMain', 'WindowState', Integer(WindowState)));

      SendModelList.LoadFrom(MemIniFile);
      SetComboBoxDataToSendModel;

      eRESTServerAdress.Text       := ReadString('fmMain', 'eRESTServerAdress.Text', '');
      eRESTServerUsername.Text     := ReadString('fmMain', 'eRESTServerUsername.Text', '');
      eRESTServerPassword.Text     := ReadString('fmMain', 'eRESTServerPassword.Text', '');

      eDataToSendURI.Text          := ReadString('fmMain', 'eDataToSendURI.Text', '');
      cbDataToSendMethod.ItemIndex := ReadInteger('fmMain', 'cbDataToSendMethod.ItemIndex',
        cbDataToSendMethod.ItemIndex);
      mDataToSend.Lines.Text       := StringReplace(ReadString('fmMain', 'mDataToSend.Text', ''),
        sLineBreak, '#LNBREAK#', [RfReplaceAll, RfIgnoreCase]);

      cbModelDataToSend.ItemIndex := ReadInteger('fmMain', 'cbModelDataToSend.ItemIndex',
        cbModelDataToSend.ItemIndex);
      CbModelDataToSendChange(cbModelDataToSend); // ensure settings ok
    End;
  Finally
    MemIniFile.Free;
  End;
End;

Procedure TfmMain.DataToSendChange(Sender: TObject);
Begin
  If cbModelDataToSend.ItemIndex <> -1 Then
    aSaveModel.Enabled := True;
  Case TRESTRequestMethod(cbDataToSendMethod.ItemIndex) Of
    TRESTRequestMethod.RmPOST, TRESTRequestMethod.RmPUT, TRESTRequestMethod.RmPATCH:
      tcDataToSend.Visible := True;
    Else
      Begin
        mDataToSend.Lines.Clear;
        ClearFileInStringGrid;
        tcDataToSend.TabIndex := 0;
        tcDataToSend.Visible  := False;
      End;
  End;

  btDataToSendFilesDelete.Enabled := ActualSendFileList.Count > 0;
End;

Procedure TfmMain.RESTRequestAfterExecute(Sender: TCustomRESTRequest);
Begin
  fmMain.Caption := Format(rsSEND_RESULT, [Sender.GetFullRequestURL,
    Sender.ExecutionPerformance.TotalExecutionTime]);
  If Assigned(RESTResponse.JSONValue) Then
    mServerAnswer.Lines.Text := RESTResponse.JSONValue.Format()
  Else
    mServerAnswer.Lines.Add(RESTResponse.Content);
End;

Procedure TfmMain.RESTRequestHTTPProtocolError(Sender: TCustomRESTRequest);
Begin
  // show error
  mServerAnswer.Lines.Add(Sender.Response.StatusText);
  mServerAnswer.Lines.Add(Sender.Response.Content);
End;

End.
