<!--- <cfdump var="#form#">
<cfdump var="#url#">
<cfdump var="#session#"> --->
<cfset Session.E01.observacao = ''>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Lotacao from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="rsDEPTO" datasource="#dsn_inspecao#">
SELECT Dep_Descricao FROM Departamento WHERE Dep_Codigo='#qAcesso.Usu_Lotacao#'
</cfquery>

<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'DEPARTAMENTO' or Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES'>

 <cftry>

<cfif isDefined("Form.acao") And (Form.acao is 'Anexar' Or Form.acao is 'Excluir')>

	<!--- <cfif isDefined("Form.obs")><cfset Session.E01.obs = Form.obs><cfelse><cfset Session.E01.obs = ''></cfif> --->
	<cfif isDefined("Form.observacao")><cfset Session.E01.observacao = Form.observacao><cfelse><cfset Session.E01.observacao = ''></cfif>
	<cfif isDefined("Form.h_obs")><cfset Session.E01.h_obs = Form.h_obs><cfelse><cfset Session.E01.h_obs = ''></cfif>

	 <cfif Form.acao is 'Anexar' and Form.Arquivo neq "">
		<cftry>

		<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">

		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'SS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
		<!--- O arquivo anexo recebe nome indicando Numero da inspe��o, N�mero da unidade, N�mero do grupo e n�mero do item ao qual est� vinculado --->

		<cfset destino = cffile.serverdirectory & '\' & Form.ninsp & '_' & data & '_' & Right(CGI.REMOTE_USER,8) & '_' & Form.ngrup & '_' & Form.nitem & '.pdf'>

		<cfif FileExists(origem)>

			<cffile action="rename" source="#origem#" destination="#destino#">

			<cfquery datasource="#dsn_inspecao#" name="qVerificaAnexo">
				SELECT Ane_Codigo FROM Anexos
				WHERE Ane_Caminho = <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">
			</cfquery>


			<cfif qVerificaAnexo.recordCount eq 0>

				<cfquery datasource="#dsn_inspecao#" name="qVerifica">
				 INSERT INTO Anexos(Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Caminho)
				 VALUES ('#Form.ninsp#','#Form.unid#',#Form.ngrup#,#Form.nitem#,'#destino#')
				</cfquery>

			</cfif>
		</cfif>

		<cfcatch type="any">
			<cfset mensagem = 'Ocorreu um erro ao efetuar esta opera��o, o campo Arquivo est� vazio, Selecione um arquivo no formato PDF'>
			<script>
				alert('<cfoutput>#mensagem#</cfoutput>');
				history.back();
			</script>
			<cfif isDefined("Session.E01")>
			 <cfset StructClear(Session.E01)>
			</cfif>
			 <cfdump var="#cfcatch#">
			<cfabort> 
		</cfcatch>

		</cftry>

	  </cfif>


  <!--- Excluir anexo --->
	 <cfif Form.acao is 'Excluir'>
	  <!--- Verificar se anexo existe --->

		<cfquery datasource="#dsn_inspecao#" name="qAnexos">
			SELECT Ane_Codigo, Ane_Caminho FROM Anexos WHERE Ane_Codigo = '#vCodigo#'
		</cfquery>


	 <cfif qAnexos.recordCount Neq 0>

		<!--- Exluindo arquivo do diret�rio de Anexos --->
		<cfif FileExists(qAnexos.Ane_Caminho)>
			<cffile action="delete" file="#qAnexos.Ane_Caminho#">
		</cfif>


		<!--- Excluindo anexo do banco de dados --->

		<cfquery datasource="#dsn_inspecao#">
		  DELETE FROM Anexos WHERE Ane_Codigo = '#vCodigo#'
		</cfquery>

	 </cfif>

	</cfif>
</cfif>

<!--- <cfset area = 'sins'> --->
<cfset Encaminhamento = '� SGCIN'>

<cfset evento = 'document.form1.observacao.focus();'>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">

<cfparam name="URL.Unid" default="#Form.Unid#">
<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
<cfparam name="URL.Nitem" default="#Form.Nitem#">
<cfparam name="URL.Desc" default="">
<cfparam name="URL.DGrup" default="">
<cfparam name="URL.numpag" default="0">
<cfparam name="URL.Reop" default="#Form.Reop#">

<cfelse>

<cfparam name="URL.Unid" default="0">
<cfparam name="URL.Ninsp" default="">
<cfparam name="URL.Ngrup" default="">
<cfparam name="URL.Nitem" default="">
<cfparam name="URL.Desc" default="">
<cfparam name="URL.DGrup" default="0">
<cfparam name="URL.numpag" default="0">
<cfparam name="URL.DtInic" default="0">
<cfparam name="URL.dtFim" default="0">
<cfparam name="URL.Reop" default="">
<cfparam name="URL.ckTipo" default="">
<cfparam name="URL.SE" default="">

</cfif>


<cfquery name="rsItem" datasource="#dsn_inspecao#">
   SELECT RIP_NumInspecao, RIP_Unidade, Und_Descricao, RIP_NumGrupo, RIP_NumItem, RIP_Comentario, RIP_Recomendacoes, INP_DtInicInspecao, INP_Responsavel, Rep_Codigo, Itn_Descricao, Grp_Descricao
   FROM Unidades 
   INNER JOIN Resultado_Inspecao 
   INNER JOIN Inspecao ON RIP_Unidade = INP_Unidade AND RIP_NumInspecao = INP_NumInspecao 
   INNER JOIN Grupos_Verificacao ON RIP_NumGrupo = Grp_Codigo ON
   Und_Codigo = INP_Unidade 
   INNER JOIN Itens_Verificacao ON Itn_NumGrupo = RIP_NumGrupo AND Itn_NumItem = RIP_NumItem 
   INNER JOIN Reops ON Und_CodReop = Rep_Codigo AND convert(char(4), Rip_ano) = Itn_Ano AND right([RIP_NumInspecao], 4) = Grp_Ano and (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade)
   WHERE RIP_NumInspecao ='#ninsp#' AND RIP_Unidade='#unid#' AND RIP_NumGrupo= #ngrup# AND RIP_NumItem=#nitem#
</cfquery>

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome
 FROM Usuarios
 WHERE Usu_Login = '#CGI.REMOTE_USER#'
 GROUP BY Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome
</cfquery>

<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem#
  order by Ane_Codigo
</cfquery>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
  SELECT INP_Responsavel
  FROM Inspecao
  WHERE (INP_NumInspecao = '#URL.Ninsp#')
</cfquery>

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
  SELECT IPT_MatricInspetor, Fun_Nome
  FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND
  IPT_MatricInspetor = Fun_Matric
  WHERE (IPT_NumInspecao = '#URL.Ninsp#')
</cfquery>
<!--- Registros dos dados da manifesta��o e da daa de previs�o --->
<!--- ================================================================== --->
<cfif IsDefined("FORM.submit") AND (Form.acao is "Salvar2")>
  <cfset strManifes = "">
  <cfset nID_Resp = 6>
  <cfset Encaminhamento = '� SGCIN'>
  <cfset sSigla_Resp = "RA">
  <cfset sDesc_Resp = "RESPOSTA DA AREA">
  <cfquery datasource="#dsn_inspecao#">
  UPDATE ParecerUnidade SET Pos_DtPrev_Solucao =
  <cfif IsDefined("FORM.cbData") AND FORM.cbData NEQ "">
		<cfset concluir = "N">
		<cfset dia_data = Left(FORM.cbData,2)>
		<cfset mes_data = Mid(FORM.cbData,4,2)>
		<cfset ano_data = Right(FORM.cbData,2)>
		<cfset dtcbData = CreateDate(ano_data,mes_data,dia_data)>
		<cfset dthoje = CreateDate(Year(Now()),Month(Now()),Day(Now()))>
		<!--- Valor pre-existente em banco ref. ao campo (Pos_Situacao_Resp => 14 = N�O RESPONDIDO)  --->
		 <!--- Valor digitado com a data de agora (now()) --->
		  <cfif dtcbData eq dthoje>
			 <!--- acrescentar mais dois dias para Pos_dtprev_solucao --->
				 <cfset dtcbData = DateAdd( "d", 2, dtcbData)>
				 <cfset Encaminhamento = '� SGCIN'>
				 <cfset nID_Resp = 6>
				 <cfset sSigla_Resp = "RA">
				 <cfset sDesc_Resp = "RESPOSTA DA AREA">
		  <cfelse>
				 <!--- h� inten��o de concluir a resposta  no futuro (trocar o status)--->
				 <cfset Encaminhamento = 'A AREA'>
				 <cfset nID_Resp = 19>
				 <cfset sSigla_Resp = "TA">
				 <cfset sDesc_Resp = "TRATAMENTO DA AREA">
		  </cfif>

	<!--- antes da salvar procurar o dia util na tabela feriados nacionais e por sabado e domingo --->
		<cfset nCont = 1>
		<cfloop condition="nCont lte 1">
			<cfset nCont = nCont + 1>
			<cfset vDiaSem = DayOfWeek(dtcbData)>
			<cfif vDiaSem neq 1 and vDiaSem neq 7>
				<!--- verificar se Feriado Nacional --->
				<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
					 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtcbData#
				</cfquery>
				<cfif rsFeriado.recordcount gt 0>
				   <cfset nCont = nCont - 1>
				   <cfset dtcbData = DateAdd( "d", 1, dtcbData)>
				</cfif>
			</cfif>
			<!--- Verifica se final de semana  --->
			<cfif vDiaSem eq 1 or vDiaSem eq 7>
				<cfset nCont = nCont - 1>
				<cfset dtcbData = DateAdd( "d", 1, dtcbData)>
			</cfif>	
		</cfloop>			
     <!--- ==================================== --->
	 <cfset data = 'Data de Previs�o da Solu��o: '>
	 <!--- valor a ser salvo no banco --->
       #dtcbData#
	<cfelse>
	  <cfset data = ''>
		NULL
    </cfif>
  , Pos_Situacao_Resp = #nID_Resp#
  , Pos_Area = '#qUsuario.Usu_Lotacao#'
  , Pos_NomeArea = '#qUsuario.Usu_LotacaoNome#'
  , Pos_Situacao = '#sSigla_Resp#'
  , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
  , Pos_NomeResp = '#CGI.REMOTE_USER#'
  , Pos_username = '#CGI.REMOTE_USER#'
  , Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
  , Pos_Sit_Resp_Antes = #form.respantes#
  <cfset aux_obs = "">
  <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
  , Pos_Parecer=
    <cfset aux_obs = Trim(FORM.observacao)>
	<cfset aux_obs = Replace(aux_obs,'"','','All')>
    <cfset aux_obs = Replace(aux_obs,"'","","All")>
	<cfset aux_obs = Replace(aux_obs,'*','','All')>
	<cfset aux_obs = Replace(aux_obs,'>','','All')>

	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif>
	
  <cfset pos_obs = trim(Form.H_obs) & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Situação: ' & #sDesc_Resp# & CHR(13) & CHR(13) & #data# & #DateFormat(dtcbData,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
	'#pos_obs#'
   </cfif>
  WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
  </cfquery>

 <!--- Inserindo dados dados na tabela Andamento --->
 <cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1" And IsDefined("FORM.acao") And Form.acao is "Salvar2">
 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Situação: ' & #sDesc_Resp# & CHR(13) & CHR(13) & #data# & #DateFormat(dtcbData,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>	
 <cfquery datasource="#dsn_inspecao#">
    insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) 
	values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', '#FORM.frmResp#', '#hhmmssdc#', '#and_obs#', '#qUsuario.Usu_Lotacao#')
 </cfquery>

