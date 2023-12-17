<cfprocessingdirective pageencoding = "utf-8">
<!--- <cfapplication name="conteudo" sessionmanagement="yes" clientmanagement="yes" sessiontimeout="#createtimespan(0,0,45,0)#" applicationtimeout="120"> --->
<cfset SetLocale("pt_BR")>
<cfapplication 
name="conteudo" 
sessionmanagement="Yes" 
clientmanagement="Yes" 
sessiontimeout="#createtimespan(0,1,0,0)#" 
applicationtimeout="#createtimespan(0,6,0,0)#">

<cfset application.dsn_processos = 'DBSNCI'>
<cfset application.SESSIONTIMEOUT = 60>

<cfset application.auxsite =  cgi.server_name>
<cfif FindNoCase("intranetsistemaspe", application.auxsite)>
	<cfset application.diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_ANEXOS\'>
	<cfset application.diretorio_avaliacoes = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_AVALIACOES\'>
	<cfset application.diretorio_faqs = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_FAQS\'>
<cfelseif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) >
	<cfset application.diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
	<cfset application.diretorio_avaliacoes = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
	<cfset application.diretorio_faqs = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
<cfelse>
	<cfset application.diretorio_anexos = 'C:\SNCI_TESTE\'>
	<cfset application.diretorio_avaliacoes = 'C:\SNCI_TESTE\'>
	<cfset application.diretorio_faqs = 'C:\SNCI_TESTE\'>
</cfif>



<cfquery name="qUsuariosSNCIProc" datasource="#application.dsn_processos#">
	SELECT pc_usu_login FROM pc_usuarios WHERE pc_usu_status='A'
</cfquery>

<cfset application.Lista_usuariosCad = UCase(ValueList(qUsuariosSNCIProc.pc_usu_login))>


<cfquery name="application.rsUsuarioParametros" datasource="#application.dsn_processos#">
	SELECT pc_usuarios.*, pc_orgaos.*, pc_perfil_tipos.* FROM pc_usuarios 
	INNER JOIN pc_orgaos ON pc_org_mcu = pc_usu_lotacao
	INNER JOIN pc_perfil_tipos on pc_perfil_tipo_id = pc_usu_perfil
	<cfif application.auxsite neq "localhost">
		WHERE pc_usu_login = '#cgi.REMOTE_USER#'
	<cfelse>
		WHERE pc_usu_login = 'CORREIOSNET\80859992'
	</cfif>
</cfquery>

<cfif Len(application.rsUsuarioParametros.pc_org_se_abrangencia) NEQ 0>
	<cfset application.seAbrangencia = ValueList(application.rsUsuarioParametros.pc_org_se_abrangencia) />
<cfelse>
	<cfset application.seAbrangencia = 0 />
</cfif>

<cfquery name="qControleAcessoParametros" datasource="#application.dsn_processos#">
	SELECT '/snci/snci_processos/'+pc_controle_acesso_pagina as pagina FROM pc_controle_acesso
	WHERE pc_controle_acesso_perfis like '%#application.rsUsuarioParametros.pc_usu_perfil#%'
</cfquery>

<cfset application.Lista_paginasPerfilUsuario = ValueList(qControleAcessoParametros.pagina)>

<cfquery name="application.rsOrgaoSubordinados" datasource="#application.dsn_processos#">
	SELECT pc_orgaos.* FROM pc_orgaos
	WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') and (pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'  
								or pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu FROM pc_orgaos WHERE pc_org_controle_interno ='N' AND pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'))
						
</cfquery>

