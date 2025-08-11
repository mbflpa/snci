<cfcomponent displayname="TesteAplicados" hint="CFC para listar os testes aplicados" output="false">

    <cffunction name="rsTestesAplicados" access="public" returntype="struct" hint="Busca todos os testes aplicados">
        <cfset var qryAssuntosPorTipo= "">
        <cfset var dados = structNew()>
        
        <cftry>
            <cfquery name="qryAssuntosPorTipo" datasource="#application.dsn_avaliacoes_automatizadas#">
                WITH cteAssuntoTipoUnidade AS (SELECT 
                            p.*,
                        LTRIM(RTRIM(value)) AS TipoIndividual
                    FROM aa_dim_teste_processos p
                    CROSS APPLY STRING_SPLIT(p.TIPO_UNI, ',')
                ),
                cteUnidadeSelecionada AS (
                    SELECT 
                            CASE 
                                WHEN tu.TUN_Descricao IN ('CTC (COM GCCAP)', 'CTE (COM GCCAP)', 'CTCE (COM GCCAP)') 
                                    THEN REPLACE(tu.TUN_Descricao, ' (COM GCCAP)', '')
                                ELSE tu.TUN_Descricao
                            END AS TUN_Descricao
                        FROM Unidades u
                        INNER JOIN Tipo_Unidades tu 
                            ON tu.TUN_Codigo = u.Und_TipoUnidade
                    WHERE CAST(u.Und_MCU AS INT) = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.rsUsuarioParametros.Und_MCU#">
                )


                SELECT cte.* FROM cteAssuntoTipoUnidade cte
                INNER JOIN cteUnidadeSelecionada us ON us.TUN_Descricao = cte.TipoIndividual
                WHERE ativo=1
                ORDER BY cte.sk_grupo_item
            </cfquery>
            
            <cfcatch>
                <cfset dados.erro = cfcatch.message>
            </cfcatch>
        </cftry>
        
        <cfif qryAssuntosPorTipo.recordcount>
            <cfset dados.testes = qryAssuntosPorTipo>
        </cfif>
        
        <cfreturn dados>
    </cffunction>

</cfcomponent>