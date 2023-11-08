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
<cfparam name="url.reop" default="">
<cfif IsDefined("dtini")><cfset Url.DtInic = DtIni></cfif>

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao
 FROM Usuarios
 WHERE Usu_Login = '#CGI.REMOTE_USER#'
 GROUP BY Usu_Apelido, Usu_Lotacao 
</cfquery>    

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
SELECT Pos_NumGrupo,     
       Pos_NumItem, ParecerUnidade.Pos_Unidade, 
       Pos_Situacao_Resp, Pos_Parecer, Rep_Codigo
FROM   Reops, ParecerUnidade 
WHERE  (Pos_NumGrupo = #URL.ngrup#) AND (Pos_NumItem = #URL.nitem#) AND (Pos_Unidade = '#URL.unid#') AND (Pos_Inspecao = '#URL.ninsp#') AND (Rep_Codigo ='#url.reop#')
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
  <cfif IsDefined("FORM.frmResp") AND FORM.frmResp NEQ "">
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
    <cfset pos_obs = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Situação: RESPOSTA DA UNIDADE' & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu#& '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
	'#pos_obs#'
  </cfif> 
  , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
  , Pos_NomeResp='#CGI.REMOTE_USER#'
  , Pos_username = '#CGI.REMOTE_USER#'
  , Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
  WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem# 
  </cfquery>
  
  <cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1">
	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif>  
  <cfset hhmmss = timeFormat(now(), "HH:mm:ss")>
	<cfset hhmmss = left(hhmmss,2) & mid(hhmmss,4,2) & mid(hhmmss,7,2)>
   <cfquery datasource="#dsn_inspecao#">
   INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Orgao_Solucao, And_HrPosic, And_Parecer)
   VALUES (   
   <cfif IsDefined("form.Ninsp") AND form.Ninsp NEQ "">   
   '#form.ninsp#'
      <cfelse>
      NULL
   </cfif> 
   ,
   <cfif IsDefined("form.Unid") AND form.Unid NEQ "">   
   '#form.unid#'
      <cfelse>
      NULL
   </cfif> 
   ,
   <cfif IsDefined("form.Ngrup") AND form.Ngrup NEQ "">   
   #form.Ngrup#
      <cfelse>
      NULL
   </cfif> 
   ,
   <cfif IsDefined("form.Nitem") AND form.Nitem NEQ "">   
   #form.Nitem#
      <cfelse>
      NULL
   </cfif>
   ,   
   convert(char, getdate(), 102)
   ,
   '#CGI.REMOTE_USER#',
      
   <cfif IsDefined("FORM.frmResp") AND FORM.frmResp NEQ "">   
   '#FORM.frmResp#'
      <cfelse>
      NULL
   </cfif>
   ,  
   <cfswitch expression="#Form.frmResp#">
     <cfcase value="2">
	   '#form.unid#' 
	 </cfcase>	
	 <cfcase value="3">	   
	     <!--- Tratamento da �rea solucionadora--->
       <cfif IsDefined("FORM.cbunid") AND FORM.cbunid NEQ "">
         '#Form.cbunid#'
       <cfelse>
          <cfif IsDefined("FORM.cbOrgao") AND FORM.cbOrgao NEQ "---">
            '#Form.cbOrgao#'
          <cfelse>
            NULL
          </cfif>
       </cfif>
       <!--- --->	     
	 </cfcase>
	 <cfcase value="0">
	 	NULL
	 </cfcase>
	 <cfcase value="4">
	   '#form.reop#' 
	 </cfcase>
	 <cfcase value="5">
	   '#FORM.cbArea#'
	 </cfcase>	 
	 <cfcase value="8">
	  '#FORM.cbArea#'
	 </cfcase>
	 <cfcase value="9">
	  '#FORM.cbArea#'
	 </cfcase>
	 <cfcase value="1">
	  '#FORM.unid#' 
	 </cfcase>	 	 
   </cfswitch> 
   ,      
  '#hhmmss#'
  ,
  <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
	  <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Situação: RESPOSTA DA UNIDADE' & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
  '#and_obs#'
  <cfelse>
   NULL
  </cfif>
  )
 </cfquery>          
  WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
</cfif>
  
   <cflocation url="itens_controle_respostas_reop.cfm?#CGI.QUERY_STRING#">
</cfif>
<cfquery name="rsMOd" datasource="#dsn_inspecao#">
SELECT Unidades.Und_Descricao, Unidades.Und_CodReop
FROM Unidades
WHERE Unidades.Und_Codigo = '#URL.Unid#' 
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
<cfoutput>  //página chamada, seguida dos parâmetros número, unidade, grupo e item
var page = "itens_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
} 
</script>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das InAvaliações</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">

</head>
<body onLoad="popupPage();">
<table width="800" height="450">
<tr>
	  <td width="96%" valign="top">
<!--- �rea de conte�do   --->
	<form name="form1" method="post" onSubmit="return valida_form(this.name)" action="<cfoutput>#CurrentPage#?#CGI.QUERY_STRING#</cfoutput>">
  <table width="98%" align="center">
    <tr>
      <td colspan="5"><p align="center" class="titulo1"><strong>Controle de Respostas Por Órgão Subordinador </strong></p>
        <p>            <br>
            <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
            <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
            <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
            <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
            <input name="dtinicio" type="hidden" id="dtinicio" value="<cfoutput>#URL.DtInic#</cfoutput>">
            <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.DtFinal#</cfoutput>">
            <input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>"> 
</p>  </td>
    </tr>
    <tr bgcolor="#FFFFFF" class="exibir">
      <td>&nbsp;</td>
      <td><input name="comentarios" type="button" class="botao" onClick="window.open('itens_controle_respostas_comentarios.cfm?numero=<cfoutput>#URL.ninsp#</cfoutput>&unidade=<cfoutput>#URL.unid#</cfoutput>&numgrupo=<cfoutput>#URL.ngrup#</cfoutput>&numitem=<cfoutput>#URL.nitem#</cfoutput>','','scrollbars=yes, resizable=yes, width=600, height=460, left=120, top=100')" value="Coment&aacute;rios"></td>
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
	  <!--- <input type="hidden" name="frmResp" value="7"><input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>"> --->
    <tr>
      <td valign="middle" bgcolor="eeeeee" class="exibir">Resposta do &Oacute;rg&atilde;o Subordinador </td>
      <td colspan="4" bgcolor="f7f7f7">
	  <cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.Pos_Parecer) neq ''>
	  <textarea name="H_obs" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea>
	  </cfif>
	  <textarea name="observacao" cols="120" rows="6" vazio="false" wrap="VIRTUAL" class="form" id="observacao"></textarea>
	  </td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
      <td colspan="3">
        <div align="center">
		<input name="Cancelar" type="button" class="botao" value="Cancelar" onClick="history.back()">
          &nbsp;&nbsp;&nbsp;
		  <cfif IsDefined("dtini")>
            <input name="Submit" type="submit" class="botao" value="Confirmar">
		  </cfif>	
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
