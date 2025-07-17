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

        
      
        
        return true;
    }

   
}
