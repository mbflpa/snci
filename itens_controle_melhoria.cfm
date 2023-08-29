<cfparam name="URL.numero" default="0">
<cfparam name="URL.unidade" default="0">
<cfparam name="URL.numgrupo" default="">
<cfparam name="URL.numitem" default="">
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao
 FROM Usuarios
 WHERE Usu_Login = '#CGI.REMOTE_USER#'
 GROUP BY Usu_Apelido, Usu_Lotacao 
</cfquery>


<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {font-size: 14px}
-->
</style>
</head>
<body>
<table width="718" border="0" bgcolor="#f7f7f7">
  <tr>
    <td width="712">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td><div align="center" class="red_titulo style1">Registro inclu&iacute;do  com sucesso!! </div></td>
  </tr>
  <tr>
    <td colspan="5" align="center" bgcolor="#f7f7f7">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5" align="center" bgcolor="#f7f7f7"><input type="button" class="botao" value="Fechar" onClick="window.close()"></td>
  </tr>
  <tr>
    <td colspan="5" align="center" bgcolor="#f7f7f7">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5" align="center" bgcolor="#f7f7f7">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5" align="center" bgcolor="#f7f7f7">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5" align="center" bgcolor="#f7f7f7">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5" align="center" bgcolor="#f7f7f7">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5" align="center" bgcolor="#f7f7f7">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5" align="center" bgcolor="#f7f7f7">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5" align="center" bgcolor="#f7f7f7">&nbsp;</td>
  </tr>
</table>

 <cfquery name="alterarmelhoria" datasource="#dsn_inspecao#"> 
  UPDATE Resultado_Inspecao SET RIP_Melhoria =
  <cfif IsDefined("FORM.melhoria") AND FORM.melhoria NEQ "">
     1
      <cfelse>
      NULL
  </cfif>
  , RIP_Incorreto = 
  <cfif IsDefined("FORM.Incorreto") AND form.Incorreto NEQ "">
     1
      <cfelse>
	  NULL     	   
  </cfif>
  , RIP_Comunicacao = 
  <cfif IsDefined("FORM.Comunicacao") AND FORM.Comunicacao NEQ "">
     1
      <cfelse>
	  NULL     	   
  </cfif>
  , RIP_Inadequado =
  <cfif IsDefined("FORM.Inadequado") AND FORM.Inadequado NEQ "">
     1
      <cfelse>
	  NULL     	   
  </cfif>
  , RIP_Objetividade =
  <cfif IsDefined("FORM.Objetividade") AND FORM.Objetividade NEQ "">
     1
      <cfelse>
	  NULL     	   
  </cfif>
  , RIP_Normativa = 
  <cfif IsDefined("FORM.Normativa") AND FORM.Normativa NEQ "">
     1
      <cfelse>
	  NULL     	   
  </cfif>
  , RIP_Recomendacao = 
  <cfif IsDefined("FORM.Recomendacao") AND FORM.Recomendacao NEQ "">
     1
      <cfelse>
	  NULL     	   
  </cfif>
  , RIP_Pratica = 
  <cfif IsDefined("FORM.Pratica") AND FORM.Pratica NEQ "">
     1
      <cfelse>
	  NULL     	   
  </cfif>
  , RIP_Recomendacao_Inspetor =
  <cfif IsDefined("FORM.correcao") AND FORM.correcao NEQ "">
	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif>  
    <cfset aux_recomendacao = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(FORM.correcao) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13)>
    '#aux_recomendacao#'
      <cfelse>
	  NULL     	   
  </cfif>  
   WHERE RIP_NumInspecao='#form.numero#' AND RIP_Unidade='#form.unidade#' AND RIP_NumGrupo=#form.numgrupo# AND RIP_NumItem=#form.numitem#
 </cfquery>
 <!---<cflocation url="itens_controle_respostas_comentarios.cfm?numero=#URL.numero#&unidade=#URL.unidade#&numgrupo=#URL.numgrupo#&numitem=#URL.numitem#">--->
 
</body>
</html>
