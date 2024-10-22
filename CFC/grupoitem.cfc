<cfcomponent>
    <cfprocessingdirective pageencoding = "utf-8">	
    <cffunction name="init">
        <cfreturn this>
    </cffunction>
    <!--- Este método retorna grupos --->
    <cffunction  name="pontuacao" access="remote" ReturnFormat="json" returntype="query">
        <cfargument name="anogrupo" required="true">
        <cftransaction>
           <cfquery name="rspontuacao" datasource="DBSNCI">
            SELECT PTC_Seq,PTC_Valor,PTC_Descricao,PTC_Franquia 
            FROM Pontuacao 
            WHERE PTC_Ano = '#anogrupo#'
          </cfquery>
          <cfreturn rspontuacao>
        </cftransaction>
    </cffunction>     

    <!--- Este método retorna grupos --->
    <cffunction  name="gruposverificacao" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="anogrupo" required="true">
        <cftransaction>
           <cfquery name="rsgrpverif" datasource="DBSNCI">
            SELECT Grp_Codigo, Grp_Descricao
            FROM Grupos_Verificacao
            WHERE Grp_Ano = <cfqueryparam value="#anogrupo#" cfsqltype="cf_sql_char">
          </cfquery>
          <cfreturn rsgrpverif>
        </cftransaction>
    </cffunction>    
    <!--- Este método retorna classificacao do controle --->
    <cffunction  name="classifctrl" access="remote" ReturnFormat="json" returntype="any">
         <cftransaction>
            <cfquery name="rsClassCtrl" datasource="DBSNCI">
                SELECT TPCT_ID, TPCT_DESCRICAO
                FROM UN_TIPOCONTROLETESTADO
                ORDER BY TPCT_DESCRICAO
           </cfquery>
           <cfreturn rsClassCtrl>
         </cftransaction>
     </cffunction>
    <!--- Este método retorna categoria do controle --->
    <cffunction  name="categcontrole" access="remote" ReturnFormat="json" returntype="query">
        <cftransaction>
            <cfquery name="rscategcontrole" datasource="DBSNCI">
                SELECT CTCT_ID, CTCT_DESCRICAO
                FROM UN_CATEGORIACONTROLE 
                order by CTCT_DESCRICAO
            </cfquery>
          <cfreturn rscategcontrole> 
        </cftransaction>
    </cffunction>   
        <!--- Este método retorna categoria risco --->
        <cffunction  name="categoriarisco" access="remote" ReturnFormat="json" returntype="query">
            <cftransaction>
                <cfquery name="rscategoriarisco" datasource="DBSNCI">
                    SELECT CTRC_ID, CTRC_DESCRICAO FROM UN_CATEGORIARISCO
                </cfquery>
              <cfreturn rscategoriarisco> 
            </cftransaction>
        </cffunction>   
    <!--- Este método retorna risco identificado --->
    <cffunction  name="riscoidentificado" access="remote" ReturnFormat="json" returntype="query">
        <cftransaction>
            <cfquery name="rsRiscoID" datasource="DBSNCI">
                SELECT RCID_ID, RCID_Descricao
                FROM UN_RISCOIDENTIFICADO
                order by RCID_Descricao
            </cfquery>
          <cfreturn rsRiscoID> 
        </cftransaction>
    </cffunction>   
    <!--- Este método retorna macroprocesso --->
    <cffunction  name="macroprocesso" access="remote" ReturnFormat="json" returntype="query">
        <cftransaction>
            <cfquery name="rsMacroproc" datasource="DBSNCI">
                SELECT MAPC_ID, MAPC_Descricao
                FROM UN_MACROPROCESSO
                ORDER BY MAPC_Descricao
            </cfquery>
          <cfreturn rsMacroproc> 
        </cftransaction>
    </cffunction>   
    <!--- Este método retorna gestor do processo --->
    <cffunction  name="gestorprocesso" access="remote" ReturnFormat="json" returntype="query">
        <cftransaction>
            <cfquery name="rsgespro" datasource="DBSNCI">
                SELECT DPGP_ID, DPGP_SIGLA
                FROM UN_GESTORPROCESSO_DEPARTAMENTO
                order by DPGP_SIGLA
            </cfquery>
          <cfreturn rsgespro> 
        </cftransaction>
    </cffunction>   
    <!--- Este método retorna Objetivo estratégico --->
    <cffunction  name="objetivoestrategico" access="remote" ReturnFormat="json" returntype="query">
        <cftransaction>
            <cfquery name="rsobjestrat" datasource="DBSNCI">
                SELECT OBES_ID, OBES_Descricao
                FROM UN_OBJETIVOESTRATEGICO
                order by OBES_Descricao
            </cfquery>
          <cfreturn rsobjestrat> 
        </cftransaction>
    </cffunction>    
    <!--- Este método retorna risco estratégico --->
    <cffunction  name="riscoestrategico" access="remote" ReturnFormat="json" returntype="query">
        <cftransaction>
            <cfquery name="rsRiscoID" datasource="DBSNCI">
                SELECT RCES_ID, RCES_Descricao
                FROM UN_RISCOESTRATEGICO
                order by RCES_Descricao
            </cfquery>
          <cfreturn rsRiscoID> 
        </cftransaction>
    </cffunction>   
    <!--- Este método retorna indicador estratégico --->
    <cffunction  name="indicadorestrategico" access="remote" ReturnFormat="json" returntype="query">
        <cftransaction>
            <cfquery name="rsindestrat" datasource="DBSNCI">
                SELECT IDES_ID, IDES_Descricao 
                FROM UN_INDICADORESTRATEGICO
                order by IDES_Descricao
            </cfquery>
          <cfreturn rsindestrat> 
        </cftransaction>
    </cffunction>      
    <!--- Este método retorna COSO2013 COMPONENTE --->
    <cffunction  name="componentecoso" access="remote" ReturnFormat="json" returntype="query">
        <cftransaction>
            <cfquery name="rscomponentecoso" datasource="DBSNCI">
                SELECT CPCS_ID, CPCS_DESCRICAO 
                FROM UN_COMPONENTECOSO
                order by CPCS_DESCRICAO
            </cfquery>
          <cfreturn rscomponentecoso> 
        </cftransaction>
    </cffunction>  
    <!--- Este método retorna Principios COSO2013 --->
    <cffunction  name="principioscoso" access="remote" ReturnFormat="json" returntype="query">
        <cfargument name="PRCSCPCSID" required="true">
        <cftransaction>
            <cfquery name="rsprincipioscoso" datasource="DBSNCI">
                SELECT PRCS_ID, PRCS_Descricao
                FROM UN_PRINCIPIOCOSO
                WHERE PRCS_CPCS_ID= <cfqueryparam value="#PRCSCPCSID#" cfsqltype="cf_sql_integer">
            </cfquery>
          <cfreturn rsprincipioscoso> 
        </cftransaction>
    </cffunction>     
    <!--- Este método retorna macrorocesso N1 --->
    <cffunction  name="macroprocesson1" access="remote" ReturnFormat="json" returntype="query">
        <cfargument name="PCN1MAPCID" required="true">
        <cftransaction>
            <cfquery name="rsproc01" datasource="DBSNCI">
                SELECT PCN1_ID, PCN1_Descricao
                FROM UN_PROCESSON1
                WHERE PCN1_MAPC_ID= <cfqueryparam value="#PCN1MAPCID#" cfsqltype="cf_sql_integer">
            </cfquery>
          <cfreturn rsproc01> 
        </cftransaction>
    </cffunction>     
    <!--- Este método retorna macrorocesso N2 --->
    <cffunction  name="macroprocesson2" access="remote" ReturnFormat="json" returntype="query">
        <cfargument name="PCN1MAPCID" required="true">
        <cfargument name="PCN1ID" required="true">
        <cftransaction>
            <cfquery name="rsproc02" datasource="DBSNCI">
                SELECT PCN2_ID, PCN2_Descricao
                FROM UN_PROCESSON2
                WHERE 
                PCN2_PCN1_MAPC_ID=<cfqueryparam value="#PCN1MAPCID#" cfsqltype="cf_sql_integer"> AND 
                PCN2_PCN1_ID=<cfqueryparam value="#PCN1ID#" cfsqltype="cf_sql_integer">
            </cfquery>
          <cfreturn rsproc02> 
        </cftransaction>
    </cffunction>    
    <!--- Este método retorna macrorocesso N3 --->
    <cffunction  name="macroprocesson3" access="remote" ReturnFormat="json" returntype="query">
        <cfargument name="PCN3PCN2PCN1MAPCID" required="true">
        <cfargument name="PCN3PCN2PCN1ID" required="true">
        <cfargument name="PCN3PCN2ID" required="true">
        <cftransaction>
            <cfquery name="rsproc03" datasource="DBSNCI">
            SELECT PCN3_ID, PCN3_Descricao
            FROM UN_PROCESSON3
            WHERE 
            PCN3_PCN2_PCN1_MAPC_ID=<cfqueryparam value="#PCN3PCN2PCN1MAPCID#" cfsqltype="cf_sql_integer"> AND 
            PCN3_PCN2_PCN1_ID=<cfqueryparam value="#PCN3PCN2PCN1ID#" cfsqltype="cf_sql_integer"> and 
            PCN3_PCN2_ID=<cfqueryparam value="#PCN3PCN2ID#" cfsqltype="cf_sql_integer">
            </cfquery>
          <cfreturn rsproc03> 
        </cftransaction>
    </cffunction>                           
