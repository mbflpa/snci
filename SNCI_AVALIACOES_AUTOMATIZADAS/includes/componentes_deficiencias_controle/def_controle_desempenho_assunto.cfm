<cfprocessingdirective pageencoding="utf-8">

<!-- Inicializa nomes dos meses para evitar erro de variável indefinida -->
<cfset nomeMesAtual = "Mês Atual">
<cfset nomeMesAnterior = "Mês Anterior">
<!--- Consulta para obter os dois últimos meses disponíveis na tabela --->
<cfquery name="rsUltimosMeses" datasource="#application.dsn_avaliacoes_automatizadas#">
    SELECT TOP 2 FORMAT(data_encerramento, 'yyyy-MM') AS mes_ano
    FROM fato_verificacao
    WHERE data_encerramento IS NOT NULL
    GROUP BY FORMAT(data_encerramento, 'yyyy-MM')
    ORDER BY mes_ano DESC
</cfquery>

<cfif rsUltimosMeses.recordCount GTE 2>
    <cfset mesAtualId = rsUltimosMeses.mes_ano[1]>
    <cfset mesAnteriorId = rsUltimosMeses.mes_ano[2]>
    <cfset nomeMesAtual = monthAsString(listLast(mesAtualId, "-")) & "/" & left(mesAtualId, 4)>
    <cfset nomeMesAnterior = monthAsString(listLast(mesAnteriorId, "-")) & "/" & left(mesAnteriorId, 4)>
<cfelse>
    <cfset mesAtualId = "">
    <cfset mesAnteriorId = "">
</cfif>


<!--- Consulta agregada por MANCHETE e mês --->
<cfquery name="rsDadosAssunto" datasource="#application.dsn_avaliacoes_automatizadas#">
    SELECT DISTINCT
        p.MANCHETE,
        FORMAT(f.data_encerramento, 'yyyy-MM') AS mes_ano,
        f.NC_Eventos AS total_eventos
    FROM fato_verificacao f
    INNER JOIN dim_teste_processos p ON f.sk_grupo_item = p.sk_grupo_item
    WHERE f.sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.rsUsuarioParametros.Und_MCU#">
      AND f.suspenso = 0
      AND f.sk_grupo_item <> 12
      AND FORMAT(f.data_encerramento, 'yyyy-MM') IN (
        <cfqueryparam value="#mesAtualId#,#mesAnteriorId#" list="true" cfsqltype="cf_sql_varchar">
      )
  
</cfquery>

<!--- Monta estrutura de dados por MANCHETE --->
<cfset dados = {}>

<cfloop query="rsDadosAssunto">
    <cfset chave = rereplace(MANCHETE, "[^A-Za-z0-9]", "", "all")>
    <cfif NOT structKeyExists(dados, chave)>
        <cfset dados[chave] = { titulo = MANCHETE, anterior = 0, atual = 0 }>
    </cfif>
    <cfif mes_ano EQ mesAnteriorId>
        <cfset dados[chave].anterior = total_eventos>
    <cfelseif mes_ano EQ mesAtualId>
        <cfset dados[chave].atual = total_eventos>
    </cfif>
</cfloop>

<!--- Calcula evolução percentual e encontra o maior valor para escala das barras --->
<cfset maxValor = 0>
<cfloop collection="#dados#" item="chave">
    <cfset registro = dados[chave]>
    <cfset anterior = registro.anterior>
    <cfset atual = registro.atual>
    <cfset delta = atual - anterior>
    <cfset percentual = (anterior GT 0 ? round((delta/anterior)*100) : (atual GT 0 ? 100 : 0))>
    <cfset tipo = (delta GTE 0 ? "increase" : "decrease")>
    <cfset registro.percentual = percentual>
    <cfset registro.tipo = tipo>
    <cfset registro.delta = delta>
    <cfif anterior GT maxValor>
        <cfset maxValor = anterior>
    </cfif>
    <cfif atual GT maxValor>
        <cfset maxValor = atual>
    </cfif>
</cfloop>

