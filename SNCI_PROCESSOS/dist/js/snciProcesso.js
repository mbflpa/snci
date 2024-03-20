function generateColors(numColors) {
    var colors = [];
  
    for (var i = 0; i < numColors; i++) {
      var r = Math.floor(Math.random() * 256);
      var g = Math.floor(Math.random() * 256);
      var b = Math.floor(Math.random() * 256);
      //var a = Math.random().toFixed(2);
  
      colors.push(`rgba(${r}, ${g}, ${b},0.5)`);
    }
    colors.unshift('rgba(60, 141, 188 ,0.7)', 'rgb(243, 156, 18,0.5)', 'rgb(0, 192, 239, 0.5)','rgb(0, 166, 90, 0.5)');//insere estas cores padrões no início do array
    return colors;
}

function graficoPizza (tipo, tabela, titulo, nomeColuna, canvasID){
				
    var table =  $('#' + tabela).DataTable();
    // Obter as informações das colunas
    var columns = table.columns().header().toArray();
    // Encontrar a coluna pelo nome
    var nomeColumnIndex = columns.findIndex(function(column) {
        return column.textContent === nomeColuna;
    });
    var dados = table.columns(nomeColumnIndex)
            .data()
            .eq( 0 )      // Reduce the 2D array into a 1D array of data
            .sort()       // Sort data alphabetically
            .join( ',' )

    var dados2 = dados.split(',');

    var frequencies = {};
    dados2.map( 
    function (v) {
        if (frequencies[v]) { frequencies[v] += 1; }
        else { frequencies[v] = 1; }
        return v;
    }, frequencies);

    var labels=  Object.keys(frequencies);
    var data=  Object.values(frequencies);

    var pieData = {
        labels: labels,
        datasets: [
            {
            data: data,
            backgroundColor : generateColors(10),
            }
        ]
    
    }
    
    //-------------
    //- DONUT CHART -
    //-------------
    // Get context with jQuery - using jQuery's .get() method.
    var pieChartCanvas = $('#' + canvasID).get(0).getContext('2d')
    var pieData        = pieData;
    var pieOptions     = {
                            maintainAspectRatio : false,
                            responsive : true,
                            }
    //Create pie or douhnut chart
    // You can switch between pie and douhnut using the method below.
    Chart.plugins.register(ChartDataLabels)//para legendas dentro do gráfico
    var chart = new Chart(canvasID, {
        type: tipo,
        data: pieData,
        options: {
            
            title: {
            display: true,
            text: titulo
            },
            tooltips: {
                callbacks: {
                    label: function(tooltipItem, data) {
                        var dataset = data.datasets[tooltipItem.datasetIndex];
                        var total = dataset.data.reduce(function(previousValue, currentValue, currentIndex, array) {
                            return previousValue + currentValue;
                        });
                        var currentValue = dataset.data[tooltipItem.index];
                        var percentage = currentValue/total * 100;
                        return data.labels[tooltipItem.index] + ": " + currentValue + " (" + percentage.toFixed(1) + "%)";
                    }
                }
            },
    
            plugins: {//para legendas dentro do gráfico
                datalabels: {
                    color: '#000',
                    labels: {
                        title: {
                            font: {
                                weight: 'normal',
                                size: 12
                            }
                        }
                    },
                    formatter: (value, ctx) => {//incluir percentual e valor na labels dentro do gráfico
                        let sum = 0;
                        let dataArr = ctx.chart.data.datasets[0].data;
                        let label = ctx.chart.data.labels[ctx.dataIndex];
                        dataArr.map(data => {
                            sum += data;
                        });
                        let percentage = (value*100 / sum).toFixed(1);
                        let texto = '';
                        if(percentage>20){
                            texto = "   " + label + "\n   " + value + " (" + percentage +"%)";	
                        }
                    
                        return  texto;
                        
                    },
                    
                    
                }
            }, 
            legend: {
                labels: {
                    display: true,
                    labels: {
                        fontSize: 10,
                    },
                    generateLabels: function(chart) {
                        var data = chart.data;
                        if (data.labels.length && data.datasets.length) {
                        return data.labels.map(function(label, i) {
                            var meta = chart.getDatasetMeta(0);
                            var ds = data.datasets[0];
                            var arc = meta.data[i];
                            var custom = arc && arc.custom || {};
                            var getValueAtIndexOrDefault = Chart.helpers.getValueAtIndexOrDefault;
                            var arcOpts = chart.options.elements.arc;
                            var fill = custom.backgroundColor ? custom.backgroundColor : getValueAtIndexOrDefault(ds.backgroundColor, i, arcOpts.backgroundColor);
                            var stroke = custom.borderColor ? custom.borderColor : getValueAtIndexOrDefault(ds.borderColor, i, arcOpts.borderColor);
                            var bw = custom.borderWidth ? custom.borderWidth : getValueAtIndexOrDefault(ds.borderWidth, i, arcOpts.borderWidth);
                            var total = ds.data.reduce(function(acc, val) {
                                        return acc + val;
                                        });
                            var percentual = (ds.data[i]/total*100).toFixed(1);
                            return {

                                text: label + ':' + ds.data[i] + ' ('+ percentual + '%)',
                                fillStyle: fill,
                                strokeStyle: stroke,
                                lineWidth: bw,
                                hidden: isNaN(ds.data[i]) || meta.data[i].hidden,

                                // Extra data used for toggling the correct item
                                index: i
                            };
                        });
                        }
                        return [];
                    }
                }
            },
            
        }
    })
    //fim do gráfico DONUT
};


