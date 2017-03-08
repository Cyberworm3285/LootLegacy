unit URandomizer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    ListBox1: TListBox;
    Memo1: TMemo;
    Shape1: TShape;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    Stages,Rarities,EffectW,EffectA,Sources,Attribute,LootCount: TSTringlist;
    NItems,RItems,VRItems,LItems:TStringlist;
    initialised:boolean;
    source,lBound,rBound:integer;
    AttribCount:integer;
    Chars: Set of Char;
  public
    Function getRarity(var RName:String; Amp:integer):integer  ;
    Function getType(var TName:String; Rarity:integer):integer ;
    Function getValue(rarity,Stage:integer;Item:String;Armor:boolean):String            ;
    Function getAttrib(AMP:integer):String              ;
    procedure setMetaType(raw:String;safe:boolean; var a,b,c,d,e:boolean)     ;
    Function clearName(raw:String):String                      ;
    procedure setRdmBounds(Start,Mid,Ende:Char;raw:String; var l,r:integer)        ;
    procedure Show(A:string);
    Function Censor(raw:String):String;
    Function convertStr(raw:String;Ersatz:integer):integer;
    Function clearDate:String;
    procedure getList(var List:TStringlist);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
 Amplifier,Stage,MetaType:integer;
 LRarity,LType:integer;
 LRdm,RRdm:integer;
 LRarityN,LTypeN,Attribut,Count:String;
 Loot,LValue:String;
 a,b,c,d,e:boolean;
 copy:String;
 i,rdm,cLow,cHigh:integer;
begin
 IF not (self.initialised)
  THEN
   begin
    show('----------------');
    show('Nicht initialisiert!');
    show('abbruch!');
    exit;
   end;
 IF (edit1.Text='') or (edit2.Text ='')
  THEN
   begin
    show('----------------');
    show('Keine Parameter vorhanden!');
    show('abbruch!');
    exit;
   end;
 Amplifier:=convertStr(self.Edit2.Text,rbound+1);
 Stage:=convertStr(self.Edit1.Text,0)-1;
 IF (Amplifier>rBound) or (Amplifier<lBound)
  THEN
   begin
    show('----------------');
    show('Unbekannte Quelle! ('+IntToStr(lBound)+'..'+IntToStr(rbound)+')');
    show('abbruch!');
    exit;
   end;
 IF (Stage<0) or (Stage>4)
  THEN
   begin
    show('----------------');
    show('Lootsource im ungültigen Bereich! (1..5)');
    show('abbruch');
    exit;
   end;
 show('Beginne Generierung!');
 cLow:=0;
 cHigh:=0;
 IF (self.Edit6.Text='-')
  THEN
   begin
    self.setRdmBounds('(',',',')',self.LootCount[Amplifier-StrToInt(self.Sources[self.Sources.Count-1])],cLow,cHigh);
    rdm:=random(cHigh-cLow+1)+cLow;
    show('Es werden '+IntToStr(rdm)+' Items erstellt ('+IntToStr(cLow)+';'+IntToStr(cHigh)+')');
   end
  ELSE
   begin
    rdm:=self.convertStr(self.Edit6.Text,0);
    IF (rdm=0)
     THEN
      begin
       show('Eingabe der Anzahl');
       show('ist für den Arsch!');
       self.setRdmBounds('(',',',')',self.LootCount[Amplifier-StrToInt(self.Sources[self.Sources.Count-1])],cLow,cHigh);
       rdm:=random(cHigh-cLow+1)+cLow;
       show('Es werden '+IntToStr(rdm)+' Items erstellt ('+IntToStr(cLow)+';'+IntToStr(cHigh)+')');
      end
     ELSE
      begin
       show('Es werden '+IntToStr(rdm)+' Items erstellt');
      end;
   end;
 IF (rdm>1) THEN self.Memo1.Append('--'+IntToStr(rdm)+' Items--');
 For i:=1 to rdm Do
  begin
   show('<<->>');
   LRarityN:='';
   LTYpeN:='';
   Attribut:='';
   Count:='';
   self.AttribCount:=0;
   MetaType:=0;
   a:=false;
   b:=false;
   c:=false;
   d:=false;
   e:=false;
   LType:=0;
   LRdm:=LType; //quasi =0, aber so werde ich ein nerfige fehlermeldung los..
   RRdm:=0;
   LRarity:=self.getRarity(LRarityN,Amplifier);
   LType:=self.getType(LTypeN,LRarity);
   copy:=self.clearName(LTypeN);
   IF (LTypeN<>copy)
    THEN
     begin
      show('säubere Itemname..');
      show(LtypeN+' -> '+copy);
     end;
   copy:=self.Censor(LTypeN);
   IF (copy<>LTypeN)
    THEN
     begin
      show('filtere Sonderzeichen..');
      show(LTypeN+' -> '+copy);
     end;
   self.setMetaType(copy,false,a,b,c,d,e);
   IF (a) and (b)
    THEN
     begin
      show('Entweder Ruestung, oder Waffe!');
      show('Item ist ungültig :(');
      show('abbruch!');
      exit;
     end;
   IF (a) THEN MetaType:=1;
   IF (b) THEN MetaType:=2;
   IF (e) THEN LValue:=self.getValue(LRarity,Stage,LTypeN,(b));
   IF (c) THEN Attribut:=self.getAttrib(Amplifier);
   IF (d)
    THEN
     begin
      self.setRdmBounds('(',',',')',LTypeN,LRdm,RRdm);
      Count:='| x('+IntToStr(random(RRdm-LRdm+1)+LRdm)+')';
     end;
   IF (LRarity<>0)
    THEN
     begin
      LTypeN:=self.clearName(LTypeN);
      Loot:=TimeTosTr(Now)+'||';
      CASE MetaType of
       0: Loot:=Loot+LTypeN+'|'+LRarityN+ Attribut+Count+'|'+self.Stages[Stage];
       1: Loot:=Loot+LTypeN+'|'+LRarityN+'|'+LValue+'Dmg'+'|'+IntToStr(random(5)+1)+' Parade'+ Attribut+Count+'|'+self.Stages[Stage];
       2: Loot:=Loot+LTypeN+'|'+LRarityN+'|'+LValue+'DmgReduction'+ Attribut+Count+'|'+self.Stages[Stage];
      end;
     end
    ELSE
     begin
      Loot:=LRarityN;
     end;
   IF (LRarity=4)
    THEN
     begin
      show('Fisch aufm Tisch,');
      show('Legendary Shit! :)');
      self.Memo1.Append(Loot);
      IF (b)
       THEN
        begin
         self.Memo1.Append(EffectA[random(self.EffectA.Count)]);
        end
       ELSE IF (a)
        THEN
         begin
          self.Memo1.Append(EffectW[random(self.EffectW.Count)]);
         end;
     end
    ELSE
     begin
      self.Memo1.Append(Loot);
     end;
 end;
 show('----------------------');
 IF (rdm>1) THEN Memo1.Append('--Ende--');
