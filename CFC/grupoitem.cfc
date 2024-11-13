<cfcomponent>
    <cfprocessingdirective pageencoding = "utf-8">	
    <cffunction name="init">
        <cfreturn this>
    </cffunction>
    <!--- Este método retorna se item já está em uso --->
    <cffunction  name="verificarUsoItem" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="ano" required="true">
        <cfargument name="grupo" required="true">
        <cfargument name="itm" required="true">  
        <cfargument name="modal" required="true"> 
        <cftransaction>
           <cfquery name="rsUsoItem" datasource="DBSNCI">
                SELECT  top 1 RIP_NumInspecao
                FROM Resultado_Inspecao
                INNER JOIN Inspecao ON INP_NumInspecao = RIP_NumInspecao
                WHERE RIP_Ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_char"> and 
                    RIP_NumGrupo = <cfqueryparam value="#grupo#" cfsqltype="cf_sql_integer"> and
                    RIP_NumItem = <cfqueryparam value="#itm#" cfsqltype="cf_sql_integer"> and 
                    INP_Modalidade = <cfqueryparam value="#modal#" cfsqltype="cf_sql_char">
                    group by RIP_NumInspecao 
          </cfquery>
          <cfreturn rsUsoItem>
        </cftransaction>
    </cffunction>     
    <!--- Este método retorna pontuação --->
    <cffunction  name="pontuacao" access="remote" ReturnFormat="json" returntype="query">
        <cfargument name="anogrupo" required="true">
        <cftransaction>
           <cfquery name="rspontuacao" datasource="DBSNCI">
            SELECT PTC_Seq,PTC_Valor,trim(PTC_Descricao),PTC_Franquia 
            FROM Pontuacao 
            WHERE PTC_Ano = '#anogrupo#'
          </cfquery>
          <cfreturn rspontuacao>
        </cftransaction>
    </cffunction> 
    <!--- Este método retornar dados para alteração de item  --->
    <cffunction  name="alteraritens" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="ano" required="true">
        <cfargument name="grupo" required="true">
        <cfargument name="itm" required="true">  
        <cfargument name="modal" required="true">   
           
        <cftransaction>
            <cfquery name="rsAlterarITM" datasource="DBSNCI">
                SELECT Itn_TipoUnidade,Itn_Descricao,Itn_Manchete,Itn_ValorDeclarado,Itn_ValidacaoObrigatoria,Itn_Orientacao,Itn_Amostra,Itn_Norma,Itn_PreRelato,Itn_OrientacaoRelato,Itn_ClassificacaoControle,Itn_ControleTestado,Itn_CategoriaControle,Itn_RiscoIdentificado,Itn_RiscoIdentificadoOutros,Itn_MacroProcesso,Itn_ProcessoN1,Itn_ProcessoN1NaoAplicar,Itn_ProcessoN2,Itn_ProcessoN3,Itn_ProcessoN3Outros,Itn_GestorProcesso,Itn_ObjetivoEstrategico,Itn_RiscoEstrategico,Itn_IndicadorEstrategico,Itn_Coso2013Componente,Itn_Coso2013Principios,Itn_PTC_Seq
                FROM Itens_Verificacao
                WHERE Itn_Ano=<cfqueryparam value="#ano#" cfsqltype="cf_sql_char"> AND 
                Itn_Modalidade=<cfqueryparam value="#modal#" cfsqltype="cf_sql_char"> AND 
                Itn_NumGrupo=<cfqueryparam value="#grupo#" cfsqltype="cf_sql_integer"> AND 
                Itn_NumItem=<cfqueryparam value="#itm#" cfsqltype="cf_sql_integer">
                ORDER BY Itn_NumGrupo,Itn_NumItem
            </cfquery>
            <cfreturn rsAlterarITM>
        </cftransaction>
    </cffunction>      
    <!--- Este método retorna Modalidade --->
    <cffunction  name="modalidade" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="ano" required="true">
        <cfargument name="grupo" required="true">
        <cfargument name="itm" required="true">       
        <cftransaction>
            <cfquery name="rsModalidade" datasource="DBSNCI">
                SELECT TUI_Modalidade,
                CASE 
                    WHEN TUI_Modalidade = 0 THEN 'Presencial'
                    WHEN TUI_Modalidade = 1 THEN 'A Distância'
                    ELSE 'Mista'
                END as nome_modalidade
                FROM Itens_Verificacao 
                INNER JOIN TipoUnidade_ItemVerificacao ON TUI_GrupoItem = Itn_NumGrupo and 
                TUI_ItemVerif = Itn_NumItem AND TUI_Ano = Itn_Ano
                WHERE TUI_Ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_char"> and 
                Itn_NumGrupo = <cfqueryparam value="#grupo#" cfsqltype="cf_sql_integer"> and
                Itn_NumItem = <cfqueryparam value="#itm#" cfsqltype="cf_sql_integer"> 
                group by TUI_Modalidade
                order by TUI_Modalidade
            </cfquery>
            <cfreturn rsModalidade>
        </cftransaction>
    </cffunction>     
    <!--- Este método retorna itens --->
    <cffunction  name="itensverificacao" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="ano" required="true">
        <cfargument name="grupo" required="true">
        <cftransaction>
           <cfquery name="rsitmverif" datasource="DBSNCI">
            SELECT Itn_NumItem, trim(Itn_Descricao)
            FROM Itens_Verificacao
            WHERE Itn_Ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_char"> and 
            Itn_NumGrupo = <cfqueryparam value="#grupo#" cfsqltype="cf_sql_integer"> 
            group by Itn_NumItem,Itn_Descricao
            order by Itn_NumItem,Itn_Descricao
          </cfquery>
          <cfreturn rsitmverif>
        </cftransaction>
    </cffunction>  
    <!--- Este método retorna grupos --->
    <cffunction  name="gruposverificacao" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="anogrupo" required="true">
        <cftransaction>
           <cfquery name="rsgrpverif" datasource="DBSNCI">
                SELECT Grp_Codigo,trim(Grp_Descricao),Grp_Ano
                FROM Grupos_Verificacao INNER JOIN Itens_Verificacao ON (Grp_Ano = Itn_Ano) AND (Grp_Codigo = Itn_NumGrupo)
                GROUP BY Grp_Ano,Grp_Codigo, Grp_Descricao
                HAVING Grp_Ano=<cfqueryparam value="#anogrupo#" cfsqltype="cf_sql_char">
                ORDER BY Grp_Codigo, Grp_Descricao
          </cfquery>
          <cfreturn rsgrpverif>
        </cftransaction>
    </cffunction>    
    <!--- Este método retorna classificacao do controle --->
    <cffunction  name="classifctrl" access="remote" ReturnFormat="json" returntype="any">
         <cftransaction>
            <cfquery name="rsClassCtrl" datasource="DBSNCI">
                SELECT TPCT_ID, trim(TPCT_DESCRICAO)
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
                SELECT CTCT_ID, trim(CTCT_DESCRICAO)
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
                    SELECT CTRC_ID, trim(CTRC_DESCRICAO)
                    FROM UN_CATEGORIARISCO
                </cfquery>
              <cfreturn rscategoriarisco> 
            </cftransaction>
        </cffunction>   
    <!--- Este método retorna risco identificado --->
    <cffunction  name="riscoidentificado" access="remote" ReturnFormat="json" returntype="query">
        <cftransaction>
            <cfquery name="rsRiscoID" datasource="DBSNCI">
                SELECT RCID_ID, trim(RCID_Descricao)
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
                SELECT MAPC_ID, trim(MAPC_Descricao)
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
                SELECT DPGP_ID, trim(DPGP_SIGLA)
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
                SELECT OBES_ID, trim(OBES_Descricao)
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
                SELECT RCES_ID, trim(RCES_Descricao)
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
                SELECT IDES_ID, trim(IDES_Descricao) 
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
                SELECT CPCS_ID, trim(CPCS_DESCRICAO)
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
                SELECT PRCS_ID, trim(PRCS_Descricao)
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
                SELECT PCN1_ID, trim(PCN1_Descricao)
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
                SELECT PCN2_ID, trim(PCN2_Descricao)
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
            SELECT PCN3_ID, trim(PCN3_Descricao)
            FROM UN_PROCESSON3
            WHERE 
            PCN3_PCN2_PCN1_MAPC_ID=<cfqueryparam value="#PCN3PCN2PCN1MAPCID#" cfsqltype="cf_sql_integer"> AND 
            PCN3_PCN2_PCN1_ID=<cfqueryparam value="#PCN3PCN2PCN1ID#" cfsqltype="cf_sql_integer"> and 
            PCN3_PCN2_ID=<cfqueryparam value="#PCN3PCN2ID#" cfsqltype="cf_sql_integer">
            </cfquery>
          <cfreturn rsproc03> 
        </cftransaction>
    </cffunction>                           
    <!--- incluir/alterar/excluir Classificação do Controle  --->
    <cffunction name="cad_classifctrl" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="tpctid" required="true">
        <cfargument name="tpctdesc" required="true">
        
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(TPCT_ID)+1 as novoid 
                    FROM UN_TIPOCONTROLETESTADO
                </cfquery>
                <cfquery datasource="DBSNCI">
                    insert into UN_TIPOCONTROLETESTADO 
                        (TPCT_ID,TPCT_DESCRICAO,TPCT_username,TPCT_DtCriar,TPCT_DtAlter)
                    values 
                        (#rsNovo.novoid#,<cfqueryparam value="#tpctdesc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_TIPOCONTROLETESTADO set
                        TPCT_DESCRICAO = <cfqueryparam value="#tpctdesc#" cfsqltype="cf_sql_char">
                        ,TPCT_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,TPCT_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        TPCT_ID = <cfqueryparam value="#tpctid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExiste">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_ClassificacaoControle In ('#tpctid#')
                </cfquery>
                <cfif rsExiste.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_TIPOCONTROLETESTADO 
                        where 
                            TPCT_ID = <cfqueryparam value="#tpctid#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao possui a Classificação Selecionada!'>                     
                </cfif> 
            </cfif>
            <cfcatch type="any">
                <cfif acao eq 'inc'>
                    <cfset ret = 'Inclusão Falhou!'>  
                <cfelseif acao eq 'alt'>
                    <cfset ret = 'Alteração Falhou!'>  
                <cfelse>
                    <cfset ret = 'Exclusão Falhou!'>  
                </cfif>
            </cfcatch>
        </cftry>
        <cfreturn #ret#>
    </cffunction>
    <!--- incluir/alterar/excluir Categoria do Controle  --->
    <cffunction name="cad_categctrl" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="ctctid" required="true">
        <cfargument name="ctctdesc" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(CTCT_ID)+1 as novoid 
                    FROM UN_CATEGORIACONTROLE
                </cfquery>
                <cfquery datasource="DBSNCI">
                    insert into UN_CATEGORIACONTROLE 
                        (CTCT_ID,CTCT_DESCRICAO,CTCT_username,CTCT_DtCriar,CTCT_DtAlter)
                    values 
                        (#rsNovo.novoid#,<cfqueryparam value="#ctctdesc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_CATEGORIACONTROLE set
                         CTCT_DESCRICAO = <cfqueryparam value="#ctctdesc#" cfsqltype="cf_sql_char">
                        ,CTCT_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,CTCT_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        CTCT_ID = <cfqueryparam value="#ctctid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExiste">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_CategoriaControle In ('#ctctid#')
                </cfquery>
                <cfif rsExiste.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_CATEGORIACONTROLE 
                        where 
                            CTCT_ID = <cfqueryparam value="#ctctid#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao possui a Classificação Selecionada!'>                     
                </cfif> 
            </cfif>
            <cfcatch type="any">
                <cfif acao eq 'inc'>
                    <cfset ret = 'Inclusão Falhou!'>  
                <cfelseif acao eq 'alt'>
                    <cfset ret = 'Alteração Falhou!'>  
                <cfelse>
                    <cfset ret = 'Exclusão Falhou!'>  
                </cfif>
            </cfcatch>
        </cftry>
        <cfreturn #ret#>
    </cffunction>
    <!--- incluir/alterar/excluir Categoria do Controle  --->
    <cffunction name="cad_categrisco" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="ctrcid" required="true">
        <cfargument name="ctrcdesc" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(CTRC_ID)+1 as novoid 
                    FROM UN_CATEGORIARISCO
                </cfquery>
                <cfquery datasource="DBSNCI">
                    insert into UN_CATEGORIARISCO 
                        (CTRC_ID,CTRC_DESCRICAO,CTRC_username,CTRC_DtCriar,CTRC_DtAlter)
                    values 
                        (#rsNovo.novoid#,<cfqueryparam value="#ctrcdesc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_CATEGORIARISCO set
                         CTRC_DESCRICAO = <cfqueryparam value="#ctrcdesc#" cfsqltype="cf_sql_char">
                        ,CTRC_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,CTRC_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        CTRC_ID = <cfqueryparam value="#ctrcid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExiste">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_RiscoIdentificado In ('#ctrcid#')
                </cfquery>
                <cfif rsExiste.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_CATEGORIARISCO 
                        where 
                            CTRC_ID = <cfqueryparam value="#ctrcid#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao possui a Classificação Selecionada!'>                     
                </cfif> 
            </cfif>
            <cfcatch type="any">
                <cfif acao eq 'inc'>
                    <cfset ret = 'Inclusão Falhou!'>  
                <cfelseif acao eq 'alt'>
                    <cfset ret = 'Alteração Falhou!'>  
                <cfelse>
                    <cfset ret = 'Exclusão Falhou!'>  
                </cfif>
            </cfcatch>
        </cftry>
        <cfreturn #ret#>
    </cffunction>    
</cfcomponent>