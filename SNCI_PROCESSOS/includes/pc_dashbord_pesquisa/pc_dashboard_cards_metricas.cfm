<cfparam name="anoSelecionado" default="">
<cfparam name="mcuSelecionado" default="Todos">

<!--- Incluir o CSS específico deste componente --->
<link rel="stylesheet" href="dist/css/stylesSNCI_CardsMetricas.css">

<!--- Card para Métricas Principais --->
<div class="card mb-4" id="card-metricas">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-tachometer-alt mr-2"></i>Indicadores de Desempenho
        </h3>
    </div>
    <div class="card-body">
        <!-- Cards de métricas - Todos na mesma linha com 5 cards -->
        <div class="row">
            <div class="col-lg col-md-6 col-12">
                <div class="small-box bg-info">
                    <div class="inner">
                        <h3 id="totalPesquisas">0</h3>
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
                        <h3 id="indiceRespostas">0%</h3>
                        <p>Índice de Respostas</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-percent"></i>
                    </div>
                    <p class="formula-text">
                        (Total Resp. / Total Proc.) × 100<br>
                        <span id="formulaDetalhes"></span>
                    </p>
                </div>
            </div>
            <div class="col-lg col-md-6 col-12">
                <div class="small-box bg-success">  
                    <div class="inner">
                        <h3 id="mediaGeral">0</h3>
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
                            <h3 id="npsValorContainer">0</h3>
                            <div id="npsClassificacao" class="nps-classification-badge">(-)</div>
                        </div>
                        <p style="top: 10px;position: relative;">
                            NPS
                            <i class="fas fa-info-circle ml-1 nps-info-icon" 
                               data-toggle="popover" 
                               data-placement="auto" 
                               data-trigger="hover" 
                               title="<i class='fas fa-chart-line mr-2'></i>O que é o NPS?" 
                               data-content="<div class='text-justify'><p>O <strong>Net Promoter Score (NPS)</strong> mede a satisfação e percepção dos órgãos avaliados quanto aos trabalhos realizados, em uma escala de -100 a +100.</p><p><strong>NPS = </strong> %Promotores-%Detratores</p><p><strong>Classificação dos respondentes:</strong><br>• <span class='badge badge-success'>Promotores</span>: notas 9-10<br>• <span class='badge badge-warning'>Neutros</span>: notas 7-8<br>• <span class='badge badge-danger'>Detratores</span>: notas 1-6</p><p><strong>Interpretação:</strong><br>• <span class='text-danger'>Ruim</span>: menor que 0<br>• <span class='text-warning'>Regular</span>: 0 a 50<br>• <span class='text-info'>Bom</span>: 50 a 70<br>• <span class='text-success'>Excelente</span>: acima de 70</p></div>"></i>
                        </p>
                        <p id="npsDetalhes" class="formula-text" style="left:0px;top:6px;position: relative;">
                            Promotores: 0 | Neutros: 0 | Detratores: 0
                        </p>
                    </div>
                    <div class="icon" id="npsIcon">
                        <i class="fas fa-meh"></i>
                    </div>
                </div>
            </div>
            <div class="col-lg col-md-6 col-12">
                <div class="small-box bg-warning">
                    <div class="inner">
                        <h3 id="mediaGeralPontualidade">0</h3>
                        <p>Pontualidade</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-clock"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Verificar se o script já foi carregado para evitar duplicidade
    if (typeof window.cardsMetricasLoaded === 'undefined') {
        window.cardsMetricasLoaded = true;
        
        // Inicializar tooltips e popovers com configurações avançadas
        $('[data-toggle="tooltip"]').tooltip({
            container: 'body',
            html: true,
            delay: {show: 100, hide: 100},
            template: '<div class="tooltip" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>'
        });
        
        // Inicializar popovers para ícones de informação
        $('[data-toggle="popover"]').popover({
            container: 'body',
            html: true,
            trigger: 'hover',
            boundary: 'window',
            fallbackPlacement: ['left', 'right', 'bottom', 'top'],
            template: '<div class="popover" role="tooltip"><div class="arrow"></div><div class="popover-header"></div><div class="popover-body"></div></div>',
            sanitize: false
        });
        
        // Função para animação dos números
        window.animateNumberValue = function(el, start, end, duration, isPercentage = false) {
            let startTimestamp = null;
            const step = (timestamp) => {
                if (!startTimestamp) startTimestamp = timestamp;
                const progress = Math.min((timestamp - startTimestamp) / duration, 1);
                const currentValue = start + progress * (end - start);
                
                // Formatar o valor atual com 1 casa decimal ou como percentual
                if (isPercentage) {
                    el.textContent = parseFloat(currentValue.toFixed(1)) + "%";
                } else {
                    el.textContent = parseFloat(currentValue.toFixed(1));
                }
                
                if (progress < 1) {
                    window.requestAnimationFrame(step);
                }
            };
            window.requestAnimationFrame(step);
        }
        
        // Armazenar valores anteriores para permitir animação
        window.previousCardValues = {
            totalPesquisas: 0,
            indiceRespostas: 0,
            mediaGeral: 0,
            npsValor: 0,
            pontualidade: 0
        };
        
        // Função para classificar o NPS baseado no valor
        window.classificarNPS = function(valor) {
            // Converter para número para garantir comparação correta
            const nps = parseFloat(valor);
            
            if (nps > 70) {
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
        
        // Função para atualizar os cards de métricas
        window.atualizarCards = function(resultado) {
            // Valores atuais para animação
            const totalPesquisas = parseInt(resultado.total) || 0;
            const mediaGeral = parseFloat(resultado.mediaGeral) || 0;
            const pontualidade = parseFloat(resultado.pontualidadePercentual) || 0;
            const npsValor = parseFloat(resultado.nps) || 0;
            
            // Animar o total de pesquisas
            const elTotalPesquisas = document.getElementById("totalPesquisas");
            window.animateNumberValue(elTotalPesquisas, window.previousCardValues.totalPesquisas, totalPesquisas, 1000);
            window.previousCardValues.totalPesquisas = totalPesquisas;
            
            // Animar média geral
            const elMediaGeral = document.getElementById("mediaGeral");
            window.animateNumberValue(elMediaGeral, window.previousCardValues.mediaGeral, mediaGeral, 1000);
            window.previousCardValues.mediaGeral = mediaGeral;
            
            // Animar pontualidade
            const elPontualidade = document.getElementById("mediaGeralPontualidade");
            window.animateNumberValue(elPontualidade, window.previousCardValues.pontualidade, pontualidade, 1000, true);
            window.previousCardValues.pontualidade = pontualidade;
            
            // Lógica do índice de respostas
            if (parseInt(resultado.totalProcessos) === 0) {
                $("#indiceRespostas").text("Processos não localizados").addClass('texto-menor');
                $(".formula-text").hide();
            } else if (parseInt(resultado.total) === 0) {
                // Reset para zero sem animação quando não há pesquisas
                $("#indiceRespostas").text("0%").removeClass('texto-menor');
                $("#formulaDetalhes").text(`(0 / ${parseInt(resultado.totalProcessos)}) × 100 = 0%`);
                $(".formula-text").show();
                window.previousCardValues.indiceRespostas = 0;
            } else {
                const totalRespondidas = parseInt(resultado.total) || 0;
                const totalProcessos = parseInt(resultado.totalProcessos) || 0;
                const indice = ((totalRespondidas / totalProcessos) * 100).toFixed(1);
                
                // Animar índice de respostas
                const elIndiceRespostas = document.getElementById("indiceRespostas");
                window.animateNumberValue(elIndiceRespostas, window.previousCardValues.indiceRespostas, parseFloat(indice), 1000, true);
                window.previousCardValues.indiceRespostas = parseFloat(indice);
                
                $("#indiceRespostas").removeClass('texto-menor');
                $("#formulaDetalhes").text(
                    `(${totalRespondidas} / ${totalProcessos}) × 100 = ${indice}%`
                );
                $(".formula-text").show();
            }
            
            // Atualizar o NPS se disponível
            if (resultado.nps !== undefined) {
                // Animar valor do NPS
                const elNPS = document.getElementById("npsValorContainer");
                window.animateNumberValue(elNPS, window.previousCardValues.npsValor, npsValor, 1000);
                window.previousCardValues.npsValor = npsValor;
                
                // Classificar o NPS
                const classificacao = window.classificarNPS(npsValor);
                
                // Atualiza a classificação com o novo elemento badge
                $("#npsClassificacao")
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
                    $("#npsClassificacao").css('background-color', '#28a745').css('color', 'white');
                    // Atualiza o ícone para um sorriso amplo
                    $("#npsIcon i").removeClass().addClass('fas fa-grin-stars');
                } else if (classificacao.classe === "nps-bom") {
                    $("#npsClassificacao").css('background-color', '#17a2b8').css('color', 'white');
                    // Atualiza o ícone para um sorriso
                    $("#npsIcon i").removeClass().addClass('fas fa-smile');
                } else if (classificacao.classe === "nps-regular") {
                    $("#npsClassificacao").css('background-color', '#ffc107').css('color', '#343a40');
                    // Atualiza o ícone para um rosto neutro
                    $("#npsIcon i").removeClass().addClass('fas fa-meh');
                } else {
                    $("#npsClassificacao").css('background-color', '#dc3545').css('color', 'white');
                    // Atualiza o ícone para um rosto triste
                    $("#npsIcon i").removeClass().addClass('fas fa-frown');
                }
                
                // Atualizar detalhes do NPS com formato simplificado
                if (resultado.npsDetalhes) {
                    const { promotores, neutros, detratores } = resultado.npsDetalhes;
                    $("#npsDetalhes").text(`Promotores: ${promotores} | Neutros: ${neutros} | Detratores: ${detratores}`);
                }
            }
        }
        
        // Carregar dados iniciais se possível
        if (typeof anoSelecionado !== 'undefined' && typeof mcuSelecionado !== 'undefined') {
            $.ajax({
                url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getEstatisticas&returnformat=json',
                method: 'GET',
                data: { 
                    ano: anoSelecionado,
                    mcuOrigem: mcuSelecionado 
                },
                dataType: 'json',
                success: function(resultado) {
                    if (resultado) {
                        window.atualizarCards(resultado);
                    }
                }
            });
        }
        
        // Escutar o evento de filtro alterado que pode ser disparado por outras partes do dashboard
        $(document).on('filtroAlterado', function(e, data) {
            // Este evento pode ser usado quando outras partes do dashboard mudam os filtros
            // O componente dos cards irá se atualizar automaticamente
        });
    }
});
</script>