end;

procedure TForm1.Button10Click(Sender: TObject);
var
 i:integer;
 temp:TStringlist;
begin
 temp:=TStringlist.Create;
 For i:=0 to self.Memo1.Lines.Count Do
  begin
   temp.Append(self.Memo1.Lines.Strings[i]);
  end;
 temp.SaveToFile('..\lootrandomizerZ\saves\Items'+self.clearDate+'.txt');
 temp.Clear;
 For i:=0 to self.ListBox1.Items.Count-1 DO
  begin
   temp.Append(self.ListBox1.Items.Strings[i]);
  end;
 temp.SaveToFile('..\lootrandomizerZ\saves\Log'+self.clearDate+'.txt');
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  self.ListBox1.Height:=self.ListBox1.Height+5;
  self.Memo1.Height:=self.Memo1.Height+5;
  self.Height:=self.Height+5;
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
  showmessage(IntToStr(random(6)+1));
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  showmessage(IntToStr(random(20)+1));
end;

procedure TForm1.Button14Click(Sender: TObject);
var
 tempList:TStringlist;
begin
  IF not (self.initialised)
   THEN
    begin
     show('Nicht initialisiert!');
     show('abbruch!');
     exit;
    end;
  IF (self.CheckBox3.Checked)
   THEN
    IF (random(2)=0)
     THEN templist:=self.EffectA
     ELSE templist:=self.EffectW
   ELSE
    IF (self.CheckBox1.Checked)
     THEN templist:=self.EffectA
     ELSE templist:=self.EffectW;
  show('-------------------------');
  show('Wähle zufälligen Effekt..');
  self.Memo1.Append(TimeToStr(Now)+'|'+tempList[random(templist.Count)]);
