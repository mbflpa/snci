<cfquery name="qryAlteraTabela" datasource="#application.dsn_processos#">
    ALTER TABLE pc_usuarios
    ADD pc_usu_gerente BIT NOT NULL DEFAULT 0,
        pc_usu_recebeEmail_primeiraManif BIT NOT NULL DEFAULT 0,
        pc_usu_recebeEmail_segundaManif BIT NOT NULL DEFAULT 0;
</cfquery>

<cfoutput>
    Tabela alterada com sucesso!
</cfoutput>