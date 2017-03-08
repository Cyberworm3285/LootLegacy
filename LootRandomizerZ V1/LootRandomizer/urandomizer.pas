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
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    ListBox1: TListBox;
    Memo1: TMemo;
    Shape1: TShape;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    Types,Stages,Normal,Rare,VRare,Legendary,Rarities,EffectW,EffectA,Sources: TSTringlist;
    initialised:boolean;
    source,lBound,rBound:integer;
  public
    Function getRarity(var RName:String; Amp:integer):integer  ;
    Function getType(var TName:String; Rarity:integer):integer ;
    Function getValue(rarity,Stage:integer):integer            ;
    Function getAttrib(rarity,AMP:integer):String                  ;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
 Amplifier,Stage:integer;
 LRarity,LType,LValue:integer;
 LRarityN,LTypeN,Attribut:String;
 Loot:String;
begin
 IF not (self.initialised)
  THEN
   begin
    self.ListBox1.Items.Append('----------------');
    self.ListBox1.Items.Append('Nicht Initialisiert!');
    self.ListBox1.Items.Append('abbruch!');
    exit;
   end;
 IF (edit1.Text='') or (edit2.Text ='')
  THEN
   begin
    self.ListBox1.Items.Append('----------------');
    self.ListBox1.Items.Append('Keine Parameter vorhanden!');
    self.ListBox1.Items.Append('abbruch!');
    exit;
   end;
 Amplifier:=StrToInt(self.Edit2.Text);
 Stage:=StrToInt(self.Edit1.Text)-1;
 IF (Amplifier>rBound) or (Amplifier<lBound)
  THEN
   begin
    self.ListBox1.Items.Append('----------------');
    self.ListBox1.Items.Append('Unbekannte Quelle! ('+IntToStr(lBound)+'..'+IntToStr(rbound)+')');
    self.ListBox1.Items.Append('abbruch!');
    exit;
   end;
 IF (Stage<0) or (Stage>4)
  THEN
   begin
    self.ListBox1.Items.Append('----------------');
    self.ListBox1.Items.Append('Lootsource im ungültigen Bereich! (1..5)');
    self.ListBox1.Items.Append('abbruch');
    exit;
   end;
 self.ListBox1.Items.Append('----------------------');
 self.ListBox1.Items.Append('Beginne Generierung!');
 LRarity:=self.getRarity(LRarityN,Amplifier);
 LType:=self.getType(LTypeN,LRarity);
 LValue:=self.getValue(LRarity,Stage);
 Attribut:=self.getAttrib(LRarity,Amplifier);
 IF (LRarity<>0)
  THEN
   begin
    IF (LType<>5)
     THEN Loot:=LTypeN+'|'+LRarityN+'|'+IntToStr(LValue)+'Dmg'+'|'+IntToStr(random(5)+1)+' Parade'+ Attribut+'|'+self.Stages[Stage]
     ELSE Loot:=LTypeN+'|'+LRarityN+'|'+IntToStr(LValue div 2)+'DmgReduction'+ Attribut+'|'+self.Stages[Stage];
   end
  ELSE
   begin
    Loot:=LRarityN;
   end;
 IF (LRarity=4)
  THEN
   begin
    self.ListBox1.Items.Append('Fisch aufm Tisch,');
    self.ListBox1.Items.Append('Legendary Shit!');
    self.Memo1.Append(Loot);
    IF (LType=5)
     THEN
      begin
       self.Memo1.Append(EffectA[random(self.EffectA.Count)]);
      end
     ELSE
      begin
       self.Memo1.Append(EffectW[random(self.EffectW.Count)]);
      end;
   end
  ELSE
   begin
    self.Memo1.Append(Loot);
   end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