end;

procedure TForm1.Button15Click(Sender: TObject);
var
 a,b,c,d,e:boolean;
 i,j,k:integer;
 templist:TStringlist;
 Errors:TStringlist;
 clearString:String;
 max:integer;
begin
 IF not (self.initialised)
  THEN
   begin
    show('Nich initialisiert!');
    show('abbruch!');
    exit;
   end;
 Errors:=TStringlist.Create;
 show('----Validieren----');
 For i:=1 to 4 Do
  begin
   Case i of
    1:
     begin
      templist:=self.NItems;
      show('Normal:');
     end;
    2:
     begin
      templist:=self.RItems;
      show('Selten:');
     end;
    3:
     begin
      templist:=self.VRItems;
      show('Sehr Selten:');
     end;
    4:
     begin
      templist:=self.LItems;
      show('Legendary:');
     end;
   end;
   For j:=0 to templist.Count-1 Do
    begin
     Errors.Clear;
     a:=false;
     b:=false;
     c:=false;
     d:=false;
     e:=false;
     self.setMetaType(templist[j],true,a,b,c,d,e);
     IF(a) THEN if(b) THEN Errors.Append('I. ist Ruestung und Waffe!');
     IF (((a) or (b)) and not (e)) THEN Errors.Append('Deklariert, aber kein Wert!');
     clearString:=self.Censor(templist[j]);
     max:=length(clearString);
     For K:=1 to max Do
      begin
       Case clearString[k] of
        '(':If (K<>1) THEN If not (clearstring[k+1] in ['1'..'9']) THEN Errors.Append('Ungültige Anzahl-Konfig!(E0)('+clearstring[k+1]+')');
        ',':
         begin
          If (K<>1) THEN If not (clearstring[k-1] in ['0'..'9']) THEN Errors.Append('Ungültige Anzahl-Konfig!(E1)('+clearstring[k-1]+')');
          If (K<>max) THEN If not (clearstring[k+1] in ['1'..'9']) THEN Errors.Append('Ungültige Anzahl-Konfig!(E2)('+clearstring[k+1]+')');
         end;
        ')':IF (K<>1) THEN If not (clearstring[k-1] in ['1'..'9']) THEN Errors.Append('Ungültige Anzahl-Konfig!(E3)('+clearstring[k-1]+')');
        '{':If (K<>max) THEN If not (clearstring[k+1] in ['0'..'9']) THEN Errors.Append('Ungültige Wert-Konfig!(E0)('+clearstring[k+1]+')');
        '-':
         begin
          If (K<>1) THEN If not (clearstring[k-1] in ['0'..'9']) THEN Errors.Append('Ungültige Wert-Konfig!(E1)('+clearstring[k-1]+')');
          If (K<>max) THEN If not (clearstring[k+1] in ['1'..'9']) THEN Errors.Append('Ungültige Wert-Konfig!(E2)('+clearstring[k+1]+')');
         end;
        '}':If (K<>1) THEN If not (clearstring[k-1] in ['0'..'9']) THEN Errors.Append('Ungültige Wert-Konfig!(E3)('+clearstring[k-1]+')');
        '#':If (K<>max) THEN If not (clearstring[k+1] in ['1'..'9']) THEN Errors.Append('Ungültige Attribut-Konfig!('+clearstring[k+1]+')');
       end;
      end;
     IF(Errors.Count<>0)
      THEN
       begin
        show('XXXXXXXXXXXXXXXXXXXX');
        show('Bei Item '+self.clearName(templist[j])+' gibt es Fehler:');
        For K:=0 To Errors.Count-1 Do
         begin
          show(Errors[K]);
         end;
       end
      ELSE
       begin
        show('Item '+self.clearName(templist[j])+' ist sauber!');
       end;
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
Entry:integer;
begin
 show('Initialisiere Randomizer..');
 randomize;
 show('Erstelle Stringlists..');
 self.Stages:=TStringlist.Create        ;
 self.Rarities:=TStringlist.Create      ;
 self.EffectA:=TStringlist.Create       ;
 self.EffectW:=TStringlist.Create       ;
 self.Sources:=TStringlist.Create       ;
 self.Attribute:=TStringlist.Create     ;
 self.NItems:=Tstringlist.Create        ;
 self.RItems:=TStringlist.Create        ;
 self.VRItems:=TStringlist.Create       ;
 self.LItems:=TStringlist.Create        ;
 self.LootCount:=TStringlist.Create     ;
 show('Erstmaliges leeren..');
 self.Stages.Clear        ;
 self.Rarities.Clear      ;
 self.EffectA.Clear       ;
 self.EffectW.Clear       ;
 self.Sources.Clear       ;
 self.Attribute.Clear     ;
 self.NItems.Clear        ;
 self.RItems.Clear        ;
 self.VRItems.Clear       ;
 self.LItems.Clear        ;
 self.LootCount.Clear     ;
 show('Einlesen der cfg Dateien..');                      ;
 self.Stages.LoadFromFile('..\lootrandomizerZ\config\Stage.txt')                ;
 self.Rarities.LoadFromFile('..\lootrandomizerZ\config\Rarities.txt')           ;
 self.EffectA.LoadFromFile('..\lootrandomizerZ\config\LegendaryEffectA.txt')    ;
 self.EffectW.LoadFromFile('..\lootrandomizerZ\config\LegendaryEffectW.txt')    ;
 self.Sources.LoadFromFile('..\lootrandomizerZ\config\Sources.txt')             ;
 self.Attribute.LoadFromFile('..\lootrandomizerZ\config\Attribute.txt')         ;
 self.NItems.LoadFromFile('..\lootrandomizerZ\config\Items\NItems.txt')         ;
 self.RItems.LoadFromFile('..\lootrandomizerZ\config\Items\RItems.txt')               ;
 self.VRItems.LoadFromFile('..\lootrandomizerZ\config\Items\VRItems.txt')             ;
 self.LItems.LoadFromFile('..\lootrandomizerZ\config\Items\LItems.txt')               ;
 self.LootCount.LoadFromFile('..\lootrandomizerZ\config\LootCount.txt');
 Entry:=self.Stages.Count + self.Rarities.Count  ;
 show('Es wurden '+IntToStr(self.EffectA.Count)+' Rüstungseffekte gefunden!');
 show('Es wurden '+IntToStr(self.EffectW.Count)+' Waffeneffekte gefunden!');
 show('Es wurden '+IntToStr(self.Sources.Count)+' Lootquellen gefunden!');
 show('Es wurden ' + IntToStr(Entry)+' Einträge gefunden!');
 show('Es wurden ' + IntToStr(self.NItems.Count)+' normale Items gefunden!');
 show('Es wurden ' + IntToStr(self.RItems.Count)+' seltene Items gefunden!');
 show('Es wurden ' + IntToStr(self.VRItems.Count)+' sehr seltene Items gefunden!');
 show('Es wurden ' + IntToStr(self.LItems.Count)+' legendäre Items gefunden!');
 source:=self.Sources.Count;
 lBound:=StrToInt(self.Sources[self.Sources.Count-1]);
 rBound:=LBound+source-2;
 IF (self.LootCount.Count=self.Sources.Count-1)
  THEN
   begin
    self.initialised:=true;
    show('Erfolgreich initialsiert!');
   end
  ELSE
   begin
    self.initialised:=false;
    show('Ungültige Lootquellen Konfig. !');
    show('Initialisierung fehlgeschlagen!');
   end;
 self.Shape1.Brush.Color:=clGreen;
 self.Button2.Brush.Color:=clBlack;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  self.Button10.Click;
  self.ListBox1.Clear;
  self.Memo1.Clear;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
 i,j,c:integer;
 Temp,Fixed:Boolean;
 Key:Char;