</cfif>

</cfif>

<cfquery name="rsMOd" datasource="#dsn_inspecao#">
  SELECT Unidades.Und_Descricao, Unidades.Und_CodReop
  FROM Unidades
  WHERE Unidades.Und_Codigo = '#URL.Unid#'
</cfquery>

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
  SELECT Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Parecer, Pos_DtPrev_Solucao, Pos_DtPosic, Pos_Situacao_Resp
  FROM ParecerUnidade
  WHERE Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem# AND Pos_Unidade = '#unid#' AND Pos_Inspecao = '#ninsp#'
</cfquery>

<cfquery name="rsTPUnid" datasource="#dsn_inspecao#">
     SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#URL.unid#'
</cfquery>
<cfif rsTPUnid.Und_TipoUnidade is 12>
	<cfquery name="rsPonto" datasource="#dsn_inspecao#">
	  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo not in (2,5,19,21)
	</cfquery>
<cfelse>
	<cfquery name="rsPonto" datasource="#dsn_inspecao#">
	  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo not in (5,19,20,21)		
	</cfquery>
</cfif>
<script>

function Trim(str)
{
while (str.charAt(0) == ' ')
str = str.substr(1,str.length -1);

while (str.charAt(str.length-1) == ' ')
str = str.substr(0,str.length-1);

return str;
}

