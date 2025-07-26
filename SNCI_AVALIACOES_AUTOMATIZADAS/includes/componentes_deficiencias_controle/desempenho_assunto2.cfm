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
<cfset assuntosEmAlta = 0>
<cfset assuntosEmQueda = 0>
<cfset somaPercentuais = 0>
<cfset totalAssuntos = 0>

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
    
    <cfif anterior GT 0 OR atual GT 0>
        <cfset totalAssuntos = totalAssuntos + 1>
        <cfif delta GT 0>
            <cfset assuntosEmAlta = assuntosEmAlta + 1>
        <cfelseif delta LT 0>
            <cfset assuntosEmQueda = assuntosEmQueda + 1>
        </cfif>
        <cfset somaPercentuais = somaPercentuais + abs(percentual)>
    </cfif>
    
    <cfif anterior GT maxValor>
        <cfset maxValor = anterior>
    </cfif>
    <cfif atual GT maxValor>
        <cfset maxValor = atual>
    </cfif>
</cfloop>

<cfset variacaoMedia = (totalAssuntos GT 0 ? round(somaPercentuais / totalAssuntos) : 0)>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
.snci-desempenho-assunto {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background-color: #f8fafc;
    padding: 20px;
}

.desempenho-container {
    max-width: 1200px;
    margin: 0 auto;
}

