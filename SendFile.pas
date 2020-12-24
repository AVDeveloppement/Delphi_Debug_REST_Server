Unit SendFile;

Interface

Uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Edit, FMX.StdCtrls, FMX.Controls.Presentation, REST.Types, FMX.DialogService.Sync,
  System.ImageList, FMX.ImgList, SendModel;

Type
  TfmSendFile = Class(TForm)
    gbFileToSendInfos: TGroupBox;
    btOk: TButton;
    btCancel: TButton;
    eName: TEdit;
    cbMimetype: TComboBox;
    eFileName: TEdit;
    btSelectFile: TButton;
    lMimetype: TLabel;
    OpenDialog: TOpenDialog;
    ImageList16: TImageList;
    Procedure FormCreate(Sender: TObject);
    Procedure BtSelectFileClick(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure BtOkClick(Sender: TObject);
    Procedure eFileNameDblClick(Sender: TObject);
  Public
    SendFile: TSendFile;
  End;

Var
  FmSendFile: TfmSendFile;

Implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}


Resourcestring
  RsERROR_NEED_NAME = 'Error you must specify a name';
  RsERROR_NEED_FILENAME = 'Error you must specify a filename';
  RsERROR_NEED_MIMETYPE = 'Error you must specify a mimetype';

  { TfmSendFile }

Procedure TfmSendFile.BtOkClick(Sender: TObject);
Begin
  If eName.Text = '' Then
  Begin
    TDialogServiceSync.MessageDialog(RsERROR_NEED_NAME, TMsgDlgType.MtError, [TMsgDlgBtn.MbOk], TMsgDlgBtn.MbOk, 0);
    Exit;
  End;
  If cbMimetype.ItemIndex = -1 Then
  Begin
    TDialogServiceSync.MessageDialog(RsERROR_NEED_MIMETYPE, TMsgDlgType.MtError, [TMsgDlgBtn.MbOk], TMsgDlgBtn.MbOk, 0);
    Exit;
  End;
  If eFileName.Text = '' Then
  Begin
    TDialogServiceSync.MessageDialog(RsERROR_NEED_FILENAME, TMsgDlgType.MtError, [TMsgDlgBtn.MbOk], TMsgDlgBtn.MbOk, 0);
    Exit;
  End;

  SendFile.Name        := eName.Text;
  SendFile.Filename    := eFileName.Text;
  SendFile.ContentType := TRESTContentType(cbMimetype.ItemIndex);

  ModalResult          := MrOk;
End;

Procedure TfmSendFile.BtSelectFileClick(Sender: TObject);
Begin
  With OpenDialog Do
    If Execute Then
      eFileName.Text := Filename;
End;

Procedure TfmSendFile.eFileNameDblClick(Sender: TObject);
Begin
  BtSelectFileClick(btSelectFile);
End;

Procedure TfmSendFile.FormCreate(Sender: TObject);
Begin
  SendFile  := TSendFile.Create;

  For Var I := Low(CRESTContentTypeAsString) To High(CRESTContentTypeAsString) Do
    cbMimetype.Items.Add(CRESTContentTypeAsString[I]);
End;

Procedure TfmSendFile.FormDestroy(Sender: TObject);
Begin
  SendFile.Free;
End;

Procedure TfmSendFile.FormShow(Sender: TObject);
Begin
  eName.Text           := SendFile.Name;
  eFileName.Text       := SendFile.Filename;
  cbMimetype.ItemIndex := Integer(SendFile.ContentType);
End;

End.
