component {
    this.name = "SNCI - AVALIAÇÕES AUTOMATIZADAS";
    this.sessionManagement = true;
    this.clientManagement = true;
    this.sessionTimeout = createTimeSpan(0,1,0,0);
    this.applicationTimeout = createTimeSpan(0,6,0,0);
    this.setClientCookies = true;
    this.scriptProtect = "all";
    
    // Definição do datasource
    this.datasource = "DBSNCI";
    public boolean function onApplicationStart() {
        application.dsn_avaliacoes_automatizadas = "DBSNCI";
        application.SESSIONTIMEOUT = 60;
        application.auxsite = CGI.SERVER_NAME;
        application.loginCGI = CGI.REMOTE_USER;
        
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

       application.rsUsuarioParametros = queryExecute(
            "SELECT us.*, un.*, d.* 
            FROM Usuarios us
            LEFT JOIN Unidades un ON un.Und_Codigo = us.Usu_Lotacao
            INNER JOIN Diretoria d ON d.Dir_Codigo = un.Und_CodDiretoria
            WHERE trim(us.Usu_Login) = :login",
            {login = {value=local.loginUsuario, cfsqltype="cf_sql_varchar"}},
            {datasource=application.dsn_avaliacoes_automatizadas}
        );

         return true;

    }


        

   
}
