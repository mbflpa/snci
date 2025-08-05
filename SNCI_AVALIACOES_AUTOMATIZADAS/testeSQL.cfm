 <cfquery name="rsDadosDetalhados" datasource="#application.dsn_avaliacoes_automatizadas#">
        SELECT 
            p.MANCHETE,
                        p.sk_grupo_item,
                        p.TESTE AS teste,
            LTRIM(RTRIM(value)) AS TipoIndividual
        FROM dim_teste_processos p
        CROSS APPLY STRING_SPLIT(p.TIPO_UNI, ',')
</cfquery>
<cfdump var="#rsDadosDetalhados#">
