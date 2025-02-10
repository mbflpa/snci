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
                SELECT Itn_TipoUnidade,Itn_Descricao,Itn_Manchete,Itn_ValorDeclarado,Itn_ValidacaoObrigatoria,Itn_Orientacao,Itn_Amostra,Itn_Norma,Itn_PreRelato,Itn_OrientacaoRelato,Itn_ClassificacaoControle,Itn_ControleTestado,Itn_CategoriaControle,Itn_RiscoIdentificado,Itn_RiscoIdentificadoOutros,Itn_MacroProcesso,Itn_ProcessoN1,Itn_ProcessoN1NaoAplicar,Itn_ProcessoN2,Itn_ProcessoN3,Itn_ProcessoN3Outros,Itn_GestorProcessoDir,Itn_GestorProcessoDepto,Itn_ObjetivoEstrategico,Itn_RiscoEstrategico,Itn_IndicadorEstrategico,Itn_Coso2013Componente,Itn_Coso2013Principios,Itn_PTC_Seq
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
                SELECT Grp_Codigo,trim(Grp_Descricao),Grp_Ano,Itn_Ano
                FROM Grupos_Verificacao 
                left JOIN Itens_Verificacao ON (Grp_Ano = Itn_Ano) AND (Grp_Codigo = Itn_NumGrupo)
                GROUP BY Grp_Ano,Grp_Codigo, Grp_Descricao,Itn_Ano
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
    <cffunction  name="gestordiretoria" access="remote" ReturnFormat="json" returntype="query">
        <cftransaction>
            <cfquery name="rsgesdir" datasource="DBSNCI">
                SELECT DIGP_ID, trim(DIGP_SIGLA)
                FROM UN_GESTORPROCESSO_DIRETORIA
                order by DIGP_SIGLA
            </cfquery>
          <cfreturn rsgesdir> 
        </cftransaction>
    </cffunction>      
    <!--- Este método retorna gestor do processo --->
    <cffunction  name="gestorprocesso" access="remote" ReturnFormat="json" returntype="query">
        <cfargument name="digpid" required="true">
        <cftransaction>
            <cfquery name="rsgesdepto" datasource="DBSNCI">
                SELECT DPGP_ID, trim(DPGP_SIGLA)
                FROM UN_GESTORPROCESSO_DEPARTAMENTO
                where DPGP_DIGP_ID = <cfqueryparam value="#digpid#" cfsqltype="cf_sql_integer">
                order by DPGP_SIGLA
            </cfquery>
          <cfreturn rsgesdepto> 
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
                WHERE PCN1_MAPC_ID = <cfqueryparam value="#PCN1MAPCID#" cfsqltype="cf_sql_integer">
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
                PCN2_PCN1_MAPC_ID = <cfqueryparam value="#PCN1MAPCID#" cfsqltype="cf_sql_integer"> AND 
                PCN2_PCN1_ID in(#PCN1ID#)
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
            PCN3_PCN2_PCN1_ID in(#PCN3PCN2PCN1ID#) and
            PCN3_PCN2_ID in(#PCN3PCN2ID#)
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
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao possui a Classificação do Controle Selecionada!'>                     
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
    <!--- incluir/alterar/excluir Categoria de Risco  --->
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
                    WHERE Itn_RiscoIdentificado = #ctrcid#
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
    <!--- incluir/alterar/excluir Macroprocesso  --->
    <cffunction name="cad_macproc" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="mapcid" required="true">
        <cfargument name="mapcdesc" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(MAPC_ID)+1 as novoid 
                    FROM UN_MACROPROCESSO
                </cfquery>
                <cfquery datasource="DBSNCI">
                    insert into UN_MACROPROCESSO 
                        (MAPC_ID,MAPC_Descricao,MAPC_username,MAPC_DtCriar,MAPC_DtAlter)
                    values 
                        (#rsNovo.novoid#,<cfqueryparam value="#mapcdesc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_MACROPROCESSO set
                         MAPC_Descricao = <cfqueryparam value="#mapcdesc#" cfsqltype="cf_sql_char">
                        ,MAPC_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,MAPC_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        MAPC_ID = <cfqueryparam value="#mapcid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExisteA">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_MacroProcesso = #mapcid#
                </cfquery>
                <cfquery datasource="DBSNCI" name="rsExisteB">
                    SELECT PCN1_MAPC_ID
                    FROM UN_PROCESSON1
                    WHERE PCN1_MAPC_ID = #mapcid#
                </cfquery>
                <cfif rsExisteA.recordcount lte 0 and rsExisteB.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_MACROPROCESSO 
                        where 
                            MAPC_ID = <cfqueryparam value="#mapcid#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao e/ou UN_PROCESSON1 possui o Macroprocesso selecionado!'>                     
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
    <!--- incluir/alterar/excluir Processo-N1  --->
    <cffunction name="cad_procn1" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="pcn1mapcid" required="true">
        <cfargument name="pcn1id" required="true">
        <cfargument name="pcn1desc" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(PCN1_ID)+1 as novoid 
                    FROM UN_PROCESSON1
                    WHERE PCN1_MAPC_ID = #pcn1mapcid#
                </cfquery>
                <cfif rsNovo.novoid is ''>
                    <cfset rsNovo.novoid = 1>
                </cfif>
                <cfquery datasource="DBSNCI">
                    insert into UN_PROCESSON1 
                        (PCN1_MAPC_ID,PCN1_ID,PCN1_Descricao,PCN1_username,PCN1_DtCriar,PCN1_DtAlter)
                    values 
                        (#pcn1mapcid#,#rsNovo.novoid#,<cfqueryparam value="#pcn1desc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_PROCESSON1 set
                        PCN1_Descricao = <cfqueryparam value="#pcn1desc#" cfsqltype="cf_sql_char">
                        ,PCN1_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,PCN1_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        PCN1_MAPC_ID = <cfqueryparam value="#pcn1mapcid#" cfsqltype="cf_sql_integer"> 
                        AND PCN1_ID = <cfqueryparam value="#pcn1id#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExisteA">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_MacroProcesso = #pcn1mapcid# 
                    and Itn_ProcessoN1 = #pcn1id#
                </cfquery>
                <cfquery datasource="DBSNCI" name="rsExisteB">
                    SELECT PCN2_PCN1_MAPC_ID, PCN2_PCN1_ID
                    FROM UN_PROCESSON2
                    WHERE PCN2_PCN1_MAPC_ID=#pcn1mapcid# AND PCN2_PCN1_ID=#pcn1id#
                </cfquery>

                <cfif rsExisteA.recordcount lte 0 and rsExisteB.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_PROCESSON1 
                        where 
                        PCN1_MAPC_ID = <cfqueryparam value="#pcn1mapcid#" cfsqltype="cf_sql_integer"> 
                        AND PCN1_ID = <cfqueryparam value="#pcn1id#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse> 
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao e/ou UN_PROCESSON2 possui o Processo-N1 selecionado!'>                      
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
    <!--- incluir/alterar/excluir Processo-N2  --->
    <cffunction name="cad_procn2" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="pcn1mapcid" required="true">
        <cfargument name="pcn1id" required="true">
        <cfargument name="pcn2id" required="true">
        <cfargument name="pcn2desc" required="true">            
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(PCN2_ID)+1 as novoid 
                    FROM UN_PROCESSON2
                    WHERE PCN2_PCN1_MAPC_ID = #pcn1mapcid# 
                    AND PCN2_PCN1_ID = #pcn1id#
                </cfquery>
                <cfif rsNovo.novoid is ''>
                    <cfset rsNovo.novoid = 1>
                </cfif>
                <cfquery datasource="DBSNCI">
                    insert into UN_PROCESSON2 
                        (PCN2_PCN1_MAPC_ID,PCN2_PCN1_ID,PCN2_ID,PCN2_Descricao,PCN2_username,PCN2_DtCriar,PCN2_DtAlter)
                    values 
                        (#pcn1mapcid#,#pcn1id#,#rsNovo.novoid#,<cfqueryparam value="#pcn2desc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_PROCESSON2 set
                        PCN2_Descricao = <cfqueryparam value="#pcn2desc#" cfsqltype="cf_sql_char">
                        ,PCN2_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,PCN2_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        PCN2_PCN1_MAPC_ID = <cfqueryparam value="#pcn1mapcid#" cfsqltype="cf_sql_integer"> 
                        AND PCN2_PCN1_ID = <cfqueryparam value="#pcn1id#" cfsqltype="cf_sql_integer"> 
                        AND PCN2_ID = <cfqueryparam value="#pcn2id#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExisteA">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_MacroProcesso = #pcn1mapcid# 
                    and Itn_ProcessoN1 = #pcn1id# 
                    and Itn_ProcessoN2 = #pcn2id#
                </cfquery>
                <cfquery datasource="DBSNCI" name="rsExisteB">
                    SELECT PCN3_PCN2_ID
                    FROM UN_PROCESSON3
                    WHERE PCN3_PCN2_PCN1_MAPC_ID = #pcn1mapcid#
                    AND PCN3_PCN2_PCN1_ID=#pcn1id# 
                    AND PCN3_PCN2_ID=#pcn2id#
                </cfquery>
                <cfif rsExisteA.recordcount lte 0 and rsExisteB.recordcount lte 0>                
                    <cfquery datasource="DBSNCI">
                        delete from  UN_PROCESSON2
                        where 
                        PCN2_PCN1_MAPC_ID = <cfqueryparam value="#pcn1mapcid#" cfsqltype="cf_sql_integer"> 
                        AND PCN2_PCN1_ID = <cfqueryparam value="#pcn1id#" cfsqltype="cf_sql_integer"> 
                        AND PCN2_ID = <cfqueryparam value="#pcn2id#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>     
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao e/ou UN_PROCESSON3 possui o Processo-N2 selecionado!'>                     
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
    <!--- incluir/alterar/excluir Processo-N3  --->
    <cffunction name="cad_procn3" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="pcn1mapcid" required="true">
        <cfargument name="pcn1id" required="true">
        <cfargument name="pcn2id" required="true">
        <cfargument name="pcn3id" required="true">
        <cfargument name="pcn3desc" required="true">            
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(PCN3_ID)+1 as novoid 
                    FROM UN_PROCESSON3
                    WHERE PCN3_PCN2_PCN1_MAPC_ID = #pcn1mapcid# 
                    AND PCN3_PCN2_PCN1_ID = #pcn1id# 
                    and PCN3_PCN2_ID = #pcn2id#
                </cfquery>
                <cfif rsNovo.novoid is ''>
                    <cfset rsNovo.novoid = 1>
                </cfif>
                <cfquery datasource="DBSNCI">
                    insert into UN_PROCESSON3 
                        (PCN3_PCN2_PCN1_MAPC_ID,PCN3_PCN2_PCN1_ID,PCN3_PCN2_ID,PCN3_ID,PCN3_Descricao,PCN3_username,PCN3_DtCriar,PCN3_DtAlter)
                    values 
                        (#pcn1mapcid#,#pcn1id#,#pcn2id#,#rsNovo.novoid#,<cfqueryparam value="#pcn3desc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_PROCESSON3 set
                        PCN3_Descricao = <cfqueryparam value="#pcn3desc#" cfsqltype="cf_sql_char">
                        ,PCN3_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,PCN3_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        PCN3_PCN2_PCN1_MAPC_ID = <cfqueryparam value="#pcn1mapcid#" cfsqltype="cf_sql_integer"> 
                        AND PCN3_PCN2_PCN1_ID = <cfqueryparam value="#pcn1id#" cfsqltype="cf_sql_integer"> 
                        AND PCN3_PCN2_ID = <cfqueryparam value="#pcn2id#" cfsqltype="cf_sql_integer">
                        AND PCN3_ID = <cfqueryparam value="#pcn3id#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExiste">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_MacroProcesso = #pcn1mapcid# 
                    and Itn_ProcessoN1 = #pcn1id# 
                    and Itn_ProcessoN2 = #pcn2id# 
                    and Itn_ProcessoN3 = #pcn3id#
                </cfquery>
                <cfif rsExiste.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_PROCESSON3
                        where 
                        PCN3_PCN2_PCN1_MAPC_ID = <cfqueryparam value="#pcn1mapcid#" cfsqltype="cf_sql_integer"> 
                        AND PCN3_PCN2_PCN1_ID = <cfqueryparam value="#pcn1id#" cfsqltype="cf_sql_integer"> 
                        AND PCN3_PCN2_ID = <cfqueryparam value="#pcn2id#" cfsqltype="cf_sql_integer">
                        AND PCN3_ID = <cfqueryparam value="#pcn3id#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao possui o Processo-N3 selecionado!'>                     
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
    <!--- incluir/alterar/excluir Gestor do Processo Diretoria --->
    <cffunction name="cad_gestordir" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="digpid" required="true">
        <cfargument name="digpdesc" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(DIGP_ID)+1 as novoid 
                    FROM UN_GESTORPROCESSO_DIRETORIA
                </cfquery>
                <cfquery datasource="DBSNCI">
                    insert into UN_GESTORPROCESSO_DIRETORIA 
                        (DIGP_ID,DIGP_SIGLA,DIGP_username,DIGP_DtCriar,DIGP_DtAlter)
                    values 
                        (#rsNovo.novoid#,<cfqueryparam value="#digpdesc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_GESTORPROCESSO_DIRETORIA set
                         DIGP_SIGLA = <cfqueryparam value="#digpdesc#" cfsqltype="cf_sql_char">
                        ,DIGP_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,DIGP_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        DIGP_ID = <cfqueryparam value="#digpid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExiste">
                    SELECT DPGP_DIGP_ID
                    FROM UN_GESTORPROCESSO_DEPARTAMENTO
                    WHERE DPGP_DIGP_ID=#digpid#
                </cfquery>
                <cfif rsExiste.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_GESTORPROCESSO_DIRETORIA 
                        where 
                            DIGP_ID = <cfqueryparam value="#digpid#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela UN_GESTORPROCESSO_DEPARTAMENTO possui a Diretoria do Processo Selecionada!'>                     
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
    <!--- incluir/alterar/excluir Gestor do Processo Departamento--->
    <cffunction name="cad_gestordepto" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="dpgpdigpid" required="true">
        <cfargument name="dpgpid" required="true">
        <cfargument name="dpgpsigla" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(DPGP_ID)+1 as novoid 
                    FROM UN_GESTORPROCESSO_DEPARTAMENTO
                    where DPGP_DIGP_ID = #dpgpdigpid#
                </cfquery>
                <cfif rsNovo.novoid is ''>
                    <cfset rsNovo.novoid = 1>
                </cfif>
                <cfquery datasource="DBSNCI">
                    insert into UN_GESTORPROCESSO_DEPARTAMENTO 
                        (DPGP_DIGP_ID,DPGP_ID,DPGP_SIGLA,DPGP_username,DPGP_DtCriar,DPGP_DtAlter)
                    values 
                        (#dpgpdigpid#,#rsNovo.novoid#,<cfqueryparam value="#dpgpsigla#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_GESTORPROCESSO_DEPARTAMENTO set
                         DPGP_SIGLA = <cfqueryparam value="#dpgpsigla#" cfsqltype="cf_sql_char">
                        ,DPGP_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,DPGP_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                    DPGP_DIGP_ID = <cfqueryparam value="#dpgpdigpid#" cfsqltype="cf_sql_integer"> and 
                    DPGP_ID = <cfqueryparam value="#dpgpid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExiste">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_GestorProcessoDir=#dpgpdigpid# and Itn_GestorProcessoDepto = '#dpgpid#'
                </cfquery>
                <cfif rsExiste.recordcount lte 0>   
                    <cfquery datasource="DBSNCI">
                        delete from  UN_GESTORPROCESSO_DEPARTAMENTO 
                        where 
                            DPGP_DIGP_ID = <cfqueryparam value="#dpgpdigpid#" cfsqltype="cf_sql_integer"> and 
                            DPGP_ID = <cfqueryparam value="#dpgpid#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao possui a Departamento do Processo Selecionado!'>                     
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
    <!--- incluir/alterar/excluir Objetivo estrategico  --->
    <cffunction name="cad_objtestra" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="obesid" required="true">
        <cfargument name="obesdesc" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(OBES_ID)+1 as novoid 
                    FROM UN_OBJETIVOESTRATEGICO
                </cfquery>
                <cfquery datasource="DBSNCI">
                    insert into UN_OBJETIVOESTRATEGICO 
                        (OBES_ID,OBES_DESCRICAO,OBES_username,OBES_DtCriar,OBES_DtAlter)
                    values 
                        (#rsNovo.novoid#,<cfqueryparam value="#obesdesc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_OBJETIVOESTRATEGICO set
                         OBES_DESCRICAO = <cfqueryparam value="#obesdesc#" cfsqltype="cf_sql_char">
                        ,OBES_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,OBES_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        OBES_ID = <cfqueryparam value="#obesid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExiste">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_ObjetivoEstrategico In ('#obesid#')
                </cfquery>
                <cfif rsExiste.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_OBJETIVOESTRATEGICO 
                        where 
                            OBES_ID = <cfqueryparam value="#obesid#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao possui a Objetivo Estratégico Selecionado!'>                     
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
    <!--- incluir/alterar/excluir Objetivo estrategico  --->
    <cffunction name="cad_riscestra" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="rcesid" required="true">
        <cfargument name="rcesdesc" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(RCES_ID)+1 as novoid 
                    FROM UN_RISCOESTRATEGICO
                </cfquery>
                <cfquery datasource="DBSNCI">
                    insert into UN_RISCOESTRATEGICO 
                        (RCES_ID,RCES_DESCRICAO,RCES_username,RCES_DtCriar,RCES_DtAlter)
                    values 
                        (#rsNovo.novoid#,<cfqueryparam value="#rcesdesc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_RISCOESTRATEGICO set
                         RCES_DESCRICAO = <cfqueryparam value="#rcesdesc#" cfsqltype="cf_sql_char">
                        ,RCES_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,RCES_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        RCES_ID = <cfqueryparam value="#rcesid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExiste">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_RiscoEstrategico = '#rcesid#'
                </cfquery>
                <cfif rsExiste.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_RISCOESTRATEGICO 
                        where 
                            RCES_ID = #rcesid#
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao possui a Risco Estratégico Selecionado!'>                     
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
    <!--- incluir/alterar/excluir Indicador estrategico  --->
    <cffunction name="cad_indiestra" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="idesid" required="true">
        <cfargument name="idesdesc" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(IDES_ID)+1 as novoid 
                    FROM UN_INDICADORESTRATEGICO
                </cfquery>
                <cfquery datasource="DBSNCI">
                    insert into UN_INDICADORESTRATEGICO 
                        (IDES_ID,IDES_DESCRICAO,IDES_username,IDES_DtCriar,IDES_DtAlter)
                    values 
                        (#rsNovo.novoid#,<cfqueryparam value="#idesdesc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_INDICADORESTRATEGICO set
                         IDES_DESCRICAO = <cfqueryparam value="#idesdesc#" cfsqltype="cf_sql_char">
                        ,IDES_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,IDES_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        IDES_ID = <cfqueryparam value="#idesid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExiste">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_IndicadorEstrategico = '#idesid#'
                </cfquery>
                <cfif rsExiste.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_INDICADORESTRATEGICO 
                        where 
                            IDES_ID = #idesid#
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao possui a Indicador Estratégico Selecionado!'>                     
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
    <!--- incluir/alterar/excluir composição do COSO-2013  --->
    <cffunction name="cad_compcoso2013" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="cpcsid" required="true">
        <cfargument name="cpcsdesc" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(CPCS_ID)+1 as novoid 
                    FROM UN_COMPONENTECOSO
                </cfquery>
                <cfquery datasource="DBSNCI">
                    insert into UN_COMPONENTECOSO 
                        (CPCS_ID,CPCS_DESCRICAO,CPCS_username,CPCS_DtCriar,CPCS_DtAlter)
                    values 
                        (#rsNovo.novoid#,<cfqueryparam value="#cpcsdesc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_COMPONENTECOSO set
                         CPCS_DESCRICAO = <cfqueryparam value="#cpcsdesc#" cfsqltype="cf_sql_char">
                        ,CPCS_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,CPCS_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        CPCS_ID = <cfqueryparam value="#cpcsid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExisteA">
                    SELECT Itn_ClassificacaoControle
                    FROM Itens_Verificacao
                    WHERE Itn_Coso2013Componente = #cpcsid# 
                </cfquery>
                <cfquery datasource="DBSNCI" name="rsExisteB">
                    SELECT PRCS_CPCS_ID
                    FROM UN_PRINCIPIOCOSO
                    WHERE PRCS_CPCS_ID= #cpcsid#
                </cfquery>
                <cfif rsExisteA.recordcount lte 0 and rsExisteB.recordcount lte 0>                
                    <cfquery datasource="DBSNCI">
                        delete from  UN_COMPONENTECOSO 
                        where 
                            CPCS_ID = #cpcsid#
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao e/ou UN_COMPONENTECOSO possui o Componentes Existentes Selecionado!'>                     
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
    <!--- incluir/alterar/excluir composição do COSO-2013  --->
    <cffunction name="cad_princoso2013" access="remote" returntype="any">
        <cfargument name="acao" required="true">
        <cfargument name="prcscpcsid" required="true">
        <cfargument name="prcsid" required="true">
        <cfargument name="prcsdesc" required="true">
        <cftry>
            <cfif acao eq 'inc'>
                <cfquery datasource="DBSNCI" name="rsNovo">
                    SELECT Max(PRCS_ID)+1 as novoid 
                    FROM UN_PRINCIPIOCOSO
                    where PRCS_CPCS_ID = #prcscpcsid#
                </cfquery>
                <cfif rsNovo.novoid is ''>
                    <cfset rsNovo.novoid = 1>
                </cfif>
                <cfquery datasource="DBSNCI">
                    insert into UN_PRINCIPIOCOSO 
                        (PRCS_CPCS_ID,PRCS_ID,PRCS_DESCRICAO,PRCS_username,PRCS_DtCriar,PRCS_DtAlter)
                    values 
                        (#prcscpcsid#,#rsNovo.novoid#,<cfqueryparam value="#prcsdesc#" cfsqltype="cf_sql_char">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">,CONVERT(char, GETDATE(), 120),CONVERT(char, GETDATE(), 120)) 
                </cfquery>  
                <cfset ret = 'Inclusão realizada com sucesso!'>              
            </cfif>
            <cfif acao eq 'alt'>
                <cfquery datasource="DBSNCI">
                    update UN_PRINCIPIOCOSO set
                         PRCS_DESCRICAO = <cfqueryparam value="#prcsdesc#" cfsqltype="cf_sql_char">
                        ,PRCS_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">
                        ,PRCS_DtAlter =  CONVERT(char, GETDATE(), 120)
                    where 
                        PRCS_CPCS_ID = <cfqueryparam value="#prcscpcsid#" cfsqltype="cf_sql_integer">
                        and PRCS_ID = <cfqueryparam value="#prcsid#" cfsqltype="cf_sql_integer">
                </cfquery> 
                <cfset ret = 'Alteração realizada com sucesso!'> 
            </cfif>
            <cfif acao eq 'exc'>
                <cfquery datasource="DBSNCI" name="rsExiste">
                    SELECT Itn_Coso2013Principios
                    FROM Itens_Verificacao
                    WHERE Itn_Coso2013Componente=#prcscpcsid# and Itn_Coso2013Principios = #prcsid#
                </cfquery>
                <cfif rsExiste.recordcount lte 0>
                    <cfquery datasource="DBSNCI">
                        delete from  UN_PRINCIPIOCOSO 
                        where 
                        PRCS_CPCS_ID = <cfqueryparam value="#prcscpcsid#" cfsqltype="cf_sql_integer">
                        and PRCS_ID = <cfqueryparam value="#prcsid#" cfsqltype="cf_sql_integer">
                    </cfquery> 
                    <cfset ret = 'Exclusão realizada com sucesso!'> 
                <cfelse>    
                    <cfset ret = 'Exclusão Cancelada - Tabela de Itens_Verificacao possui O Princípio COSO-2013 Selecionado!'>                     
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