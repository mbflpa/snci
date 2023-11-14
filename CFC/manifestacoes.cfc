<cfcomponent>

    <cfproperty  name="DSN" type="String">
    <cfset DSN = "DBSNCI">

    <!--- início  CAUSAS PROVÁVEIS --->
    <cffunction  name="incluir_causas_provaveis" returntype="String">
        <cfargument  name="gesunidade"  required="yes">
        <cfargument  name="gesavaliacao" required="yes">
        <cfargument  name="gesgrupo"  required="yes">
        <cfargument  name="gesitem"  required="yes">
        <cfargument  name="PCP_CodCausaProvavel"  required="yes">
        <cfset erro = 0>
        <cftry>

            <cfquery datasource="#dsn#" name="qExiste">
	            SELECT PCP_Unidade FROM ParecerCausaProvavel
                WHERE 
                PCP_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                PCP_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                PCP_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                PCP_NumItem=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> AND 
                PCP_CodCausaProvavel=<cfqueryparam value="#arguments.PCP_CodCausaProvavel#" cfsqltype="cf_sql_integer">
	        </cfquery>

            <cfif qExiste.RecordCount lte 0>
                <cfquery datasource="#dsn#">
                        INSERT ParecerCausaProvavel(
                            PCP_Unidade, PCP_Inspecao, PCP_NumGrupo, PCP_NumItem, PCP_CodCausaProvavel
                            )
                            VALUES 
                            (
                            <cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR">, 
                            <cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR">,
                            <cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer">, 
                            <cfqueryparam value="#arguments.PCP_CodCausaProvavel#" cfsqltype="cf_sql_integer">
                            )
                </cfquery>
            </cfif>
            <cfcatch type="any">
                <cfset erro = 1>
            </cfcatch>
        </cftry>
        <cfif erro eq 0>
            <cfset msg = 'Causa Provável Inserida com sucesso!'>
        <cfelse>
            <cfset msg = 'Inserção de Causa Provável, ocorreu um erro!'>            
        </cfif>
        <cfreturn msg>
    </cffunction>
    <!--- final  CAUSAS PROVÁVEIS --->

    <!--- início  excluir CAUSAS PROVÁVEIS --->
    <cffunction  name="excluir_causas_provaveis" returntype="String">
        <cfargument  name="gesunidade" required="yes">
        <cfargument  name="gesavaliacao" required="yes">
        <cfargument  name="gesgrupo" required="yes">
        <cfargument  name="gesitem" required="yes">
        <cfargument  name="PCP_CodCausaProvavel" required="yes">
        <cfset erro = 0>
        <cftry>

            <cfquery datasource="#dsn#">
                DELETE FROM ParecerCausaProvavel
                WHERE 
                PCP_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                PCP_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                PCP_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                PCP_NumItem=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> AND 
                PCP_CodCausaProvavel=<cfqueryparam value="#arguments.PCP_CodCausaProvavel#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfcatch type="any">
                <cfset erro = 1>
            </cfcatch>
        </cftry>
        <cfif erro eq 0>
            <cfset msg = 'Exclusão de Causa Provável com sucesso!'>
        <cfelse>
            <cfset msg = 'Exclusão de Causa Provável, ocorreu um erro!'>            
        </cfif>
        <cfreturn msg>
    </cffunction>
    <!--- final  excluir CAUSAS PROVÁVEIS --->

    <!--- início  incluir_processo_disciplinar --->
    <cffunction  name="incluir_processo_disciplinar" returntype="String">
        <cfargument  name="gesunidade"  required="yes">
        <cfargument  name="gesavaliacao" required="yes">
        <cfargument  name="gesgrupo"  required="yes">
        <cfargument  name="gesitem"  required="yes">
        <cfargument  name="PDC_Processo"  required="yes">
        <cfargument  name="PDC_Modalidade"  required="yes">
        <cfargument  name="PDC_ProcSEI"  required="yes">
        <cfargument  name="PDC_username"  required="yes">
        <cfargument  name="Parecer"  required="yes">
        <cfargument  name="lotacaousu"  required="yes">
        <cfargument  name="nomelotacaousu"  required="yes">

        <cfset maskcgiusu = ucase(trim(arguments.PDC_username))>
        <cfif left(maskcgiusu,8) eq 'EXTRANET'>
            <cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
        <cfelse>
            <cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
        </cfif>

        <cfset erro = 0>
        <cftry>
            <cfif len(arguments.PDC_Processo) eq 5>
                <cfquery datasource="#dsn#" name="qExiste">
                    SELECT PDC_Unidade FROM Inspecao_ProcDisciplinar
                    WHERE
                    PDC_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    PDC_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    PDC_Grupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    PDC_Item=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> AND 
                    PDC_Processo=<cfqueryparam value="#arguments.PDC_Processo#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    PDC_ProcSEI=<cfqueryparam value="#arguments.PDC_ProcSEI#" cfsqltype="CF_SQL_VARCHAR">
                </cfquery>

                <cfif qExiste.RecordCount lte 0>
                   <cfquery datasource="#dsn#">
                        INSERT Inspecao_ProcDisciplinar(
                            PDC_Unidade, PDC_Inspecao, PDC_Grupo, PDC_Item, PDC_Processo, PDC_Modalidade, PDC_ProcSEI, PDC_dtultatu, PDC_username
                            )
                            VALUES 
                            (
                            <cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR">,
                            <cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR">, 
                            <cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer">, 
                            <cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer">, 
                            <cfqueryparam value="#arguments.PDC_Processo#" cfsqltype="CF_SQL_VARCHAR">
                            <cfqueryparam value="#arguments.PDC_Modalidade#" cfsqltype="CF_SQL_VARCHAR">, 
                            <cfqueryparam value="#arguments.PDC_ProcSEI#" cfsqltype="CF_SQL_VARCHAR">, 
                            convert(char, getdate(), 120), 
                            <cfqueryparam value="#arguments.PDC_username#" cfsqltype="CF_SQL_VARCHAR">
                            )
	                </cfquery> 
                    <cfset pos_aux = arguments.Parecer & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Registro de Processo Disciplinar(Inclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Nº do Processo: ' & #left(arguments.PDC_Processo,2)# & '-' & #mid(arguments.PDC_Processo,3,5)# & '-' & #right(arguments.PDC_Processo,2)# & CHR(13) & CHR(13) & 'Modalidade: ' & #arguments.PDC_Modalidade# & CHR(13) & CHR(13) & 'Nº SEI(Processo): ' & #left(arguments.PDC_ProcSEI,5)# & '.' & #mid(arguments.PDC_ProcSEI,6,6)# & '/' & #mid(arguments.PDC_ProcSEI,12,4)# & '-' & #right(arguments.PDC_ProcSEI,2)# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & #lotacaousu# & '-' & #nomelotacaousu# & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
                    <cfset and_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Registro de Processo Disciplinar(Inclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Nº do Processo: ' & #left(arguments.PDC_Processo,2)# & '-' & #mid(arguments.PDC_Processo,3,5)# & '-' & #right(arguments.PDC_Processo,2)# & CHR(13) & CHR(13) & 'Modalidade: ' & #arguments.PDC_Modalidade# & CHR(13) & CHR(13) & 'Nº SEI(Processo): ' & #left(arguments.PDC_ProcSEI,5)# & '.' & #mid(arguments.PDC_ProcSEI,6,6)# & '/' & #mid(arguments.PDC_ProcSEI,12,4)# & '-' & #right(arguments.PDC_ProcSEI,2)# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & #lotacaousu# & '-' & #nomelotacaousu# & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
                </cfif>
            <cfelse>
                <cfquery datasource="#dsn#" name="qExiste">
                    SELECT SEI_Inspecao FROM Inspecao_SEI
                    WHERE 
                    SEI_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    SEI_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    SEI_Grupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    SEI_Item=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> AND 
                    SEI_NumSEI=<cfqueryparam value="#arguments.PDC_ProcSEI#" cfsqltype="CF_SQL_VARCHAR">
                </cfquery>

                <cfif qExiste.RecordCount eq 0>
                  <cfquery datasource="#dsn#">
                        INSERT Inspecao_SEI (
                            SEI_Unidade, SEI_Inspecao, SEI_Grupo, SEI_Item, SEI_NumSEI, SEI_dtultatu, SEI_username
                        )
                        VALUES 
                        (
                        <cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR">,
                        <cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR">, 
                        <cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer">, 
                        <cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer">, 
                        <cfqueryparam value="#arguments.PDC_ProcSEI#" cfsqltype="CF_SQL_VARCHAR">, 
                        convert(char, getdate(), 120),
                        <cfqueryparam value="#arguments.PDC_username#" cfsqltype="CF_SQL_VARCHAR">
                        )
                    </cfquery>   
                      <cfset pos_aux = arguments.Parecer & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Registro de Nº SEI Apuracao(Inclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Nº do SEI: ' & #left(arguments.PDC_ProcSEI,5)# & '.' & #mid(arguments.PDC_ProcSEI,6,6)# & '/' & #mid(arguments.PDC_ProcSEI,12,4)# & '-' & #right(arguments.PDC_ProcSEI,2)# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & #lotacaousu# & '-' & #nomelotacaousu# & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
                      <cfset and_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Registro de Nº SEI Apuracao(Inclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Nº do SEI: ' & #left(arguments.PDC_ProcSEI,5)# & '.' & #mid(arguments.PDC_ProcSEI,6,6)# & '/' & #mid(arguments.PDC_ProcSEI,12,4)# & '-' & #right(arguments.PDC_ProcSEI,2)# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & #lotacaousu# & '-' & #nomelotacaousu# & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
                </cfif>
            </cfif>
     
            <!--- Atualizar PareceUnidade --->
            <cfquery datasource="#dsn#">
                UPDATE ParecerUnidade SET Pos_Parecer= '#pos_aux#' 
                WHERE 
                    Pos_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    Pos_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    Pos_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    Pos_NumItem= <cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfquery name="rsPos" datasource="#dsn#">
                SELECT Pos_Situacao_Resp, Pos_DtPosic
                FROM ParecerUnidade
                WHERE 
                    Pos_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    Pos_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    Pos_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    Pos_NumItem= <cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset PosDtPosic = lsdateformat(rsPos.Pos_DtPosic, "YYYY-MM-DD")>
            <cfquery name="rsAnd" datasource="#dsn#">
                SELECT and_Parecer
                FROM Andamento
                WHERE 
                    And_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    And_NumInspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    And_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    And_NumItem=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> and 
                    And_DtPosic = '#PosDtPosic#' and 
                    And_Situacao_Resp = <cfqueryparam value="#rsPos.Pos_Situacao_Resp#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfif rsAnd.recordcount gt 0>
                <cfset and_aux = #rsAnd.and_Parecer# & CHR(13) & CHR(13) & #and_aux#>
                <cfquery datasource="#dsn#">
                    UPDATE Andamento SET and_Parecer= '#and_aux#' 
                    WHERE 
                        And_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                        And_NumInspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                        And_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                        And_NumItem=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> and 
                        And_DtPosic = '#PosDtPosic#' and 
                        And_Situacao_Resp = <cfqueryparam value="#rsPos.Pos_Situacao_Resp#" cfsqltype="cf_sql_integer">
                </cfquery>
            </cfif>            
            <cfcatch type="any">
                <cfset erro = 1>
            </cfcatch>
        </cftry>
        <cfif erro eq 0>
            <cfset msg = 'Inserção de Processo Disciplinar, com sucesso!'>
        <cfelse>
            <cfset msg = 'Inserção de Processo Disciplinar, ocorreu um erro!'>            
        </cfif>       
        <cfreturn msg>
    </cffunction>
    <!--- final  incluir_processo_disciplinar --->

============================================
<!--- início  excluir_processo_disciplinar --->
    <cffunction  name="excluir_processo_disciplinar" returntype="String">
        <cfargument  name="gesunidade"  required="yes">
        <cfargument  name="gesavaliacao" required="yes">
        <cfargument  name="gesgrupo"  required="yes">
        <cfargument  name="gesitem"  required="yes">
        <cfargument  name="PDC_Processo"  required="yes">
        <cfargument  name="PDC_ProcSEI"  required="yes">
        <cfargument  name="Parecer"  required="yes">
        <cfargument  name="PDC_Modalidade"  required="yes">
        <cfargument  name="PDC_username"  required="yes">
        <cfargument  name="lotacaousu"  required="yes">
        <cfargument  name="nomelotacaousu"  required="yes">

        <cfset erro = 0>
        <cftry>
            <cfquery datasource="#dsn#">
                DELETE FROM Inspecao_ProcDisciplinar 
                WHERE 
                    PDC_Unidade= <cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    PDC_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    PDC_Grupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    PDC_Item=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> AND 
                    PDC_Processo=<cfqueryparam value="#arguments.PDC_Processo#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    PDC_ProcSEI=<cfqueryparam value="#arguments.PDC_ProcSEI#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
 
            <cfset aux_sei = trim(arguments.PDC_ProcSEI)>
            <cfset aux_sei = left(aux_sei,5) & '.' & mid(aux_sei,6,6) & '/' & mid(aux_sei,12,4) & '-' & right(aux_sei,2)>
            <cfset aux_proc = left(arguments.PDC_Processo,2) & '-' & mid(arguments.PDC_Processo,3,5)  & '-' & right(arguments.PDC_Processo,2)>
        
            <cfset maskcgiusu = ucase(trim(arguments.PDC_username))>
            <cfif left(maskcgiusu,8) eq 'EXTRANET'>
                <cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
            <cfelse>
                <cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
            </cfif>

 		    <cfset pos_aux = #arguments.Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Registro de Processo Disciplinar(Exclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Nº do Processo: ' & #aux_proc# & CHR(13) & CHR(13) & 'Modalidade: ' & #arguments.PDC_Modalidade# & CHR(13) & CHR(13) & 'Nº SEI(Processo): ' & #aux_sei# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & #lotacaousu# & '-' & #nomelotacaousu# & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
        
            <cfquery datasource="#dsn#">
                UPDATE ParecerUnidade SET Pos_Parecer= '#pos_aux#' 
                WHERE 
                    Pos_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    Pos_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    Pos_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    Pos_NumItem= <cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer">
            </cfquery>	
            <cfquery name="rsPos" datasource="#dsn#">
                    SELECT Pos_Situacao_Resp, Pos_DtPosic
                    FROM ParecerUnidade
                    WHERE 
                        Pos_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                        Pos_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                        Pos_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                        Pos_NumItem= <cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset PosDtPosic = lsdateformat(rsPos.Pos_DtPosic, "YYYY-MM-DD")>
            <cfquery name="rsAnd" datasource="#dsn#">
                SELECT and_Parecer
                FROM Andamento
                WHERE 
                    And_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    And_NumInspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    And_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    And_NumItem=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> and 
                    And_DtPosic = '#PosDtPosic#' and 
                    And_Situacao_Resp = <cfqueryparam value="#rsPos.Pos_Situacao_Resp#" cfsqltype="cf_sql_integer">
            </cfquery>
 		     
            <cfif rsAnd.recordcount gt 0>
                <cfset and_aux = #rsAnd.and_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Registro de Processo Disciplinar(Exclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Nº do Processo: ' & #aux_proc# & CHR(13) & CHR(13) & 'Modalidade: ' & #arguments.PDC_Modalidade# & CHR(13) & CHR(13) & 'Nº SEI(Processo): ' & #aux_sei# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & #lotacaousu# & '-' & #nomelotacaousu# & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
                <cfquery datasource="#snci.dsn#">
                    UPDATE Andamento SET and_Parecer= '#and_aux#' 
                    WHERE 
                        And_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                        And_NumInspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                        And_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                        And_NumItem=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> and 
                        And_DtPosic = '#PosDtPosic#' and 
                        And_Situacao_Resp = <cfqueryparam value="#rsPos.Pos_Situacao_Resp#" cfsqltype="cf_sql_integer">
                </cfquery>
            </cfif>	
        
            <cfcatch type="any">
                <cfset erro = 1>
            </cfcatch>
        </cftry>
        <cfif erro eq 0>
            <cfset msg = 'Exclusão de Processo Disciplinar, com sucesso!'>
        <cfelse>
            <cfset msg = 'Exclusão de Processo Disciplinar, ocorreu um erro!'>            
        </cfif>       
        <cfreturn msg>
    </cffunction>
    <!--- final  excluir_processo_disciplinar --->

<!--- início  excluir_numero_sei --->
    <cffunction  name="excluir_numero_sei" returntype="String">
        <cfargument  name="gesunidade"  required="yes">
        <cfargument  name="gesavaliacao" required="yes">
        <cfargument  name="gesgrupo"  required="yes">
        <cfargument  name="gesitem"  required="yes">
        <cfargument  name="SEI_username"  required="yes">
        <cfargument  name="SEI_NumSEI"  required="yes">
        <cfargument  name="Parecer"  required="yes">
        <cfargument  name="lotacaousu"  required="yes">
        <cfargument  name="nomelotacaousu"  required="yes">

        <cfset erro = 0>
        <cftry>
            <cfquery datasource="#dsn#">
                DELETE FROM Inspecao_SEI 
                WHERE 
                    SEI_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    SEI_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    SEI_Grupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    SEI_Item=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> AND 
                    SEI_NumSEI=<cfqueryparam value="#arguments.SEI_NumSEI#" cfsqltype="CF_SQL_VARCHAR"> 
            </cfquery>
 
            <cfset aux_sei = left(arguments.SEI_NumSEI,5) & '.' & mid(arguments.SEI_NumSEI,6,6) & '/' & mid(arguments.SEI_NumSEI,12,4) & '-' & right(arguments.SEI_NumSEI,2)>
            
        
            <cfset maskcgiusu = ucase(trim(arguments.SEI_username))>
            <cfif left(maskcgiusu,8) eq 'EXTRANET'>
                <cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
            <cfelse>
                <cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
            </cfif>
            
            <cfset pos_aux = #arguments.Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Registro de Nº SEI Apuracao(Exclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Nº do SEI: ' & #aux_sei# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & #lotacaousu# & '-' & #nomelotacaousu# & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
            
            <cfquery datasource="#dsn#">
                UPDATE ParecerUnidade SET Pos_Parecer= '#pos_aux#' 
                WHERE 
                    Pos_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    Pos_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    Pos_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    Pos_NumItem= <cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer">
            </cfquery>	

            <cfquery name="rsPos" datasource="#dsn#">
                    SELECT Pos_Situacao_Resp, Pos_DtPosic
                    FROM ParecerUnidade
                    WHERE 
                        Pos_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                        Pos_Inspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                        Pos_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                        Pos_NumItem= <cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset PosDtPosic = lsdateformat(rsPos.Pos_DtPosic, "YYYY-MM-DD")>
            <cfquery name="rsAnd" datasource="#dsn#">
                SELECT and_Parecer
                FROM Andamento
                WHERE 
                    And_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    And_NumInspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                    And_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                    And_NumItem=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> and 
                    And_DtPosic = '#PosDtPosic#' and 
                    And_Situacao_Resp = <cfqueryparam value="#rsPos.Pos_Situacao_Resp#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif rsAnd.recordcount gt 0>
                <cfset and_aux = #rsAnd.and_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Registro de Nº SEI Apuracao(Exclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Nº do SEI: ' & #FORM.dbfrmnumsei# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & #lotacaousu# & '-' & #nomelotacaousu# & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'> 
                <cfquery datasource="#snci.dsn#">
                    UPDATE Andamento SET and_Parecer= '#and_aux#' 
                    WHERE 
                        And_Unidade=<cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR"> AND 
                        And_NumInspecao=<cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR"> AND 
                        And_NumGrupo=<cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer"> AND 
                        And_NumItem=<cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer"> and 
                        And_DtPosic = '#PosDtPosic#' and 
                        And_Situacao_Resp = <cfqueryparam value="#rsPos.Pos_Situacao_Resp#" cfsqltype="cf_sql_integer">
                </cfquery>
            </cfif>	
        
            <cfcatch type="any">
                <cfset erro = 1>
            </cfcatch>
        </cftry>
        <cfif erro eq 0>
            <cfset msg = 'Exclusão do Número SEI, com sucesso!'>
        <cfelse>
            <cfset msg = 'Exclusão do Número SEI, ocorreu um erro!'>            
        </cfif>       
        <cfreturn msg>
    </cffunction>
    <!--- final  excluir_numero_sei --->

<!--- início  incluir anexo --->
    <cffunction  name="incluir_anexo" returntype="String">
        <cfargument  name="gesunidade"  required="yes">
        <cfargument  name="gesavaliacao" required="yes">
        <cfargument  name="gesgrupo"  required="yes">
        <cfargument  name="gesitem"  required="yes">
        <cfargument  name="pastanexos"  required="yes">
        <cfargument  name="matricula_cpf"  required="yes">

        <cfset erro = 0>
        <cftry>
        
            <cffile action="upload" filefield="arquivo" destination="#pastanexos#" nameconflict="overwrite" accept="application/pdf">
            
            <cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'SS') & 's'>
            
            <cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
            
            <cfset destino = cffile.serverdirectory & '\' & #arguments.gesavaliacao# & '_' & data & '_' & #arguments.matricula_cpf# & '_' & #arguments.gesgrupo# & '_' & #arguments.gesitem# & '.pdf'>
            
            <cfif FileExists(origem)>
			    <cffile action="rename" source="#origem#" destination="#destino#">
                <cfquery datasource="#dsn#" name="qAnexo">
                    SELECT Ane_Codigo FROM Anexos
                    WHERE Ane_Caminho = <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">
                </cfquery>
			    <cfif qAnexo.recordCount eq 0>
                    <cfquery datasource="#dsn#" name="qVerifica">
                    INSERT Anexos (
                        Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Caminho
                        )
                        VALUES 
                        (
                        <cfqueryparam value="#arguments.gesavaliacao#" cfsqltype="CF_SQL_VARCHAR">,
                        <cfqueryparam value="#arguments.gesunidade#" cfsqltype="CF_SQL_VARCHAR">,
                        <cfqueryparam value="#arguments.gesgrupo#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#arguments.gesitem#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#destino#" cfsqltype="CF_SQL_VARCHAR">
                        )
                    </cfquery>
		        </cfif>
            </cfif>

        
            <cfcatch type="any">
                <cfset erro = 1>
            </cfcatch>
        </cftry>
        <cfif erro eq 0>
            <cfset msg = 'Incluir Anexos, com sucesso!'>
        <cfelse>
            <cfset msg = 'Incluir Anexos, ocorreu um erro!'>            
        </cfif>       
        <cfreturn msg>
    </cffunction>
    <!--- final incluir_anexo --->

<!--- início  excluir_anexo --->
    <cffunction  name="excluir_anexo" returntype="String">
        <cfargument  name="Ane_Codigo"  required="yes">

        <cfset erro = 0>
        <cftry>
        
            <cfquery datasource="#dsn#" name="qAnexos">
			    SELECT Ane_Caminho 
                FROM Anexos
			    WHERE 
                    Ane_Codigo = '#arguments.Ane_Codigo#'
		    </cfquery>

            <cfif qAnexos.recordCount Neq 0>
                <!--- Exluindo arquivo do diretorio de Anexos --->
                <cfif FileExists(qAnexos.Ane_Caminho)>
                    <cffile action="delete" file="#qAnexos.Ane_Caminho#">
                </cfif>
                <!--- Excluindo anexo do banco de dados --->
                <cfquery datasource="#dsn#">
                    DELETE 
                    FROM Anexos
                    WHERE  
                        Ane_Codigo = '#arguments.Ane_Codigo#'
                </cfquery>
		    </cfif>
        
            <cfcatch type="any">
                <cfset erro = 1>
            </cfcatch>
        </cftry>
        <cfif erro eq 0>
            <cfset msg = 'Excluir Anexos, com sucesso!'>
        <cfelse>
            <cfset msg = 'Excluir Anexos, ocorreu um erro!'>            
        </cfif>       
        <cfreturn msg>
    </cffunction>
    <!--- final excluir_anexo --->

<!--- início  manifesto --->
    <cffunction  name="manifesto" returntype="String">
        <cfargument  name="gesunidade"  required="yes">
        <cfargument  name="gesavaliacao" required="yes">
        <cfargument  name="gesgrupo"  required="yes">
        <cfargument  name="gesitem"  required="yes">
 
        <cfargument  name="Parecer"  required="yes">
        <cfargument  name="lotacaousu"  required="yes">
        <cfargument  name="nomelotacaousu"  required="yes">

        <cfset maskcgiusu = ucase(trim(arguments.PDC_username))>
        <cfif left(maskcgiusu,8) eq 'EXTRANET'>
            <cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
        <cfelse>
            <cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
        </cfif>

        <cfset erro = 0>
            <!--- <cftry> --->
            
            <!--- caso cbdata não seja dia útil busca o próximo dia útil --->
			<cfset dtnovoprazo = lsdateformat(cbdata,"YYYY-MM-DD")>  
			<cfoutput>
				<cfset nCont = 1>
				<cfloop condition="nCont lte 1">
					<cfset nCont = nCont + 1>
					<cfset vDiaSem = DayOfWeek(dtnovoprazo)>
					<cfif vDiaSem neq 1 and vDiaSem neq 7>
						<!--- verificar se Feriado Nacional --->
						<cfquery name="rsFeriado" datasource="#snci.dsn#">
							SELECT Fer_Data FROM FeriadoNacional where Fer_Data = '#dtnovoprazo#'
						</cfquery>
						<cfif rsFeriado.recordcount gt 0>
						<cfset nCont = nCont - 1>
						<cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
                        <cfset dtnovoprazo = lsdateformat(dtnovoprazo,"YYYY-MM-DD")>
						</cfif>
					</cfif>
					<!--- Verifica se final de semana  --->
					<cfif vDiaSem eq 1 or vDiaSem eq 7>
						<cfset nCont = nCont - 1>
						<cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
                        <cfset dtnovoprazo = lsdateformat(dtnovoprazo,"YYYY-MM-DD")>
					</cfif>	
				</cfloop>	
			</cfoutput> 
 
			<!--- ===================== --->
 			<cfquery datasource="#snci.dsn#">
 				UPDATE ParecerUnidade SET
				<cfif IsDefined("FORM.frmResp") AND FORM.frmResp NEQ "N">
					Pos_Situacao_Resp=#FORM.frmResp#
				</cfif>
  				<cfset IDArea = #snci.gesunidade#>
				<cfswitch expression="#Form.frmResp#">
					<cfcase value=2>
						<cfif form.frmtransfer eq 'S'>
							<cfquery name="rsMod" datasource="#snci.dsn#">
								SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
								FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
								WHERE Und_Codigo = '#form.cbunidtransfer#'
							</cfquery>
							<cfset strIDGestor = #form.cbunidtransfer#>
							<cfset strNomeGestor = #rsMod.Und_Descricao#>
							<cfset Gestor = '#rsMod.Und_Descricao#'>
						</cfif>			
						<!--- Atualizar variaveis com os dados do CDD ---> 
						<!--- Item da AC respondido por CDD quando Centralizada --->
						<cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
							<!--- uma AC  => verificar se centralizada --->
							<cfquery name="rsCDD" datasource="#snci.dsn#">
								SELECT Und_Codigo, Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsMod.Und_Centraliza#'
							</cfquery>
							<cfif rsCDD.recordcount gt 0>
								<cfset strIDGestor = #rsCDD.Und_Codigo#>
								<cfset strNomeGestor = #rsCDD.Und_Descricao#>
								<cfset Gestor = '#strNomeGestor#'>
							</cfif>
						</cfif>
						, Pos_Situacao = 'PU'
						, Pos_Area = '#strIDGestor#'
						, Pos_NomeArea = '#strNomeGestor#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset situacao = 'PENDENTE DE UNIDADE'>
						<cfset IDArea = #strIDGestor#>
					</cfcase>
					<cfcase value=3>
						, Pos_Situacao = 'SO'
						<!---, Pos_Area = '#strIDGestor#'
						, Pos_NomeArea = '#strNomeGestor#'--->
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
						<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
						<cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
						<cfset situacao = 'SOLUCIONADO'>
						<cfset IDArea = '#qSituacaoResp.Pos_Area#'>
					</cfcase>
					<cfcase value=4>
						<cfif form.frmtransfer eq 'S'>
							<cfquery name="rsReop" datasource="#snci.dsn#">
								SELECT Rep_Codigo, Rep_Nome, Rep_Email FROM Reops WHERE Rep_Codigo = '#form.cbsubordinador#'
							</cfquery>		
						<cfelse>
							<cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
								<!--- uma AC  => verificar se centralizada --->
								<cfset strIDGestor = #rsMod.Und_Centraliza#>
							</cfif>
							<cfquery name="rsReop" datasource="#snci.dsn#">
								SELECT Rep_Codigo, Rep_Nome, Rep_Email FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop WHERE Und_Codigo='#strIDGestor#'
							</cfquery>		
						</cfif>		  
						, Pos_Situacao = 'PO'
						, Pos_Area = '#rsReop.Rep_Codigo#'
						, Pos_Nomearea = '#rsReop.Rep_Nome#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
						<cfset Gestor = '#rsReop.Rep_Nome#'>
						<cfset situacao = 'PENDENTE DE ORGAO SUBORDINADOR'>
						<cfset IDArea = #rsReop.Rep_Codigo#>
						<cfset sdestina = #rsReop.Rep_Email#>
						<cfset nomedestino = #rsReop.Rep_Nome#>
					</cfcase>
					<cfcase value=5>
						<cfquery name="qArea2" datasource="#snci.dsn#">
							SELECT Ars_Sigla, Ars_Descricao, Ars_Email 
							FROM Areas
							WHERE Ars_Codigo = '#Form.cbarea#'
						</cfquery>
						, Pos_Situacao = 'PA'
						, Pos_Area = '#Form.cbarea#'

						, Pos_Nomearea = '#qArea2.Ars_Descricao#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
						<cfset Gestor = '#qArea2.Ars_Descricao#'>
						<cfset situacao = 'PENDENTE DE AREA'>
						<cfset IDArea = #Form.cbarea#>
						<cfset sdestina = #qArea2.Ars_Email#>
						<cfset nomedestino = #qArea2.Ars_Descricao#>
					</cfcase>
					<cfcase value=8>
						<cfquery name="rsSE" datasource="#snci.dsn#">
							SELECT Dir_Sto, Dir_Codigo, Dir_Descricao, Dir_Email
							FROM  Diretoria
							WHERE Dir_Codigo = '#left(form.posarea,2)#'
						</cfquery>
						, Pos_Situacao = 'SE'
						, Pos_Area = '#rsSE.Dir_Sto#'
						, Pos_NomeArea = '#rsSE.Dir_Descricao#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
						<cfset Gestor = '#rsSE.Dir_Descricao#'>
						<cfset situacao = 'PENDENTE SUPERINTENDENCIA ESTADUAL'>
						<cfset IDArea = #rsSE.Dir_Sto#>
						<cfset sdestina = #rsSE.Dir_Email#>
						<cfset nomedestino = #rsSE.Dir_Descricao#>
					</cfcase>
					<cfcase value=9>
						<cfquery name="qArea2" datasource="#snci.dsn#">
							SELECT Ars_Sigla, Ars_Descricao
							FROM Areas
							WHERE Ars_Codigo = '#Form.cbareaCS#'
						</cfquery>
						, Pos_Nomearea = '#qArea2.Ars_Descricao#'
						, Pos_Situacao = 'CS'
						, Pos_Area = '#Form.cbareaCS#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
						<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
						<cfset Gestor = '#qArea2.Ars_Descricao#'>
						<cfset situacao = 'CORPORATIVO CS'>
						<cfset IDArea = #Form.cbareaCS#>
					</cfcase>
					<cfcase value=10>
						<cfquery name="qArea2" datasource="#snci.dsn#">
							SELECT Ars_Sigla,Ars_Descricao
							FROM Areas
							WHERE Ars_Codigo = '#Form.cbarea#'
						</cfquery>
						, Pos_Situacao = 'PS'
						, Pos_Area = '#Form.cbarea#'
						, Pos_Nomearea = '#qArea2.Ars_Descricao#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset Gestor = '#qArea2.Ars_Descricao#'>
						<cfset situacao = 'PONTO SUSPENSO'>
						<cfset IDArea = #Form.cbarea#>
						</cfcase>
						<cfcase value=12>
						, Pos_Situacao = 'PI'
						, Pos_Area = '#strIDGestor#'
						, Pos_NomeArea = '#strNomeGestor#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
						<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
						<cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
						<cfset situacao = 'PONTO IMPROCEDENTE'>
						<cfset IDArea = #strIDGestor#>
						</cfcase>
						<cfcase value=13>
						, Pos_Situacao = 'OC'
						, Pos_Area = '#strIDGestor#'
						, Pos_NomeArea = '#strNomeGestor#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
						<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
						<cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
						<cfset situacao = 'ORIENTACAO CANCELADA'>
						<cfset IDArea = #strIDGestor#>
					</cfcase>
					<cfcase value=15>
						<cfif form.frmtransfer eq 'S'>
							<cfquery name="rsMod" datasource="#snci.dsn#">
								SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
								FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
								WHERE Und_Codigo = '#form.cbunidtransfer#'
							</cfquery>
							<cfset strIDGestor = #form.cbunidtransfer#>
							<cfset strNomeGestor = #rsMod.Und_Descricao#>
							<cfset Gestor = '#rsMod.Und_Descricao#'>
						</cfif>
						<!--- Atualizar variaveis com os dados do CDD ---> 
						<!--- Item da AC respondido por CDD quando Centralizada --->
						<cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
							<!--- ao uma AC  => verificar se centralizada --->
							<cfquery name="rsCDD" datasource="#snci.dsn#">
								SELECT Und_Codigo, Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsMod.Und_Centraliza#'
							</cfquery>
							<cfif rsCDD.recordcount gt 0>
								<cfset strIDGestor = #rsCDD.Und_Codigo#>
								<cfset strNomeGestor = #rsCDD.Und_Descricao#>
								<cfset Gestor = '#strNomeGestor#'>
							</cfif>
						</cfif>
						, Pos_Situacao = 'TU'
						, Pos_Area = '#strIDGestor#'
						, Pos_NomeArea = '#strNomeGestor#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<!---   <cfset Gestor = '#rsMod.Und_Descricao#'> --->
						<cfset situacao = 'TRATAMENTO UNIDADE'>
						<cfset IDArea = #strIDGestor#>
						<cfset sdestina = #rsMod.Und_Email#>
						<cfset nomedestino = #rsMod.Und_Descricao#>
					</cfcase>
					<cfcase value=16>
						<cfif form.frmtransfer eq 'S'>
							<cfquery name="rsReop" datasource="#snci.dsn#">
								SELECT Rep_Codigo, Rep_Nome, Rep_Email FROM Reops WHERE Rep_Codigo = '#form.cbsubordinador#'
							</cfquery>		
						<cfelse>
							<cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
								<!--- uma AC  => verificar se centralizada --->
								<cfset strIDGestor = #rsMod.Und_Centraliza#>
							</cfif>
							<cfquery name="rsReop" datasource="#snci.dsn#">
								SELECT Rep_Codigo, Rep_Nome, Rep_Email FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop WHERE Und_Codigo='#strIDGestor#'
							</cfquery>		
						</cfif>	
						, Pos_Situacao = 'TS'
						, Pos_Area = '#rsReop.Rep_Codigo#'
						, Pos_Nomearea = '#rsReop.Rep_Nome#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset Gestor = '#rsReop.Rep_Nome#'>
						<cfset situacao = 'TRATAMENTO ORGAO SUBORDINADOR'>
						<cfset IDArea = #rsReop.Rep_Codigo#>
						<cfset sdestina = #rsReop.Rep_Email#>
						<cfset nomedestino = #rsReop.Rep_Nome#>
					</cfcase>
					<cfcase value=18>
						<cfif form.frmtransfer eq 'S'>
							<cfquery name="rsMod" datasource="#snci.dsn#">
							SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
							FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
							WHERE Und_Codigo = '#form.cbterctransfer#'
							</cfquery>
							<cfset strIDGestor = #form.cbterctransfer#>
							<cfset strNomeGestor = #rsMod.Und_Descricao#>
							<cfset Gestor = '#rsMod.Und_Descricao#'>
						</cfif>
						, Pos_Situacao = 'TF'
						, Pos_Area = '#strIDGestor#'
						, Pos_NomeArea = '#strNomeGestor#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset Gestor = '#rsMod.Und_Descricao#'>
						<cfset situacao = 'TRATAMENTO TERCEIRIZADA'>
						<cfset IDArea = #strIDGestor#>
						<cfset sdestina = #rsMod.Und_Email#>
						<cfset nomedestino = #rsMod.Und_Descricao#>
					</cfcase>
					<cfcase value=19>
						<cfquery name="qArea2" datasource="#snci.dsn#">
							SELECT Ars_Sigla, Ars_Descricao, Ars_Email FROM Areas	WHERE Ars_Codigo = '#Form.cbarea#'
						</cfquery>
						, Pos_Situacao = 'TA'
						, Pos_Area = '#Form.cbarea#'
						, Pos_Nomearea = '#qArea2.Ars_Descricao#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset Gestor = '#qArea2.Ars_Descricao#'>
						<cfset situacao = 'TRATAMENTO DA AREA'>
						<cfset IDArea = #Form.cbarea#>
						<cfset sdestina = #qArea2.Ars_Email#>
						<cfset nomedestino = #qArea2.Ars_Descricao#>
					</cfcase>
					<cfcase value=20>
						<cfif form.frmtransfer eq 'S'>
							<cfquery name="rsMod" datasource="#snci.dsn#">
							SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
							FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
							WHERE Und_Codigo = '#form.cbterctransfer#'
							</cfquery>
							<cfset strIDGestor = #form.cbterctransfer#>
							<cfset strNomeGestor = #rsMod.Und_Descricao#>
							<cfset Gestor = '#rsMod.Und_Descricao#'>
						</cfif>	
						, Pos_Situacao = 'PF'
						, Pos_Area = '#strIDGestor#'
						, Pos_NomeArea = '#strNomeGestor#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset Gestor = '#rsMod.Und_Descricao#'>
						<cfset situacao = 'PENDENTE DE TERCEIRIZADA'>
						<cfset IDArea = #strIDGestor#>
					</cfcase>
					<cfcase value=21>
						<cfquery name="qArea2" datasource="#snci.dsn#">
							SELECT Ars_Sigla, Ars_Descricao, Ars_Email
							FROM Areas
							WHERE Ars_Codigo = '#Form.cbscia#'
						</cfquery>
						, Pos_Situacao = 'RV'
						, Pos_Area = '#Form.cbscia#'
						, Pos_Nomearea = '#qArea2.Ars_Descricao#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
						<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
						<cfset Gestor = '#qArea2.Ars_Descricao#'>
						<cfset situacao = 'REAVALIACAO'>
						<cfset IDArea = #Form.cbscia#>
						<cfset sdestina = #qArea2.Ars_Email#>
						<cfset nomedestino = #qArea2.Ars_Descricao#>
					</cfcase>
					<cfcase value=23>
						<!--- Status: Tratamento pela SE --->
						<cfquery name="rsSE" datasource="#snci.dsn#">
							SELECT Dir_Sto, Dir_Codigo, Dir_Descricao, Dir_Email
							FROM  Diretoria
							WHERE Dir_Codigo = '#left(form.posarea,2)#'
						</cfquery>
						, Pos_Situacao = 'TO'
						, Pos_Area = '#rsSE.Dir_Sto#'
						, Pos_NomeArea = '#rsSE.Dir_Descricao#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset Gestor = '#rsSE.Dir_Descricao#'>
						<cfset IDArea = #rsSE.Dir_Sto#>
						<cfset situacao = 'TRATAMENTO SUPERINTENDENCIA ESTADUAL'>
						<cfset sdestina = #rsSE.Dir_Email#>
						<cfset nomedestino = #rsSE.Dir_Descricao#>
					</cfcase>
					<cfcase value=24>
						<cfquery name="qArea2" datasource="#snci.dsn#">
							SELECT Ars_Sigla, Ars_Descricao
							FROM Areas
							WHERE Ars_Codigo = '#Form.cbareaCS#'
						</cfquery>
						, Pos_Nomearea = '#qArea2.Ars_Descricao#'
						, Pos_Situacao = 'CS'
						, Pos_Area = '#Form.cbareaCS#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
						<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
						<cfset Gestor = '#qArea2.Ars_Descricao#'>
						<cfset situacao = 'APURACAO'>
						<cfset IDArea = #Form.cbareaCS#>
					</cfcase>
					<cfcase value=25>
						<cfquery name="qArea2" datasource="#snci.dsn#">
							SELECT Ars_Sigla, Ars_Descricao, Ars_Email
							FROM Areas
							WHERE Ars_Codigo = '#Form.cbarea#'
						</cfquery>
						, Pos_Situacao = 'RC'
						, Pos_Area = '#Form.cbarea#'
						, Pos_Nomearea = '#qArea2.Ars_Descricao#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset Gestor = '#qArea2.Ars_Descricao#'>
						<cfset situacao = 'REGULARIZADO - APLICAR O CONTRATO'>
						<cfset IDArea = #Form.cbarea#>
						<cfset sdestina = #qArea2.Ars_Email#>
						<cfset nomedestino = #qArea2.Ars_Descricao#>
					</cfcase>
					<cfcase value=26>
						<cfquery name="qArea2" datasource="#snci.dsn#">
							SELECT Ars_Sigla, Ars_Descricao, Ars_Email
							FROM Areas
							WHERE Ars_Codigo = '#Form.cbarea#'
						</cfquery>
						, Pos_Situacao = 'NC'
						, Pos_Area = '#Form.cbarea#'
						, Pos_Nomearea = '#qArea2.Ars_Descricao#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset Gestor = '#qArea2.Ars_Descricao#'>
						<cfset situacao = 'NAO REGULARIZADO - APLICAR O CONTRATO'>
						<cfset IDArea = #Form.cbarea#>
						<cfset sdestina = #qArea2.Ars_Email#>
						<cfset nomedestino = #qArea2.Ars_Descricao#>
					</cfcase>	   
					<cfcase value=28>
						, Pos_Situacao = 'EA'
						, Pos_Area = '#strIDGestor#'
						, Pos_NomeArea = '#strNomeGestor#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset situacao = 'EM ANALISE'>
						<cfset IDArea = #strIDGestor#>
					</cfcase>	
					<cfcase value=29>
						, Pos_Situacao = 'EC'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset situacao = 'ENCERRADO'>
						<cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
						<cfset IDArea = '#qSituacaoResp.Pos_Area#'>
					</cfcase>	 
					<cfcase value=30>
						<cfquery name="qArea3" datasource="#snci.dsn#">
							SELECT Ars_Sigla, Ars_Descricao
							FROM Areas
							WHERE Ars_Codigo = '#Form.cbscoi#'
						</cfquery>
						, Pos_Area = '#Form.cbscoi#'	   
						, Pos_Nomearea = '#qArea3.Ars_Descricao#'
						, Pos_Situacao = 'TP'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
						<cfset situacao = 'TRANSFERENCIA DE PONTO'>
						<cfset Gestor = '#qArea3.Ars_Sigla#'>		  
						<cfset IDArea = #Form.cbscoi#>
					</cfcase>
					<cfcase value=31>
						, Pos_Situacao = 'JD'
						, Pos_NumProcJudicial = '#Form.posnumprocjudicial#'
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
						<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
						<cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
						<cfset situacao = 'JUDICIALIZADO'>
						<cfset IDArea = '#qSituacaoResp.Pos_Area#'>
					</cfcase>	
				</cfswitch>
    
				<cfset Encaminhamento = 'Opiniao do Controle Interno'>
				<cfset aux_obs = "">  

				<cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
					, Pos_Parecer=
					<!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instrua§aµes SQL --->
					<cfset aux_obs = Trim(FORM.observacao)>
					<cfset aux_obs = Replace(aux_obs,'"','','All')>
					<cfset aux_obs = Replace(aux_obs,"'","","All")>
					<cfset aux_obs = Replace(aux_obs,'*','','All')>
					<cfset aux_obs = Replace(aux_obs,'>','','All')>
					<!---	 <cfset aux_obs = Replace(aux_obs,'&','','All')>
							<cfset aux_obs = Replace(aux_obs,'%','','All')> --->
	
					<cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'A(O)' & '  ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
					<cfif "#Form.frmResp#" eq 25 || "#Form.frmResp#" eq 26 >
						<cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'A(O)' & '  ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'> 
					</cfif> 	 
			
					'#pos_aux#'
				</cfif>
				<cfif IsDefined("FORM.abertura") AND FORM.abertura EQ "Sim">
					, Pos_Abertura = '#FORM.abertura#'
					, Pos_Processo =
					<cfset proc_se = FORM.proc_se>
					<cfset proc_num = FORM.proc_num>
					<cfset proc_ano = FORM.proc_ano>
					<cfset Processo = proc_se & proc_num & proc_ano>
					#Processo#
					, Pos_Tipo_Processo = '#FORM.modalidade#'
					<cfelse>
					, Pos_Abertura = ''
					, Pos_Processo = ''
					, Pos_Tipo_Processo = ''
				</cfif>

				<cfif IsDefined("FORM.VLRecuperado") AND FORM.VLRecuperado NEQ "">
					<cfset aux_vlr = Trim(FORM.VLRecuperado)>
					<cfset aux_vlr = Replace(aux_vlr,'.','','All')>
					<cfset aux_vlr = Replace(aux_vlr,',','.','All')>
					, Pos_VLRecuperado='#aux_vlr#'
				</cfif>
				, pos_username = '#snci.login#'
				, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
				, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
				, Pos_Sit_Resp_Antes = #form.scodresp#
				WHERE Pos_Unidade= '#snci.gesunidade#' AND Pos_Inspecao='#snci.gesavaliacao#' AND Pos_NumGrupo=#snci.gesgrupo# AND Pos_NumItem=#snci.gesitem#
		</cfquery> 
<cfset hhmmss = timeFormat(now(), "HH:mm:ss")>
			<cfset hhmmss = left(hhmmss,2) & mid(hhmmss,4,2) & mid(hhmmss,7,2)>
			<cfquery datasource="#snci.dsn#">
				INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area)
				VALUES 
				(
				'#snci.gesavaliacao#'
				,
				'#snci.gesunidade#'
				,
				#snci.gesgrupo#
				,
				#snci.gesitem#
				,
				convert(char, getdate(), 102)
				,
				'#snci.login#'
				,
				#FORM.frmResp#
				,
				'#hhmmss#'
				,
				<cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
					<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)#  & CHR(13) & CHR(13) & 'AO (À) ' & '  ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
					<cfif "#Form.frmResp#" eq 25 || "#Form.frmResp#" eq 26 >
						<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)#  & CHR(13) & CHR(13) & 'AO (À) ' & '  ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
					</cfif>	 	 
					'#and_obs#'
				<cfelse>
					NULL
				</cfif>
				,
				'#IDArea#'
				)
			</cfquery> 

			<!--- Encerramento do processo --->
			<cfif IsDefined("FORM.frmResp") AND FORM.frmResp EQ "3">
				<cfquery name="qVerificaEncerramento" datasource="#snci.dsn#">
					SELECT COUNT(Pos_Inspecao) AS vTotal
					FROM ParecerUnidade
					WHERE Pos_Unidade='#snci.gesunidade#' AND Pos_Inspecao='#snci.gesavaliacao#' AND Pos_Situacao_Resp <> '3'
				</cfquery>
				<cfif qVerificaEncerramento.vTotal is 0>
				<cfquery datasource="#snci.dsn#">
					UPDATE ProcessoParecerUnidade SET Pro_Situacao = 'EN', Pro_DtEncerr = CONVERT(char, GETDATE(), 102)
					WHERE Pro_Unidade='#snci.gesunidade#' AND Pro_Inspecao='#snci.gesavaliacao#'
				</cfquery>
				</cfif>
			</cfif>

			<!--- Envio de aviso por email para situacao = Tratamento --->
			<cfif Form.frmResp is 15 or Form.frmResp is 16 or Form.frmResp is 18 or Form.frmResp is 19 or Form.frmResp is 23>
	  			<cfoutput>
					<cfif Form.frmResp is 15 or Form.frmResp is 18>
							<!--- Participar ao Orgao subordinador --->
							<cfquery name="rsOrgSub" datasource="#snci.dsn#">
								SELECT Rep_Email FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop WHERE Und_Codigo='#strIDGestor#'
							</cfquery>
							<cfset sdestina = #sdestina# & ';' & #rsOrgSub.Rep_Email#>
					</cfif>

					<cfif findoneof("@", trim(sdestina)) eq 0>
						<cfset sdestina = "gilvanm@correios.com.br">
					</cfif>

					<!---   <cfset sdestina = #sdestina# & ';' & #Form.emailusu#> --->
					<!---     <cfset sdestina = "gilvanm@correios.com.br">  --->
					<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="Relatorio Item Em Tratamento" type="HTML">
						Mensagem autom&atilde;tica. Nao precisa responder!<br><br>
						<strong>
								Ao Gestor do(a) #nomedestino#. <br><br><br>

							&nbsp;&nbsp;&nbsp;Para conhecimento deste Órgão.<br><br>

							&nbsp;&nbsp;&nbsp;Comunicamos que há pontos de Controle Interno "Em Tratamento" de manifestação/Solução.<br><br>

							&nbsp;&nbsp;&nbsp;Unidade: #snci.gesunidade# - #rsMod.Und_Descricao#, Avaliação: #snci.gesavaliacao#, Grupo: #snci.gesgrupo#, Item: #snci.gesitem# e Data de Previsão Solução: #DateFormat(dtnovoprazo,"DD/MM/YYYY")#.<br><br>

							&nbsp;&nbsp;&nbsp;O registro da manifestação está disponível no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório Item Em Tratamento.</a><br><br>

							&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
						</strong>
					</cfmail>						
				</cfoutput>   
                

          

           
           
        <!---       
            <cfcatch type="any">
                <cfset erro = 1>
            </cfcatch>
        </cftry> --->
        <cfif erro eq 0>
            <cfset msg = 'Inserção de Processo Disciplinar, com sucesso!'>
        <cfelse>
            <cfset msg = 'Inserção de Processo Disciplinar, ocorreu um erro!'>            
        </cfif>       
        <cfreturn msg>
    </cffunction>
    <!--- final  manifesto --->
</cfcomponent>