Entry:integer;
begin
 self.ListBox1.Items.Append('Initialisiere Randomizer..');
 randomize;
 self.ListBox1.Items.Append('Erstelle Stringlists..');
 self.Types:=TStringlist.Create     ;
 self.Stages:=TStringlist.Create    ;
 self.Normal:=TStringlist.Create    ;
 self.Rare:=TStringlist.Create      ;
 self.VRare:=TStringlist.Create     ;
 self.Legendary:=TStringlist.Create ;
 self.Rarities:=TStringlist.Create  ;
 self.EffectA:=TStringlist.Create   ;
 self.EffectW:=TStringlist.Create   ;
 self.Sources:=TStringlist.Create   ;
 self.ListBox1.Items.Append('Erstmaliges leeren..');
 self.Types.Clear     ;
 self.Stages.Clear    ;
 self.Normal.Clear    ;
 self.Rare.Clear      ;
 self.VRare.Clear     ;
 self.Legendary.Clear ;
 self.Rarities.Clear  ;
 self.EffectA.Clear   ;
 self.EffectW.Clear   ;
 self.Sources.Clear   ;
 self.ListBox1.Items.Append('Einlesen der cfg Dateien..');
 self.Types.LoadFromFile('..\LootRandomizer\config\Types.txt')              ;
 self.Stages.LoadFromFile('..\lootrandomizer\config\Stage.txt')             ;
 self.Normal.LoadFromFile('..\lootrandomizer\config\Normal.txt')            ;
 self.Rare.LoadFromFile('..\lootrandomizer\config\Rare.txt')                ;
 self.VRare.LoadFromFile('..\lootrandomizer\config\veryrare.txt')           ;
 self.Legendary.LoadFromFile('..\lootrandomizer\config\Legendary.txt')      ;
 self.Rarities.LoadFromFile('..\lootrandomizer\config\Rarities.txt')        ;
 self.EffectA.LoadFromFile('..\lootrandomizer\config\LegendaryEffectA.txt') ;
 self.EffectW.LoadFromFile('..\lootrandomizer\config\LegendaryEffectW.txt') ;
 self.Sources.LoadFromFile('..\lootrandomizer\config\Sources.txt')          ;
 Entry:=self.Types.Count     +
        self.Stages.Count    +
        self.Normal.Count    +
        self.Rare.Count      +
        self.VRare.Count     +
        self.Legendary.Count +
        self.Rarities.Count  ;
 self.ListBox1.Items.Append('Es wurden '+IntToStr(self.EffectA.Count)+' Rüstungseffekte gefunden!');
 self.ListBox1.Items.Append('Es wurden '+IntToStr(self.EffectW.Count)+' Waffeneffekte gefunden!');
 self.ListBox1.Items.Append('Es wurden '+IntToStr(self.Sources.Count)+' Lootquellen gefunden!');
 self.ListBox1.Items.Append('Es wurden ' + IntToStr(Entry)+' Einträge gefunden!');
 source:=self.Sources.Count;
 lBound:=StrToInt(self.Sources[self.Sources.Count-1]);
 rBound:=LBound+source-2;
 self.initialised:=true;
 self.ListBox1.Items.Append('Erfolgreich initialsiert!');
 self.Shape1.Brush.Color:=clGreen;
 self.Button2.Brush.Color:=clBlack;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  self.ListBox1.Clear;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
 i:integer;
begin
 IF not (self.initialised)
  THEN
   begin
    self.ListBox1.Items.Append('----------------');
    self.ListBox1.Items.Append('Nicht initialisiert!');
    exit;
   end;
 self.ListBox1.Items.Append('----------------');
 For i:=1 To self.Types.Count Do
  begin
   self.ListBox1.Items.Append(IntToStr(i)+': '+self.Types[i-1]);
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
 i:integer;
