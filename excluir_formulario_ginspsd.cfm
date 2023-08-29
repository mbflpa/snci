<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<!--- <cfinclude template="verificar_logon.cfm"> --->
<cfif IsDefined("form.sacao") and #form.sacao# neq "">
 <cfif form.sacao is "exc">
   <cfquery datasource="#dsn_inspecao#">
    DELETE FROM Pesquisa WHERE Pes_NumInspecao = '#form.sninsp#'
   </cfquery>
   <cfset smsg = "exclusão">
  </cfif>
  <cfif form.sacao is "inc">
   <cfquery datasource="#dsn_inspecao#">
     UPDATE Pesquisa SET Pes_Observacao='#form.sobs#', Pes_Tipo='#form.stipo#' WHERE Pes_NumInspecao = '#form.sninsp#'
   </cfquery> 
   <cfset smsg = "alteraçao">
  </cfif>
  <script language="javascript">
     msg='Operação ref. a pesquisa de satisfação realizada com sucesso!'
  </script> 
</cfif>
<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
</head>
<body onLoad="alert(msg); document.form.submit();">
  <form name="form" method="post" action="index.cfm">  
  
 </form>
</body> 
</html>
