unit Gsoft.CadProdutos.View.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  AdvGlowButton, Gsoft.CadProdutos.Model.Produto, System.TypInfo,
  Gsoft.CadProdutos.DAO.Produto, Gsoft.CadProdutos.Produto.View.Consulta;

type
  TFrmPrincipal = class(TForm)
    PnlTop: TPanel;
    PnlBot: TPanel;
    PnlDireita: TPanel;
    PnlCostas: TPanel;
    PnlPrincipal: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    EdtCodigo: TEdit;
    EdtDescricao: TEdit;
    EdtPrecoVenda: TEdit;
    EdtICMS: TEdit;
    CbbUnidade: TComboBox;
    ChbAtivo: TCheckBox;
    BtnIncluir: TAdvGlowButton;
    BtnCadastrar: TAdvGlowButton;
    BtnEditar: TAdvGlowButton;
    BtnExcluir: TAdvGlowButton;
    BtnConsultar: TAdvGlowButton;
    LblResultadoICMS: TLabel;
    BtnCalcularICMS: TAdvGlowButton;
    procedure BtnIncluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnEditarClick(Sender: TObject);
    procedure BtnConsultarClick(Sender: TObject);
    procedure BtnExcluirClick(Sender: TObject);
    procedure BtnCadastrarClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnCalcularICMSClick(Sender: TObject);
  private
    Produto: TProduto;
    procedure PreencherProduto;
    procedure GravarProduto;
    procedure PreencherTela;
    procedure EditarProduto;
    procedure LimparCampos;
  public
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

procedure TFrmPrincipal.BtnCadastrarClick(Sender: TObject);
begin
  Self.PnlPrincipal.Enabled := False;
  if  Assigned(Self.Produto) then
  begin
    if Produto.Codigo > 0 then
    begin
      Self.EditarProduto();
    end
    else
    begin
      Self.GravarProduto();
    end;
  end
  else
  begin
    Self.Produto := TProduto.Create();
    Self.GravarProduto();
  end;

end;

procedure TFrmPrincipal.BtnCalcularICMSClick(Sender: TObject);
begin
  if Assigned(Self.Produto) then
  begin
    LblResultadoICMS.Caption := FloatToStr(Self.Produto.ImpostoICMS);
  end
  else {ShowMessage('N�o h� produto para calcular o valor!');}
  Application.MessageBox('N�o h� produto para calcular o valor!', 'Erro ao Calcular', 0);
end;

procedure TFrmPrincipal.BtnConsultarClick(Sender: TObject);
begin
  FrmConsultaProdutos := TFrmConsultaProdutos.Create(Self);
  try
    FrmConsultaProdutos.ShowModal;
    if FrmConsultaProdutos.ProdutoSelecionado > 0 then
    begin
      Self.Produto := DmProduto.Selecionar(FrmConsultaProdutos.ProdutoSelecionado);
      Self.PreencherTela();
    end;
  finally
    FreeAndNil(FrmConsultaProdutos);
  end;
end;

procedure TFrmPrincipal.BtnEditarClick(Sender: TObject);
begin
  if not Assigned(Self.Produto) then
  begin
    ShowMessage('N�o existe produto para ser alterada!');
  end;
  if Assigned(Self.Produto) then Self.PnlPrincipal.Enabled := True;

end;

procedure TFrmPrincipal.BtnExcluirClick(Sender: TObject);
begin
  if Assigned(Self.Produto) then
  begin
    if Produto.Codigo > 0 then
    begin
       If (DmProduto.Excluir(Self.Produto.Codigo)) then
       begin
          Self.LimparCampos;
          ShowMessage('Registro excluido com sucesso!')
       end;
    end
    else
    begin
      Self.LimparCampos();
    end;
  end
  else
  begin
    ShowMessage('Pessoa n�o selecionada')
  end;
end;

procedure TFrmPrincipal.BtnIncluirClick(Sender: TObject);
begin
  Self.PnlPrincipal.Enabled := True;
  Self.LimparCampos();
  if EdtDescricao.CanFocus then EdtDescricao.SetFocus;
  ChbAtivo.Checked := True;
end;

procedure TFrmPrincipal.LimparCampos();
begin
  EdtCodigo.Text := EmptyStr;
  EdtDescricao.Text := EmptyStr;
  EdtPrecoVenda.Text := EmptyStr;
  CbbUnidade.ItemIndex := -1;
  EdtICMS.Text := EmptyStr;
  ChbAtivo.Checked := False;
end;

procedure TFrmPrincipal.PreencherTela;
begin
  EdtCodigo.Text := Self.Produto.Codigo.ToString();
  EdtDescricao.Text := Self.Produto.Descricao;
  EdtPrecoVenda.Text := FloatToStr(Self.Produto.PrecoVenda);
  CbbUnidade.ItemIndex := Integer(Self.Produto.Unidade);
  EdtICMS.Text := IntToStr((Self.Produto.Icms));
  ChbAtivo.Checked := Self.Produto.Ativo;
end;

procedure TFrmPrincipal.PreencherProduto();
begin
  Self.Produto.Descricao := EdtDescricao.Text;
  Self.Produto.PrecoVenda := StrToFloat(EdtPrecoVenda.Text);
  Self.Produto.Unidade := TUnidade(GetEnumValue(TypeInfo(TUnidade),CbbUnidade.text));
  Self.Produto.Icms := StrToInt(EdtICMS.Text);
  Self.Produto.Ativo := ChbAtivo.Checked;
end;

procedure TFrmPrincipal.GravarProduto();
begin
  Self.PreencherProduto();
  Self.Produto := DmProduto.Inserir(Self.Produto);
  Self.PreencherTela();
end;

procedure TFrmPrincipal.EditarProduto();
begin
  Self.PreencherProduto();
  Self.Produto := DmProduto.Alterar(Self.Produto);
  Self.PreencherTela();
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  DmProduto := TDmProduto.Create(Self);
end;
procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
  FreeAndNil(DmProduto);
end;

procedure TFrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_ESCAPE then Close;
end;

end.