function graficoBarra (tabela, titulo, nomeColuna, canvasID){
				
    var table =  $('#' + tabela).DataTable();
    // Obter as informações das colunas
    var columns = table.columns().header().toArray();
    // Encontrar a coluna pelo nome
    var nomeColumnIndex = columns.findIndex(function(column) {
        return column.textContent === nomeColuna;
    });
    var dados = table.columns(nomeColumnIndex)
            .data()
            .eq( 0 )      // Reduce the 2D array into a 1D array of data
            .sort()       // Sort data alphabetically
            .join( ',' )

    var dados2 = dados.split(',');
    
    var frequencies = {};
    dados2.map( 
    function (v) {
        if (frequencies[v]) { frequencies[v] += 1; }
        else { frequencies[v] = 1; }
        return v;
    }, frequencies);

    //coloca array em ordem decrescente de valor
    const sortedFrequencies = Object.entries(frequencies)
    .sort((a, b) => b[1] - a[1])
    .reduce((obj, [key, value]) => {
        obj[key] = value;
        return obj;
    }, {});

    var labels=  Object.keys(sortedFrequencies);
    var data=  Object.values(sortedFrequencies);

    var pieData = {
        labels: labels,
        datasets: [
            {
            data: data,
            backgroundColor: generateColors(10),
            }
        ]
    
    }
    
    // Get context with jQuery - using jQuery's .get() method.
    var pieChartCanvas = $('#' + canvasID).get(0).getContext('2d')
    var pieData        = pieData;
    var pieOptions     = {
                            maintainAspectRatio : false,
                            responsive : true,
                            }
    //Create pie or douhnut chart
    // You can switch between pie and douhnut using the method below.
    Chart.plugins.register(ChartDataLabels)//para legendas dentro do gráfico
    var chart = new Chart(canvasID, {
        type: 'bar',
        data: pieData,
        options: {

            title: {
                display: true,
                text: titulo
            },
            legend: {
                display: false
            },
            scales: {
                xAxes: [{
                    ticks: {
                        maxRotation: 45,
                        callback: function(value) {
                          var label = value;
                          var maxLength = 20;
                          if (label.length > maxLength) {
                            label = label.substring(0, maxLength) + "...";
                          }
                          return label;
                        }
                      },
                  gridLines: {
                    display:false
                  }
                }],
                yAxes: [{
                  display:false
                }]
              },
            tooltips: {
                callbacks: {
                    label: function(tooltipItem, data) {
                        var dataset = data.datasets[tooltipItem.datasetIndex];
                        var total = dataset.data.reduce(function(previousValue, currentValue, currentIndex, array) {
                            return previousValue + currentValue;
                        });
                        var currentValue = dataset.data[tooltipItem.index];
                        var percentage = currentValue/total * 100;
                        return data.labels[tooltipItem.index] + ": " + currentValue + " (" + percentage.toFixed(1) + "%)";
                    }
                }
            },
            plugins: {//para legendas dentro do gráfico
                datalabels: {
                    color: '#000',
                    labels: {
                        title: {
                            font: {
                                weight: 'normal',
                                size: 12
                            }
                        }
                    },
                    
                    
                    
                }
            }, 
    
            
            
            
        }
    })
 
};