begin
 IF not (self.initialised)
  THEN
   begin
    show('----------------');
    show('Nicht initialisiert!');
    exit;
   end;
 show('----------------');
 Fixed:=(Checkbox1.Checked) or (Checkbox2.Checked);
 IF (Fixed)
  THEN
   begin
    IF (Checkbox1.Checked) THEN Key:='~' ELSE Key:='$';
   end;
 Temp:=false;
 c:=1;
 show(self.Rarities[1]+':');
 For i:=1 To self.NItems.Count Do
  begin
   For j:=1 To Length(self.NItems[i-1]) DO
    begin
     IF (self.Censor(self.NItems[i-1])[j]=Key) THEN Temp:=True;
    end;
   IF (Temp) or not (Fixed)
    THEN
     begin
      show(IntToStr(c)+': '+self.NItems[i-1]);
      inc(c);
     end;
   Temp:=False;
  end;
 c:=1;
 show(self.Rarities[2]+':');
 For i:=1 To self.RItems.Count Do
  begin
   For j:=1 To Length(self.RItems[i-1]) DO
    begin
     IF (self.Censor(self.RItems[i-1])[j]=Key) THEN Temp:=True;
    end;
    IF (Temp) or not (Fixed)
     THEN
      begin
       show(IntToStr(c)+': '+self.RItems[i-1]);
       inc(c);
      end;
    Temp:=False;
  end;
 c:=1;
 show(self.Rarities[3]+':');
 For i:=1 To self.VRItems.Count Do
  begin
   For j:=1 To Length(self.VRItems[i-1]) Do
    begin
     IF (self.Censor(self.VRItems[i-1])[j]=Key) THEN Temp:=True;
    end;
   IF (Temp) or not (Fixed)
    THEN
     begin
      show(IntToStr(c)+': '+self.VRItems[i-1]);
      inc(c);
     end;
   Temp:=False;
  end;
 c:=1;
 show(self.Rarities[4]+':');
 For i:=1 To self.LItems.Count Do
  begin
   For j:=1 To Length(self.LItems[i-1]) DO
    begin
     IF (self.Censor(self.LItems[i-1])[j]=Key) THEN Temp:=True;
    end;
    IF (Temp) or not (Fixed)
     THEN
      begin
       show(IntToStr(c)+': '+self.LItems[i-1]);
       inc(c);
      end;
    Temp:=False;
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
 i:integer;
