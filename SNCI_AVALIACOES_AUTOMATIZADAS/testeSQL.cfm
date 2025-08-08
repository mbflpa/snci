 <cfquery name="rsDadosDetalhados" datasource="#application.dsn_avaliacoes_automatizadas#">
        WITH cteAssuntoTipoUnidade AS (SELECT 
                        p.*,
                    LTRIM(RTRIM(value)) AS TipoIndividual
                FROM aa_dim_teste_processos p
                CROSS APPLY STRING_SPLIT(p.TIPO_UNI, ',')
            ),
            cteUnidadeSelecionada AS (
                SELECT tu.TUN_Descricao FROM Unidades u
                INNER JOIN Tipo_Unidades tu ON tu.TUN_Codigo = u.Und_TipoUnidade
                WHERE u.Und_MCU = '00004237'
            )

            SELECT cte.* FROM cteAssuntoTipoUnidade cte
            INNER JOIN cteUnidadeSelecionada us ON us.TUN_Descricao = cte.TipoIndividual
            WHERE ativo=1
            ORDER BY cte.sk_grupo_item
    
</cfquery>
<cfdump var="#rsDadosDetalhados#">
