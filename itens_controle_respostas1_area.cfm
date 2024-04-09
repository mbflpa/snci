<cfprocessingdirective pageEncoding ="utf-8"/> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>  
 
<cfset area = 'sins'>
<cfset evento = 'document.form1.observacao.focus();'>

<cfparam name="URL.Unid" default="0">
<cfparam name="URL.Ninsp" default="">
<cfparam name="URL.Ngrup" default="">
<cfparam name="URL.Nitem" default="">
<cfparam name="URL.Desc" default="">
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfparam name="URL.DGrup" default="0">
<cfparam name="URL.numpag" default="0">
<cfparam name="URL.DtInic" default="0">
<cfparam name="URL.DtFinal" default="0">
<cfparam name="URL.area" default="">

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao
 FROM Usuarios
 WHERE Usu_Login = '#CGI.REMOTE_USER#'
 GROUP BY Usu_Apelido, Usu_Lotacao 
</cfquery>    

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
SELECT Pos_NumGrupo,     
       Pos_NumItem, Pos_Unidade, 
       Pos_Inspecao, Pos_Situacao_Resp,      
       Pos_Parecer, Ars_CodGerencia
FROM (((Inspecao 
INNER JOIN ParecerUnidade ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)) 
INNER JOIN Itens_Verificacao ON (right(Pos_Inspecao,4) = Itn_Ano) and (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) AND (INP_Modalidade = Itn_Modalidade)) 
INNER JOIN Areas ON Pos_Area = Ars_Codigo) 
INNER JOIN Unidades ON (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Unidade = Und_Codigo)
WHERE  (Pos_NumGrupo = #URL.ngrup#) AND (Pos_NumItem = #URL.nitem#) AND (Pos_Unidade = '#URL.unid#') AND (Pos_Inspecao = '#URL.ninsp#') AND (Pos_Area = '#URL.area#')
</cfquery>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
SELECT     INP_Responsavel
FROM         Inspecao
WHERE     (INP_NumInspecao = #URL.Ninsp#) AND (INP_DtInicInspecao = #DateFormat(URL.DtInic,"mm/dd/yy")#)
</cfquery>

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
SELECT     IPT_MatricInspetor, Fun_Nome
FROM         Inspetor_Inspecao INNER JOIN
                      Funcionarios ON IPT_MatricInspetor = Fun_Matric AND 
                      IPT_MatricInspetor = Fun_Matric
WHERE     (IPT_NumInspecao = '#URL.Ninsp#')
</cfquery>

<cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1">
	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif>
  <cfquery datasource="#dsn_inspecao#">
  UPDATE ParecerUnidade SET Pos_Situacao_Resp=
    <cfif IsDefined("FORM.frmResp") AND #FORM.frmResp# NEQ "">
    '#FORM.frmResp#'
	, Pos_Sit_Resp_Antes = #form.scodresp#
      <cfelse>
      NULL
  </cfif>
  <cfset aux_obs = "">
   <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ ""> 
	, Pos_Parecer=
	<cfset aux_obs = Trim(FORM.observacao)>
	<cfset aux_obs = Replace(aux_obs,'"','','All')>
    <cfset aux_obs = Replace(aux_obs,"'","","All")>
	<cfset aux_obs = Replace(aux_obs,'*','','All')>
	<cfset aux_obs = Replace(aux_obs,'>','','All')>		
	<!---	 <cfset aux_obs = Replace(aux_obs,'&','','All')>
		     <cfset aux_obs = Replace(aux_obs,'%','','All')> --->
    <cfset pos_obs = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #aux_obs# & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
  '#pos_obs#'
  </cfif>
  , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
  , Pos_NomeResp='#CGI.REMOTE_USER#'
  , Pos_username = '#CGI.REMOTE_USER#'
  , Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
  WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem# 
  </cfquery>
  <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
  <cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
  <cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
  <cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>	
 <cfquery datasource="#dsn_inspecao#">
    insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Orgao_Solucao, And_HrPosic, And_Parecer) 
    values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', '#FORM.frmResp#', '#url.reop#', '#hhmmssdc#', '#and_obs#')
 </cfquery>
  <cflocation url="itens_controle_respostas_area.cfm?#CGI.QUERY_STRING#">
</cfif>
<cfquery name="rsMOd" datasource="#dsn_inspecao#">
SELECT Und_Descricao, Und_CodReop
FROM Unidades
WHERE Und_Codigo = '#URL.Unid#' 
</cfquery>

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
function valida_form(form) {
 var frm = document.forms[form];
 var quant = frm.elements.length;
 for (var i=0; i<quant; i++) {
   var elemento = document.forms[form].elements[i];
   if (elemento.getAttribute('vazio') == 'false') {
	 if (Trim(elemento.value) == '') {
	   var nome = elemento.getAttribute('nome');
	   alert('Informe o campo ' + nome + '!');
	   elemento.focus();
	   return false;
	   break;
	 }
   }
 }
}

//Fun��o que abre uma p�gina em Popup
function popupPage() {
<cfoutput>  //página chamada, seguida dos parametros número, unidade, grupo e item
var page = "itens_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
} 
</script>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Avaliações</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body onLoad="popupPage();">

<cfinclude template="cabecalho.cfm">
<table width="800" height="450">
<tr>
	  <td width="96%" valign="top">
<!--- �rea de conte�do   --->
	<form name="form1" method="post" onSubmit="return valida_form(this.name)" action="<cfoutput>#CurrentPage#?#CGI.QUERY_STRING#</cfoutput>">
  <table width="98%" align="center">
    <tr>
      <td colspan="5"><p align="center"><span class="titulo1">Relatório de Avaliação </span></p>
        <p>            <br>
            <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
            <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
            <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
            <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
            <input name="dtinicio" type="hidden" id="dtinicio" value="<cfoutput>#URL.DtInic#</cfoutput>">
            <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.DtFinal#</cfoutput>">
            <input name="area" type="hidden" id="area" value="<cfoutput>#URL.area#</cfoutput>"> 
</p>  </td>
    </tr>
    <tr bgcolor="#FFFFFF" class="exibir">
      <td>&nbsp;</td>
      <td><input name="comentarios" type="button" class="botao" onClick="window.open('itens_unidades_controle_respostas_comentarios.cfm?numero=<cfoutput>#URL.ninsp#</cfoutput>&unidade=<cfoutput>#URL.unid#</cfoutput>&numgrupo=<cfoutput>#URL.ngrup#</cfoutput>&numitem=<cfoutput>#URL.nitem#</cfoutput>','','scrollbars=yes, resizable=yes, width=600, height=460, left=120, top=100')" value="N&atilde;o-Conformidade"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF" class="exibir">
      <td colspan="5">&nbsp;</td>
    </tr>
	<tr bgcolor="#FFFFFF" class="exibir">
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr class="exibir">
      <td width="81" bgcolor="eeeeee">Unidade      </td>
      <td width="71" bgcolor="f7f7f7"><cfoutput>#URL.Unid#</cfoutput></td>
      <td width="205" bgcolor="f7f7f7"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td width="45" bgcolor="eeeeee">Órgão Subordinador</td>
      <td width="138" bgcolor="f7f7f7"><cfoutput><strong>#rsMOd.Und_CodReop#</strong></cfoutput></td>
    </tr>
	<tr class="exibir">
      <cfif qInspetor.RecordCount lt 2>
	    <td bgcolor="eeeeee">Inspetor</td>
	  <cfelse>
	    <td bgcolor="eeeeee">Inspetores</td>
	  </cfif>
	  <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
      <td bgcolor="f7f7f7">&nbsp;</td>
      <td colspan="3" bgcolor="f7f7f7">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Relat&oacute;rio </td>
	  <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
      <td bgcolor="f7f7f7">&nbsp;</td>
      <td bgcolor="f7f7f7"><cfoutput><strong>#Num_Insp#</strong></cfoutput></td>
      <td bgcolor="eeeeee">Respons&aacute;vel</td>
      <td bgcolor="f7f7f7"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">N&ordm; Grupo </td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Ngrup#</cfoutput></td>
      <td colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#URL.DGrup#</strong></cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">N&ordm; Item </td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Nitem#</cfoutput></td>
      <td colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#URL.Desc#</strong></cfoutput></td>
    </tr>
	  <!--- <input type="hidden" name="frmResp" value="6"><input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>"> --->
    <tr>
      <td valign="middle" bgcolor="eeeeee" class="exibir">Resposta &Aacute;rea </td>
      <td colspan="4" bgcolor="f7f7f7">
	  <cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.Pos_Parecer) neq ''><textarea name="H_obs" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea></cfif>
	  <textarea name="observacao" cols="120" rows="6" vazio="false" wrap="VIRTUAL" class="form" id="observacao"></textarea>
	  </td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
      <td colspan="3">
        <div align="center">
		<input name="Cancelar" type="button" class="botao" value="Cancelar" onClick="history.back()">
          &nbsp;&nbsp;&nbsp;
          <input name="Submit" type="submit" class="botao" value="Confirmar">
        </div></td>
    </tr>
  </table>
  <input type="hidden" name="MM_UpdateRecord" value="form1">
  <input type="hidden" name="scodresp" id="scodresp" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
</form>

<!--- Fim �rea de conte�do --->
	  </td>
  </tr>
</table>
</body>
</html>
