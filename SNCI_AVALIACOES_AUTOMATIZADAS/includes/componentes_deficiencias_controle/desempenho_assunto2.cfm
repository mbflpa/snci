<cfprocessingdirective pageencoding="utf-8">

<!--- Consulta para obter os dois últimos meses disponíveis na tabela --->
<cfquery name="rsUltimosMeses" datasource="#application.dsn_avaliacoes_automatizadas#">
    SELECT TOP 2 FORMAT(data_encerramento, 'yyyy-MM') AS mes_ano
    FROM fato_verificacao
    WHERE data_encerramento IS NOT NULL
    GROUP BY FORMAT(data_encerramento, 'yyyy-MM')
    ORDER BY mes_ano DESC
</cfquery>

<cfif rsUltimosMeses.recordCount LT 2>
    <div class="snci-desempenho-assunto2">
        <div class="desempenho-container">
            <div class="alerta">Não há dados suficientes para exibir o desempenho por assunto.</div>
        </div>
    </div>
    <cfabort>
</cfif>

<cfset mesAtualId = rsUltimosMeses.mes_ano[1]>
<cfset mesAnteriorId = rsUltimosMeses.mes_ano[2]>
<cfset nomeMesAtual = monthAsString(listLast(mesAtualId, "-")) & "/" & left(mesAtualId, 4)>
<cfset nomeMesAnterior = monthAsString(listLast(mesAnteriorId, "-")) & "/" & left(mesAnteriorId, 4)>

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
<cfdump var="#rsDadosAssunto#" label="Dados por Assunto" abortOnError="true">
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
    .snci-desempenho-assunto2 .desempenho-container {
        display: flex;
        flex-direction: column;
        gap: 20px;
    }
    .snci-desempenho-assunto2 .comparison-container {
        background: var(--card-bg-color, #fff);
        padding: 20px;
        border-radius: 16px;
        box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.05), 0 4px 6px -4px rgb(0 0 0 / 0.05);
        border: 1px solid var(--border-color, #e2e8f0);
        transition: all 0.3s ease;
    }
    .snci-desempenho-assunto2 .comparison-container h2 {
        font-size: 1.5rem;
        font-weight: 600;
        margin: 0 0 24px 0;
        color: var(--text-primary, #1e293b);
        position: relative;
        padding-bottom: 10px;
    }
    .snci-desempenho-assunto2 .comparison-container h2::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        width: 50px;
        height: 3px;
        background: linear-gradient(90deg, #457b9d, #a8dadc);
        border-radius: 2px;
    }
    .snci-desempenho-assunto2 .comparison-item {
        display: grid;
        grid-template-columns: 2fr 3fr 1fr;
        align-items: center;
        gap: 10px;
        padding: 15px 0;
        border-bottom: 1px solid var(--border-color, #e2e8f0);
        transition: all 0.3s ease;
    }
    .snci-desempenho-assunto2 .comparison-item:last-child { border-bottom: none; }
    .snci-desempenho-assunto2 .comparison-item:hover {
        background-color: rgba(0, 51, 102, 0.02);
        padding-left: 10px;
        border-radius: 8px;
    }
    .snci-desempenho-assunto2 .item-title {
        font-weight: 500;
        color: var(--text-primary, #1e293b);
        font-size: 0.95rem;
    }
    .snci-desempenho-assunto2 .item-bars {
        position: relative;
    }
    .snci-desempenho-assunto2 .item-bars .bar {
        height: 12px;
        border-radius: 6px;
        background-color: var(--border-color, #e2e8f0);
        transition: width 1.5s ease-in-out;
        position: relative;
        overflow: hidden;
    }
    .snci-desempenho-assunto2 .item-bars .bar.anterior {
        background: linear-gradient(90deg, #a8dadc, #7fb3d3);
        margin-bottom: 8px;
    }
    .snci-desempenho-assunto2 .item-bars .bar.atual {
        background: linear-gradient(90deg, #457b9d, #1e3d59);
    }
    .snci-desempenho-assunto2 .item-bars .label {
        display: flex;
        justify-content: space-between;
        font-size: 0.8rem;
        color: var(--text-secondary, #64748b);
        margin-bottom: 6px;
        font-weight: 500;
    }
    .snci-desempenho-assunto2 .item-change {
        text-align: right;
    }
    .snci-desempenho-assunto2 .item-change .value {
        font-size: 1.1rem;
        font-weight: 600;
        display: block;
        margin-bottom: 4px;
    }
    .snci-desempenho-assunto2 .item-change .status {
        font-size: 0.85rem;
        opacity: 0.8;
    }
    .snci-desempenho-assunto2 .increase { color: #e63946; }
    .snci-desempenho-assunto2 .decrease { color: #2a9d8f; }
    .snci-desempenho-assunto2 .alerta {
        color: #e63946;
        background: #fff0f0;
        border-radius: 8px;
        padding: 16px;
        text-align: center;
        font-weight: 600;
    }
    @media (max-width: 1200px) {
        .snci-desempenho-assunto2 .comparison-item {
            grid-template-columns: 1fr;
            gap: 16px;
            padding: 20px 0;
        }
        .snci-desempenho-assunto2 .item-change { text-align: left; }
    }
    @media (max-width: 768px) {
        .snci-desempenho-assunto2 .desempenho-container { gap: 15px; }
        .snci-desempenho-assunto2 .comparison-container { padding: 15px; }
        .snci-desempenho-assunto2 .comparison-container h2 { font-size: 1.3rem; }
    }
</style>

<div class="snci-desempenho-assunto2">
    <div class="desempenho-container">
        <div class="comparison-container">
            <h2>Desempenho por Assunto</h2>
            <cfloop collection="#dados#" item="chave">
                <cfset item = dados[chave]>
                <cfif item.anterior GT 0 OR item.atual GT 0>
                    <div class="comparison-item fade-in-up">
                        <div class="item-title"><cfoutput>#item.titulo#</cfoutput></div>
                        <div class="item-bars">
                            <div class="label">
                                <span><cfoutput>#nomeMesAnterior#</cfoutput></span>
                                <span><cfoutput>#item.anterior#</cfoutput></span>
                            </div>
                            <div class="bar anterior animated-bar" style="width:0%;" data-width="<cfoutput>#(maxValor GT 0 ? round(item.anterior/maxValor*100) : 0)#%</cfoutput>"></div>
                            <div class="label" style="margin-top:8px;">
                                <span><cfoutput>#nomeMesAtual#</cfoutput></span>
                                <span><cfoutput>#item.atual#</cfoutput></span>
                            </div>
                            <div class="bar atual animated-bar" style="width:0%;" data-width="<cfoutput>#(maxValor GT 0 ? round(item.atual/maxValor*100) : 0)#%</cfoutput>"></div>
                        </div>
                        <div class="item-change <cfoutput>#item.tipo#</cfoutput>">
                            <span class="value">
                                <cfif item.tipo eq "increase">↑<cfelse>↓</cfif>
                                <cfoutput>#abs(item.delta)#</cfoutput>
                            </span>
                            <span class="status">
                                <cfif item.anterior GT 0>
                                    <cfoutput>#item.percentual#%</cfoutput>
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
        // Animação das barras
        $('.snci-desempenho-assunto2 .animated-bar').each(function() {
            var $this = $(this);
            var width = $this.data('width') || '0%';
            setTimeout(function() {
                $this.css('width', width);
            }, 400);
        });
        // Animação de entrada dos cards
        $('.snci-desempenho-assunto2 .fade-in-up').each(function(i) {
            var $this = $(this);
            setTimeout(function() {
                $this.addClass('animate');
            }, i * 100);
        });
    });
</script>