// Exporta o timeline(histórico) das manifestações para PDF
async function exportarTimelineParaPDF() {
    var mensagem = '<p style="text-align: justify;">Deseja gerar um arquivo PDF contendo o histórico das manifestações?</p>Escolha uma orientação para o PDF:</p>';

    // Espera pela seleção do usuário
    const { value: orientacao } = await Swal.fire({
        //title: 'Selecione a orientação do PDF',
        html: logoSNCIsweetalert2(mensagem),
        showCancelButton: true,
        inputValue: '1', // Esta linha define a opção "orientacaoHorizontal" como padrão
        confirmButtonText: 'Sim!',
        cancelButtonText: 'Cancelar!',
            get focusConfirm() {
            return this._focusConfirm;
        },
        set focusConfirm(value) {
            this._focusConfirm = value;
        },
        input: 'radio',
        inputValidator: (value) => {
            if (!value) {
                return 'Você precisa escolher uma opção!';
            }
        },
        inputOptions: {
            '1': '<span style="margin-right: 50px;"><i class="fas fa-file fa-rotate-270 fa-3x" ></i></span>',//horizontal
            '2': '<span style="margin-right: 8px;"><i class="fas fa-file fa-3x"></i></span>'//vertical
 
        }
    });

    if (orientacao) {
        $('#modalOverlay').modal('show');
        setTimeout(function () {
            const content = document.querySelector('.timeline');
            const tituloParaPDF = document.querySelector('#tituloParaPDF');
    
            const pdfOptions = {
                margin: [20, 10, 18, 0],
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2 },
                jsPDF: { unit: 'mm', format: 'a4', orientation: orientacao === '1' ? 'landscape' : 'portrait' }
            };
    
            // Criar o PDF usando html2pdf.js
            html2pdf().from(content).set(pdfOptions).toPdf().get('pdf').then(function(pdf) {
    
                var totalPages = pdf.internal.getNumberOfPages();
                
                for (let i = 1; i <= totalPages; i++) {
                    
                    pdf.setPage(i);
                    pdf.setFontSize(10);
                    pdf.setTextColor(255); 
    
                    // Adicionar retângulo de fundo
                    pdf.setFillColor(0, 65, 107);
                    pdf.rect(
                            5,                                          // Posição horizontal do canto superior esquerdo (coordenada X)
                            5,                                          // Posição vertical do canto superior esquerdo (coordenada Y)
                            pdf.internal.pageSize.getWidth() - 10,       // Largura do retângulo (largura total da página - 10 unidades)
                            9.1,                                         // Altura do retângulo
                            'F'                                         // 'F' para preencher o retângulo
                        );
    
                    // Adicionar borda na mesma cor nas páginas
                    pdf.setLineWidth(0.5); // Largura da borda
                    pdf.setDrawColor(0, 65, 107); // Cor da borda
                    pdf.rect(5, 5, pdf.internal.pageSize.getWidth() - 10, pdf.internal.pageSize.getHeight() - 10); // Borda da página
    
                    // Desenhar os elementos do cabeçalho
                    pdf.setFontSize(12);
                    pdf.setTextColor(255);
                    pdf.text('SNCI - Processos', 20, 9.5);
                    pdf.addImage(
                            'dist/img/icone_sistema_standalone_ico.png', // Caminho para a imagem
                            'PNG',                                       // Formato da imagem (PNG, JPEG, etc.)
                            10,                                          // Posição horizontal (coordenada X)
                            5.5,                                           // Posição vertical (coordenada Y)
                            8,                                          // Largura da imagem
                            8                                           // Altura da imagem
                        );
                                                
                    // Adicionar conteúdo no lugar do exemplo original
                    pdf.setFontSize(8);
                    pdf.text(tituloParaPDF.innerText, 20, 12.5);
    
                    
    
                    // Adicionar rodapé centralizado
                    const footerText = 'SNCI - Processos: Histórico de Manifestações - Página ' + i + ' de ' + totalPages;
                    const footerWidth = pdf.getStringUnitWidth(footerText) * pdf.internal.getFontSize() / pdf.internal.scaleFactor;
                    const footerX = (pdf.internal.pageSize.getWidth() - footerWidth) / 2;
                    const footerY = pdf.internal.pageSize.getHeight() - 10;
    
                    pdf.setFontSize(8);
                    pdf.setTextColor(150);
                    pdf.text(footerText, footerX, footerY);
    
                }
                
                var nomeArquivo = tituloParaPDF.innerText.replace(/\s+/g, '_').replace(/:/g, '').replace(/-/g, '') + ".pdf";   
                pdf.save(nomeArquivo);
                var mensagemSucessos = '<br><p class="font-weight-light" style="color:#28a745;">PDF criado com sucesso!</p><p class="font-weight-light" style="color:#0083CA;text-align: justify;"><strong>Atenção!</strong> Aguarde o seu navegador informar o fim do download.</p>';
                $('#modalOverlay').delay(500).hide(0, function() {
                    Swal.fire({
								title: mensagemSucessos,
								html: logoSNCIsweetalert2(''),
								icon: 'success'
							});
                    $('#modalOverlay').modal('hide');
                });
    
            });
        }, 500);
    } else {
        // Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
        $('#modalOverlay').modal('hide');
        Swal.fire({
								title: 'Operação Cancelada',
								html: '<div style="position:absolute;top:5px;left:5px;whidth:100%;display:flex;justify-content: center;align-items: center;margin-bottom:10px"><img src="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png"class="brand-image" style="width:33px;margin-right:10px">'
                                + '<span class="font-weight-light" style="font-size:20px!important;color:#00416B">SNCI - Processos</span></div>',
								icon: 'info'
							});
    }
 
}