begin
 IF not (self.initialised)
  THEN
   begin
    self.ListBox1.Items.Append('----------------');
    self.ListBox1.Items.Append('Nicht initialisiert!');
    exit;
   end;
 self.ListBox1.Items.Append('----------------');
 For i:=1 To self.Rarities.Count Do
  begin
   self.ListBox1.Items.Append(IntToStr(i-1)+': '+self.Rarities[i-1]);
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  self.Edit1.Text:=IntToStr(random(5)+1);
  self.Edit2.Text:=IntToStr(random(7)-3);
  self.Edit3.Text:='-';
  self.Edit4.Text:='-';
  self.Button1.Click;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
 i:integer;
begin
 IF not (self.initialised)
  THEN
   begin
    self.ListBox1.Items.Append('----------------');
    self.ListBox1.Items.Append('Nicht initialisiert!');
    exit;
   end;
 self.ListBox1.Items.Append('----------------');
 For i:=1 To self.Stages.Count Do
  begin
   self.ListBox1.Items.Append(IntToStr(i)+': '+self.Stages[i-1]);
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
i,c:integer;
  begin
   IF not (self.initialised)
    THEN
     begin
      self.ListBox1.Items.Append('----------------');
      self.ListBox1.Items.Append('Nicht initialisiert!');
      exit;
     end;
   self.ListBox1.Items.Append('----------------');
   c:=lBound;
   For i:=0 To self.Sources.Count-2 Do
    begin
     self.ListBox1.Items.Append(IntToStr(c)+': '+self.Sources[i]);
     inc(c);
    end;
 end;



procedure TForm1.FormCreate(Sender: TObject);
begin
 randomize;
 self.Memo1.Clear;
 self.initialised:=false;
end;

Function TForm1.getRarity(var RName:String; Amp:integer):integer;
var
 E,rdm,fixed:integer;
 isFixed:Boolean;
 begin
  isFixed:=not (edit3.Text='-');
  self.ListBox1.Items.Append('Erzeuge Seltenheit..');
  rdm:=random(250)+1-Amp;
  self.ListBox1.Items.Append('Randomizer ergibt: '+IntToStr(rdm));
  CASE rdm of
   151..250:
    begin
     E:=0 ;
     self.ListBox1.Items.Append('150<rdm>253 ->'+self.Rarities[E]);
    end;
   51..150:
    begin
     E:=1 ;
     self.ListBox1.Items.Append('50<rdm>151 ->'+self.Rarities[E]);
    end;
   13..50:
    begin
     E:=2 ;
     self.ListBox1.Items.Append('12<rdm>51 ->'+self.Rarities[E]);
    end;
   5..12:
    begin
     E:=3 ;
     self.ListBox1.Items.Append('4<rdm>13 ->'+self.Rarities[E]);
    end;
   -2..4:
    begin
     E:=4 ;
     self.ListBox1.Items.Append('(-3)<rdm>5 ->'+self.Rarities[E]);
    end;
  end;
  IF (isFixed)
   THEN
    begin
     self.ListBox1.Items.Append('Ignoriere Ergebnis und wechsel zu');
     self.ListBox1.Items.Append('erzwungener Seltenheit..');
     fixed:=StrToInt(self.Edit3.Text);
     IF (fixed<0) or (fixed>4)
      THEN
       begin
        self.ListBox1.Items.Append('Keine Gültige Seltenheit! (0..4)');
        self.ListBox1.Items.Append('abbruch!');
        RName:=self.Rarities[E];
        self.ListBox1.Items.Append('Item erhaelt Seltenheit: '+self.Rarities[E]);
        result:=E;
        exit;
       end
      ELSE
       begin
        E:=fixed;
       end;
    end;
  RName:=self.Rarities[E];
  self.ListBox1.Items.Append('Item erhaelt Seltenheit: '+self.Rarities[E]);
  result:=E;
 end;

Function TForm1.getType(var TName:String; Rarity:integer):integer;
var
 rdm:integer;