<!--- 
<!--- inclusao de transportadora  --->
    <cffunction name="inserir_transportadora"   access="remote" returntype="any">
        <cfset nome       = #form.nometransportadora#>
        <cfset endereco   = #form.endereco#>
        <cfset cidade     = #form.cidade#>
        <cfset estado     = #form.estados#>
        <cfset erro = 'V'>
        <cftry>
            <cfquery name="rsteste" datasource="db_andes">
                INSERT INTO transportadoras (nometransportadora,endereco,cidade,estadoID)
                values
                ('#nome#','#endereco#','#cidade#', #estado#)
            </cfquery>
            <cfcatch type="any">
                <cfset erro = 'F'>
            </cfcatch>
        </cftry>
        <cfreturn #erro#>
    </cffunction>
    <!--- alterar de transportadora --->
    <cffunction name="alterar_transportadora"   access="remote" returntype="any">
        <cfargument name="transportadoraID" required="true">
        <cfargument name="nometransportadora" type="string" required="true">
        <cfargument name="endereco" required="true">
        <cfargument name="telefone" required="false">
        <cfargument name="cidade" required="true">
        <cfargument name="estados" required="true">
        <cfargument name="cep" required="false">
        <cfargument name="cnpj" required="false">

        <cfset arguments.transportadoraID  = #form.transportadoraID#>
        <cfset arguments.nometransportadora  = #form.nometransportadora#>
        <cfset arguments.endereco  = #form.endereco#>
        <cfset arguments.cidade  = #form.cidade#>
        <cfset arguments.estados  = #form.estados# >
        <cfset arguments.cep  = 52090260>
        <cfset arguments.telefone  = 32686435>
        <cfset arguments.cnpj  = 33370818434>
        <cfset erro = 'V'>
        <cftry>
            <cfquery datasource="db_andes">
                update transportadoras set 
                        nometransportadora = <cfqueryparam value="#arguments.nometransportadora#" cfsqltype="CF_SQL_VARCHAR">, 
                        endereco = <cfqueryparam value="#arguments.endereco#" cfsqltype="CF_SQL_VARCHAR">,
                        telefone = <cfqueryparam value="#arguments.telefone#" cfsqltype="CF_SQL_VARCHAR">,
                        cidade = <cfqueryparam value="#arguments.cidade#" cfsqltype="CF_SQL_VARCHAR">, 
                        estadoID = <cfqueryparam value="#arguments.estados#" cfsqltype="cf_sql_integer">, 
                        cep = <cfqueryparam value="#arguments.cep#" cfsqltype="CF_SQL_VARCHAR">, 
                        cnpj = <cfqueryparam value="#arguments.cnpj#" cfsqltype="CF_SQL_VARCHAR">
                where 
                        transportadoraID = <cfqueryparam value="#arguments.transportadoraID#" cfsqltype="cf_sql_integer">

            </cfquery>
            <cfcatch type="any">
                <cfset erro = 'F'>
            </cfcatch>
        </cftry>
        <cfreturn #erro#>
    </cffunction>

    <cffunction name="excluir_transportadora"   access="remote" returntype="any">
        <cfargument name="transportadoraID" required="true">
        <cfset arguments.transportadoraID  = #form.transportadoraID#>
        <cfset erro = 'V'>
        <cftry>
            <cfquery datasource="db_andes">
               DELETE FROM transportadoras
               where 
               transportadoraID = <cfqueryparam value="#arguments.transportadoraID#" cfsqltype="cf_sql_integer">

            </cfquery>
            <cfcatch type="any">
                <cfset erro = 'F'>
            </cfcatch>
        </cftry>
        <cfreturn #erro#>
    </cffunction>

    <cffunction  name="retornarCategoria" access="remote" returntype="query">
         <cfquery name="rsCategoria" datasource="db_andes">
            SELECT categoriaID, nomecategoria FROM categorias
        </cfquery>
        <cfset categ = ''>
        <cfset nomecateg = ''>
        <cfoutput query="rsCategoria">
            <cfif categ eq ''>
                <cfset categ = #rsCategoria.categoriaID#>
                <cfset nomecateg = #rsCategoria.nomecategoria#>
            <cfelse>
                <cfset categ = categ & ',' & #rsCategoria.categoriaID#>
                <cfset nomecateg = nomecateg & ',' & #rsCategoria.nomecategoria#>
            </cfif>
        </cfoutput>
        <cfreturn rsCategoria>
    </cffunction>
    <!--- este método retorna dados Produtos --->
    <cffunction  name="retornarProdutos" access="remote" ReturnFormat="json" returntype="query">
       <!--- <cfargument name="categoriaID"  required="yes"> --->
        <cftransaction>
        <cfquery name="listaProdutos" datasource="db_andes">
           SELECT produtoID, nomeproduto FROM produtos
          
        </cfquery>
        <cfreturn listaProdutos> 
        </cftransaction>
    </cffunction>

    <!--- este método retorna dados federativo --->
    <cffunction  name="retornarEstados"  access="remote" returntype="Query">
        <cfheader name="Content-Type" value="application/json">
        <cfquery name="qEstados" datasource="db_andes">
            select * from estados
        </cfquery>
        <cfreturn #serializeJSON(qEstados, 'STRUCT')#>
    </cffunction>

    <!--- este método retorna dados transportadoras --->
    <cffunction  name="retornarTransportadoras"  access="remote" returntype="any">
        <cfargument name="codigo"  required="yes">
        
        <cfquery name="listaTransportadoras" datasource="db_andes">
            select * from transportadoras
    
            <cfif arguments.codigo neq 0>
                where transportadoraID = <cfqueryparam value="#arguments.codigo#" cfsqltype="cf_sql_integer">
            </cfif>

        </cfquery>
        <cfreturn listaTransportadoras>
    </cffunction>
    --->    
</cfcomponent>