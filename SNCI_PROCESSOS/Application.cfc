component {
    this.name = "SNCI-PROCESSOS";
    this.mappings["/cfcSNCI"] = expandPath("/snci/SNCI_PROCESSOS/cfc");
    this.sessionManagement = true;
    this.clientManagement = true;
    this.sessionTimeout = createTimeSpan(0,1,0,0);
    this.applicationTimeout = createTimeSpan(0,6,0,0);
    this.setClientCookies = true;
    this.scriptProtect = "all";
    
    // Definição do datasource
    this.datasource = "DBSNCI";
    
    public boolean function onApplicationStart() {
        application.dsn_processos = "DBSNCI";
        application.SESSIONTIMEOUT = 60;
        application.auxsite = CGI.SERVER_NAME;
        
        // Definição dos diretórios base
        var baseDir = "\\sac0424\SISTEMAS\SNCI\";
        var testDir = "C:\SNCI_TESTE\";
        
        if (FindNoCase("intranetsistemaspe", application.auxsite)) {
            application.diretorio_anexos = baseDir & "SNCI_PROCESSOS_ANEXOS\";
            application.diretorio_avaliacoes = baseDir & "SNCI_PROCESSOS_AVALIACOES\";
            application.diretorio_faqs = baseDir & "SNCI_PROCESSOS_FAQS\";
            application.anoPesquisaOpiniao = 2025;
            application.diretorio_busca_pdf = baseDir & "SNCI_PROCESSOS_AVALIACOES\";
        } else if (FindNoCase("homologacaope", application.auxsite) || FindNoCase("desenvolvimentope", application.auxsite)) {
            application.diretorio_anexos = baseDir & "SNCI_TESTE\";
            application.diretorio_avaliacoes = baseDir & "SNCI_TESTE\";
            application.diretorio_faqs = baseDir & "SNCI_TESTE\";
            application.anoPesquisaOpiniao = 2000;
            application.diretorio_busca_pdf = baseDir & "SNCI_PROCESSOS_AVALIACOES\";
        } else {
            application.diretorio_anexos = testDir;
            application.diretorio_avaliacoes = testDir;
            application.diretorio_faqs = testDir;
            application.anoPesquisaOpiniao = 2000;
            application.diretorio_busca_pdf = testDir;
        }
        
        return true;
    }
    
    public void function onSessionStart() {
        session.created = now();
    }
    
    public boolean function onRequestStart(required string targetPage) {
        setLocale("pt_BR");
        
        // Definição do login do usuário
        if (FindNoCase("localhost", application.auxsite)) {
            local.loginUsuario = "CORREIOSNET\80859992";
        } else {
            local.loginUsuario = CGI.REMOTE_USER;
        }
        
        // Consulta de parâmetros do usuário
        application.rsUsuarioParametros = queryExecute(
            "SELECT u.*, o.*, p.* 
            FROM pc_usuarios u
            INNER JOIN pc_orgaos o ON o.pc_org_mcu = u.pc_usu_lotacao
            INNER JOIN pc_perfil_tipos p ON p.pc_perfil_tipo_id = u.pc_usu_perfil
            WHERE u.pc_usu_login = :login",
            {login = {value=local.loginUsuario, cfsqltype="cf_sql_varchar"}},
            {datasource=application.dsn_processos}
        );
        
        // Definição da abrangência SE
        if (Len(application.rsUsuarioParametros.pc_org_se_abrangencia)) {
            application.seAbrangencia = ValueList(application.rsUsuarioParametros.pc_org_se_abrangencia);
        } else {
            application.seAbrangencia = 0;
        }
        
        // Controle de acesso
        var qControleAcessoParametros = queryExecute(
            "SELECT '/snci/snci_processos/' + pc_controle_acesso_pagina AS pagina 
            FROM pc_controle_acesso
            WHERE pc_controle_acesso_perfis LIKE :perfil",
            {perfil = {value="%#application.rsUsuarioParametros.pc_usu_perfil#%", cfsqltype="cf_sql_varchar"}},
            {datasource=application.dsn_processos}
        );
        application.Lista_paginasPerfilUsuario = ValueList(qControleAcessoParametros.pagina);
        
        // Consulta de órgãos subordinados
        application.rsOrgaoSubordinados = queryExecute(
            "SELECT o.* 
            FROM pc_orgaos o
            WHERE o.pc_org_controle_interno = 'N' 
              AND o.pc_org_Status = 'A' 
              AND (
                  o.pc_org_mcu_subord_tec = :lotacao  
                  OR o.pc_org_mcu_subord_tec IN (
                      SELECT pc_org_mcu 
                      FROM pc_orgaos 
                      WHERE pc_org_controle_interno = 'N' 
                        AND pc_org_mcu_subord_tec = :lotacao
                  )
              )",
            {lotacao = {value=application.rsUsuarioParametros.pc_usu_lotacao, cfsqltype="cf_sql_varchar"}},
            {datasource=application.dsn_processos}
        );
        
        // Hierarquia de órgãos usando CTE
        var getOrgHierarchy = queryExecute(
            "WITH OrgHierarchy AS (
                SELECT pc_org_mcu, pc_org_mcu_subord_tec
                FROM pc_orgaos
                WHERE pc_org_mcu_subord_tec = :lotacao
                UNION ALL
                SELECT o.pc_org_mcu, o.pc_org_mcu_subord_tec
                FROM pc_orgaos o
                INNER JOIN OrgHierarchy oh ON o.pc_org_mcu_subord_tec = oh.pc_org_mcu
            )
            SELECT pc_org_mcu
            FROM OrgHierarchy",
            {lotacao = {value=application.rsUsuarioParametros.pc_usu_lotacao, cfsqltype="cf_sql_varchar"}},
            {datasource=application.dsn_processos, timeout=120}
        );
        application.orgaosHierarquiaList = ValueList(getOrgHierarchy.pc_org_mcu);
        
        // Consulta de diretorias
        var getDiretoriasList = queryExecute(
            "SELECT pc_org_mcu
             FROM pc_orgaos
             WHERE pc_org_descricao_tipo_orgao = 'CORREIOS SEDE - DIRECAO' 
             AND pc_org_mcu_subord_tec = '00001003'",
            {},
            {datasource=application.dsn_processos}
        );
        
        application.listaDiretorias = ValueList(getDiretoriasList.pc_org_mcu);
        
        return true;
    }
}