begin
 IF not (self.initialised)
  THEN
   begin
    show('----------------');
    show('Nicht initialisiert!');
    exit;
   end;
 show('----------------');
 For i:=1 To self.Rarities.Count Do
  begin
   show(IntToStr(i-1)+': '+self.Rarities[i-1]);
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
 Bound:integer;
begin
  IF not (self.initialised)
   THEN
    begin
     show('Nicht initialisiert!');
     show('abbruch');
     exit;
    end;
  Bound:=StrToInt(self.Sources[self.Sources.Count-1]);
  self.Edit1.Text:=IntToStr(random(5)+1);
  self.Edit2.Text:=IntToStr(random(self.Sources.Count-1)+Bound);
  self.Edit3.Text:='-';
  self.Edit4.Text:='-';
  self.Edit5.Text:='-';
  self.Edit6.Text:='-';
  self.Button1.Click;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
 i:integer;
begin
 IF not (self.initialised)
  THEN
   begin
    show('----------------');
    show('Nicht initialisiert!');
    exit;
   end;
 show('----------------');
 For i:=1 To self.Stages.Count Do
  begin
   show(IntToStr(i)+': '+self.Stages[i-1]);
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
i,c:integer;
  begin
   IF not (self.initialised)
    THEN
     begin
      show('----------------');
      show('Nicht initialisiert!');
      exit;
     end;
   show('----------------');
   c:=lBound;
   For i:=0 To self.Sources.Count-2 Do
    begin
     show(IntToStr(c)+': '+self.Sources[i]+' '+self.LootCount[i]);
     inc(c);
    end;
 end;

procedure TForm1.Button9Click(Sender: TObject);
begin
 IF (self.ListBox1.Height>=6)
  THEN self.ListBox1.Height:=self.ListBox1.Height-5;
 IF (self.Memo1.Height>=6)
  THEN self.Memo1.Height:=self.Memo1.Height-5;
 IF (self.Height>=100)
  THEN self.Height:=self.Height-5;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  IF (checkbox1.Checked)
   THEN
    begin
     checkbox2.Checked:=false;
     checkbox3.Checked:=false;
    end;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  IF (checkbox2.Checked)
   THEN
    begin
     checkbox1.Checked:=false;
     checkbox3.Checked:=false;
    end;
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
begin
  IF (checkbox3.Checked)
   THEN
    begin
     checkbox1.Checked:=false;
     checkbox2.Checked:=false;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 randomize;
 self.Memo1.Clear;
 self.initialised:=false;
 self.Chars:=['$','~','#',',','(',')','?','[',']',';','_','.','-','{','}','0'..'9'];
 self.DoubleBuffered:=true;
end;