<style>
        .snci-desempenho-assunto .desempenho-container {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .snci-desempenho-assunto .comparison-container {
            background: #fff;
            padding: 12px 16px;
            border-radius: 12px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
            border: 1px solid #e2e8f0;
        }

        .snci-desempenho-assunto .comparison-container h2 {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 16px;
            color: #1e293b;
            padding-bottom: 6px;
            position: relative;
        }

        .snci-desempenho-assunto .comparison-container h2::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 2px;
            background: linear-gradient(90deg, #457b9d, #a8dadc);
            border-radius: 1px;
        }

        .snci-desempenho-assunto .comparison-item {
            display: grid;
            grid-template-columns: 2fr 3fr 1fr;
            align-items: center;
            gap: 6px;
            padding: 6px 0;
            border-bottom: 1px solid #e2e8f0;
            padding-left: 12px;
            padding-right: 12px;
        }

        .snci-desempenho-assunto .comparison-item:last-child {
            border-bottom: none;
        }

        .snci-desempenho-assunto .item-title {
            font-size: 0.85rem;
            font-weight: 500;
            color: #1e293b;
        }

        .snci-desempenho-assunto .item-bars {
            position: relative;
        }

        .snci-desempenho-assunto .label {
            display: flex;
            justify-content: space-between;
            font-size: 0.65rem;
            color: #64748b;
            margin-bottom: 2px;
        }

        .bar-wrapper {
            background-color: #ffffff;
            border-radius: 6px;
            box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.15);
            height: 10px;
            position: relative;
            margin-bottom: 4px;
        }

        .bar-wrapper:last-child {
            margin-bottom: 0;
        }

        .bar {
            height: 100%;
            border-radius: 6px;
            transition: width 1.5s ease-in-out;
            position: absolute;
            top: 0;
            left: 0;
        }

        .bar.anterior {
            background: linear-gradient(90deg, #a8dadc, #7fb3d3);
            z-index: 1;
        }

        .bar.atual {
            background: linear-gradient(90deg, #457b9d, #1e3d59);
            z-index: 1;
        }

        .snci-desempenho-assunto .item-change {
            text-align: right;
        }

        .snci-desempenho-assunto .item-change .value {
            font-size: 0.95rem;
            font-weight: 600;
            margin-bottom: 2px;
            display: block;
        }

        .snci-desempenho-assunto .item-change .status {
            font-size: 0.75rem;
            opacity: 0.85;
        }

        .snci-desempenho-assunto .increase { color: #e63946; }
        .snci-desempenho-assunto .decrease { color: #2a9d8f; }

        @media (max-width: 768px) {
            .snci-desempenho-assunto .comparison-item {
                grid-template-columns: 1fr;
                gap: 8px;
                padding: 12px 0;
                
            }

            .snci-desempenho-assunto .item-change {
                text-align: left;
            }
        }

        .snci-desempenho-assunto .comparison-item:nth-child(even) {
            background-color: rgba(0, 51, 102, 0.03); /* leve destaque no hover */
            border-radius: 6px;
            padding-left: 12px;
            padding-right: 12px;
        }

    </style>
</head>
<body>

<div class="container snci-desempenho-assunto">
   
    <div class="desempenho-container">
        <div class="comparison-container">
            <h2>Desempenho por Assunto <span style="font-size: 0.85rem;">(<cfoutput>#nomeMesAtual# x #nomeMesAnterior#</cfoutput>)</span></h2>
            <cfloop collection="#dados#" item="chave">
                <cfset item = dados[chave]>
                <cfif item.anterior GT 0 OR item.atual GT 0>
                    <div class="comparison-item">
                        <div class="item-title"><cfoutput>#item.titulo#</cfoutput></div>

                        <div class="item-bars">
                            <div class="label">
                                <span><cfoutput>#nomeMesAnterior#</cfoutput></span>
                                <span><cfoutput>#item.anterior#</cfoutput></span>
                            </div>
                            <div class="bar-wrapper">
                                <div class="bar anterior animated-bar" style="width:0%;" data-width="<cfoutput>#(maxValor GT 0 ? round(item.anterior/maxValor*100) : 0)#%</cfoutput>"></div>
                            </div>

                            <div class="label mt-1">
                                <span><cfoutput>#nomeMesAtual#</cfoutput></span>
                                <span><cfoutput>#item.atual#</cfoutput></span>
                            </div>
                            <div class="bar-wrapper">
                                <div class="bar atual animated-bar" style="width:0%;" data-width="<cfoutput>#(maxValor GT 0 ? round(item.atual/maxValor*100) : 0)#%</cfoutput>"></div>
                            </div>
                        </div>

                        <div class="item-change <cfoutput>#item.tipo#</cfoutput>">
                            <span class="value">
                                <cfif item.tipo eq "increase">↑<cfelse>↓</cfif>
                                <cfoutput>#abs(item.delta)#</cfoutput>
                            </span>
                            <span class="status">
                                <cfif item.anterior GT 0>
                                    <cfoutput>#abs(item.percentual)#%</cfoutput>
                                <cfelse>
                                    <cfoutput>#(item.atual GT 0 ? 100 : 0)#%</cfoutput>
                                </cfif>
                                <cfif item.tipo eq "increase"> de aumento<cfelse> de redução</cfif>
                            </span>
                        </div>
                    </div>
                </cfif>
            </cfloop>
        </div>
    </div>
</div>


<script>
    $(document).ready(function() {
        $(document).ready(function(){
            $('.animated-bar').each(function(){
                var width = $(this).data('width');
                $(this).css('width', width);
            });
        });

    });
</script>
</script>
