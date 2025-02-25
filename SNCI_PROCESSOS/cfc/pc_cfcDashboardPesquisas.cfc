<cfcomponent>
    <cffunction name="getPesquisas" access="remote" returntype="string" returnformat="json">
        <cfargument name="matricula" type="string" required="false" default="">
        <cfargument name="processo" type="string" required="false" default="">
        <cfargument name="mcu" type="string" required="false" default="">
        <cfargument name="dataInicio" type="string" required="false" default="">
        <cfargument name="dataFim" type="string" required="false" default="">
        
        <cfquery name="qPesquisas" datasource="#application.dsn_processos#">
            SELECT 
                pc_pesq_id,
                pc_usu_matricula,
                pc_processo_id,
                pc_org_mcu,
                pc_pesq_comunicacao,
                pc_pesq_interlocucao,
                pc_pesq_reuniao_encerramento,
                pc_pesq_relatorio,
                pc_pesq_pos_trabalho,
                pc_pesq_importancia_processo,
                pc_pesq_pontualidade,
                pc_pesq_observacao,
                pc_pesq_data_hora
            FROM pc_pesquisas
            WHERE 1=1
            <cfif len(arguments.matricula)>
                AND pc_usu_matricula = <cfqueryparam value="#arguments.matricula#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif len(arguments.processo)>
                AND pc_processo_id = <cfqueryparam value="#arguments.processo#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif len(arguments.mcu)>
                AND pc_org_mcu = <cfqueryparam value="#arguments.mcu#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif len(arguments.dataInicio) AND len(arguments.dataFim)>
                AND pc_pesq_data_hora BETWEEN 
                    <cfqueryparam value="#arguments.dataInicio#" cfsqltype="cf_sql_timestamp">
                    AND 
                    <cfqueryparam value="#arguments.dataFim#" cfsqltype="cf_sql_timestamp">
            </cfif>
            ORDER BY pc_pesq_data_hora DESC
        </cfquery>
        
        <cfreturn serializeJSON(qPesquisas)>
    </cffunction>

    <cffunction name="getEstatisticas" access="remote" returntype="struct" output="false">
        <cfargument name="ano" type="string" required="true">
        
        <cfset var retorno = structNew()>
        <cfset var qryPesquisas = "">
        <cfset var qryEvolucao = "">
        
        <cfquery name="qryPesquisas" datasource="#application.dsn_processos#">
            SELECT 
                COUNT(*) as total_pesquisas,
                COALESCE(CAST(AVG(CAST(pc_pesq_comunicacao AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_comunicacao,
                COALESCE(CAST(AVG(CAST(pc_pesq_interlocucao AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_interlocucao,
                COALESCE(CAST(AVG(CAST(pc_pesq_reuniao_encerramento AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_reuniao,
                COALESCE(CAST(AVG(CAST(pc_pesq_relatorio AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_relatorio,
                COALESCE(CAST(AVG(CAST(pc_pesq_pos_trabalho AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_pos_trabalho,
                COALESCE(CAST(AVG(CAST(pc_pesq_pontualidade AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_pontualidade
            FROM pc_pesquisas 
            WHERE YEAR(pc_pesq_data_hora) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
        </cfquery>
    
        <cfquery name="qryEvolucao" datasource="#application.dsn_processos#">
            SELECT 
                FORMAT(pc_pesq_data_hora, 'yyyy-MM') as mes,
                AVG((pc_pesq_comunicacao + pc_pesq_interlocucao + pc_pesq_reuniao_encerramento + 
                     pc_pesq_relatorio + pc_pesq_pos_trabalho) / 5.0) as media_geral
            FROM pc_pesquisas 
            WHERE YEAR(pc_pesq_data_hora) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            GROUP BY FORMAT(pc_pesq_data_hora, 'yyyy-MM')
            ORDER BY mes
        </cfquery>
    
        <cfset mediaGeral = (
            val(qryPesquisas.media_comunicacao) +
            val(qryPesquisas.media_interlocucao) +
            val(qryPesquisas.media_reuniao) +
            val(qryPesquisas.media_relatorio) +
            val(qryPesquisas.media_pos_trabalho)
        ) / 5>
    
        <cfset var evolucaoArray = []>
        <cfloop query="qryEvolucao">
            <cfset arrayAppend(evolucaoArray, {
                "mes": mes,
                "media": NumberFormat(media_geral, "999.99")
            })>
        </cfloop>
    
        <cfset retorno = {
            "total": qryPesquisas.total_pesquisas,
            "comunicacao": NumberFormat(qryPesquisas.media_comunicacao, "999.99"),
            "interlocucao": NumberFormat(qryPesquisas.media_interlocucao, "999.99"),
            "reuniao": NumberFormat(qryPesquisas.media_reuniao, "999.99"), 
            "relatorio": NumberFormat(qryPesquisas.media_relatorio, "999.99"),
            "pos_trabalho": NumberFormat(qryPesquisas.media_pos_trabalho, "999.99"),
            "pontualidadePercentual": NumberFormat(qryPesquisas.media_pontualidade * 100, "999.99"),
            "mediaGeral": NumberFormat(mediaGeral, "999.99"),
            "medias": [
                val(qryPesquisas.media_comunicacao),
                val(qryPesquisas.media_interlocucao),
                val(qryPesquisas.media_reuniao),
                val(qryPesquisas.media_relatorio),
                val(qryPesquisas.media_pos_trabalho)
            ],
            "evolucaoTemporal": evolucaoArray
        }>
    
        <cfreturn retorno>
    </cffunction>

    <cffunction name="exportarPDF" access="remote" returntype="void">
        <cfargument name="filtros" type="string" required="false" default="">
        
        <cfcontent type="application/pdf">
        <cfdocument format="PDF">
            <cfinclude template="relatorio_pesquisas.cfm">
        </cfdocument>
    </cffunction>
    <!-- As funções acima serão consumidas via AJAX no dashboard -->
</cfcomponent>
