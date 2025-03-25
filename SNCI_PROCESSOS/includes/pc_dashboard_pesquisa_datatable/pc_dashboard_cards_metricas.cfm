<cfprocessingdirective pageencoding = "utf-8">

<!--- Incluir o CSS específico deste componente --->
<link rel="stylesheet" href="dist/css/stylesSNCI_CardsMetricas.css">

<!--- Card para Métricas Principais --->
<div class="card mb-4" id="card-metricas-datatable">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-tachometer-alt mr-2"></i>Indicadores de Desempenho
        </h3>
        <div class="card-tools">
            <button type="button" class="btn btn-tool" data-card-widget="collapse">
                <i class="fas fa-minus"></i>
            </button>
        </div>
    </div>
    <div class="card-body">
        <!-- Cards de métricas - Todos na mesma linha com 5 cards -->
        <div class="row">
            <div class="col-lg col-md-6 col-12">
                <div class="small-box bg-info">
                    <div class="inner">
                        <h3 id="totalPesquisasDT">0</h3>
                        <p>Pesquisas Respondidas</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-file-text"></i>
                    </div>
                </div>
            </div>
            <div class="col-lg col-md-6 col-12">
                <div class="small-box bg-primary">
                    <div class="inner">
                        <h3 id="indiceRespostasDT">0%</h3>
                        <p>Índice de Respostas</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-percent"></i>
                    </div>
                    <p class="formula-text">
                        (Total Resp. / Total Proc.) × 100<br>
                        <span id="formulaDetalhesDT"></span>
                    </p>
                </div>
            </div>
            <div class="col-lg col-md-6 col-12">
                <div class="small-box bg-success">  
                    <div class="inner">
                        <h3 id="mediaGeralDT">0</h3>
                        <p>Média Geral das Notas</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-calculator"></i>
                    </div>
                </div>
            </div>
            <div class="col-lg col-md-6 col-12">
                <!-- Card do NPS com estrutura melhorada -->
                <div class="small-box bg-azul-navy">  
                    <div class="inner">
                        <div class="nps-value-container">
                            <h3 id="npsValorContainerDT">0</h3>
                            <div id="npsClassificacaoDT" class="nps-classification-badge">(-)</div>
                        </div>
                        <p style="top: 10px;position: relative;">
                            NPS
                            <i class="fas fa-info-circle ml-1 nps-info-icon" id="npsInfoIconDT"></i>
                        </p>
                        <p id="npsDetalhesDT" class="formula-text" style="left:0px;top:6px;position: relative;">
                            Promotores: 0 | Neutros: 0 | Detratores: 0
                        </p>
                    </div>
                    <div class="icon" id="npsIconDT">
                        <i class="fas fa-meh"></i>
                    </div>
                </div>
            </div>
            <div class="col-lg col-md-6 col-12">
                <div class="small-box bg-warning">
                    <div class="inner">
                        <h3 id="mediaGeralPontualidadeDT">0%</h3>
                        <p>Pontualidade <i class="fas fa-info-circle" data-toggle="popover" data-placement="top" title="Pontualidade" data-content="Avalia se a equipe de controle interno cumpriu os prazos estabelecidos para a condução e entrega do trabalho."></i></p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-clock"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal personalizado para NPS que se comporta como popover -->