.header-section {
    background: white;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.header-title {
    display: flex;
    align-items: center;
    gap: 12px;
}

.header-title .icon {
    width: 24px;
    height: 24px;
    background: #3b82f6;
    border-radius: 6px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 12px;
}

.header-title h1 {
    font-size: 1.5rem;
    font-weight: 600;
    color: #1e293b;
    margin: 0;
}

.header-subtitle {
    color: #64748b;
    font-size: 0.875rem;
    margin: 4px 0 0 36px;
}

.header-badge {
    background: #f1f5f9;
    color: #475569;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 0.875rem;
    font-weight: 500;
}

.content-section {
    background: white;
    border-radius: 12px;
    padding: 0;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    overflow: hidden;
}

.comparison-item {
    display: grid;
    grid-template-columns: 2fr 3fr 1fr;
    align-items: center;
    gap: 20px;
    padding: 20px 24px;
    border-bottom: 1px solid #f1f5f9;
}

.comparison-item:last-child {
    border-bottom: none;
}

.item-title {
    font-size: 0.95rem;
    font-weight: 500;
    color: #1e293b;
    line-height: 1.4;
}

.item-subtitle {
    color: #64748b;
    font-size: 0.8rem;
    margin-top: 2px;
}

.item-bars {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.bar-row {
    display: flex;
    align-items: center;
    gap: 12px;
}

.bar-label {
    font-size: 0.8rem;
    color: #64748b;
    min-width: 80px;
    text-align: right;
}

.bar-container {
    flex: 1;
    height: 8px;
    background: #f1f5f9;
    border-radius: 4px;
    position: relative;
    overflow: hidden;
}

.bar {
    height: 100%;
    border-radius: 4px;
    transition: width 1.5s ease-out;
    position: relative;
}

.bar.anterior {
    background: #94a3b8;
}

.bar.atual {
    background: #3b82f6;
}

.bar-value {
    font-size: 0.8rem;
    color: #1e293b;
    font-weight: 500;
    min-width: 30px;
    text-align: left;
}

.item-change {
    text-align: right;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 4px;
}

.change-icon {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 0.9rem;
    font-weight: 600;
}

.change-percentage {
    font-size: 0.8rem;
    font-weight: 500;
}

.change-label {
    font-size: 0.75rem;
    color: #64748b;
}

.increase {
    color: #dc2626;
}

.decrease {
    color: #16a34a;
}

.summary-section {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
    margin-top: 20px;
}

.summary-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    text-align: center;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    position: relative;
}

.summary-icon {
    font-size: 1.5rem;
    margin-bottom: 12px;
    opacity: 0.8;
}

.summary-number {
    font-size: 2.5rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 8px;
}

.summary-label {
    color: #64748b;
    font-size: 0.875rem;
    font-weight: 500;
}

.summary-card.alta .summary-number,
.summary-card.alta .summary-icon {
    color: #dc2626;
}

.summary-card.queda .summary-number,
.summary-card.queda .summary-icon {
    color: #16a34a;
}

.summary-card.media .summary-number,
.summary-card.media .summary-icon {
    color: #3b82f6;
}

@media (max-width: 768px) {
    .header-section {
        flex-direction: column;
        align-items: flex-start;
        gap: 12px;
    }
    
    .header-subtitle {
        margin-left: 0;
    }
    
    .comparison-item {
        grid-template-columns: 1fr;
        gap: 16px;
        padding: 16px;
    }
    
    .item-change {
        text-align: left;
        align-items: flex-start;
    }
    
    .summary-section {
        grid-template-columns: 1fr;
        gap: 12px;
    }
    
    .bar-row {
        gap: 8px;
    }
    
    .bar-label {
        min-width: 60px;
        font-size: 0.75rem;
    }
}
</style>

<div class="snci-desempenho-assunto">
    <div class="desempenho-container">
        <!-- Header Section -->
        <div class="header-section">
            <div class="header-title">
                <div class="icon"><i class="fas fa-chart-bar"></i></div>
                <div>
                    <h1>Desempenho por Assunto</h1>
                    <div class="header-subtitle"><cfoutput>#nomeMesAnterior# x #nomeMesAtual#</cfoutput></div>
                </div>
            </div>
            <div class="header-badge">
                <cfoutput>#totalAssuntos# assuntos</cfoutput>
            </div>
        </div>

        <!-- Content Section -->
        <div class="content-section">
            <cfloop collection="#dados#" item="chave">
                <cfset item = dados[chave]>
                <cfif item.anterior GT 0 OR item.atual GT 0>
                    <div class="comparison-item">
                        <div>
                            <div class="item-title"><cfoutput>#item.titulo#</cfoutput></div>
                            <div class="item-subtitle">Comparativo mensal</div>
                        </div>

                        <div class="item-bars">
                            <div class="bar-row">
                                <div class="bar-label"><cfoutput>#nomeMesAnterior#</cfoutput></div>
                                <div class="bar-container">
                                    <div class="bar anterior animated-bar" style="width:0%;" data-width="<cfoutput>#(maxValor GT 0 ? round(item.anterior/maxValor*100) : 0)#%</cfoutput>"></div>
                                </div>
                                <div class="bar-value"><cfoutput>#item.anterior#</cfoutput></div>
                            </div>
                            
                            <div class="bar-row">
                                <div class="bar-label"><cfoutput>#nomeMesAtual#</cfoutput></div>
                                <div class="bar-container">
                                    <div class="bar atual animated-bar" style="width:0%;" data-width="<cfoutput>#(maxValor GT 0 ? round(item.atual/maxValor*100) : 0)#%</cfoutput>"></div>
                                </div>
                                <div class="bar-value"><cfoutput>#item.atual#</cfoutput></div>
                            </div>
                        </div>

                        <div class="item-change">
                            <div class="change-icon <cfoutput>#item.tipo#</cfoutput>">
                                <cfif item.tipo eq "increase"><i class="fas fa-arrow-trend-up"></i><cfelse><i class="fas fa-arrow-trend-down"></i></cfif>
                                <cfoutput>+#abs(item.delta)#</cfoutput>
                            </div>
                            <div class="change-percentage <cfoutput>#item.tipo#</cfoutput>">
                                <cfif item.anterior GT 0>
                                    <cfoutput>#abs(item.percentual)#%</cfoutput>
                                <cfelse>
                                    <cfoutput>#(item.atual GT 0 ? 100 : 0)#%</cfoutput>
                                </cfif>
                            </div>
                            <div class="change-label">
                                <cfif item.tipo eq "increase">de aumento<cfelse>de redução</cfif>
                            </div>
                        </div>
                    </div>
                </cfif>
            </cfloop>
        </div>

        <!-- Summary Section -->
        <div class="summary-section">
            <div class="summary-card alta">
                <div class="summary-icon"><i class="fas fa-trending-up"></i></div>
                <div class="summary-number"><cfoutput>#assuntosEmAlta#</cfoutput></div>
                <div class="summary-label">Assuntos em alta</div>
            </div>
            
            <div class="summary-card queda">
                <div class="summary-icon"><i class="fas fa-trending-down"></i></div>
                <div class="summary-number"><cfoutput>#assuntosEmQueda#</cfoutput></div>
                <div class="summary-label">Assuntos em queda</div>
            </div>
            
            <div class="summary-card media">
                <div class="summary-icon"><i class="fas fa-chart-line"></i></div>
                <div class="summary-number"><cfoutput>#variacaoMedia#%</cfoutput></div>
                <div class="summary-label">Variação média</div>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Anima as barras com delay
    setTimeout(function() {
        $('.animated-bar').each(function(index) {
            var width = $(this).data('width');
            var delay = index * 100; // Delay progressivo
            
            setTimeout(() => {
                $(this).css('width', width);
            }, delay);
        });
    }, 500);
});
</script>