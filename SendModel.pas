Unit SendModel;

Interface

Uses
  System.SysUtils, System.IniFiles, System.Generics.Collections, FMX.ListBox,
  FMX.Grid, REST.Types;

Type
  TSendFile = Class
    ContentType: TRESTContentType;
    Name, Filename: String;
    Constructor Create; Overload;
    Constructor Create(ASendFile: TSendFile); Overload;
    Constructor Create(AName, AFilename: String; AContentType: TRESTContentType); Overload;
    Procedure Assign(ASendFile: TSendFile);
  End;

  TSendFileList = Class(TObjectList<TSendFile>)
    Procedure SetToStringGrid(AStringGrid: TStringGrid);
    Procedure Assign(ASendFileList: TSendFileList);
  End;

  TSendModel = Class
    Method: TRESTRequestMethod;
    URI, Data, Name: String;
    FileList: TSendFileList;
    Constructor Create(AName: String; AMethod: TRESTRequestMethod = TRESTRequestMethod.RmGET;
      AURI: String = ''; AData: String = ''); Overload;
    Constructor Create(ASendModel: TSendModel); Overload;
    Destructor Destroy; Override;
  End;

  TSendModelList = Class(TObjectList<TSendModel>)
    Procedure LoadFrom(AMemIniFile: TMemIniFile);
    Procedure SaveTo(AMemIniFile: TMemIniFile);
    Procedure Assign(ASendModelList: TSendModelList);
  End;

Const
  CRESTContentTypeAsString: Array [TRESTContentType] Of String = (
    'None', 'APPLICATION_ATOM_XML', 'APPLICATION_ECMASCRIPT', 'APPLICATION_EDI_X12', 'APPLICATION_EDIFACT',
    'APPLICATION_JSON', 'APPLICATION_JAVASCRIPT', 'APPLICATION_OCTET_STREAM', 'tAPPLICATION_OGG', 'APPLICATION_PDF',
    'APPLICATION_POSTSCRIPT', 'APPLICATION_RDF_XML', 'APPLICATION_RSS_XML',
    'APPLICATION_SOAP_XML', 'APPLICATION_FONT_WOFF', 'APPLICATION_XHTML_XML', 'APPLICATION_XML', 'APPLICATION_XML_DTD',
    'APPLICATION_XOP_XML', 'APPLICATION_ZIP', 'APPLICATION_GZIP', 'TEXT_CMD', 'TEXT_CSS', 'TEXT_CSV', 'TEXT_HTML',
    'TEXT_JAVASCRIPT', 'TEXT_PLAIN', 'TEXT_VCARD', 'TEXT_XML', 'AUDIO_BASIC', 'AUDIO_L24', 'AUDIO_MP4', 'AUDIO_MPEG',
    'AUDIO_OGG', 'AUDIO_VORBIS', 'AUDIO_VND_RN_REALAUDIO', 'AUDIO_VND_WAVE', 'AUDIO_WEBM', 'IMAGE_GIF', 'IMAGE_JPEG',
    'IMAGE_PJPEG', 'IMAGE_PNG', 'IMAGE_SVG_XML', 'IMAGE_TIFF', 'MESSAGE_HTTP', 'MESSAGE_IMDN_XML', 'MESSAGE_PARTIAL',
    'MESSAGE_RFC822', 'MODEL_EXAMPLE', 'MODEL_IGES', 'MODEL_MESH', 'MODEL_VRML', 'MODEL_X3D_BINARY', 'MODEL_X3D_VRML',
    'MODEL_X3D_XML', 'MULTIPART_MIXED', 'MULTIPART_ALTERNATIVE', 'MULTIPART_RELATED', 'MULTIPART_FORM_DATA',
    'MULTIPART_SIGNED', 'MULTIPART_ENCRYPTED', 'VIDEO_MPEG', 'VIDEO_MP4', 'VIDEO_OGG', 'VIDEO_QUICKTIME', 'VIDEO_WEBM',
    'VIDEO_X_MATROSKA', 'VIDEO_X_MS_WMV', 'VIDEO_X_FLV',
    'APPLICATION_VND_OASIS_OPENDOCUMENT_TEXT', 'APPLICATION_VND_OASIS_OPENDOCUMENT_SPREADSHEET',
    'APPLICATION_VND_OASIS_OPENDOCUMENT_PRESENTATION', 'APPLICATION_VND_OASIS_OPENDOCUMENT_GRAPHICS',
    'APPLICATION_VND_MS_EXCEL', 'APPLICATION_VND_OPENXMLFORMATS_OFFICEDOCUMENT_SPREADSHEETML_SHEET',
    'APPLICATION_VND_MS_POWERPOINT', 'APPLICATION_VND_OPENXMLFORMATS_OFFICEDOCUMENT_PRESENTATIONML_PRESENTATION',
    'APPLICATION_VND_OPENXMLFORMATS_OFFICEDOCUMENT_WORDPROCESSINGML_DOCUMENT',
    'APPLICATION_VND_MOZILLA_XUL_XML', 'APPLICATION_VND_GOOGLE_EARTH_KML_XML', 'APPLICATION_VND_GOOGLE_EARTH_KMZ',
    'APPLICATION_VND_DART', 'APPLICATION_VND_ANDROID_PACKAGE_ARCHIVE', 'APPLICATION_X_DEB', 'APPLICATION_X_DVI',
    'APPLICATION_X_FONT_TTF', 'APPLICATION_X_JAVASCRIPT', 'APPLICATION_X_LATEX', 'APPLICATION_X_MPEGURL',
    'APPLICATION_X_RAR_COMPRESSED', 'APPLICATION_X_SHOCKWAVE_FLASH', 'APPLICATION_X_STUFFIT', 'APPLICATION_X_TAR',
    'APPLICATION_X_WWW_FORM_URLENCODED', 'APPLICATION_X_XPINSTALL', 'AUDIO_X_AAC', 'AUDIO_X_CAF', 'IMAGE_X_XCF',
    'TEXT_X_GWT_RPC', 'TEXT_X_JQUERY_TMPL', 'TEXT_X_MARKDOWN', 'APPLICATION_X_PKCS12',
    'APPLICATION_X_PKCS7_CERTIFICATES', 'APPLICATION_X_PKCS7_CERTREQRESP', 'APPLICATION_X_PKCS7_MIME',
    'APPLICATION_X_PKCS7_SIGNATURE', 'APPLICATION_VND_EMBARCADERO_FIREDAC_JSON');