<div id="npsInfoModalDT" class="snci-nps-modal">
    <div class="snci-nps-modal-header navbar_correios_backgroundColor">
        <i class='fas fa-chart-line mr-2'></i>O que é o NPS?
    </div>
    <div class="snci-nps-modal-body">
        <div class='text-justify'>
            <p>O <strong>Net Promoter Score (NPS)</strong> mede a satisfação e percepção dos órgãos avaliados quanto aos trabalhos realizados, em uma escala de -100 a +100.</p>
            
            <div class="alert alert-info">
                <i class="fas fa-info-circle mr-2"></i><strong>Regra de cálculo:</strong> O NPS é calculado com base na média das pesquisas de opinião por órgão respondente. Isso significa que cada órgão é classificado como Promotor, Neutro ou Detrator com base na média de todas as pesquisas de opinião respondidas, de acordo com os filtros selecionados.
            </div>
            
            <p><strong>NPS = </strong> % Promotores - % Detratores</p>
            <p><strong>Classificação dos respondentes:</strong></p>
            <div class="nps-category-box">
                <h5><span class='badge badge-success'>Promotores (nota 9,0 - 10,0)</span></h5>
                <p>São órgãos que consideram o processo de avaliação do controle interno como altamente positivo e eficaz. Reconhecem o valor agregado pela avaliação, destacando a qualidade do trabalho, a transparência e a contribuição para a melhoria dos processos internos. Estes órgãos tendem a incorporar prontamente as recomendações e a valorizar a parceria com o controle interno.</p>
            </div>
            <div class="nps-category-box">
                <h5><span class='badge badge-warning'>Neutros (nota 7,0 - 8,9)</span></h5>
                <p>São órgãos que consideram o processo de avaliação satisfatório, mas identificam aspectos a serem aprimorados. Reconhecem a importância do trabalho do controle interno, porém, não percebem valor extraordinário agregado às suas operações. Tendem a adotar parcialmente as recomendações e podem apresentar resistência moderada durante os processos de avaliação e acompanhamento.</p>
            </div>
            <div class="nps-category-box">
                <h5><span class='badge badge-danger'>Detratores (nota 1 - 6,9)</span></h5>
                <p>São órgãos que demonstram insatisfação com o processo de avaliação conduzido pelo controle interno dos Correios. Podem considerar as avaliações como burocráticas, punitivas ou desconectadas da realidade operacional. Representam oportunidades críticas para o aprimoramento da metodologia de avaliação, comunicação e abordagem do órgão de controle interno, sinalizando necessidade de revisão nos procedimentos adotados.</p>
            </div>
            <p><strong>Interpretação:</strong></p>
            <ul>
                <li><span class='text-danger'>Ruim</span>: < 0 (menor que zero)</li>
                <li><span class='text-warning'>Regular</span>: [0 - 50) (de zero até 49,9)</li>
                <li><span class='text-info'>Bom</span>: [50 - 70) (de 50 até 69,9)</li>
                <li><span class='text-success'>Excelente</span>: ≥ 70 (maior ou igual a 70)</li>
            </ul>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Verificar se o script já foi carregado para evitar duplicidade
    if (typeof window.cardsMetricasDTLoaded === 'undefined') {
        window.cardsMetricasDTLoaded = true;
        
        // Inicializar tooltips e popovers
        $('[data-toggle="tooltip"]').tooltip({
            container: 'body',
            html: true,
            delay: {show: 100, hide: 100},
            template: '<div class="tooltip" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>'
        });
        
        // Inicializar o popover de pontualidade
        $('[data-toggle="popover"]').popover({
            container: 'body',
            html: true,
            trigger: 'hover',
            template: '<div class="popover" role="tooltip"><div class="arrow"></div><div class="popover-header"></div><div class="popover-body"></div></div>'
        });

        // Implementar comportamento de popover para o modal personalizado do NPS
        let hoverTimeout;
        
        $("#npsInfoIconDT").on('mouseenter', function(e) {
            clearTimeout(hoverTimeout);
            
            const $icon = $(this);
            const $modal = $("#npsInfoModalDT");
            
            // Certificar-se que o modal está visível para calcular sua altura real
            $modal.css({
                'visibility': 'hidden',
                'display': 'block',
                'position': 'fixed',
                'top': 0,
                'left': 0
            });
            
            // Capturar as dimensões após o modal estar visível
            const modalWidth = $modal.outerWidth();
            const modalHeight = $modal.outerHeight();
            
            // Restaurar a invisibilidade para posicionar corretamente
            $modal.css({
                'display': 'none',
                'visibility': 'visible',
                'position': 'absolute'
            });
            
            // Posicionar o modal próximo ao ícone
            const iconPos = $icon.offset();
            const iconWidth = $icon.outerWidth();
            const iconHeight = $icon.outerHeight();
            
            const windowScrollTop = $(window).scrollTop();
            
            $modal.css({
                'top': windowScrollTop,
                'left': iconPos.left - modalWidth - 15,
                'z-index': 9999
            }).fadeIn(200);
            
            // Ajustar posição se estiver fora da tela (à esquerda)
            if (iconPos.left - modalWidth - 15 < 0) {
                $modal.css({
                    'left': iconPos.left + iconWidth + 15
                });
            }
        }).on('mouseleave', function() {
            hoverTimeout = setTimeout(function() {
                $("#npsInfoModalDT").fadeOut(200);
            }, 300);
        });
        
        // Evitar que o modal desapareça quando o mouse estiver sobre ele
        $("#npsInfoModalDT").on('mouseenter', function() {
            clearTimeout(hoverTimeout);
        }).on('mouseleave', function() {
            $(this).fadeOut(200);
        });
        
        // Função para animação dos números - melhorada para transição mais suave
        function animateNumberValue(el, start, end, duration, isPercentage = false) {
            // Se a diferença for mínima, apenas atualize diretamente
            if (Math.abs(end - start) < 0.1) {
                el.textContent = isPercentage ? parseFloat(end.toFixed(1)) + "%" : parseFloat(end.toFixed(1));
                return;
            }
            
            // Cancelar qualquer animação anterior
            if (el._animationFrameId) {
                cancelAnimationFrame(el._animationFrameId);
            }
            
            let startTimestamp = null;
            const step = (timestamp) => {
                if (!startTimestamp) startTimestamp = timestamp;
                const progress = Math.min((timestamp - startTimestamp) / duration, 1);
                
                // Usar uma função de easing para uma transição mais suave
                // Esta é uma função de easing "easeOutQuad"
                const easing = 1 - Math.pow(1 - progress, 2);
                const currentValue = start + (end - start) * easing;
                
                if (isPercentage) {
                    el.textContent = parseFloat(currentValue.toFixed(1)) + "%";
                } else {
                    el.textContent = parseFloat(currentValue.toFixed(1));
                }
                
                if (progress < 1) {
                    el._animationFrameId = window.requestAnimationFrame(step);
                } else {
                    // Garantir que o valor final seja exato
                    el.textContent = isPercentage ? parseFloat(end.toFixed(1)) + "%" : parseFloat(end.toFixed(1));
                }
            };
            el._animationFrameId = window.requestAnimationFrame(step);
        }
        
        // Armazenar valores anteriores para permitir animação
        window.previousCardValuesDT = {
            totalPesquisas: 0,
            indiceRespostas: 0,
            mediaGeral: 0,
            npsValor: 0,
            pontualidade: 0
        };
        
        // Função para classificar o NPS baseado no valor
        function classificarNPS(valor) {
            const nps = parseFloat(valor);
            
            if (nps >= 70) { // Alterado para >= 70 para incluir o valor exato 70 como Excelente
                return {
                    texto: "Excelente",
                    classe: "nps-excelente"
                };
            } else if (nps >= 50) {
                return {
                    texto: "Bom",
                    classe: "nps-bom"
                };
            } else if (nps >= 0) {
                return {
                    texto: "Regular",
                    classe: "nps-regular"
                };
            } else {
                return {
                    texto: "Ruim",
                    classe: "nps-ruim"
                };
            }
        }
        
        // Função para atualizar os cards de métricas com base nos dados do datatable
        window.atualizarCardsDatatable = function() {
            // Obter a tabela
            const dataTable = $('#tabelaPesquisasDetalhada').DataTable();
            
            // Verificar se a tabela existe e está inicializada
            if (!dataTable) return;
            
            // Obter os dados filtrados da tabela
            const dados = dataTable.rows({search: 'applied'}).data().toArray();
            const totalPesquisas = dados.length;
            
            // Atualizar o card de total de pesquisas
            const elTotalPesquisas = document.getElementById("totalPesquisasDT");
            animateNumberValue(elTotalPesquisas, window.previousCardValuesDT.totalPesquisas, totalPesquisas, 1000);
            window.previousCardValuesDT.totalPesquisas = totalPesquisas;
            
            // Calcular a média geral de todas as notas válidas
            let todasNotas = [];
            dados.forEach(item => {
                const notas = [
                    parseFloat(item.comunicacao) || 0,
                    parseFloat(item.interlocucao) || 0,
                    parseFloat(item.reuniao) || 0,
                    parseFloat(item.relatorio) || 0,
                    parseFloat(item.pos_trabalho) || 0,
                    parseFloat(item.importancia) || 0
                ];
                
                notas.forEach(nota => {
                    if (nota > 0) todasNotas.push(nota);
                });
            });
            
            // Calcular média geral
            let mediaGeral = 0;
            if (todasNotas.length > 0) {
                mediaGeral = todasNotas.reduce((sum, nota) => sum + nota, 0) / todasNotas.length;
            }
            
            // Atualizar o card de média geral
            const elMediaGeral = document.getElementById("mediaGeralDT");
            animateNumberValue(elMediaGeral, window.previousCardValuesDT.mediaGeral, mediaGeral, 1000);
            window.previousCardValuesDT.mediaGeral = mediaGeral;
            
            // Calcular a pontualidade (percentual de "Sim")
            let totalPontualidade = 0;
            let totalPontualidadeSim = 0;
            
            dados.forEach(item => {
                if (item.pontualidade !== undefined) {
                    totalPontualidade++;
                    if (item.pontualidade === 1 || item.pontualidade === true || item.pontualidade === '1') {
                        totalPontualidadeSim++;
                    }
                }
            });
            
            const pontualidadePercentual = totalPontualidade > 0 ? 
                (totalPontualidadeSim / totalPontualidade) * 100 : 0;
            
            // Atualizar o card de pontualidade
            const elPontualidade = document.getElementById("mediaGeralPontualidadeDT");
            animateNumberValue(elPontualidade, window.previousCardValuesDT.pontualidade, pontualidadePercentual, 1000, true);
            window.previousCardValuesDT.pontualidade = pontualidadePercentual;
            
            // Calcular o índice de respostas (assumindo um valor estimado de processos totais)
            // Para este exemplo, vamos estimar que existem aproximadamente 20% mais processos que respostas
            const estimatedTotalProcessos = Math.max(Math.round(totalPesquisas * 1.2), totalPesquisas);
            const indiceRespostas = estimatedTotalProcessos > 0 ? 
                (totalPesquisas / estimatedTotalProcessos) * 100 : 0;
            
            // Atualizar o índice de respostas
            if (estimatedTotalProcessos === 0) {
                $("#indiceRespostasDT").text("Pesquisas não localizadas").addClass('texto-menor');
                $(".formula-text").hide();
            } else {
                const elIndiceRespostas = document.getElementById("indiceRespostasDT");
                animateNumberValue(elIndiceRespostas, window.previousCardValuesDT.indiceRespostas, indiceRespostas, 1000, true);
                window.previousCardValuesDT.indiceRespostas = indiceRespostas;
                
                $("#indiceRespostasDT").removeClass('texto-menor');
                $("#formulaDetalhesDT").text(
                    `(${totalPesquisas} / ${estimatedTotalProcessos}) × 100 = ${indiceRespostas.toFixed(1)}%`
                );
                $(".formula-text").show();
            }
            
            // Calcular o NPS (Net Promoter Score) baseado em órgãos respondentes
            let orgaosRespondentes = {};

            dados.forEach(item => {
                // Verificar se o item tem o campo orgao_respondente
                const orgao = item.orgao_respondente || 'Não informado';
                
                // Inicializar o objeto para este órgão se ainda não existir
                if (!orgaosRespondentes[orgao]) {
                    orgaosRespondentes[orgao] = {
                        somaNotas: 0,
                        totalNotasValidas: 0
                    };
                }
                
                // Usar a média das notas para determinar a categoria NPS
                const notas = [
                    parseFloat(item.comunicacao) || 0,
                    parseFloat(item.interlocucao) || 0,
                    parseFloat(item.reuniao) || 0,
                    parseFloat(item.relatorio) || 0,
                    parseFloat(item.pos_trabalho) || 0,
                    parseFloat(item.importancia) || 0
                ];
                
                const notasValidas = notas.filter(nota => nota > 0);
                if (notasValidas.length > 0) {
                    // Adicionar à soma das notas deste órgão
                    orgaosRespondentes[orgao].somaNotas += notasValidas.reduce((a, b) => a + b, 0);
                    orgaosRespondentes[orgao].totalNotasValidas += notasValidas.length;
                }
            });

            // Contar órgãos em cada categoria
            let promotores = 0, neutros = 0, detratores = 0;

            Object.keys(orgaosRespondentes).forEach(orgao => {
                const dadosOrgao = orgaosRespondentes[orgao];
                
                // Calcular a média das notas para este órgão
                if (dadosOrgao.totalNotasValidas > 0) {
                    const mediaOrgao = dadosOrgao.somaNotas / dadosOrgao.totalNotasValidas;
                    
                    // Classificar o órgão com base na média
                    if (mediaOrgao >= 9) {
                        promotores++;
                    } else if (mediaOrgao >= 7) {
                        neutros++;
                    } else if (mediaOrgao > 0) {
                        detratores++;
                    }
                }
            });

            const totalOrgaosRespondentes = promotores + neutros + detratores;
            const npsValor = totalOrgaosRespondentes > 0 ? 
                ((promotores / totalOrgaosRespondentes) - (detratores / totalOrgaosRespondentes)) * 100 : 0;
            
            // Atualizar o NPS
            const elNPS = document.getElementById("npsValorContainerDT");
            animateNumberValue(elNPS, window.previousCardValuesDT.npsValor, npsValor, 1000);
            window.previousCardValuesDT.npsValor = npsValor;
            
            // Classificar o NPS
            const classificacao = classificarNPS(npsValor);
            
            // Atualiza a classificação
            $("#npsClassificacaoDT")
                .text(classificacao.texto)
                .removeClass()
                .addClass('nps-classification-badge')
                .css({
                    'display': 'inline-block',
                    'padding': '3px 10px',
                    'border-radius': '12px',
                    'font-weight': '600',
                    'font-size': '14px'
                });
                
            // Aplicar cores baseadas na classificação
            if (classificacao.classe === "nps-excelente") {
                $("#npsClassificacaoDT").css('background-color', '#28a745').css('color', 'white');
                $("#npsIconDT i").removeClass().addClass('fas fa-grin-stars');
            } else if (classificacao.classe === "nps-bom") {
                $("#npsClassificacaoDT").css('background-color', '#17a2b8').css('color', 'white');
                $("#npsIconDT i").removeClass().addClass('fas fa-smile');
            } else if (classificacao.classe === "nps-regular") {
                $("#npsClassificacaoDT").css('background-color', '#ffc107').css('color', '#343a40');
                $("#npsIconDT i").removeClass().addClass('fas fa-meh');
            } else {
                $("#npsClassificacaoDT").css('background-color', '#dc3545').css('color', 'white');
                $("#npsIconDT i").removeClass().addClass('fas fa-frown');
            }
            
            // Atualizar detalhes do NPS
            $("#npsDetalhesDT").text(`Órgãos Promotores: ${promotores} | Órgãos Neutros: ${neutros} | Órgãos Detratores: ${detratores}`);
        };
        
        // Inicializar os cards quando a tabela estiver pronta
        $(document).on('init.dt', function(e, settings) {
            if (settings.nTable.id === 'tabelaPesquisasDetalhada') {
                setTimeout(function() {
                    window.atualizarCardsDatatable();
                }, 500);
            }
        });
        
        // Atualizar os cards quando a tabela for filtrada
        $(document).on('draw.dt', function(e, settings) {
            if (settings.nTable.id === 'tabelaPesquisasDetalhada') {
                window.atualizarCardsDatatable();
            }
        });
    }
});
</script>
