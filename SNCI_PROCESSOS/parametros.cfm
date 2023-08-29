<cfprocessingdirective pageencoding = "utf-8">	

<cfset dsn_processos = 'DBSNCI'>
<!--- Diretório onde serão armazenados arquivos anexados a avaliações --->
<cfset auxsite =  cgi.server_name>
	  <cfif auxsite eq "intranetsistemaspe">
			<cfset diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_ANEXOS\'>
			<cfset diretorio_avaliacoes = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_AVALIACOES\'>
			<cfset diretorio_faqs = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_FAQS\'>
			<cfset url_relatorio = 'http://intranetsistemaspe/snci/GeraRelatorio/gerador/dsp'>
	  <cfelse>
			<cfset diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
			<cfset diretorio_avaliacoes = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
			<cfset diretorio_faqs = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
			<cfset url_relatorio = 'http://desenvolvimentope/snci/GeraRelatorio/gerador/dsp'>
	  </cfif>


<!--- Listas de permissões --->
<cfquery name="qUsuariosSNCIProc" datasource="#dsn_processos#">
	SELECT pc_usuarios.* FROM pc_usuarios WHERE pc_usu_status='A'
</cfquery>

<cfset Lista_usuariosCad = UCase(ValueList(qUsuariosSNCIProc.pc_usu_login))>

 <!--- Consulta Páginas por Perfil do Usuario --->
<cfquery name="rsUsuarioParametros" datasource="#dsn_processos#">
	SELECT pc_usuarios.*, pc_orgaos.*, pc_perfil_tipos.* FROM pc_usuarios 
	INNER JOIN pc_orgaos ON pc_org_mcu = pc_usu_lotacao
	INNER JOIN pc_perfil_tipos on pc_perfil_tipo_id = pc_usu_perfil
	WHERE pc_usu_login = '#cgi.REMOTE_USER#'
</cfquery>
<cfquery name="qControleAcessoParametros" datasource="#dsn_processos#">
	SELECT '/snci/snci_processos/'+pc_controle_acesso_pagina as pagina FROM pc_controle_acesso
	WHERE pc_controle_acesso_perfis like '%#rsUsuarioParametros.pc_usu_perfil#%'
</cfquery>

<cfset Lista_paginasPerfilUsuario = ValueList(qControleAcessoParametros.pagina)>

<!---Session Timeout Warning Pop up set to 1 hour--->
<cfset sessionTimeout = 60>


