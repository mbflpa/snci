<cfcomponent>
<cfprocessingdirective pageencoding = "utf-8">	
    
    <cffunction name="cadastrarNota" access="remote" returntype="struct" output="false" hint="Cadastra uma nova nota de versão">
        <cfargument name="versao" type="string" required="true" hint="Número da versão, ex.: 2.1.0">
        <cfargument name="dataLancamento" type="date" required="true" hint="Data de lançamento da versão">
        <cfargument name="novidades" type="string" required="false" hint="Descrição das novidades">
        <cfargument name="melhorias" type="string" required="false" hint="Descrição das melhorias">
        <cfargument name="correcoes" type="string" required="false" hint="Descrição das correções">
        <cfargument name="outrasAlteracoes" type="string" required="false" hint="Descrição de outras alterações">

        <cfset var result = {success=false, message=""}>

        <cftry>
            <cfquery name="insereNota" datasource="#application.dsn_processos#">
                INSERT INTO [pc_notasVersao] (
                    [pc_notasVersao_versao],
                    [pc_notasVersao_data_lancamento],
                    [pc_notasVersao_novidades],
                    [pc_notasVersao_melhorias],
                    [pc_notasVersao_correcoes],
                    [pc_notasVersao_observacoes],
                    [pc_notasVersao_data_criacao],
                    [pc_notasVersao_data_atualizacao]
                ) VALUES (
                    <cfqueryparam value="#arguments.versao#" cfsqltype="cf_sql_varchar" >,
                    <cfqueryparam value="#arguments.dataLancamento#" cfsqltype="cf_sql_date">,
                    <cfqueryparam value="#arguments.novidades#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(arguments.novidades))#">,
                    <cfqueryparam value="#arguments.melhorias#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(arguments.melhorias))#">,
                    <cfqueryparam value="#arguments.correcoes#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(arguments.correcoes))#">,
                    <cfqueryparam value="#arguments.outrasAlteracoes#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(arguments.outrasAlteracoes))#">,
                    GETDATE(),
                    GETDATE()
                )
            </cfquery>

            <cfset result.success = true>
            <cfset result.message = "Nota de versão cadastrada com sucesso.">
            
            <cfcatch type="any">
                <cfset result.message = "Erro ao cadastrar a nota de versão: #cfcatch.message#">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <cffunction name="listarNotas" access="remote" returntype="array" returnformat="json" output="false" hint="Lista todas as notas de versão">
        <cfset var notasArray = []>
        <cftry>
            <cfquery name="rsListNotas" datasource="#application.dsn_processos#">
                SELECT 
                    [pc_notasVersao_id],
                    [pc_notasVersao_versao],
                    [pc_notasVersao_data_lancamento],
                    [pc_notasVersao_novidades],
                    [pc_notasVersao_melhorias],
                    [pc_notasVersao_correcoes],
                    [pc_notasVersao_observacoes],
                    [pc_notasVersao_data_criacao],
                    [pc_notasVersao_data_atualizacao]
                FROM [pc_notasVersao]
                ORDER BY [pc_notasVersao_data_lancamento] DESC
            </cfquery>
            
            <cfloop query="rsListNotas">
                <cfset var nota = {}>
                <cfset nota.PC_NOTASVERSAO_ID = rsListNotas.pc_notasVersao_id>
                <cfset nota.PC_NOTASVERSAO_VERSAO = rsListNotas.pc_notasVersao_versao>
                <cfset nota.PC_NOTASVERSAO_DATA_LANCAMENTO = DateFormat(rsListNotas.pc_notasVersao_data_lancamento, "dd/mm/yyyy")>
                <cfset nota.PC_NOTASVERSAO_NOVIDADES = rsListNotas.pc_notasVersao_novidades>
                <cfset nota.PC_NOTASVERSAO_MELHORIAS = rsListNotas.pc_notasVersao_melhorias>
                <cfset nota.PC_NOTASVERSAO_CORRECOES = rsListNotas.pc_notasVersao_correcoes>
                <cfset nota.PC_NOTASVERSAO_OBSERVACOES = rsListNotas.pc_notasVersao_observacoes>
                <cfset nota.PC_NOTASVERSAO_DATA_CRIACAO = DateFormat(rsListNotas.pc_notasVersao_data_criacao, "dd/mm/yyyy")>
                <cfset nota.PC_NOTASVERSAO_DATA_ATUALIZACAO = DateFormat(rsListNotas.pc_notasVersao_data_atualizacao, "dd/mm/yyyy")>
                
                <cfset ArrayAppend(notasArray, nota)>
            </cfloop>
            
            <cfcatch type="any">
                <!--- Caso ocorra um erro, retorna um array vazio ou uma mensagem de erro --->
                <cfset notasArray = []>
                <cfset arrayAppend(notasArray, {error=true, message="Erro ao listar as notas de versão: #cfcatch.message#"})>
            </cfcatch>
        </cftry>
        
        <cfreturn notasArray>
    </cffunction>
 
    <cffunction name="atualizarNota" access="remote" returntype="struct" output="false" hint="Atualiza uma nota de versão existente">
        <cfargument name="id" type="numeric" required="true" hint="ID da nota de versão">
        <cfargument name="versao" type="string" required="true" hint="Número da versão, ex.: 2.1.0">
        <cfargument name="dataLancamento" type="date" required="true" hint="Data de lançamento da versão">
        <cfargument name="novidades" type="string" required="false" hint="Descrição das novidades">
        <cfargument name="melhorias" type="string" required="false" hint="Descrição das melhorias">
        <cfargument name="correcoes" type="string" required="false" hint="Descrição das correções">
        <cfargument name="outrasAlteracoes" type="string" required="false" hint="Descrição de outras alterações">

        <cfset var result = {success=false, message=""}>

        <cftry>
            <cfquery name="atualizaNota" datasource="#application.dsn_processos#">
                UPDATE [pc_notasVersao]
                SET 
                    [pc_notasVersao_versao] = <cfqueryparam value="#arguments.versao#" cfsqltype="cf_sql_varchar" maxlength="10">,
                    [pc_notasVersao_data_lancamento] = <cfqueryparam value="#arguments.dataLancamento#" cfsqltype="cf_sql_date">,
                    [pc_notasVersao_novidades] = <cfqueryparam value="#arguments.novidades#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(arguments.novidades))#">,
                    [pc_notasVersao_melhorias] = <cfqueryparam value="#arguments.melhorias#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(arguments.melhorias))#">,
                    [pc_notasVersao_correcoes] = <cfqueryparam value="#arguments.correcoes#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(arguments.correcoes))#">,
                    [pc_notasVersao_observacoes] = <cfqueryparam value="#arguments.outrasAlteracoes#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(arguments.outrasAlteracoes))#">,
                    [pc_notasVersao_data_atualizacao] = GETDATE()
                WHERE [pc_notasVersao_id] = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.success = true>
            <cfset result.message = "Nota de versão atualizada com sucesso.">
            
            <cfcatch type="any">
                <cfset result.message = "Erro ao atualizar a nota de versão: #cfcatch.message#">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    
    <cffunction name="deletarNota" access="remote" returntype="struct" output="false" hint="Deleta uma nota de versão">
        <cfargument name="id" type="numeric" required="true" hint="ID da nota de versão">

        <cfset var result = {success=false, message=""}>

        <cftry>
            <cfquery name="deletaNota" datasource="#application.dsn_processos#">
                DELETE FROM [pc_notasVersao]
                WHERE [pc_notasVersao_id] = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.success = true>
            <cfset result.message = "Nota de versão deletada com sucesso.">
            
            <cfcatch type="any">
                <cfset result.message = "Erro ao deletar a nota de versão: #cfcatch.message#">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <cffunction name="listarNotaPorId" access="remote" returntype="struct" output="false" hint="Lista uma nota de versão por ID" returnformat="json">
        <cfargument name="id" type="numeric" required="true" hint="ID da nota de versão">

        <cfset var result = StructNew()>
        <cfset result["success"] = false>
        <cfset result["dados"] = StructNew()>

        <cftry>
            <cfquery name="rsNota" datasource="#application.dsn_processos#">
                SELECT 
                    [pc_notasVersao_id],
                    [pc_notasVersao_versao],
                    [pc_notasVersao_data_lancamento],
                    [pc_notasVersao_novidades],
                    [pc_notasVersao_melhorias],
                    [pc_notasVersao_correcoes],
                    [pc_notasVersao_observacoes]
                FROM [pc_notasVersao]
                WHERE [pc_notasVersao_id] = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif rsNota.recordCount EQ 1>
                <cfset result["success"] = true>
                <cfset result["dados"] = {
                    "PC_NOTASVERSAO_ID" = rsNota.pc_notasVersao_id,
                    "PC_NOTASVERSAO_VERSAO" = rsNota.pc_notasVersao_versao,
                    "PC_NOTASVERSAO_DATA_LANCAMENTO" = DateFormat(rsNota.pc_notasVersao_data_lancamento, "yyyy-mm-dd"),
                    "PC_NOTASVERSAO_NOVIDADES" = rsNota.pc_notasVersao_novidades,
                    "PC_NOTASVERSAO_MELHORIAS" = rsNota.pc_notasVersao_melhorias,
                    "PC_NOTASVERSAO_CORRECOES" = rsNota.pc_notasVersao_correcoes,
                    "PC_NOTASVERSAO_OBSERVACOES" = rsNota.pc_notasVersao_observacoes
                }>
            <cfelse>
                <cfset result["message"] = "Nota de versão não encontrada.">
            </cfif>

            <cfcatch type="any">
                <cfset result["message"] = "Erro ao listar a nota de versão: #cfcatch.message#">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>