Var
  SendModelList: TSendModelList;

Implementation

{ TSendFile }

Procedure TSendFile.Assign(ASendFile: TSendFile);
Begin
  Name        := ASendFile.Name;
  Filename    := ASendFile.Filename;
  ContentType := ASendFile.ContentType;
End;

Constructor TSendFile.Create;
Begin
  Name        := '';
  Filename    := '';
  ContentType := TRESTContentType.CtNone;
End;

Constructor TSendFile.Create(ASendFile: TSendFile);
Begin
  Assign(ASendFile);
End;

Constructor TSendFile.Create(AName, AFilename: String;
  AContentType: TRESTContentType);
Begin
  Name        := AName;
  Filename    := AFilename;
  ContentType := AContentType;
End;

{ TSendFileList }

Procedure TSendFileList.Assign(ASendFileList: TSendFileList);
Begin
  Clear;
  For Var I := 0 To ASendFileList.Count - 1 Do
    Add(TSendFile.Create(ASendFileList[I]));
End;

Procedure TSendFileList.SetToStringGrid(AStringGrid: TStringGrid);
Begin
  AStringGrid.RowCount := Count;
  AStringGrid.BeginUpdate;
  Try
    For Var I                 := 0 To Count - 1 Do
    Begin
      AStringGrid.Cells[0, I] := Items[I].Name;
      AStringGrid.Cells[1, I] := Items[I].Filename;
      AStringGrid.Cells[2, I] := CRESTContentTypeAsString[Items[I].ContentType];
    End;
  Finally
    AStringGrid.EndUpdate;
  End;
End;

{ TSendModel }

