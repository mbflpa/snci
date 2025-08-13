<cfquery name="qryAssuntosPorTipo" datasource="#application.dsn_avaliacoes_automatizadas#">
                WITH cteAssuntoTipoUnidade AS (SELECT 
                            p.*,
                        LTRIM(RTRIM(value)) AS TipoIndividual
                    FROM aa_dim_teste_processos p
                    CROSS APPLY STRING_SPLIT(p.TIPO_UNI, ',')
                ),
                cteUnidadeSelecionada AS (
                  SELECT 
                    REPLACE(
                        REPLACE(tu.TUN_Descricao, ' (COM GCCAP)', ''),
                        ' (SEM GCCAP)', ''
                    ) AS TUN_Descricao
                    FROM Unidades u
                    INNER JOIN Tipo_Unidades tu 
                    ON tu.TUN_Codigo = u.Und_TipoUnidade
                    WHERE CAST(u.Und_MCU AS INT) = <cfqueryparam cfsqltype="cf_sql_integer" value="431083">
                )

                SELECT cte.* FROM cteAssuntoTipoUnidade cte
                INNER JOIN cteUnidadeSelecionada us ON us.TUN_Descricao = cte.TipoIndividual
                WHERE ativo=1
                ORDER BY cte.sk_grupo_item
              
                
             </cfquery>


    <cfdump var="#qryAssuntosPorTipo#" label="qryAssuntosPorTipo">