Function TForm1.getRarity(var RName:String; Amp:integer):integer;
var
 E,rdm,minRdm,maxRdm:integer;
 isFixed:Boolean;
 begin
  isFixed:=(not (edit3.Text='-') or not (edit5.Text='-'));
  show('Erzeuge Seltenheit..');
  maxRdm:=250;
  minRdm:=0;
  IF (isFixed)
   THEN
    begin
     IF (self.Edit3.Text='-')
      THEN maxRdm:=0
      ELSE maxRdm:=convertStr(self.Edit3.Text,0);
     IF (self.Edit5.Text='-')
      THEN minRdm:=4
      ELSE minRdm:=convertStr(self.Edit5.Text,4);
     IF ((maxRdm>4) or (MaxRdm<0))
      THEN
       begin
        show('Ungültige Untergrenze als Seltenheit! (0-4)');
        show('abbruch!');
        RName:=self.Rarities[0];
        result:=0;
        exit;
       end;
     IF ((minRdm<0) or (minRdm>4))
      THEN
       begin
        show('Ungültige Obergrenze als Seltenheit! (0-4)');
        show('abbruch!');
        RName:=self.Rarities[0];
        result:=0;
        exit;
       end;
     Case maxRdm of
      0: maxRdm:=250;
      1: maxRdm:=150;
      2: maxRdm:=50;
      3: maxRdm:=12;
      4: maxRdm:=4;
     end;
     Case minRdm of
      0: minRdm:=151;
      1: minRdm:=51;
      2: minRdm:=13;
      3: minRdm:=5;
      4: minRdm:=0;
     end;
     AMP:=0;
     show('Modifiziere Rdm Werte ('+IntToStr(minRdm)+'-'+intToStr(maxRdm)+')');
    end;
  rdm:=random(maxRdm-minRdm)+1-Amp+minrdm;
  show('Randomizer ergibt: '+IntToStr(rdm));
  IF (rdm<-3) THEN rdm:=-3;
  IF (rdm>253) THEN rdm:=253;
  CASE rdm of
   151..253:
    begin
     E:=0 ;
     show('150<rdm>253 ->'+self.Rarities[E]);
    end;
   51..150:
    begin
     E:=1 ;
     show('50<rdm>151 ->'+self.Rarities[E]);
    end;
   13..50:
    begin
     E:=2 ;
     show('12<rdm>51 ->'+self.Rarities[E]);
    end;
   5..12:
    begin
     E:=3 ;
     show('4<rdm>13 ->'+self.Rarities[E]);
    end;
   -3..4:
    begin
     E:=4 ;
     show('(-3)<rdm>5 ->'+self.Rarities[E]);
    end;
  end;
  RName:=self.Rarities[E];
  show('Item erhaelt Seltenheit: '+self.Rarities[E]);
  result:=E;
 end;

Function TForm1.getType(var TName:String; Rarity:integer):integer;
var
 rdm:integer;
 tempList:TStringlist;
 Filter:TStringlist;
 Key:Char;
 i,j:Integer;
begin
 show('Erzeuge Itemtyp..');
 IF (Rarity<>0)
  THEN
   begin
    CASE Rarity of
     1: tempList:=self.NItems  ;
     2: tempList:=self.RItems  ;
     3: tempList:=self.VRItems ;
     4: tempList:=self.LItems  ;
    end;
    self.Show('Filtere Itemliste...');
    self.getList(templist);
    IF not (checkbox3.Checked)
     THEN
      begin
       IF (checkbox1.Checked)
        THEN
         begin
          Key:='~';
         end
        ELSE
         begin
          Key:='$';
         end;
       Filter:=TStringlist.Create;
       For i:=0 to templist.Count-1 Do
        begin
         For j:=1 to length(templist[i]) Do
          begin
           IF (self.Censor(templist[i])[j]=Key)
            THEN
             begin
              Filter.Append(templist[i]);
             end;
          end;
        end;
       self.Show('Liste ist '+IntToStr(Filter.Count)+' Items lang');
       IF (Filter.Count=0)
        THEN self.Show('gibt keine passenden Items! :(')
        ELSE templist:=Filter;
      end;
    rdm:=random(tempList.Count);
    show('Randomizer ergibt: '+IntToStr(rdm)+' -> '+tempList[rdm]);
    IF (self.Edit4.Text<>'-')
     THEN
      begin
       show('Ignoriere Ergebnis..');
       IF (StrToInt(self.Edit4.Text)<1) or
          (StrToInt(self.Edit4.Text)>(templist.Count))
        THEN
         begin
          show('Ungültiger Itemtyp!');
          show('abbruch!');
          show('benutze Umweg..');
          rdm:=random(templist.Count);
          TName:=templist[rdm];
          show('Ergebnis: '+IntToStr(rdm)+' -> '+TName);
          exit;
         end
        ELSE
         begin
          rdm:=StrToInt(self.Edit4.Text)-1;
          show('Erzwungener Itemtyp: '+tempList[rdm]);
         end;
      end;
    TName:=tempList[rdm];
   end
  ELSE
   begin
    show(self.Rarities[0]+' bleibt '+self.Rarities[0]);
    rdm:=0;
    TName:=self.Rarities[0];
   end;
 result:=rdm;
