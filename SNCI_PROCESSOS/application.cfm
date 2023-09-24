<cfprocessingdirective pageencoding = "utf-8">
<!--- <cfapplication name="conteudo" sessionmanagement="yes" clientmanagement="yes" sessiontimeout="#createtimespan(0,0,45,0)#" applicationtimeout="120"> --->
<cfapplication 
name="conteudo" 
sessionmanagement="Yes" 
clientmanagement="Yes" 
sessiontimeout="#createtimespan(0,1,0,0)#" 
applicationtimeout="#createtimespan(0,6,0,0)#">

<cfset application.dsn_processos = 'DBSNCI'>
<cfset application.SESSIONTIMEOUT = 60>

<cfset application.auxsite =  cgi.server_name>
	<cfif application.auxsite eq "intranetsistemaspe">
		<cfset application.diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_ANEXOS\'>
		<cfset application.diretorio_avaliacoes = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_AVALIACOES\'>
		<cfset application.diretorio_faqs = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_FAQS\'>
	<cfelseif application.auxsite eq "desenvolvimentope" OR application.auxsite eq "homologacaope" >
		<cfset application.diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
		<cfset application.diretorio_avaliacoes = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
		<cfset application.diretorio_faqs = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
	<cfelse>
	  	<cfset application.diretorio_anexos = 'D:\SNCI_TESTE\'>
		<cfset application.diretorio_avaliacoes = 'D:\SNCI_TESTE\'>
		<cfset application.diretorio_faqs = 'D:\SNCI_TESTE\'>
	</cfif>



<cfquery name="qUsuariosSNCIProc" datasource="#application.dsn_processos#">
	SELECT pc_usuarios.* FROM pc_usuarios WHERE pc_usu_status='A'
</cfquery>

<cfset application.Lista_usuariosCad = UCase(ValueList(qUsuariosSNCIProc.pc_usu_login))>


<cfquery name="application.rsUsuarioParametros" datasource="#application.dsn_processos#">
	SELECT pc_usuarios.*, pc_orgaos.*, pc_perfil_tipos.* FROM pc_usuarios 
	INNER JOIN pc_orgaos ON pc_org_mcu = pc_usu_lotacao
	INNER JOIN pc_perfil_tipos on pc_perfil_tipo_id = pc_usu_perfil
	<cfif '#cgi.REMOTE_USER#' neq '' and application.auxsite neq "intranetsistemaspe" and application.auxsite neq "homologacaope" and application.auxsite neq "desenvolvimentope">
		WHERE pc_usu_login = '#cgi.REMOTE_USER#'
	<cfelse>
		WHERE pc_usu_login = 'CORREIOSNET\80859992'
	</cfif>
</cfquery>
<cfquery name="qControleAcessoParametros" datasource="#application.dsn_processos#">
	SELECT '/snci/snci_processos/'+pc_controle_acesso_pagina as pagina FROM pc_controle_acesso
	WHERE pc_controle_acesso_perfis like '%#application.rsUsuarioParametros.pc_usu_perfil#%'
</cfquery>

<cfset application.Lista_paginasPerfilUsuario = ValueList(qControleAcessoParametros.pagina)>