// Função para inicializar o Control Sidebar e inseri-lo na div de classe wrapper
function initializeSearchPanesAndSidebar(tableSelector, alteraPlaceholder) {
			
    // Crie o conteúdo do Control Sidebar
    var controlSidebarContent = 
        `
            <aside id="sidebarPaineis" class="control-sidebar " style="width: 500px!important;overflow-y: auto;">
                <div class="p-3">
                    <div style="display: flex; justify-content: space-between; align-items: center;margin-bottom:10px">
                    <h4 class="font-weight-light" style="color: #0083ca; text-shadow: -1px -1px 0 white, 1px -1px 0 white, -1px 1px 0 white, 1px 1px 0 white;">Painéis de Pesquisa</h4>
                        <button class="btn btn-secondary btn-close-sidebar" data-widget="control-sidebar" style="font-size: 0.675rem;padding: 0.25rem 0.5rem;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div id="searchPanesControlSidebar"></div>
                </div>
            </aside>
        `
    ;

    var $wrapper = $('.wrapper');
    var $existingSidebar = $wrapper.find('#sidebarPaineis');

    if ($existingSidebar.length > 0) {
        // Se o elemento existir, substitua-o pelo novo conteúdo
        $existingSidebar.replaceWith(controlSidebarContent);
    } else {
        // Se o elemento não existir, adicione o novo conteúdo
        $wrapper.append(controlSidebarContent);
    }
    
    // Obter a instância da tabela DataTable
    var dataTable = $(tableSelector).DataTable();
    // Mover o container do SearchPanes para o sidebar
    dataTable.searchPanes.container().appendTo($('#searchPanesControlSidebar'));

    // Redimensionar os painéis do SearchPanes
    dataTable.searchPanes.resizePanes();



  
    var clearFilterIcon = $('<i id="iconRetirarFiltro" class="fas fa-filter-circle-xmark grow-icon" style="cursor:pointer;font-size:23px;color:#dc3545;margin-left:8px;position: relative;top:7px" title="Retirar Filtro"></i>');
   
    dataTable.on('draw.dt', function () {
        var isFiltered = dataTable.rows({ search: 'applied' }).data().length !== dataTable.rows().data().length;
        if (isFiltered) {
            $('.dataTables_info').addClass('tabelaFiltrada');
            $('#iconRetirarFiltro').remove();
            $('.dataTables_info').after(clearFilterIcon);
           
        } else {
            $('.dataTables_info').removeClass('tabelaFiltrada');
            $('#iconRetirarFiltro').remove();
        }
    });
   
   // Delegar o evento de clique para o documento
   $(document).on('click', '#iconRetirarFiltro', function() {
        // Limpar a pesquisa
        dataTable.search('').draw();

        // Limpar os filtros dos painéis de pesquisa
        dataTable.searchPanes.clearSelections();

        // Remover o ícone após remover os filtros
        $('#iconRetirarFiltro').remove();
     });


    // Adicionar o ícone ao botão "Mostrar painéis"
    var showAllButton = $('#searchPanesControlSidebar button.dtsp-showAll');
    showAllButton.html('<i class="fas fa-eye" style="font-size:20px" title="Mostrar painéis"></i>');

    // Adicionar o ícone ao botão "Recolher painéis"
    var showAllButton = $('#searchPanesControlSidebar button.dtsp-collapseAll');
    showAllButton.html('<i class="fas fa-eye-slash" style="font-size:20px" title="Recolher painéis"></i>');

    // Adicionar o ícone ao botão "Retirar filtros"
    var showAllButton = $('#searchPanesControlSidebar button.dtsp-clearAll');
    showAllButton.html('<i class="fas fa-filter-circle-xmark" style="font-size:20px" title="Retirar Filtro"></i>');


   
   
    // Adiciona classe para alinhar os elementos da tabela
    $('.dataTables_filter').addClass('d-inline-flex align-items-center');
    $('.dataTables_filter input').addClass('form-control');
    $('.dataTables_length').addClass('d-inline-flex align-items-center');
    $('.dataTables_length select').addClass('form-control');
    var searchContainer = $('.dataTables_filter');// Container do campo de busca
    searchContainer.removeClass('float-right');// Remove a classe de alinhamento
    if (alteraPlaceholder) {
        $('.dataTables_filter input').attr('placeholder', alteraPlaceholder);
    }

    
}	

// Mostra ou esconde o botão conforme a posição do scroll
$(window).scroll(function(){
    if ($(this).scrollTop() > 100) {
        $('#scrollTopBtn').fadeIn();
    } else {
        $('#scrollTopBtn').fadeOut();
    }
});

// Scroll suave ao clicar no botão
$('#scrollTopBtn').click(function(){
    $('html, body').animate({scrollTop : 0},800);
    return false;
});

// Atualiza a cor da fita do resultado do indicador
function updateRibbon(ribbon) {
    const metaValue = parseFloat(ribbon.data('value'));

    if (metaValue > 100) {
      ribbon.text('ACIMA DO ESPERADO').css('background', '#0083CA').css('color', '#fff');
    } else if (metaValue < 100) {
      ribbon.text('ABAIXO DO ESPERADO').css('background', '#dc3545').css('color', '#fff');
    } else if (metaValue === 100) {
      ribbon.text('DENTRO DO ESPERADO').css('background', 'green').css('color', '#fff');
    } else {
      ribbon.text('SEM META').css('background', '#e3dada').css('color', '#000');
    }
}