end;

Function TForm1.getValue(rarity,Stage:integer;Item:String;Armor:boolean):String;
var
 Ug,Og,rdm:Integer;
 E:String;
 begin
  show('Erzeuge genaue Werte..');
  Ug:=0;
  Og:=0;
  IF (rarity<>0)
   THEN
    begin
     self.setRdmBounds('{','-','}',Item,Ug,Og);
     rdm:=random(Og-Ug+1)+Ug;
     E:=IntToStr(rdm+Stage*rdm);
     show('-> '+E);
    end
   ELSE
    begin
     E:='';
     show('Keine Spezi-Werte für '+self.Rarities[0]+'!');
    end;
  result:=E;
 end;

Function TForm1.getAttrib(AMP:integer):String;
var
i,j,rdm:integer;
temp,Attribut:String;
 begin
  show('Erzeuge Attribute..');
  temp:='';
  i:=self.AttribCount;
  IF (i=1)
   THEN show('Es wird 1 Attribut erzeugt!')
   ELSE show('Es werden '+IntToStr(i)+' Attribute erzeugt!');
  show('<<<<>>>>');
  For j:=1 to i Do
   begin
    rdm:=random(amp+1);
    IF (rdm>=1)
     THEN
      begin
       show('Chance auf Bonusattribut! ('+IntToStr(rdm)+')');
       rdm:=self.Attribute.Count-1;
      end
     ELSE
      begin
       show('normales Attribut ('+IntToStr(rdm)+')');
       rdm:=self.Attribute.Count-1-StrToInt(self.Attribute[self.Attribute.Count-1]);
      end;
    rdm:=random(rdm);
    Attribut:=self.Attribute[rdm];
    IF (rdm>=self.Attribute.Count-1-StrToInt(self.Attribute[self.Attribute.Count-1]))
     THEN show('Bonusattribut! ('+Attribut+')')
     ELSE show('Normal ('+Attribut+')');
    temp:=temp+'|'+Attribut+ '('+IntToStr(random(2)+1)+')';
    show('<<<<>>>>');
   end;
  result:=temp;
 end;

Procedure TForm1.setMetaType(raw:String;safe:boolean; var a,b,c,d,e:Boolean);
 var
  i:integer;
 begin
  raw:=self.Censor(raw);
  For i:=1 to length(raw) Do
   begin
   Case raw[i] of
    '$':         IF (raw[i-1]<>'?') THEN a:=true;
    '~':         IF (raw[i-1]<>'?') THEN b:=true;
    '#':         IF (raw[i-1]<>'?')
     THEN
      begin
       IF (i<>length(raw)) and not (safe)
        THEN IF (raw[i+1] in ['0'..'9'])
         THEN
          begin
           c:=true;
           self.AttribCount:=StrToint(raw[i+1]);
          end;
      end;
    '(',')': IF (raw[i-1]<>'?') THEN d:=true;
    '{','}': IF (raw[i-1]<>'?') THEN e:=true;
    end;
   end;
 end;

Procedure TForm1.setRdmBounds(Start,Mid,Ende:Char;raw:String; var l,r:integer);
 var
  i,lK,rK,K:integer;
 begin
  for i:=1 to length(raw) Do
   begin
    IF (raw[i]=Start) THEN lK:=i
    ELSE IF (raw[i]=Mid) THEN k:=i
    ELSE IF (raw[i]=Ende) THEN rK:=i;
   end;
  l:=self.convertStr(raw[lk+1..K-1],0);
  r:=self.convertStr(raw[K+1..rK-1],0);
 end;

