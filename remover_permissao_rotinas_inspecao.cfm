<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfquery datasource="#dsn_inspecao#">
DELETE FROM Usuarios
WHERE Usu_Login = '#form.login#' AND Usu_GrupoAcesso = '#form.area#';
</cfquery>
<cflocation url="index.cfm?opcao=permissao">
