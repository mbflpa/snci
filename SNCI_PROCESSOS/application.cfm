<cfprocessingdirective pageencoding="utf-8">

<cfset SetLocale("pt_BR")>

<cfapplication 
    name="conteudo" 
    sessionmanagement="Yes" 
    clientmanagement="Yes" 
    sessiontimeout="#CreateTimeSpan(0,1,0,0)#" 
    applicationtimeout="#CreateTimeSpan(0,6,0,0)#">

<cfset application.dsn_processos = "DBSNCI">
<cfset application.SESSIONTIMEOUT = 60>

<cfset application.auxsite = CGI.SERVER_NAME>

<cfscript>
    // Definição dos diretórios base
    baseDir = "\\sac0424\SISTEMAS\SNCI\";
    testDir = "C:\SNCI_TESTE\";
    
    if (FindNoCase("intranetsistemaspe", application.auxsite)) {
        application.diretorio_anexos = baseDir & "SNCI_PROCESSOS_ANEXOS\";
        application.diretorio_avaliacoes = baseDir & "SNCI_PROCESSOS_AVALIACOES\";
        application.diretorio_faqs = baseDir & "SNCI_PROCESSOS_FAQS\";
    } else if (FindNoCase("homologacaope", application.auxsite) || FindNoCase("desenvolvimentope", application.auxsite)) {
        application.diretorio_anexos = baseDir & "SNCI_TESTE\";
        application.diretorio_avaliacoes = baseDir & "SNCI_TESTE\";
        application.diretorio_faqs = baseDir & "SNCI_TESTE\";
    } else {
        application.diretorio_anexos = testDir;
        application.diretorio_avaliacoes = testDir;
        application.diretorio_faqs = testDir;
    }
</cfscript>


<cfif FindNoCase("localhost", application.auxsite)>
    <cfset loginUsuario = "CORREIOSNET\80859992">
<cfelse>
    <cfset loginUsuario = CGI.REMOTE_USER>
</cfif>

<cfquery name="application.rsUsuarioParametros" datasource="#application.dsn_processos#">
    SELECT u.*, o.*, p.* 
    FROM pc_usuarios u
    INNER JOIN pc_orgaos o ON o.pc_org_mcu = u.pc_usu_lotacao
    INNER JOIN pc_perfil_tipos p ON p.pc_perfil_tipo_id = u.pc_usu_perfil
    WHERE u.pc_usu_login = <cfqueryparam value="#loginUsuario#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif Len(application.rsUsuarioParametros.pc_org_se_abrangencia) NEQ 0>
    <cfset application.seAbrangencia = ValueList(application.rsUsuarioParametros.pc_org_se_abrangencia)>
<cfelse>
    <cfset application.seAbrangencia = 0>
</cfif>

<cfquery name="qControleAcessoParametros" datasource="#application.dsn_processos#">
    SELECT '/snci/snci_processos/' + pc_controle_acesso_pagina AS pagina 
    FROM pc_controle_acesso
    WHERE pc_controle_acesso_perfis LIKE <cfqueryparam value="%#application.rsUsuarioParametros.pc_usu_perfil#%" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset application.Lista_paginasPerfilUsuario = ValueList(qControleAcessoParametros.pagina)>

<cfquery name="application.rsOrgaoSubordinados" datasource="#application.dsn_processos#">
    SELECT o.* 
    FROM pc_orgaos o
    WHERE o.pc_org_controle_interno = 'N' 
      AND o.pc_org_Status = 'A' 
      AND (
          o.pc_org_mcu_subord_tec = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">  
          OR o.pc_org_mcu_subord_tec IN (
              SELECT pc_org_mcu 
              FROM pc_orgaos 
              WHERE pc_org_controle_interno = 'N' 
                AND pc_org_mcu_subord_tec = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
          )
      )
</cfquery>

<cfquery name="getOrgHierarchy" datasource="#application.dsn_processos#" timeout="120">
    WITH OrgHierarchy AS (
        SELECT pc_org_mcu, pc_org_mcu_subord_tec
        FROM pc_orgaos
        WHERE pc_org_mcu_subord_tec = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
        UNION ALL
        SELECT o.pc_org_mcu, o.pc_org_mcu_subord_tec
        FROM pc_orgaos o
        INNER JOIN OrgHierarchy oh ON o.pc_org_mcu_subord_tec = oh.pc_org_mcu
    )
    SELECT pc_org_mcu
    FROM OrgHierarchy
</cfquery>

<cfset application.orgaosHierarquiaList = ValueList(getOrgHierarchy.pc_org_mcu)>

<cfset application.anoPesquisaOpiniao = 2019>