Function TForm1.clearName(raw:String):String;
 var
  i,c:integer;
  e:String;
 begin
  c:=1;
  setLength(e,length(raw));
  IF (length(raw)<1) THEN exit;
  IF (raw[1]) in self.Chars
   THEN
    begin
     setLength(e,Length(e)-1);
    end
   ELSE
    begin
     e[c]:=raw[1];
     inc(c);
    end;
  For i:=2 to length(raw) Do
   begin
    IF (raw[i] in self.Chars)
     THEN
      begin
       IF (raw[i-1]='?')
        THEN
         begin
          e[c]:=raw[i];
          inc(c);
          raw[i-1]:='X';
          raw[i]:='X';
         end
        ELSE
         begin
          setLength(e,Length(e)-1);
         end;
      end
     ELSE
      begin
       e[c]:=raw[i];
       inc(c);
      end;
   end;
  result:=e;
 end;

Procedure TForm1.Show(A:String);
begin
 self.ListBox1.Items.Append(A);
end;

Function TForm1.Censor(raw:String):String;
var
 i:integer;
 e:string;
begin
 setLength(e,length(raw));
 IF (length(raw)<1) THEN exit;
 e[1]:=raw[1];
 IF (raw[1]='?')
  THEN
   begin
    e[2]:='X';
    raw[2]:='X';
   end;
 For i:=2 to length(raw) Do
  begin
   IF (raw[i] in self.Chars)
    THEN IF (raw[i-1]='?')
     THEN
      begin
       e[i]:='X';
       raw[i]:='X';
      end
     ELSE
      begin
       e[i]:=raw[i];
      end
    ELSE
     begin
      e[i]:=raw[i];
     end;
  end;
 result:=e;
end;

Function TForm1.convertStr(raw:String;Ersatz:integer):integer;
var
 E:String;
 c,i:integer;
begin
 setLength(E,length(raw));
 c:=1;
 For i:=1 to length(raw) Do
  begin
   IF (raw[i] in ['0'..'9','-'])
    THEN
     begin
      E[c]:=raw[i];
      inc(c);
     end
    ELSE
     begin
      setLength(E,length(E)-1);
     end;
  end;
 IF(length(E)<1)
  THEN
   begin
    //self.ListBox1.Items.Append('ungültige Eingabe!');
    E:=IntToStr(Ersatz);
    result:=Ersatz;
   end
  ELSE
   begin
    result:=StrToInt(E);
   end;
 IF (E<>raw)
  THEN show('Eingabe wurde gesäubert! ('+raw+'->'+E+')');
end;

Function Tform1.clearDate:String;
var
temp,e:String;
i,c:Integer;
begin
 c:=1;
 e:='';
 temp:=DateTimeToStr(Now);
 setLength(e,length(temp));
 For i:=1 To length(temp) Do
  begin
   IF not (temp[i] in ['.',':',' '])
    THEN
     begin
      E[c]:=temp[i];
      inc(c);
     end
    ELSE
     begin
      setLength(e,length(e)-1);
     end;
  end;
 result:=E;
end;

Procedure TForm1.getList(var List:TStringlist);
var
 i,j:integer;
 isFixed:Boolean;
 temp:String;
 res:TStringlist;
 Index:Integer;
 E1,E2,E3:integer;
begin
 E1:=0;
 E2:=0;
 E3:=0;
 isFixed:=false;
 res:=TStringlist.Create;
 For i:=0 to List.Count-1 Do
  begin
   temp:=self.Censor(List[i]);
   For j:=1 To length(temp) Do
    begin
     IF (List[i][j]='\')
      THEN
       begin
        IF (j=length(Temp))
         THEN
          begin
           show('ungültige konfiguration!');
           exit;
          end
         Else
          begin
           isFixed:=true;
           Index:=StrToInt(Temp[j+1]);
           IF (self.convertStr(self.Edit1.Text,0)=Index)
            THEN
             begin
              res.Append(List[i]);
              inc(E3);
             end
            ELSE
             begin
              inc(E1);
             end;
          end;
       end;
    end;
   IF not (isFixed)
    THEN
     begin
      res.Append(List[i]);
      inc(E2);
     end;
   isFixed:=false;
   temp:='';
  end;
 List:=res;
 show('Es wurde/n '+IntToStr(E1)+' Item/s aussortiert!');
 show('Es wurde/n '+IntToStr(E3)+' Treffer gefunden!');
 show('Es sind '+IntToStr(E2)+' Items ungetagged!');
end;

end.