Constructor TSendModel.Create(AName: String; AMethod: TRESTRequestMethod = TRESTRequestMethod.RmGET;
  AURI: String = ''; AData: String = '');
Begin
  Name     := AName;
  Method   := AMethod;
  URI      := AURI;
  Data     := AData;

  FileList := TSendFileList.Create(True);
End;

Constructor TSendModel.Create(ASendModel: TSendModel);
Begin
  Create(ASendModel.Name, ASendModel.Method, ASendModel.URI, ASendModel.Data);

  FileList.Assign(ASendModel.FileList);
End;

Destructor TSendModel.Destroy;
Begin
  FileList.Free;

  Inherited;
End;

{ TSendModelList }

Procedure TSendModelList.Assign(ASendModelList: TSendModelList);
Begin
  Clear;
  For Var I := 0 To ASendModelList.Count - 1 Do
    Add(TSendModel.Create(ASendModelList[I]));
End;

Procedure TSendModelList.LoadFrom(AMemIniFile: TMemIniFile);
Var
  iCountModel, iCountFile: Integer;
  sI, sN: String;
Begin
  With AMemIniFile Do
  Begin
    iCountModel := ReadInteger('SendModelList', 'Count', 0);
    If iCountModel = 0 Then
      Exit;

    For Var I := 0 To iCountModel - 1 Do
    Begin
      sI      := IntToStr(I);
      Add(TSendModel.Create(
        ReadString('SendModelList', 'Name' + sI, ''),
        TRESTRequestMethod(ReadInteger('SendModelList', 'Method' + sI, Integer(TRESTRequestMethod.RmGET))),
        ReadString('SendModelList', 'URI' + sI, ''),
        StringReplace(ReadString('SendModelList', 'Data' + sI, ''),
        '#LNBREAK#', sLineBreak, [RfReplaceAll, RfIgnoreCase])
        ));

      iCountFile := ReadInteger('SendModel' + sI + 'Filelist', 'Count', 0);
      If iCountFile = 0 Then
        Continue;
      For Var N := 0 To iCountFile - 1 Do
      Begin
        sN      := IntToStr(N);
        Items[I].FileList.Add(TSendFile.Create(
          ReadString('SendModel' + sI + 'Filelist', 'Name' + sN, ''),
          ReadString('SendModel' + sI + 'Filelist', 'Filename' + sN, ''),
          TRESTContentType(ReadInteger('SendModel' + sI + 'Filelist', 'ContentType' + sN,
          Integer(TRESTContentType.CtNone)))
          ));
      End;
    End;
  End;

End;

Procedure TSendModelList.SaveTo(AMemIniFile: TMemIniFile);
Var
  sI, sN: String;
Begin
  With AMemIniFile Do
  Begin
    WriteInteger('SendModelList', 'Count', Count);
    If Count = 0 Then
      Exit;
    For Var I := 0 To Count - 1 Do
    Begin
      sI      := IntToStr(I);
      WriteInteger('SendModelList', 'Method' + sI, Integer(Items[I].Method));
      WriteString('SendModelList', 'URI' + sI, Items[I].URI);
      WriteString('SendModelList', 'Data' + sI, StringReplace(Items[I].Data, sLineBreak, '#LNBREAK#',
        [RfReplaceAll, RfIgnoreCase]));
      WriteString('SendModelList', 'Name' + sI, Items[I].Name);

      WriteInteger('SendModel' + sI + 'Filelist', 'Count', Items[I].FileList.Count);
      For Var N := 0 To Items[I].FileList.Count - 1 Do
      Begin
        sN      := IntToStr(N);
        WriteString('SendModel' + sI + 'Filelist', 'Name' + sN, Items[I].FileList[N].Name);
        WriteString('SendModel' + sI + 'Filelist', 'Filename' + sN, Items[I].FileList[N].Filename);
        WriteInteger('SendModel' + sI + 'Filelist', 'ContentType' + sN, Integer(Items[I].FileList[N].ContentType));
      End;
    End;
  End;
End;

Initialization

SendModelList := TSendModelList.Create(True);

Finalization

SendModelList.Free;

End.