begin
 self.ListBox1.Items.Append('Erzeuge Itemtyp..');
 IF (Rarity<>0)
  THEN
   begin
    rdm:=random(5)+1;
    self.ListBox1.Items.Append('Randomizer ergibt: '+IntToStr(rdm)+' -> '+self.Types[rdm-1]);
    IF (self.Edit4.Text<>'-')
     THEN
      begin
       self.ListBox1.Items.Append('Ignoriere Ergebnis..');
       IF (StrToInt(self.Edit4.Text)<0) and
          (StrToInt(self.Edit4.Text)>5)
        THEN
         begin
          self.ListBox1.Items.Append('Ungültiger Itemtyp!');
          self.ListBox1.Items.Append('abbruch!');
          exit;
         end
        ELSE
         begin
          rdm:=StrToInt(self.Edit4.Text);
          self.ListBox1.Items.Append('Erzwungener Itemtyp: '+self.Types[rdm-1]);
         end;
      end;
    CASE rdm of
     1: TName:=self.Types[0] ;
     2: TName:=self.Types[1] ;
     3: TName:=self.Types[2] ;
     4: TName:=self.Types[3] ;
     5: TName:=self.Types[4] ;
    end
   end
  ELSE
   begin
    self.ListBox1.Items.Append(self.Rarities[0]+' bleibt '+self.Rarities[0]);
    rdm:=0;
    TName:=self.Rarities[0];
   end;
 result:=rdm;
end;

Function TForm1.getValue(rarity,Stage:integer):Integer;
var
 E:Integer;
 begin
  self.ListBox1.Items.Append('Erzeuge genaue Werte..');
  IF (rarity<>0)
   THEN
    begin
     self.ListBox1.Items.Append('Addiere Grundwert mit Randomwert..');
     Case rarity of
      1: E:=StrToInt(self.Normal[Stage])+random(7)-3  ;
      2: E:=StrToInt(self.Rare[Stage])+random(7)-3    ;
      3: E:=StrToInt(self.VRare[Stage])+random(7)-3   ;
      4: E:=StrToInt(self.Legendary[Stage])+random(5) ;
     end;
     self.ListBox1.Items.Append('-> '+IntToStr(E));
    end
   ELSE
    begin
     E:=0;
     self.ListBox1.Items.Append('Keine Spezi-Werte für '+self.Rarities[0]+'!');
    end;
  IF (E<0)
   THEN
    begin
     self.ListBox1.Items.Append('Korrigiere negative Abweichung..');
     self.ListBox1.Items.Append(IntToStr(E)+' -> 0');
     E:=0;
    end;
  result:=E;
 end;

Function TForm1.getAttrib(rarity,AMP:integer):String;
var
i,rdm:integer;
temp,Attribut:String;
 begin
  self.ListBox1.Items.Append('Erzeuge Attribute..');
  temp:='';
  Case rarity of
   1: i:=0 ;
   2: i:=1 ;
   3: i:=2 ;
   4: i:=3 ;
  end;
  IF (i=1)
   THEN self.ListBox1.Items.Append('Es wird 1 Attribut erzeugt!')
   ELSE self.ListBox1.Items.Append('Es werden '+IntToStr(i)+' Attribute erzeugt!');
  For i:=1 to i Do
   begin
    rdm:=random(17)+1+AMP;
    CASE rdm of
     1..5:  Attribut:='Geschicklichkeit' ;
     6..10: Attribut:='KKraft'           ;
     11:    Attribut:='Charisma'         ;
     12:    Attribut:='Sicherheit'       ;
     13:    Attribut:='Elektronik'       ;
     14:    Attribut:='Gewandtheit'      ;
     15:    Attribut:='Ausdauer'         ;
     16:    Attribut:='M. Belastbarkeit' ;
     17:    Attribut:='Intelligenz'      ;
     18:    Attribut:='Penisgröße'       ;
     19:    Attribut:='Rang erkennen'    ;
     20,21: Attribut:='Initiative'       ;
    end;
    temp:=temp+'|'+Attribut+ '('+IntToStr(random(4)+1)+')';
   end;
  result:=temp;
 end;

end.