//Valida��o de campos vazios em formul�rio
function validaForm() {

 if (document.form1.acao.value=='Anexar'){
	  return true;
  }
 if (document.form1.acao.value=='Excluir'){
	  return true;
  }
  if (document.form1.observacao.value == ''){
		 alert('Caro Usu�rio, est� faltando sua An�lise no campo Manifestar-se!');
		 return false;
	    }
}

//Fun��o que abre uma p�gina em Popup
function popupPage() {
<cfoutput>  //página chamada, seguida dos par�metros n�mero, unidade, grupo e item
var page = "itens_unidades_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}
</script>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script type="text/javascript" src="ckeditor/ckeditor.js"></script>
<link href="css.css" rel="stylesheet" type="text/css">


<script type="text/javascript">


function aviso(){
alert('AVISO IMPORTANTE \n\nSenhor gestor, caso sua resposta solucione a irregularidade de imediato, informar no campo Data de Previsão da Solução a data atual(hoje). \n\nSe for necess�rio prazo para regulariza��o, indicar data futura. \n\nAt� esta data ser� necess�rio entrar novamente no sistema SNCI para complementa��o de sua Resposta.');
}

//================
function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
		   if (data.value < 1 || data.value > 31) {
		      alert('Valor para o dia inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
		case 5:
			if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
		      alert('Valor para o Mês inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
	}
}
//=============================

//permite digita�ao apenas de valores num�ricos
function numericos() {
var tecla = window.event.keyCode;
//permite digita��o das teclas num�ricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {

	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		//alert(tecla);
	//  if () {
		event.returnValue = false;
	 // }
	}
//}
}
function salvar(x){
    var dtprevdig = document.form1.cbData.value;
    var strmanifesto = document.form1.observacao.value;
	strmanifesto = strmanifesto.replace(/\s/g, '');


	if(strmanifesto == '')
	  {
	   alert('Favor Informar o campo: Manifestar-se:!');
	   return false;
	  }

     if(strmanifesto.length < 100)
	  {
	   alert('Sr. Usuário! Sua manisfestação deverá conter no mínimo 100(cem) caracteres');
	   return false;
	  }

	 if (dtprevdig.length != 10){
		alert("Preencher campo: Data da Previsão da Solução ex. DD/MM/AAAA");
		return false;
	 }

	 <!--- formato AAAAMMDD --->
	 var dt_hoje_yyyymmdd = document.form1.dthojeyyyymmdd.value;
	 <!--- var dtPrevSol_bd = document.form1.frmDTPrevSoluc_Banco.value; --->
	 var And_dtposic_fut = document.form1.frmDT30dias_Fut.value;
<!--- 	 var pos_dtposic_amd_atual = document.form1.pos_posic_ymd.value; --->

	 //alert(a);
	 var vDia = dtprevdig.substr(0,2);
	 var vMes = dtprevdig.substr(3,2);
	 var vAno = dtprevdig.substr(6,10);
	 var dtprevdig_yyyymmdd = vAno + vMes + vDia

	 if (dt_hoje_yyyymmdd > dtprevdig_yyyymmdd)
	 {
	  alert("Data de Previsã da Solução é inferior a data de hoje!")
	  return false;
	 }
/*     // esta no prazo de dois dias corridos
	 if (x == 6 && ((dt_hoje_yyyymmdd - pos_dtposic_amd_atual) <= 2))
	  {
	 // alert('linha 429 onde x == 6');
	  if ((dtprevdig_yyyymmdd > db_dtposic_fut))
		{
		// alert(dtprevdig_yyyymmdd + pos_dtposic_amd_atual)
		 alert("Data Previs�o da Solu��o Informada ultrapassa ao prazo m�ximo permitido: " + db_dtposic_fut.substr(6,2) + '/' + db_dtposic_fut.substr(4,2) + '/' + db_dtposic_fut.substr(0,4))
		return false;
		}
	  }
*/
	 // Neste status considerar o prazo m�ximo contado a partir da andamento.and_DtPosic
	if ((dtprevdig_yyyymmdd > And_dtposic_fut))
	{
	// aguardar o Edimir
	//alert("Data Previs�o da Solu��o Informada ultrapassa ao prazo m�ximo permitido: " + And_dtposic_fut.substr(6,2) + '/' + And_dtposic_fut.substr(4,2) + '/' + And_dtposic_fut.substr(0,4))
	//return false;
	}
// Considerar qualquer outro status
/*	if ((x == 19) && (dtprevdig_yyyymmdd > dtPrevSol_bd))
	  {
	//  alert('linha 448 onde x == 19');
alert("Data Previs�o da Solu��o Informada ultrapassa a anteriormente solicitada para: " + dtPrevSol_bd.substr(6,2) + '/' + dtPrevSol_bd.substr(4,2) + '/' + dtPrevSol_bd.substr(0,4))
	  return false;
	  }
 */
 //return false;
}
</script>
</head>


<body onLoad="">
<cfinclude template="cabecalho.cfm">
<table width="77%" height="60%" align="center">
<tr>
	  <td width="74%" valign="top">
<!--- �rea de conte�do   --->
    <form name="form1" method="post" onSubmit="if (document.form1.acao.value == 'Salvar2') {return salvar(vPSitResp.value)}" enctype="multipart/form-data" action="itens_unidades_controle_respostas1_area.cfm">
      <div align="right"><table width="74%" align="center">
          <tr><br>
              <td colspan="9"><p align="center" class="titulo1"><strong> </strong><strong class="titulo1"><cfoutput>#rsDEPTO.Dep_Descricao#</cfoutput></strong>
                      <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
                      <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
                      <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
                      <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
                      <input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>">
					  <input type="hidden" name="acao" id="acao" value="">
                      <input type="hidden" name="anexo" id="anexo" value="">
					  <input type="hidden" name="vCodigo" id="vCodigo" value="">
					  <input name="idtpunid" type="hidden" id="idtpunid" value="<cfoutput>#rsTPUnid.Und_TipoUnidade#</cfoutput>">
					  <input name="respantes" type="hidden" id="respantes" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
					  
              </p></td>
          </tr>
		  <tr bgcolor="FFFFFF" class="exibir">
            <td colspan="9">&nbsp;</td>
          </tr>
          <tr bgcolor="FFFFFF" class="exibir">
            <td colspan="9">&nbsp;</td>
          </tr>
          <tr class="exibir">
            <td width="128" bgcolor="eeeeee">Unidade </td>
            <td colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
            <td colspan="2" bgcolor="f7f7f7">Respons&aacute;vel</td>
            <td width="644" colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
            </tr>
          <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Inspetor</td>
              <cfelse>
              <td width="73" bgcolor="eeeeee">Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="7" bgcolor="f7f7f7">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>- </cfif></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Nº Avaliação</td>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="8" bgcolor="f7f7f7"><cfoutput><strong>#Num_Insp#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Grupo</td>
            <td width="73" bgcolor="f7f7f7"><cfoutput>#URL.Ngrup#</cfoutput></td>
            <td colspan="6" bgcolor="f7f7f7"><cfoutput><strong>#rsItem.Grp_Descricao#</strong></cfoutput></td>
            </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Item</td>
            <td bgcolor="f7f7f7"><cfoutput>#URL.Nitem#</cfoutput></td>
            <td colspan="7" bgcolor="f7f7f7"><cfoutput><strong>#rsItem.Itn_Descricao#</strong></cfoutput></td>
            </tr>
          <tr class="exibir">
            <td colspan="3" bgcolor="f7f7f7">&nbsp;</td>
            <td width="287" bgcolor="f7f7f7">&nbsp;</td>
            <td colspan="5" bgcolor="f7f7f7">&nbsp;</td>
          </tr>
          <tr class="exibir">
            <td colspan="9" bgcolor="f7f7f7"></td>
           </tr>
          <tr>
            <td valign="middle" bgcolor="eeeeee" class="exibir"><div align="center"><span class="titulos">SITUAÇÃO ENCONTRADA:</span></div></td>
            <td colspan="8" bgcolor="f7f7f7"><span class="exibir">
				<cfset melhoria = replace('#rsItem.RIP_Comentario#','; ' ,';','all')>
              <textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Comentario#</cfoutput></textarea>
            </span></td>
		  </tr>
		 <tr>
            <td bgcolor="eeeeee"><div align="center"><span class="exibir"><span class="titulos">Orientações:</span></span></div></td>
            <td colspan="7"><span class="exibir">
              <textarea name="H_recom" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea>
            </span></td>
		  </tr>

            <input type="hidden" name="frmResp" value="6">

          <tr>
            <td valign="middle" bgcolor="eeeeee" class="exibir"><div align="center"><span class="titulos">Hist&oacute;rico:</span> <span class="titulos">Manifesta&ccedil;&atilde;o/An&aacute;lise do Controle Interno</span><span class="titulos">:</span></div>
              <span class="titulos"><p align="center">
          <input name="extrato" type="button" class="botao" id="extrato" onClick="window.open('Exibir_Texto_Parecer.cfm?frmUnid=<cfoutput>#unid#</cfoutput>&frmNumInsp=<cfoutput>#ninsp#</cfoutput>&frmGrupo=<cfoutput>#ngrup#</cfoutput>&frmItem=<cfoutput>#nitem#</cfoutput>','_blank')" value="+ Detalhes" />		</span></td>
            <td colspan="7" bgcolor="f7f7f7"><textarea name="H_obs" cols="200" rows="40" wrap="VIRTUAL" value="#Session.E01.h_obs#" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea></td>
          </tr>
          <tr>
        <td colspan="8" class="exibir" bgcolor="#eeeeee"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ANEXOS</strong></td>
        </tr>

 <!---      <tr>
            <td colspan="7" bgcolor="eeeeee" class="exibir">&nbsp;</td>
            </tr> --->

      <cfloop query= "qAnexos">
        <cfif FileExists(qAnexos.Ane_Caminho)>
          <tr>
            <td colspan="5" bgcolor="eeeeee" class="form"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
            <td colspan="3" align="center" bgcolor="eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" />                <span class="exibir">
			    </span></td>
			</tr>
        </cfif>
      </cfloop>
         <tr>
           <td colspan="8" bgcolor="eeeeee">&nbsp;</td>
         </tr>
		 <tr>
           <td colspan="8" bgcolor="eeeeee">&nbsp;</td>
         </tr>
          <tr>
            <td colspan="8">
			  <div align="center"><button onClick="window.close()" class="botao">Fechar</button>
			  </div></td>
            </tr>
        </table>
        <input type="hidden" name="MM_UpdateRecord" value="form1">
		  <cfoutput>
        <input type="hidden" name="frmdtprev_atual" id="frmdtprev_atual" value="#dateformat(qResposta.Pos_DtPrev_Solucao,"YYYYMMDD")#">
		<cfobject component = "CFC/Dao" name = "dao">
		<cfinvoke component="#dao#" method="VencidoPrazo_Andamento" returnVariable="VencidoPrazo_Andamento" NumeroDaInspecao="#ninsp#" 
			CodigoDaUnidade="#unid#" Grupo="#ngrup#" Item="#nitem#" MostraDump="no" RetornaQuantDias="yes" ListaDeStatusContabilizados="5,19">
			
<!--- 			 <br><cfoutput>tempo #VencidoPrazo_Andamento#</cfoutput><br>  
			<cfset gil = gil>
		   <cfset sdestina = "">--->
		    
<!---   <cfquery name="qStatus5" datasource="#dsn_inspecao#">
		  select And_DtPosic, DATEDIFF(d, And_DtPosic, GETDATE()) as qtddias from andamento where And_Situacao_Resp = 5 and And_Unidade = '#unid#' and And_NumInspecao = '#ninsp#' and And_NumGrupo = #ngrup# and And_NumItem = #nitem# order by And_DtPosic desc, And_HrPosic desc
		</cfquery>>
		 --->
		<!--- <cfif qStatus16_4.RecordCount gt 0> --->
		<cfset auxQtdDias = VencidoPrazo_Andamento> 
		<cfif auxQtdDias neq "" and auxQtdDias gt 0>		
		  	  <cfif auxQtdDias gte 30>  
					<cfquery name="rsPonto" datasource="#dsn_inspecao#">
						  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND (STO_Codigo = 7)
					</cfquery>
				    <cfset dtposicfut = dateformat(now(),"DD/MM/YYYY")>
			  <cfelse> 
				  <cfset auxqtd = auxQtdDias>
				  <cfset auxqtd = int(30 - auxqtd)>  
				  <cfset dtatual = CreateDate(year(now()),month(now()),day(now()))>
				  <cfset dtposicfut = DateAdd("d", #auxqtd#, #dtatual#)> 
			  </cfif>
	    <cfelse>
			<cfset dtposicfut = CreateDate(Year(Now()),Month(Now()),Day(Now()))>
			<cfset dtposicfut = DateAdd( "d", 30, dtposicfut)>
		</cfif>
		<input type="hidden" name="frmDT30dias_Fut" id="frmDT30dias_Fut" value="#dateformat(dtposicfut,"YYYYMMDD")#">	
</cfoutput>
	</form>
<!--- Fim �rea de conte�do --->
  </tr>
</table>
</body>

<script>
	<cfoutput>
		<!---Retorna true se a data de in�cio da inspe��o for maior ou igual a 04/03/2021, data em que o editor de texto foi implantado. Isso evitar� que os textos anteriores sejam desformatados--->
		<cfset CouponDate = createDate( 2021, 03, 04 ) />
		<cfif DateDiff( "d", '#rsItem.INP_DtInicInspecao#',CouponDate ) GTE 1>
			<cfset usarEditor = false />
		<cfelse>
			<cfset usarEditor = true />
		</cfif>
		var usarEditor = #usarEditor#;
	</cfoutput>
	if(usarEditor == true){
		//configura��es diferenciadas do editor de texto.
		CKEDITOR.replace('Melhoria', {
		width: 1020,
		height: 200,
		toolbar:[
		{ name: 'document', items: ['Preview', 'Print', '-' ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'styles', items: [ 'Styles'] },
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl' ] },
		{ name: 'insert', items: [ 'Table' ] },		
		{ name: 'insert', items: [ 'HorizontalRule' ] }
		], 
			
		// Remove the redundant buttons from toolbar groups defined above.
		removeButtons:'Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,CopyFormatting,RemoveFormat'
		// removeButtons: 'Source,Save,NewPage,ExportPdf,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,Scayt,Form,Radio,TextField,Textarea,Select,ImageButton,HiddenField,Button,Bold,Italic,Underline,Strike,Subscript,Superscript,CopyFormatting,RemoveFormat,NumberedList,BulletedList,Outdent,Indent,Blockquote,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Link,Unlink,Anchor,Image,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Format,Font,FontSize,TextColor,BGColor,Maximize,ShowBlocks,About,Checkbox'

		});

		CKEDITOR.replace('H_recom', {
		width: 1020,
		height: 100,
		toolbar:[
		{ name: 'document', items: ['Preview', 'Print', '-' ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'styles', items: [ 'Styles'] },
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl' ] },
		{ name: 'insert', items: [ 'Table' ] },		
		{ name: 'insert', items: [ 'HorizontalRule' ] }
		], 
			
		// Remove the redundant buttons from toolbar groups defined above.
		removeButtons:'Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,CopyFormatting,RemoveFormat'
		// removeButtons: 'Source,Save,NewPage,ExportPdf,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,Scayt,Form,Radio,TextField,Textarea,Select,ImageButton,HiddenField,Button,Bold,Italic,Underline,Strike,Subscript,Superscript,CopyFormatting,RemoveFormat,NumberedList,BulletedList,Outdent,Indent,Blockquote,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Link,Unlink,Anchor,Image,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Format,Font,FontSize,TextColor,BGColor,Maximize,ShowBlocks,About,Checkbox'

		});
	}
            
</script>
</html>

 <cfcatch>
  <cfdump var="#cfcatch#">
  	<cfif isDefined("Session.E01")>
	   <cfset StructClear(Session.E01)>
	</cfif>
</cfcatch>
</cftry>

<cfif isDefined("Session.E01")>
	<cfset StructClear(Session.E01)>
</cfif>

<cfelse>
     <cfinclude template="permissao_negada.htm">
</cfif>
