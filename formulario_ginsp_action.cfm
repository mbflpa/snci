<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dia = day(now())>
<cfset mes = month(now())>
<cfset ano = year(now())>
<html>
<head>
<title>GINSP .::. Pesquisa de Satisfação</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_callJS(jsStr) { //v2.0
  return eval(jsStr)
}
//-->
</script>
</head>

<body>


<cfquery name="insForm" datasource="#dsn_inspecao#">
INSERT INTO Pesquisa (Pes_Nome,Pes_Lotacao,Pes_Comoestamos1,Pes_Comoestamos2,Pes_Comoestamos3,Pes_Comoestamos4,
Pes_Comoestamos5,Pes_Comoestamos6,Pes_Comoestamos7,Pes_MaisImportante,Pes_Sugestoes,Pes_NumInspecao,Pes_DtPesquisa)
VALUES(
	<cfif IsDefined("FORM.nome") AND FORM.nome NEQ "">
    '#FORM.nome#'
    <cfelse>
    NULL
  	</cfif>
   ,
  <cfif IsDefined("FORM.unidade") AND FORM.unidade NEQ "">
    '#FORM.unidade#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("FORM.select1") AND FORM.select1 NEQ "">
    '#FORM.select1#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("FORM.select2") AND FORM.select2 NEQ "">
    '#FORM.select2#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("FORM.select3") AND FORM.select3 NEQ "">
    '#FORM.select3#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("FORM.select4") AND FORM.select4 NEQ "">
    '#FORM.select4#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("FORM.select5") AND FORM.select5 NEQ "">
    '#FORM.select5#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("FORM.select6") AND FORM.select6 NEQ "">
    '#FORM.select6#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("FORM.select7") AND FORM.select7 NEQ "">
    '#FORM.select7#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("FORM.mais_importante") AND FORM.mais_importante NEQ "">
    '#FORM.mais_importante#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("FORM.sugestoes") AND FORM.sugestoes NEQ "">
    '#FORM.sugestoes#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("FORM.inspecao") AND FORM.inspecao NEQ "">
    '#FORM.inspecao#'
    <cfelse>
    NULL
  </cfif>
  ,
   #CreateODBCDate(Createdate(ano,mes,dia))#
)
</cfquery>

<p align="center">&nbsp;</p>
<p align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Formulario enviado com sucesso! </strong></font></p>
<p align="center"><strong><font color="#6699FF" style="cursor:hand" onclick="MM_callJS('history.back();')">c</font><font color="#6699FF" size="2" face="Verdana, Arial, Helvetica, sans-serif" style="cursor:hand" onclick="MM_callJS('history.back();')">lique
          aqui para voltar</font></strong></p>

</body>
</html>