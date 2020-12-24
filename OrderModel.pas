Unit OrderModel;

Interface

Uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.StrUtils, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  System.ImageList, FMX.ImgList, FMX.ListView, FMX.Controls.Presentation,
  FMX.StdCtrls, SendModel, Data.DB, Datasnap.DBClient;

Type
  TfmOrderModel = Class(TForm)
    btOk: TButton;
    btCancel: TButton;
    lvModel: TListView;
    ImageList16: TImageList;
    Procedure FormShow(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure lvModelButtonClick(Const Sender: TObject; Const AItem: TListItem;
      Const AObject: TListItemSimpleControl);
    Procedure btUpDownClick(Sender: TObject);
  Private
    Procedure SetListViewItemDetails(AIdx: integer);
  Public
    OrderedSendModelList: TSendModelList;
  End;

Var
  fmOrderModel: TfmOrderModel;

Implementation

{$R *.fmx}


Procedure TfmOrderModel.btUpDownClick(Sender: TObject);
Begin

  // lvModel.Items. :=1;
End;

Procedure TfmOrderModel.FormCreate(Sender: TObject);
Begin
  OrderedSendModelList := TSendModelList.Create(True);
End;

Procedure TfmOrderModel.FormDestroy(Sender: TObject);
Begin
  OrderedSendModelList.Free;
End;

Procedure TfmOrderModel.FormShow(Sender: TObject);
Begin
  lvModel.BeginUpdate;
  Try
    lvModel.Items.Clear;
    For Var I := 0 To OrderedSendModelList.Count - 1 Do
    Begin
      lvModel.Items.Add;
      SetListViewItemDetails(I);
    End;
  Finally
    lvModel.EndUpdate;
  End;
End;

Procedure TfmOrderModel.SetListViewItemDetails(AIdx: integer);
Begin
  If Not AIdx In [0 .. OrderedSendModelList.Count - 1] Then
    Exit;
  If Not AIdx In [0 .. lvModel.Items.Count - 1] Then
    Exit;

  lvModel.Items[AIdx].Objects.FindObjectT<TListItemText>('Title').Text  := OrderedSendModelList.Items[AIdx].Name;
  lvModel.Items[AIdx].Objects.FindObjectT<TListItemText>('URI').Text    := OrderedSendModelList.Items[AIdx].URI;
  lvModel.Items[AIdx].Objects.FindObjectT<TListItemText>('Detail').Text :=
    IfThen(OrderedSendModelList.Items[AIdx].Data <> '', 'JSON Data: Yes,', 'JSON Data: No,') +
    IfThen(OrderedSendModelList.Items[AIdx].FileList.Count > 0,
    ' Files: ' + IntToStr(OrderedSendModelList.Items[AIdx].FileList.Count), ' Files: 0');
End;

Procedure TfmOrderModel.lvModelButtonClick(Const Sender: TObject;
  Const AItem: TListItem; Const AObject: TListItemSimpleControl);
Var
  NewIdx: integer;
Begin
  NewIdx   := -1;
  If (AObject.Name = 'ButtonUp') And (AItem.Index > 0) Then
    NewIdx := AItem.Index - 1
  Else If (AObject.Name = 'ButtonDown') And (AItem.Index < lvModel.Items.Count - 1) Then
    NewIdx := AItem.Index + 1;

  If NewIdx <> -1 Then
  Begin
    OrderedSendModelList.Move(AItem.Index, NewIdx);

    lvModel.Items.Delete(AItem.Index);

    lvModel.Items.AddItem(NewIdx);
    SetListViewItemDetails(NewIdx);

    lvModel.Selected := lvModel.Items[NewIdx];
  End;
End;

End.
