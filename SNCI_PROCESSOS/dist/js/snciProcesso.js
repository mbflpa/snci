/**
 * A função `generateColors` gera um array de valores de cor RGBA aleatórios com um número especificado
 * de cores, incluindo algumas cores padrão no início.
 * @param numColors - O parâmetro `numColors` na função `generateColors` representa o número de cores
 * aleatórias que serão geradas e retornadas em um array.
 * @returns A função `generateColors` retorna um array de cores aleatórias no formato RGBA com um
 * valor alfa de 0.5. Além disso, insere quatro cores padrão no início do array.
 */

function generateColors(numColors) {
  var colors = [];

  for (var i = 0; i < numColors; i++) {
    var r = Math.floor(Math.random() * 256);
    var g = Math.floor(Math.random() * 256);
    var b = Math.floor(Math.random() * 256);
    //var a = Math.random().toFixed(2);

    colors.push(`rgba(${r}, ${g}, ${b},0.5)`);
  }
  colors.unshift(
    "rgba(60, 141, 188 ,0.7)",
    "rgb(243, 156, 18,0.5)",
    "rgb(0, 192, 239, 0.5)",
    "rgb(0, 166, 90, 0.5)"
  ); //insere estas cores padrões no início do array
  return colors;
}

/**
 * A função `graficoPizza` gera um gráfico de rosca (donut) utilizando dados de uma DataTable e o exibe em um
 * elemento canvas especificado.
 * @param tipo - O parâmetro `tipo` na função `graficoPizza` representa o tipo de gráfico a ser exibido.
 * Pode ser "pie" para um gráfico de pizza ou "doughnut" para um gráfico de rosca. Este parâmetro
 * determina a representação visual dos dados no gráfico.
 * @param tabela - O parâmetro `tabela` na função `graficoPizza` é usado para especificar o ID do elemento de
 * tabela HTML que contém os dados dos quais o gráfico de pizza será gerado.
 * @param titulo - O parâmetro `titulo` na função `graficoPizza` representa o título do gráfico de pizza que
 * será exibido. É o texto que será mostrado na parte superior do gráfico para fornecer uma breve descrição
 * ou contexto para os dados sendo visualizados.
 * @param nomeColuna - O parâmetro `nomeColuna` na função `graficoPizza` representa o nome da coluna na
 * DataTable que você deseja usar para criar o gráfico de pizza. Esta função recupera os dados da coluna
 * especificada e gera um gráfico de pizza com base nas frequências de diferentes valores nessa coluna.
 * @param canvasID - O parâmetro `canvasID` na função `graficoPizza` é usado para especificar o ID do
 * elemento de canvas onde o gráfico de pizza será renderizado. Este ID é usado para selecionar o elemento
 * canvas usando jQuery e, em seguida, desenhar o gráfico de pizza nesse canvas.
 * @returns A função `graficoPizza` retorna um gráfico de rosca criado usando a biblioteca Chart.js com base
 * nos dados fornecidos na tabela especificada pelo parâmetro `tabela`. O gráfico de rosca exibirá as
 * frequências dos valores na coluna especificada (`nomeColuna`) da tabela. O gráfico terá um título
 * (`titulo`) e será exibido no elemento canvas especificado identificado por `canvasID`.
 */
function graficoPizza(tipo, tabela, titulo, nomeColuna, canvasID) {
  var table = $("#" + tabela).DataTable();
  // Obter as informações das colunas
  var columns = table.columns().header().toArray();
  // Encontrar a coluna pelo nome
  var nomeColumnIndex = columns.findIndex(function (column) {
    return column.textContent === nomeColuna;
  });
  var dados = table
    .columns(nomeColumnIndex)
    .data()
    .eq(0) // Reduce the 2D array into a 1D array of data
    .sort() // Sort data alphabetically
    .join(",");

  var dados2 = dados.split(",");

  var frequencies = {};
  dados2.map(function (v) {
    if (frequencies[v]) {
      frequencies[v] += 1;
    } else {
      frequencies[v] = 1;
    }
    return v;
  }, frequencies);

  var labels = Object.keys(frequencies);
  var data = Object.values(frequencies);

  var pieData = {
    labels: labels,
    datasets: [
      {
        data: data,
        backgroundColor: generateColors(10),
      },
    ],
  };

  //-------------
  //- DONUT CHART -
  //-------------
  // Get context with jQuery - using jQuery's .get() method.
  var pieChartCanvas = $("#" + canvasID)
    .get(0)
    .getContext("2d");
  var pieData = pieData;
  var pieOptions = {
    maintainAspectRatio: false,
    responsive: true,
  };
  //Create pie or douhnut chart
  // You can switch between pie and douhnut using the method below.
  Chart.plugins.register(ChartDataLabels); //para legendas dentro do gráfico
  var chart = new Chart(canvasID, {
    type: tipo,
    data: pieData,
    options: {
      title: {
        display: true,
        text: titulo,
      },
      tooltips: {
        callbacks: {
          label: function (tooltipItem, data) {
            var dataset = data.datasets[tooltipItem.datasetIndex];
            var total = dataset.data.reduce(function (
              previousValue,
              currentValue,
              currentIndex,
              array
            ) {
              return previousValue + currentValue;
            });
            var currentValue = dataset.data[tooltipItem.index];
            var percentage = (currentValue / total) * 100;
            return (
              data.labels[tooltipItem.index] +
              ": " +
              currentValue +
              " (" +
              percentage.toFixed(1) +
              "%)"
            );
          },
        },
      },

      plugins: {
        //para legendas dentro do gráfico
        datalabels: {
          color: "#000",
          labels: {
            title: {
              font: {
                weight: "normal",
                size: 12,
              },
            },
          },
          formatter: (value, ctx) => {
            //incluir percentual e valor na labels dentro do gráfico
            let sum = 0;
            let dataArr = ctx.chart.data.datasets[0].data;
            let label = ctx.chart.data.labels[ctx.dataIndex];
            dataArr.map((data) => {
              sum += data;
            });
            let percentage = ((value * 100) / sum).toFixed(1);
            let texto = "";
            if (percentage > 20) {
              texto =
                "   " + label + "\n   " + value + " (" + percentage + "%)";
            }

            return texto;
          },
        },
      },
      legend: {
        labels: {
          display: true,
          labels: {
            fontSize: 10,
          },
          generateLabels: function (chart) {
            var data = chart.data;
            if (data.labels.length && data.datasets.length) {
              return data.labels.map(function (label, i) {
                var meta = chart.getDatasetMeta(0);
                var ds = data.datasets[0];
                var arc = meta.data[i];
                var custom = (arc && arc.custom) || {};
                var getValueAtIndexOrDefault =
                  Chart.helpers.getValueAtIndexOrDefault;
                var arcOpts = chart.options.elements.arc;
                var fill = custom.backgroundColor
                  ? custom.backgroundColor
                  : getValueAtIndexOrDefault(
                      ds.backgroundColor,
                      i,
                      arcOpts.backgroundColor
                    );
                var stroke = custom.borderColor
                  ? custom.borderColor
                  : getValueAtIndexOrDefault(
                      ds.borderColor,
                      i,
                      arcOpts.borderColor
                    );
                var bw = custom.borderWidth
                  ? custom.borderWidth
                  : getValueAtIndexOrDefault(
                      ds.borderWidth,
                      i,
                      arcOpts.borderWidth
                    );
                var total = ds.data.reduce(function (acc, val) {
                  return acc + val;
                });
                var percentual = ((ds.data[i] / total) * 100).toFixed(1);
                return {
                  text: label + ":" + ds.data[i] + " (" + percentual + "%)",
                  fillStyle: fill,
                  strokeStyle: stroke,
                  lineWidth: bw,
                  hidden: isNaN(ds.data[i]) || meta.data[i].hidden,

                  // Extra data used for toggling the correct item
                  index: i,
                };
              });
            }
            return [];
          },
        },
      },
    },
  });
  //fim do gráfico DONUT
}

/**
 * A função `graficoBarra` gera um gráfico de barras com base nos dados de uma coluna de tabela
 * especificada e o exibe em um elemento de canvas indicado.
 * @param tabela - O parâmetro `tabela` na função `graficoBarra` representa o ID do elemento de tabela
 * HTML que contém os dados que você deseja visualizar no gráfico de barras.
 * @param titulo - O parâmetro `titulo` na função `graficoBarra` representa o título do gráfico de barras
 * que será exibido. É o título que será mostrado na parte superior do gráfico para fornecer uma breve
 * descrição ou contexto para os dados sendo visualizados.
 * @param nomeColuna - O parâmetro `nomeColuna` na função `graficoBarra` representa o nome da coluna
 * na DataTable da qual você deseja gerar o gráfico de barras. Esta função irá extrair dados desta
 * coluna específica para criar a visualização do gráfico de barras.
 * @param canvasID - O parâmetro `canvasID` na função `graficoBarra` é usado para especificar o ID
 * do elemento de canvas onde o gráfico de barras será renderizado. Este ID é usado para selecionar o
 * elemento canvas usando jQuery e, em seguida, desenhar o gráfico de barras nesse canvas.
 * @returns A função `graficoBarra` retorna um gráfico de barras criado usando a biblioteca Chart.js com
 * base nos dados fornecidos na coluna da tabela especificada pelo `nomeColuna`. O gráfico é exibido no
 * elemento canvas especificado identificado por `canvasID`. O gráfico inclui o título especificado,
 * rótulos de dados e dicas de ferramenta mostrando os valores e porcentagens dos dados. Os rótulos do
 * eixo x são girados para melhor legibilidade.
 */

function graficoBarra(tabela, titulo, nomeColuna, canvasID) {
  var table = $("#" + tabela).DataTable();
  // Obter as informações das colunas
  var columns = table.columns().header().toArray();
  // Encontrar a coluna pelo nome
  var nomeColumnIndex = columns.findIndex(function (column) {
    return column.textContent === nomeColuna;
  });
  var dados = table
    .columns(nomeColumnIndex)
    .data()
    .eq(0) // Reduce the 2D array into a 1D array of data
    .sort() // Sort data alphabetically
    .join(",");

  var dados2 = dados.split(",");

  var frequencies = {};
  dados2.map(function (v) {
    if (frequencies[v]) {
      frequencies[v] += 1;
    } else {
      frequencies[v] = 1;
    }
    return v;
  }, frequencies);

  //coloca array em ordem decrescente de valor
  const sortedFrequencies = Object.entries(frequencies)
    .sort((a, b) => b[1] - a[1])
    .reduce((obj, [key, value]) => {
      obj[key] = value;
      return obj;
    }, {});

  var labels = Object.keys(sortedFrequencies);
  var data = Object.values(sortedFrequencies);

  var pieData = {
    labels: labels,
    datasets: [
      {
        data: data,
        backgroundColor: generateColors(10),
      },
    ],
  };

  // Get context with jQuery - using jQuery's .get() method.
  var pieChartCanvas = $("#" + canvasID)
    .get(0)
    .getContext("2d");
  var pieData = pieData;
  var pieOptions = {
    maintainAspectRatio: false,
    responsive: true,
  };
  //Create pie or douhnut chart
  // You can switch between pie and douhnut using the method below.
  Chart.plugins.register(ChartDataLabels); //para legendas dentro do gráfico
  var chart = new Chart(canvasID, {
    type: "bar",
    data: pieData,
    options: {
      title: {
        display: true,
        text: titulo,
      },
      legend: {
        display: false,
      },
      scales: {
        xAxes: [
          {
            ticks: {
              maxRotation: 45,
              callback: function (value) {
                var label = value;
                var maxLength = 20;
                if (label.length > maxLength) {
                  label = label.substring(0, maxLength) + "...";
                }
                return label;
              },
            },
            gridLines: {
              display: false,
            },
          },
        ],
        yAxes: [
          {
            display: false,
          },
        ],
      },
      tooltips: {
        callbacks: {
          label: function (tooltipItem, data) {
            var dataset = data.datasets[tooltipItem.datasetIndex];
            var total = dataset.data.reduce(function (
              previousValue,
              currentValue,
              currentIndex,
              array
            ) {
              return previousValue + currentValue;
            });
            var currentValue = dataset.data[tooltipItem.index];
            var percentage = (currentValue / total) * 100;
            return (
              data.labels[tooltipItem.index] +
              ": " +
              currentValue +
              " (" +
              percentage.toFixed(1) +
              "%)"
            );
          },
        },
      },
      plugins: {
        //para legendas dentro do gráfico
        datalabels: {
          color: "#000",
          labels: {
            title: {
              font: {
                weight: "normal",
                size: 12,
              },
            },
          },
        },
      },
    },
  });
}

/**
 * A função `exportarTimelineParaPDF` permite que o usuário gere um arquivo PDF contendo uma linha do tempo
 * de eventos com opções de orientação personalizáveis.
 * @returns A função `exportarTimelineParaPDF` é uma função assíncrona que solicita ao usuário que
 * selecione uma orientação de PDF (paisagem ou retrato) usando um diálogo modal da biblioteca SweetAlert2.
 * Com base na seleção do usuário, ela gera um arquivo PDF contendo o conteúdo de um elemento HTML específico
 * (`.timeline`) usando a biblioteca `html2pdf.js`.
 */

async function exportarTimelineParaPDF() {
  var mensagem =
    '<p style="text-align: justify;">Deseja gerar um arquivo PDF contendo o histórico das manifestações?</p>Escolha uma orientação para o PDF:</p>';

  // Espera pela seleção do usuário
  const { value: orientacao } = await Swal.fire({
    //title: 'Selecione a orientação do PDF',
    html: logoSNCIsweetalert2(mensagem),
    showCancelButton: true,
    inputValue: "1", // Esta linha define a opção "orientacaoHorizontal" como padrão
    confirmButtonText: "Sim!",
    cancelButtonText: "Cancelar!",
    get focusConfirm() {
      return this._focusConfirm;
    },
    set focusConfirm(value) {
      this._focusConfirm = value;
    },
    input: "radio",
    inputValidator: (value) => {
      if (!value) {
        return "Você precisa escolher uma opção!";
      }
    },
    inputOptions: {
      1: '<span style="margin-right: 50px;"><i style="color:#fff" class="fas fa-file fa-rotate-270 fa-3x" ></i></span>', //horizontal
      2: '<span style="margin-right: 8px;"><i style="color:#fff" class="fas fa-file fa-3x"></i></span>', //vertical
    },
  });

  if (orientacao) {
    $("#modalOverlay").modal("show");
    setTimeout(function () {
      const content = document.querySelector(".timeline");
      const tituloParaPDF = document.querySelector("#tituloParaPDF");

      const pdfOptions = {
        margin: [20, 10, 18, 0],
        image: { type: "jpeg", quality: 0.98 },
        html2canvas: { scale: 2 },
        jsPDF: {
          unit: "mm",
          format: "a4",
          orientation: orientacao === "1" ? "landscape" : "portrait",
        },
      };

      // Criar o PDF usando html2pdf.js
      html2pdf()
        .from(content)
        .set(pdfOptions)
        .toPdf()
        .get("pdf")
        .then(function (pdf) {
          var totalPages = pdf.internal.getNumberOfPages();

          for (let i = 1; i <= totalPages; i++) {
            pdf.setPage(i);
            pdf.setFontSize(10);
            pdf.setTextColor(255);

            // Adicionar retângulo de fundo
            pdf.setFillColor(0, 65, 107);
            pdf.rect(
              5, // Posição horizontal do canto superior esquerdo (coordenada X)
              5, // Posição vertical do canto superior esquerdo (coordenada Y)
              pdf.internal.pageSize.getWidth() - 10, // Largura do retângulo (largura total da página - 10 unidades)
              9.1, // Altura do retângulo
              "F" // 'F' para preencher o retângulo
            );

            // Adicionar borda na mesma cor nas páginas
            pdf.setLineWidth(0.5); // Largura da borda
            pdf.setDrawColor(0, 65, 107); // Cor da borda
            pdf.rect(
              5,
              5,
              pdf.internal.pageSize.getWidth() - 10,
              pdf.internal.pageSize.getHeight() - 10
            ); // Borda da página

            // Desenhar os elementos do cabeçalho
            pdf.setFontSize(12);
            pdf.setTextColor(255);
            pdf.text("SNCI - Processos", 20, 9.5);
            pdf.addImage(
              "dist/img/icone_sistema_standalone_ico.png", // Caminho para a imagem
              "PNG", // Formato da imagem (PNG, JPEG, etc.)
              10, // Posição horizontal (coordenada X)
              5.5, // Posição vertical (coordenada Y)
              8, // Largura da imagem
              8 // Altura da imagem
            );

            // Adicionar conteúdo no lugar do exemplo original
            pdf.setFontSize(8);
            pdf.text(tituloParaPDF.innerText, 20, 12.5);

            // Adicionar rodapé centralizado
            const footerText =
              "SNCI - Processos: Histórico de Manifestações - Página " +
              i +
              " de " +
              totalPages;
            const footerWidth =
              (pdf.getStringUnitWidth(footerText) *
                pdf.internal.getFontSize()) /
              pdf.internal.scaleFactor;
            const footerX =
              (pdf.internal.pageSize.getWidth() - footerWidth) / 2;
            const footerY = pdf.internal.pageSize.getHeight() - 10;

            pdf.setFontSize(8);
            pdf.setTextColor(150);
            pdf.text(footerText, footerX, footerY);
          }

          var nomeArquivo =
            tituloParaPDF.innerText
              .replace(/\s+/g, "_")
              .replace(/:/g, "")
              .replace(/-/g, "") + ".pdf";
          pdf.save(nomeArquivo);
          var mensagemSucessos =
            '<br><p class="font-weight-light" style="color:#28a745;">PDF criado com sucesso!</p><p class="font-weight-light" style="color:#0083CA;text-align: justify;"><strong>Atenção!</strong> Aguarde o seu navegador informar o fim do download.</p>';
          $("#modalOverlay")
            .delay(500)
            .hide(0, function () {
              Swal.fire({
                title: mensagemSucessos,
                html: logoSNCIsweetalert2(""),
                icon: "success",
              });
              $("#modalOverlay").modal("hide");
            });
        });
    }, 500);
  } else {
    // Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
    $("#modalOverlay").modal("hide");
    Swal.fire({
      title: "Operação Cancelada",
      html: logoSNCIsweetalert2(""),
      icon: "info",
    });
  }
}

/**
 * A função inicializa painéis de busca e uma barra lateral de controle para um DataTable, permitindo que os usuários
 * filtrem dados e gerenciem painéis de busca de forma eficiente.
 * @param tableSelector - O parâmetro `tableSelector` na função `initializeSearchPanesAndSidebar`
 * é utilizado para especificar o seletor para o DataTable que você deseja aprimorar com painéis de busca
 * e uma barra lateral de controle. Este seletor deve direcionar o elemento de tabela específico que
 * está inicializado como um DataTable.
 * @param alteraPlaceholder - O parâmetro `alteraPlaceholder` na função
 * `initializeSearchPanesAndSidebar` é usado para personalizar o texto do placeholder do campo de
 * entrada de busca no DataTable. Ao passar um valor de string para este parâmetro, você pode definir um
 * texto de placeholder específico para o campo de entrada de busca.
 */

function initializeSearchPanesAndSidebar(tableSelector, alteraPlaceholder) {
  // Crie o conteúdo do Control Sidebar
  var controlSidebarContent = `
            <aside id="sidebarPaineis" class="control-sidebar " style="width: 500px!important;overflow-y: auto;">
                <div class="p-3">
                    <div style="display: flex; justify-content: space-between; align-items: center;margin-bottom:10px">
                    <h4 class="font-weight-light" style="color: #000; text-shadow: -1px -1px 0 white, 1px -1px 0 white, -1px 1px 0 white, 1px 1px 0 white;">Painéis de Pesquisa</h4>
                        <button class="btn btn-secondary btn-close-sidebar" data-widget="control-sidebar" style="font-size: 0.675rem;padding: 0.25rem 0.5rem;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div id="searchPanesControlSidebar"></div>
                </div>
            </aside>
        `;
  var $wrapper = $(".wrapper");
  var $existingSidebar = $wrapper.find("#sidebarPaineis");

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
  var interval = setInterval(function () {
    var $sidebar = $("#searchPanesControlSidebar");
    if ($sidebar.length) {
      clearInterval(interval); // Para de verificar quando o elemento for encontrado
      dataTable.searchPanes.container().appendTo($sidebar);
    }
  }, 100); // Verifica a cada 100ms

  // Redimensionar os painéis do SearchPanes
  dataTable.searchPanes.resizePanes();

  var clearFilterIcon = $(
    '<i id="iconRetirarFiltro" class="fas fa-filter-circle-xmark grow-icon" style="cursor:pointer;font-size:23px;color:#dc3545;margin-left:8px;position: relative;top:7px" title="Retirar Filtro"></i>'
  );

  dataTable.on("draw.dt", function () {
    var isFiltered =
      dataTable.rows({ search: "applied" }).data().length !==
      dataTable.rows().data().length;
    var $info = $(dataTable.table().container()).find(".dt-info");
    if (isFiltered) {
      $info.addClass("tabelaFiltrada");
      $("#iconRetirarFiltro").remove();
      $info.after(clearFilterIcon);
    } else {
      $info.removeClass("tabelaFiltrada");
      $("#iconRetirarFiltro").remove();
    }
  });

  // Delegar o evento de clique para o documento
  $(document).on("click", "#iconRetirarFiltro", function () {
    // Limpar a pesquisa
    dataTable.search("").draw();

    // Limpar os filtros dos painéis de pesquisa
    dataTable.searchPanes.clearSelections();

    // Remover o ícone após remover os filtros
    $("#iconRetirarFiltro").remove();
  });

  // Adicionar o ícone ao botão "Mostrar painéis"
  var showAllButton = $("#searchPanesControlSidebar button.dtsp-showAll");
  showAllButton.html(
    '<i class="fas fa-eye" style="font-size:20px" title="Mostrar painéis"></i>'
  );

  // Adicionar o ícone ao botão "Recolher painéis"
  var showAllButton = $("#searchPanesControlSidebar button.dtsp-collapseAll");
  showAllButton.html(
    '<i class="fas fa-eye-slash" style="font-size:20px" title="Recolher painéis"></i>'
  );

  // Adicionar o ícone ao botão "Retirar filtros"
  var showAllButton = $("#searchPanesControlSidebar button.dtsp-clearAll");
  showAllButton.html(
    '<i class="fas fa-filter-circle-xmark" style="font-size:20px" title="Retirar Filtro"></i>'
  );

  // Adiciona classe para alinhar os elementos da tabela
  $(".dataTables_filter").addClass("d-inline-flex align-items-center");
  $(".dataTables_filter input").addClass("form-control");
  $(".dataTables_length").addClass("d-inline-flex align-items-center");
  $(".dataTables_length select").addClass("form-control");
  var searchContainer = $(".dataTables_filter"); // Container do campo de busca
  searchContainer.removeClass("float-right"); // Remove a classe de alinhamento
  if (alteraPlaceholder) {
    $(".dataTables_filter input").attr("placeholder", alteraPlaceholder);
  }
}

/* O código está criando um ouvinte de evento de rolagem no objeto window. Quando o
usuário rola para baixo na página e a posição de rolagem vertical é maior que 100 pixels a partir do
topo, ele fará o elemento com o id 'scrollTopBtn' aparecer gradualmente. Se a posição de rolagem for
menor ou igual a 100 pixels, o elemento 'scrollTopBtn' desaparecerá gradualmente. Essa funcionalidade
é comumente usada para mostrar ou ocultar um botão que permite aos usuários rolar rapidamente de volta
para o topo da página. */

$(window).scroll(function () {
  if ($(this).scrollTop() > 100) {
    $("#scrollTopBtn").fadeIn();
  } else {
    $("#scrollTopBtn").fadeOut();
  }
});

/* Adicionando um ouvinte de evento de clique a um elemento com o ID
"scrollTopBtn". Quando este elemento é clicado, ele irá animar a rolagem da página para o topo 
(scrollTop: 0) ao longo de uma duração de 800 milissegundos. A instrução `return false;` é usada 
para prevenir o comportamento padrão do elemento, que neste caso é evitar que a 
página salte para o topo quando o botão é clicado. */

$("#scrollTopBtn").click(function (event) {
  event.preventDefault(); // Previne comportamento padrão
  $("html, body").animate({ scrollTop: 0 }, 800);
});

/**
 * A função `updateRibbon` recebe um elemento de fita e atualiza seu texto e estilo com base em um
 * valor numérico.
 * @param ribbon - O parâmetro `ribbon` na função `updateRibbon`
 * recupera um valor numérico de um atributo de dados e atualiza seu texto e estilo com base no valor.
 */

function updateRibbon(ribbon) {
  const metaValue = parseFloat(ribbon.data("value"));

  if (metaValue > 100) {
    ribbon
      .text("ACIMA DO ESPERADO")
      .css("background", "#0083CA")
      .css("color", "#fff");
  } else if (metaValue < 100) {
    ribbon
      .text("ABAIXO DO ESPERADO")
      .css("background", "#dc3545")
      .css("color", "#fff");
  } else if (metaValue === 100) {
    ribbon
      .text("DENTRO DO ESPERADO")
      .css("background", "green")
      .css("color", "#fff");
  } else {
    ribbon.text("SEM META").css("background", "#e3dada").css("color", "#000");
  }
}

/**
 * A função `updateTDresultIndicadores` atualiza o texto e o estilo de uma célula da tabela com base em
 * uma comparação com um valor alvo.
 * @param tdResult - O parâmetro `tdResult` na função `updateTDresultIndicadores` deve ser um objeto
 * jQuery que representa um elemento de célula de tabela (`<td>`). A função recupera um valor numérico
 * armazenado em um atributo `data-value` do elemento `tdResult` e, em seguida, atualiza o texto.
 */
function updateTDresultIndicadores(tdResult) {
  const metaValue = parseFloat(tdResult.data("value"));

  if (metaValue > 100) {
    tdResult
      .text("ACIMA DO ESPERADO")
      .css("background", "#0083CA")
      .css("color", "#fff");
  } else if (metaValue < 100) {
    tdResult
      .text("ABAIXO DO ESPERADO")
      .css("background", "#dc3545")
      .css("color", "#fff");
  } else if (metaValue === 100) {
    tdResult
      .text("DENTRO DO ESPERADO")
      .css("background", "green")
      .css("color", "#fff");
  } else {
    tdResult.text("SEM META").css("background", "#e3dada").css("color", "#000");
  }
}

/**
 * A função "periodoPorExtenso" recebe um mês e ano como entrada e retorna o nome completo do mês
 * seguido por "_de_" e o ano.
 * @param mes - O parâmetro `mes` representa o mês no formato numérico (1 para janeiro, 2 para
 * fevereiro, e assim por diante).
 * @param ano - O parâmetro `ano` representa o ano na função `periodoPorExtenso`. É o ano para o qual
 * você deseja gerar o período em português.
 * @returns o mês e o ano em português no formato como "janeiro_de_2022", com base no mês e ano
 * fornecidos.
 */
function periodoPorExtenso(mes, ano) {
  let meses = [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro",
  ];
  let nomeMesExtenso = meses[mes - 1];
  return nomeMesExtenso + "_de_" + ano;
}

/*
    cria selects a partir de um array de objetos JSON 
    Forma de utilização:
    Inserir o código abaixo no arquivo HTML:
    Tem que existir apenas a div com id dados-container e o input com id idSelecionado (pode usar outro id se desejar)
    <div class="container mt-5">
        <h2>Selecione o Processo</h2>
        <div id="dados-container" class="dados-container">
            <!-- Os selects serão adicionados aqui -->
        </div>
        <div id="selectedInfo" style="margin-top: 20px;">
            <p><strong>Id selecionado:</strong><input id="idSelecionado"></input></p>
        </div>
    </div>

    <script>
        $(document).ready(function() {
            $.ajax({
                url: 'cfc/pc_cfcAvaliacoes.cfc',
                data: {
                    method: 'getAvaliacaoTipos',
                },
                dataType: "json",
                async: false
            })//fim ajax
            .done(function(data) {
                // Define os níveis de dados e nomes dos labels
                let dataLevels = ['MACROPROCESSOS', 'PROCESSO_N1', 'PROCESSO_N2', 'PROCESSO_N3'];
                let labelNames = ['Macroprocesso', 'Processo N1', 'Processo N2', 'Processo N3'];
                let outrosOptions = [
                    { dataLevel:'PROCESSO_N3', text: "OUTROS", value: 0 },
                ];
                // Inicializa os selects dinâmicos
                initializeSelects(data, dataLevels, 'ID', labelNames, 'idSelecionado',outrosOptions);
                

            })//fim done
            .fail(function(xhr, ajaxOptions, thrownError) {
                $('#modalOverlay').delay(1000).hide(0, function() {
                    $('#modalOverlay').modal('hide');
                });
                $('#modal-danger').modal('show')
                $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
                $('#modal-danger').find('.modal-body').text(thrownError)

            })//fim fail
        });
    </script>
*/

/**
 * A função `initializeSelects` popula dinamicamente dropdowns (elementos select) com base nos dados e níveis
 * fornecidos, com a capacidade de lidar com seleções em cascata e opções adicionais como "OUTROS".
 * @param containerId - O parâmetro `containerId` é usado para especificar o ID do elemento container
 * onde os elementos select dinâmicos serão gerados. Este container conterá os selects criados dinamicamente
 * com base nos dados e configurações fornecidos.
 * @param data - O parâmetro `data` na função `initializeSelects` representa o array de objetos contendo
 * os dados para popular os selects dinâmicos. Cada objeto no array deve ter propriedades correspondentes
 * aos níveis de dados especificados no array `dataLevels`.
 * @param dataLevels - O parâmetro `dataLevels` na função `initializeSelects` é um array que especifica
 * os níveis ou hierarquia dos dados no objeto `data` fornecido. Cada nível corresponde a uma chave no
 * objeto de dados que representa uma categoria ou atributo específico. Este array ajuda a organizar e
 * filtrar os dados.
 * @param idAttributeName - O parâmetro `idAttributeName` na função `initializeSelects` é usado para
 * especificar o nome do atributo do item selecionado que será armazenado no campo de entrada alvo
 * (`inputAlvo`). Este nome de atributo é usado para recuperar o valor correspondente do item selecionado
 * no array de dados.
 * @param labelNames - O parâmetro `labelNames` na função `initializeSelects` é um array que contém os
 * rótulos a serem exibidos para cada elemento select na dropdown dinâmica. Cada rótulo corresponde a
 * um nível específico na hierarquia da dropdown. Por exemplo, `labelNames[0]` seria o rótulo do primeiro nível.
 * @param inputAlvo - O parâmetro `inputAlvo` na função `initializeSelects` representa o ID do elemento de
 * entrada onde o valor final da seleção será armazenado. Este elemento de entrada será atualizado com base
 * nas seleções feitas nos elementos select gerados dinamicamente dentro do container especificado.
 * @param [outrosOptions] - O parâmetro `outrosOptions` na função `initializeSelects` é um array opcional
 * que permite adicionar opções adicionais aos elementos select gerados dinamicamente com base em critérios
 * específicos. Essas opções são adicionadas ao elemento select se a propriedade `dataLevel` do
 * `outrosOption` corresponder.
 * @returns A função `initializeSelects` não retorna explicitamente nenhum valor. Ela inicializa uma série
 * de elementos select dinâmicos com base nos dados e parâmetros fornecidos e configura ouvintes de eventos
 * para lidar com mudanças nos elementos select. A função modifica o DOM adicionando elementos select e
 * populando-os com opções com base nos dados fornecidos.
 */

function initializeSelects(
  containerId,
  data,
  dataLevels,
  idAttributeName,
  labelNames,
  inputAlvo,
  outrosOptions = []
) {
  // Limpa o container de selects e adiciona o primeiro select
  $(containerId)
    .empty()
    .append(
      '<div class="select-container-initializeSelects"><label class="dynamic-label-initializeSelects" style="text-align: left;">' +
        labelNames[0] +
        ': </label><select class="form-control process-select" id="selectDinamico' +
        dataLevels[0] +
        '" name="selectDinamico' +
        dataLevels[0] +
        '" style="width: 100%;"></select></div>'
    );

  // Função para preencher os selects
  function populateSelect(level, parentSelections) {
    // Obtém o nível atual a partir de dataLevels
    var currentLevel = dataLevels[level];
    if (!currentLevel) return; // Se não há mais níveis, sai da função

    // Filtra os dados com base nas seleções dos níveis superiores
    var filteredData = data;
    for (var i = 0; i < level; i++) {
      filteredData = filteredData.filter(
        (item) => item[dataLevels[i]] === parentSelections[i]
      );
    }

    // Obtém opções únicas para o select atual
    var uniqueOptions = [
      ...new Set(filteredData.map((item) => item[currentLevel])),
    ];

    var $select = $("#selectDinamico" + currentLevel);

    if ($select.length === 0) {
      // Cria um novo select se ele não existir
      $select = $(
        '<select class="form-control process-select dynamic-select animate__animated animate__fadeInDown" id="selectDinamico' +
          currentLevel +
          '" name="selectDinamico' +
          currentLevel +
          '" style="width: 100%;"></select>'
      );
      var $container = $(
        '<div class="select-container-initializeSelects animate__animated animate__fadeInDown"></div>'
      );
      $container.append(
        '<label class="dynamic-label-initializeSelects" style="text-align: left;">' +
          labelNames[level] +
          ": </label>"
      );
      $container.append($select);
      $(containerId).append($container);
    }

    // Preenche o select com opções
    $select.empty().append("<option></option>");

    uniqueOptions.forEach((item) => {
      let option = $("<option></option>").val(item).text(item);
      $select.append(option);
    });

    // Adiciona opções "OUTROS" com base no array outrosOptions
    outrosOptions.forEach((outrosOption) => {
      if (dataLevels[level] === outrosOption.dataLevel) {
        $select.append(
          $("<option></option>").val(outrosOption.value).text(outrosOption.text)
        );
      }
    });

    // Calcula a largura necessária com base na largura dos textos dos options
    var maxWidth = 0;
    $select.children("option").each(function () {
      var optionWidth = $("<span>")
        .text($(this).text())
        .css({
          "font-family": $select.css("font-family"),
          "font-size": $select.css("font-size"),
          visibility: "hidden",
          "white-space": "nowrap",
        })
        .appendTo("body")
        .width();
      maxWidth = Math.max(maxWidth, optionWidth);
    });

    // Adiciona padding à largura calculada e ajusta a largura do select
    var padding = 45; // 40px de padding adicional
    if (maxWidth + padding < 100) {
      $select.css("width", "100px");
    } else {
      $select.css("width", maxWidth + padding + "px");
    }
  }

  // Inicializa o primeiro select
  populateSelect(0, []);

  // Inicializa o select2 para todos os selects
  $(".process-select").select2({
    theme: "bootstrap4",
    placeholder: "Selecione...",
  });

  // Evento de mudança para selects dinâmicos
  $(containerId).on("change", ".process-select", function () {
    var level = dataLevels.indexOf(
      $(this).attr("id").replace("selectDinamico", "")
    );
    var parentSelections = [];
    for (var i = 0; i <= level; i++) {
      parentSelections.push($("#selectDinamico" + dataLevels[i]).val());
    }

    // Verifica se o primeiro select (MACROPROCESSOS) é 'Não se aplica'
    if (parentSelections[0] === "Não se aplica") {
      var finalSelection = data.find(
        (item) => item.MACROPROCESSOS === "Não se aplica"
      );
      if (finalSelection) {
        $("#" + inputAlvo).val(finalSelection[idAttributeName]);
      }
      // Remove todos os selects além do primeiro
      $(".process-select").parent().slice(1).remove();
      return; // Sai da função, não preenche os selects adicionais
    }

    // Remove selects de níveis mais baixos
    $(".process-select").each(function () {
      var currentLevel = dataLevels.indexOf(
        $(this).attr("id").replace("selectDinamico", "")
      );
      if (currentLevel > level) {
        $(this).parent().remove();
      }
    });

    // Preenche o próximo nível de select
    if (parentSelections[level]) {
      populateSelect(level + 1, parentSelections);
    } else {
      $("#" + inputAlvo).val("");
    }

    // Atualiza o ID selecionado se for o último nível
    if (
      !$("#selectDinamico" + dataLevels[level + 1]).length &&
      parentSelections.every((selection) => selection)
    ) {
      var $select = $("#selectDinamico" + dataLevels[level]);
      var selectedOption = $select.val();

      // Verifica se a opção selecionada está em outrosOptions
      var isOutrosOption = outrosOptions.some(
        (option) => option.value.toString() === selectedOption
      );
      if (isOutrosOption) {
        $("#" + inputAlvo).val(selectedOption);
        return;
      }

      var finalSelection = data.find((item) => {
        return dataLevels.every(
          (process, index) => item[process] === parentSelections[index]
        );
      });

      if (finalSelection) {
        $("#" + inputAlvo).val(finalSelection[idAttributeName]);
      }
    } else {
      $("#" + inputAlvo).val("");
    }

    // Inicializa o select2 para os selects dinâmicos
    $(".process-select").select2({
      theme: "bootstrap4",
      placeholder: "Selecione...",
    });
  });
}

/*Função para inicializar selects com Ajax:*/
function initializeSelectsAjax(
  containerId,
  dataLevels,
  idAttributeName,
  labelNames,
  inputAlvo,
  outrosOptions = [],
  cfc,
  metodo
) {
  $.ajax({
    url: cfc,
    method: "GET", // ou "POST", dependendo do seu endpoint
    data: {
      method: metodo,
    },
    dataType: "json",
    async: false,
  })
    .done(function (data) {
      // Inicializa os selects dinâmicos
      initializeSelects(
        containerId,
        data,
        dataLevels,
        idAttributeName,
        labelNames,
        inputAlvo,
        outrosOptions
      );
    })
    .fail(function (xhr, ajaxOptions, thrownError) {
      console.log("AJAX call failed", thrownError);
      $("#modalOverlay")
        .delay(1000)
        .hide(0, function () {
          $("#modalOverlay").modal("hide");
        });
      $("#modal-danger").modal("show");
      $("#modal-danger")
        .find(".modal-title")
        .text(
          "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:"
        );
      $("#modal-danger").find(".modal-body").text(thrownError);
    });
}

/* Função para preencher selects a partir de um ID informado:
Use essa função dentro do success do ajax que retornou o json.
Exemplo:
    $.ajax({
        url: 'cfc/pc_cfcAvaliacoes.cfc',
        data: {
            method: 'getAvaliacaoTipos',
        },
        dataType: "json",
        method: 'GET'
    })
    .done(function(data) {
        // Define os IDs dos selects
        let selectIDs = ['selectDinamicoMACROPROCESSOS', 'selectDinamicoPROCESSO_N1', 'selectDinamicoPROCESSO_N2', 'selectDinamicoPROCESSO_N3'];
        
        // Inicializa os selects (se necessário)
        // initializeSelects(data, dataLevels, 'ID', labelNames, 'idTipoAvaliacao');
        
        // Exemplo de uso da função para preencher os selects a partir de um ID
        const exampleID = processoAvaliado; // Mude para o ID desejado
        
        populateSelectsFromID(data, exampleID, selectIDs, 'idTipoAvaliacao');
    })
    .fail(function(error) {
        $('#modal-danger').modal('show')
            $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
            $('#modal-danger').find('.modal-body').text(error)
    });
*/

function populateSelectsFromID(data, id, dataLevels, inputAlvo) {
  const selectedData = data.find((item) => item.ID == id);
  if (!selectedData) {
    console.error("ID inválido.");
    return;
  }

  // Preenche os selects
  dataLevels.forEach((selectID) => {
    const value = selectedData[selectID];
    $(`#selectDinamico${selectID}`).val(value).trigger("change");
  });

  // Atualiza o campo de destino com o ID correto
  $("#" + inputAlvo).val(selectedData.ID);
}

/**
 * A função `populateSelectsFromIDAjax` faz uma chamada AJAX para recuperar dados e preencher os elementos
 * select com base na resposta.
 * @param cfc - O parâmetro `cfc` na função `populateSelectsFromIDAjax` é utilizado para
 * especificar a URL do componente ColdFusion (CFC) que irá lidar com a solicitação AJAX e fornecer os
 * dados necessários para preencher os elementos select na página web.
 * @param metodo - O parâmetro `metodo` na função `populateSelectsFromIDAjax` representa o método
 * que será chamado no componente ColdFusion (CFC) especificado pelo parâmetro `cfc`. Esse método irá
 * recuperar os dados que serão usados para preencher os elementos select.
 * @param id - O parâmetro `id` na função `populateSelectsFromIDAjax` representa o ID do elemento
 * no documento HTML que você deseja preencher com os dados recuperados pela chamada AJAX. Esse ID
 * é utilizado para direcionar o elemento HTML específico onde os dados serão exibidos ou populados.
 * @param dataLevels - O parâmetro `dataLevels` na função `populateSelectsFromIDAjax` é utilizado
 * para especificar os níveis de dados que serão preenchidos nos elementos select com base nos dados
 * retornados pela chamada AJAX. Ele ajuda a determinar como os dados devem ser estruturados e exibidos
 * nos elementos select.
 * @param inputAlvo - O parâmetro `inputAlvo` na função `populateSelectsFromIDAjax` é utilizado para
 * especificar o elemento de entrada alvo onde os dados recuperados pela chamada AJAX serão
 * populados. Esse elemento de entrada geralmente é um select dropdown ou um campo de formulário similar
 * que será preenchido dinamicamente com os dados.
 */

function populateSelectsFromIDAjax(cfc, metodo, id, dataLevels, inputAlvo) {
  $.ajax({
    url: cfc,
    method: "GET", // ou "POST", dependendo do seu endpoint
    data: {
      method: metodo,
    },
    dataType: "json",
    async: false,
  })
    .done(function (data) {
      populateSelectsFromID(data, id, dataLevels, inputAlvo);
    })
    .fail(function (xhr, ajaxOptions, thrownError) {
      console.log("AJAX call failed", thrownError);
      $("#modalOverlay")
        .delay(1000)
        .hide(0, function () {
          $("#modalOverlay").modal("hide");
        });
      $("#modal-danger").modal("show");
      $("#modal-danger")
        .find(".modal-title")
        .text(
          "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:"
        );
      $("#modal-danger").find(".modal-body").text(thrownError);
    });
}

/*Função para contar a quantidade decaracteres digitados em um input ou textarea
Forma de utilização:
Inserir o código abaixo no arquivo HTML:
<div class="form-group" style="margin-bottom:25px">
        <label for="myInput">Input Text</label>
        <input type="text" id="myInput" class="form-control" >
    </div>
    ou 
    <div class="form-group">
        <label for="myTextarea">Textarea</label>
        <textarea id="myTextarea" class="form-control"></textarea>
    </div>
    <script>
        $(document).ready(function() {
            setupCharCounter('myInput', 10);
            setupCharCounter('myTextarea', 50);
        });
    </script>
*/
function setupCharCounter(inputId, spanId, maxChars) {
  const inputElem = $("#" + inputId);
  const charCountElem = $("#" + spanId);
  charCountElem.attr("hidden", true);
  inputElem.on("input", function () {
    charCountElem.attr("hidden", false);
    const currentLength = inputElem.val().length;

    if (currentLength > maxChars) {
      inputElem.val(inputElem.val().substring(0, maxChars));
      Swal.fire({
        icon: "warning",
        title: "Limite de caracteres ultrapassado!",
        html: logoSNCIsweetalert2(
          "O máximo permitido é " +
            maxChars +
            " caracteres." +
            "<br>O texto foi cortado para atender ao limite."
        ),
      })
        .then(() => {
          inputElem.focus();
        })
        .catch((error) => {
          console.error("SweetAlert2 Error:", error);
        });
    }

    charCountElem.text(`Caracteres: ${inputElem.val().length}/${maxChars}`);
  });
}

/**
 * A função `mostraInfoOrientacao` faz uma solicitação AJAX para recuperar informações e exibi-las em
 * uma div especificada, com rolagem opcional para uma aba e tratamento de erros.
 * @param divId - O parâmetro `divId` na função `mostraInfoOrientacao` é o ID do elemento HTML
 * onde as informações serão exibidas ou atualizadas. Ele é usado para direcionar e manipular o
 * conteúdo dentro dessa div específica na página.
 * @param pc_processo_id - O parâmetro `pc_processo_id` na função `mostraInfoOrientacao` é
 * utilizado para especificar o ID de um processo. Esse ID  é usado para recuperar
 * informações ou realizar ações relacionadas a um processo específico dentro do sistema. Ao chamar a função `mostraInfoOrientacao`.
 * @param pc_aval_orientacao_id - O parâmetro `pc_aval_orientacao_id` na função `mostraInfoOrientacao`
 * é utilizado para especificar o ID da orientação sendo solicitada para um determinado processo. Esse
 * ID é então utilizado na chamada AJAX para recuperar informações sobre essa orientação específica para
 * o processo fornecido.
 * @param tab - O parâmetro `tab` na função `mostraInfoOrientacao` é utilizado para especificar o ID de
 * um elemento de aba na página. Se este parâmetro for fornecido, a função rolará a página para trazer
 * a aba especificada para a visualização após o carregamento do conteúdo.
 */
function mostraInfoOrientacao(
  divId,
  pc_processo_id,
  pc_aval_orientacao_id,
  tab
) {
  $("#modalOverlay").modal("show");

  $("#" + divId).html("");
  $("#" + divId).attr("hidden", true);
  setTimeout(function () {
    $.ajax({
      type: "post",
      url: "cfc/pc_cfcInfoProcessosItens.cfc",
      data: {
        method: "infoOrientacao",
        pc_processo_id: pc_processo_id,
        pc_aval_orientacao_id: pc_aval_orientacao_id,
      },
      async: false,
    }) //fim ajax
      .done(function (result) {
        $("#" + divId).html(result);
        //$('html, body').animate({ scrollTop: ($('#custom-tabs-one-InfOrientacao-tab').offset().top)-60} , 1000);
        $("#" + divId).attr("hidden", false);
        // Verifica se tab foi informado e realiza o scroll
        if (tab) {
          $("html, body").animate(
            {
              scrollTop: $("#" + tab).offset().top - 60,
            },
            1000
          );
        }
        $("#modalOverlay")
          .delay(1000)
          .hide(0, function () {
            $("#modalOverlay").modal("hide");
          });
      }) //fim done
      .fail(function (xhr, ajaxOptions, thrownError) {
        $("#modalOverlay")
          .delay(1000)
          .hide(0, function () {
            $("#modalOverlay").modal("hide");
          });
        $("#modal-danger").modal("show");
        $("#modal-danger")
          .find(".modal-title")
          .text(
            "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:"
          );
        $("#modal-danger").find(".modal-body").text(thrownError);
      }); //fim fail
  }, 200);
}

/**
 * A função `mostraInfoProcesso` faz uma solicitação AJAX para recuperar informações sobre um processo,
 * exibe o resultado em uma div especificada e, opcionalmente, rola para uma aba específica na página.
 * @param divId - O parâmetro `divId` é o ID do elemento HTML onde o conteúdo será
 * exibido após a chamada AJAX ser realizada.
 * @param pc_processo_id - O parâmetro `pc_processo_id` na função `mostraInfoProcesso` é utilizado
 * para identificar um processo específico dentro do sistema. Ele é passado como parâmetro para
 * a função para recuperar informações relacionadas a esse processo em particular.
 * @param tab - O parâmetro `tab` na função `mostraInfoProcesso` é utilizado para especificar o ID de
 * um elemento de aba na página. Se esse parâmetro for fornecido, a função rolará a página para trazer
 * a aba especificada para a visualização após o carregamento das informações do processo.
 */
function mostraInfoProcesso(divId, pc_processo_id, tab) {
  $("#modalOverlay").modal("show");
  $("#" + divId).html("");
  $("#" + divId).attr("hidden", true);
  setTimeout(function () {
    $.ajax({
      type: "post",
      url: "cfc/pc_cfcInfoProcessosItens.cfc",
      data: {
        method: "infoProcesso",
        pc_processo_id: pc_processo_id,
      },
      async: false,
    }) //fim ajax
      .done(function (result) {
        $("#" + divId).html(result);
        $("#" + divId).attr("hidden", false);
        // Verifica se tab foi informado e realiza o scroll
        if (tab) {
          $("html, body").animate(
            {
              scrollTop: $("#" + tab).offset().top - 60,
            },
            1000
          );
        }
        $("#modalOverlay")
          .delay(1000)
          .hide(0, function () {
            $("#modalOverlay").modal("hide");
          });
      }) //fim done
      .fail(function (xhr, ajaxOptions, thrownError) {
        $("#modalOverlay")
          .delay(1000)
          .hide(0, function () {
            $("#modalOverlay").modal("hide");
          });
        $("#modal-danger").modal("show");
        $("#modal-danger")
          .find(".modal-title")
          .text(
            "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:"
          );
        $("#modal-danger").find(".modal-body").text(thrownError);
      }); //fim fail
  }, 200);
}

/**
 * A função `mostraInfoItem` faz uma solicitação AJAX para recuperar informações sobre um item específico
 * e exibi-las em uma div especificada, com a opção de rolar para uma aba específica.
 * @param divId - O parâmetro `divId` é o ID do elemento HTML onde as informações serão
 * exibidas após a chamada AJAX ser realizada.
 * @param pc_processo_id - O parâmetro `pc_processo_id` é utilizado para identificar um processo ou
 * item específico dentro do sistema. Geralmente é um identificador único associado a um processo ou
 * item. Na função `mostraInfoItem`, esse parâmetro é passado como parte do objeto de dados
 * em uma solicitação AJAX.
 * @param pc_aval_id - O parâmetro `pc_aval_id` na função `mostraInfoItem` é utilizado para passar o
 * ID do item para o método no servidor que recupera as informações sobre um item específico em
 * um processo. Esse ID é essencial para identificar o item associado à orientação consultada.
 * @param tab - O parâmetro `tab` na função `mostraInfoItem` é utilizado para especificar o ID de uma aba
 * na página. Se o parâmetro `tab` for fornecido, a função rolará a página para trazer
 * essa aba à visualização após o carregamento do conteúdo.
 */
function mostraInfoItem(divId, pc_processo_id, pc_aval_id, tab) {
  $("#modalOverlay").modal("show");
  $("#" + divId).html("");
  $("#" + divId).attr("hidden", true);
  setTimeout(function () {
    $.ajax({
      type: "post",
      url: "cfc/pc_cfcInfoProcessosItens.cfc",
      data: {
        method: "infoItem",
        pc_processo_id: pc_processo_id,
        pc_aval_id: pc_aval_id,
      },
      async: false,
    }) //fim ajax
      .done(function (result) {
        $("#" + divId).html(result);
        $("#" + divId).attr("hidden", false);
        // Verifica se tab foi informado e realiza o scroll
        if (tab) {
          $("html, body").animate(
            {
              scrollTop: $("#" + tab).offset().top - 60,
            },
            1000
          );
        }
        $("#modalOverlay")
          .delay(1000)
          .hide(0, function () {
            $("#modalOverlay").modal("hide");
          });
      }) //fim done
      .fail(function (xhr, ajaxOptions, thrownError) {
        $("#modalOverlay")
          .delay(1000)
          .hide(0, function () {
            $("#modalOverlay").modal("hide");
          });
        $("#modal-danger").modal("show");
        $("#modal-danger")
          .find(".modal-title")
          .text(
            "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:"
          );
        $("#modal-danger").find(".modal-body").text(thrownError);
      }); //fim fail
  }, 200);
}

/**
 * A função `mostraRelatoPDF` exibe um relatório em PDF em um elemento HTML especificado após fazer uma
 * requisição AJAX para recuperar os dados do relatório.
 * @param divId - O parâmetro `divId` na função `mostraRelatoPDF` é o ID do elemento HTML onde o relatório
 * em PDF será exibido.
 * @param pc_aval_id - O parâmetro `pc_aval_id` é usado para identificar um item no
 * sistema. É um identificador único associado aos dados do item no banco de dados.
 * Esse parâmetro é passado para o código no lado do servidor para recuperar as informações correspondentes
 * do item e gerar o relatório em PDF para exibição ao usuário.
 * @param todosRelatorios - O parâmetro `todosRelatorios` é usado na função `mostraRelatoPDF` para
 * determinar se todos os relatórios devem ser incluídos no processo de geração do PDF. Ele é passado como
 * parâmetro na requisição AJAX para o método `anexoAvaliacao` no servidor junto com outros parâmetros.
 * @param tab - O parâmetro `tab` na função `mostraRelatoPDF` é utilizado para especificar o ID de um
 * elemento de aba na página. Se o parâmetro `tab` for fornecido, a função irá rolar a página para trazer
 * a aba especificada à visualização após carregar o conteúdo do PDF.
 */

function mostraRelatoPDF(divId, pc_aval_id, todosRelatorios, aba) {
  $("#modalOverlay").modal("show");
  $("#" + divId).html("");
  $("#" + divId).attr("hidden", true);
  setTimeout(function () {
    $.ajax({
      type: "post",
      url: "cfc/pc_cfcAvaliacoes.cfc",
      data: {
        method: "anexoAvaliacao",
        pc_aval_id: pc_aval_id,
        todosOsRelatorios: todosRelatorios,
      },
      async: false,
    }) //fim ajax
      .done(function (result) {
        $("#" + divId).html(result);
        $("#" + divId).attr("hidden", false);
        // Verifica se a aba foi informada e realiza o scroll
        if (aba) {
          $("html, body").animate(
            {
              scrollTop: $("#" + aba).offset().top - 60,
            },
            1000
          );
        }
        $("#modalOverlay")
          .delay(1000)
          .hide(0, function () {
            $("#modalOverlay").modal("hide");
          });
      }) //fim done
      .fail(function (xhr, ajaxOptions, thrownError) {
        $("#modalOverlay")
          .delay(1000)
          .hide(0, function () {
            $("#modalOverlay").modal("hide");
          });
        $("#modal-danger").modal("show");
        $("#modal-danger")
          .find(".modal-title")
          .text(
            "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:"
          );
        $("#modal-danger").find(".modal-body").text(thrownError);
      }); //fim fail
  }, 200);
}

/**
 * A função `mostraTabAnexosJS` faz uma requisição AJAX para carregar anexos em um elemento `div`
 * especificado, opcionalmente rolando até uma aba específica dentro do conteúdo.
 * @param divId - O parâmetro `divId` é o ID do elemento HTML onde o conteúdo será exibido ou atualizado
 * após a chamada AJAX ser realizada.
 * @param pc_aval_id - O parâmetro `pc_aval_id` é usado para passar o ID de item
 * para a função `mostraTabAnexosJS`. Esse ID é então utilizado na requisição AJAX para recuperar
 * informações específicas relacionadas a esse item.
 * @param pc_orientacao_id - O parâmetro `pc_orientacao_id` na função `mostraTabAnexosJS` é utilizado
 * para especificar o ID relacionado à orientação em um determinado contexto. Esse ID é
 * usado dentro da função para recuperar ou manipular dados associados a uma orientação específica.
 * @param tab - O parâmetro `tab` na função `mostraTabAnexosJS` é utilizado para especificar o ID de um
 * elemento dentro do conteúdo carregado via AJAX. Após o carregamento bem-sucedido do conteúdo, a função
 * irá rolar a página para trazer o elemento da aba especificada à visualização.
 */

function mostraTabAnexosJS(divId, pc_aval_id, pc_orientacao_id, aba) {
  $("#modalOverlay").modal("show");
  $("#" + divId).html("");
  $("#" + divId).attr("hidden", true);
  setTimeout(function () {
    $.ajax({
      type: "post",
      url: "cfc/pc_cfcAvaliacoes.cfc",
      data: {
        method: "tabAnexos",
        pc_aval_id: pc_aval_id,
        pc_orientacao_id: pc_orientacao_id,
      },
      async: false,
    }) //fim ajax
      .done(function (result) {
        $("#" + divId).html(result);
        $("#" + divId).attr("hidden", false);
        // Verifica se a aba foi informada e realiza o scroll
        if (aba) {
          $("html, body").animate(
            {
              scrollTop: $("#" + aba).offset().top - 60,
            },
            1000
          );
        }
        $("#modalOverlay")
          .delay(1000)
          .hide(0, function () {
            $("#modalOverlay").modal("hide");
          });
      }) //fim done
      .fail(function (xhr, ajaxOptions, thrownError) {
        $("#modalOverlay")
          .delay(1000)
          .hide(0, function () {
            $("#modalOverlay").modal("hide");
          });
        $("#modal-danger").modal("show");
        $("#modal-danger")
          .find(".modal-title")
          .text(
            "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:"
          );
        $("#modal-danger").find(".modal-body").text(thrownError);
      }); //fim fail
  }, 200);
}

/**
 * A função "colocarEmAnalise" em JavaScript é usada para lidar com o processo de colocar uma
 * orientação em análise com base em certas condições e interações do usuário, incluindo exibição
 * de mensagens e execução de requisições AJAX.
 * @param idProcesso
 * @param idAvaliacao
 * @param idOrientacao
 * @param orgaoOrigem
 * @param orgaoOrigemSigla
 * @param orgaoResp
 * @param statusOrientacao
 * @param lotacaoUsuario
 * @param lotacaoUsuarioSigla
 */

function colocarEmAnalise(
  idProcesso,
  idAvaliacao,
  idOrientacao,
  orgaoOrigem,
  orgaoOrigemSigla,
  orgaoResp,
  statusOrientacao,
  lotacaoUsuario,
  lotacaoUsuarioSigla
) {
  // Dividir a sequência usando a barra (/) como delimitador epegar a última
  lotacaoUsuarioSigla = lotacaoUsuarioSigla.split("/").pop();
  orgaoOrigemSigla = orgaoOrigemSigla.split("/").pop();

  $("#tabProcessos tr").each(function () {
    $(this).removeClass("selected");
  });
  $("#tabProcessos tbody").on("click", "tr", function () {
    $(this).addClass("selected");
  });
  sessionStorage.setItem("emAnalise", idOrientacao);

  var analiseOrgaoOrigem = 0;
  if (statusOrientacao == 13 || statusOrientacao == 17) {
    if (statusOrientacao == 17) {
      var mensagem =
        '<p style="text-align: justify;">Deseja enviar a orientação ID <strong >' +
        idOrientacao +
        "</strong> para análise do órgão de origem do processo <strong>" +
        orgaoOrigemSigla +
        " </strong>(perfil CI - GESTOR MASTER - EXECUÇÃO) ?</p>";
      analiseOrgaoOrigem = 1;
    } else {
      var mensagem =
        '<p style="text-align: justify;">Deseja enviar a orientação ID <strong >' +
        idOrientacao +
        "</strong> para análise da <strong>" +
        lotacaoUsuarioSigla +
        " </strong>(perfil CI-MASTER ACOMPANHAMENTO) ?</p>";
      analiseOrgaoOrigem = 0;
    }

    if (orgaoOrigem != lotacaoUsuario && orgaoResp == lotacaoUsuario) {
      orgaoOrigemParaAnalise = orgaoOrigem;
    } else {
      orgaoOrigemParaAnalise = lotacaoUsuario;
    }

    Swal.fire({
      //sweetalert2
      html: logoSNCIsweetalert2(mensagem),
      showCancelButton: true,
      confirmButtonText: "Sim!",
      cancelButtonText: "Cancelar!",
    }).then((result) => {
      if (result.isConfirmed) {
        $("#modalOverlay").modal("show");
        setTimeout(function () {
          $.ajax({
            type: "post",
            url: "cfc/pc_cfcConsultasPorOrientacao.cfc",
            data: {
              method: "colocarEmAnalise",
              idProcesso: idProcesso,
              idAvaliacao: idAvaliacao,
              idOrientacao: idOrientacao,
              orgaoOrigem: orgaoOrigemParaAnalise,
              analiseOrgaoOrigem: analiseOrgaoOrigem,
            },
            async: false,
          }) //fim ajax
            .done(function (result) {
              var currentPage = window.location.pathname.split("/").pop();
              if (currentPage == "pc_ConsultarPorOrientacao.cfm") {
                var valorRadio = $('input[name="opcaoAno"]:checked').val();
                exibirTabela(valorRadio);
              } else {
                exibirTabela();
              }
              if (currentPage == "pc_ConsultarPorOrientacao.cfm") {
                var mensagemSucessos =
                  '<br><p class="font-weight-light" >A Orientação ID <span>' +
                  idOrientacao +
                  "</span> foi enviada para análise da <span >" +
                  orgaoOrigemSigla +
                  "</span> (perfil CI-GESTOR MASTER - EXECUÇÃO) com sucesso!</p>";
              } else {
                var mensagemSucessos =
                  '<br><p class="font-weight-light" >A Orientação ID <span>' +
                  idOrientacao +
                  "</span> foi enviada para análise da <span  >" +
                  orgaoOrigemSigla +
                  '</span> (perfil CI-GESTOR MASTER - EXECUÇÃO) com sucesso!<br><br><span  style="font-size:0.8em;"><strong>Atenção:</strong> Como a gerência e perfil que analisará esta orientação não é a sua gerência de lotação e perfil, você não poderá visualizar esta orientação em "Acompanhamento", apenas em "Consulta por Orientação", portanto, orientamos anotar o ID da orientação, informado acima, e realizar uma consulta para verificar se essa rotina realmente foi executada com sucesso.</span></p>';
              }
              $("#modalOverlay")
                .delay(1000)
                .hide(0, function () {
                  Swal.fire({
                    title: mensagemSucessos,
                    html: logoSNCIsweetalert2(""),
                    icon: "success",
                  });
                  $("#modalOverlay").modal("hide");
                });
            }) //fim done
            .fail(function (xhr, ajaxOptions, thrownError) {
              $("#modalOverlay")
                .delay(1000)
                .hide(0, function () {
                  $("#modalOverlay").modal("hide");
                });
              $("#modal-danger").modal("show");
              $("#modal-danger")
                .find(".modal-title")
                .text(
                  "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:"
                );
              $("#modal-danger").find(".modal-body").text(thrownError);
            }); //fim fail
        }, 500);
      } else {
        // Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
        $("#modalOverlay").modal("hide");
        Swal.fire({
          title: "Operação Cancelada",
          html: logoSNCIsweetalert2(""),
          icon: "info",
        });
      }
    });
  } else {
    var mensagem =
      '<p style="text-align: justify;">Deseja enviar a orientação ID <strong>' +
      idOrientacao +
      "</strong> para análise da <strong>" +
      lotacaoUsuarioSigla +
      "</strong> (perfil CI-MASTER ACOMPANHAMENTO)?</p>";
    Swal.fire({
      //sweetalert2
      html: logoSNCIsweetalert2(mensagem),
      input: "checkbox",
      inputValue: 0,
      inputPlaceholder:
        '<span class="font-weight-light" style="text-align: justify;font-size:14px">Assinale ao lado, para enviar essa orientação para análise do órgão de origem do processo <strong>' +
        orgaoOrigemSigla +
        "</strong> (perfil CI - GESTOR MASTER - EXECUÇÃO).</span>",
      showCancelButton: true,
      confirmButtonText: "Sim!",
      cancelButtonText: "Cancelar!",
    }).then((result) => {
      if (result.isConfirmed) {
        var enviaOrgaoOrigem = result.value;
        $("#modalOverlay").modal("show");
        setTimeout(function () {
          $.ajax({
            type: "post",
            url: "cfc/pc_cfcConsultasPorOrientacao.cfc",
            data: {
              method: "colocarEmAnalise",
              idProcesso: idProcesso,
              idAvaliacao: idAvaliacao,
              idOrientacao: idOrientacao,
              orgaoOrigem: orgaoOrigem,
              analiseOrgaoOrigem: enviaOrgaoOrigem,
            },
            async: false,
          }) //fim ajax
            .done(function (result) {
              var currentPage = window.location.pathname.split("/").pop();
              if (currentPage == "pc_ConsultarPorOrientacao.cfm") {
                var valorRadio = $('input[name="opcaoAno"]:checked').val();
                exibirTabela(valorRadio);
              } else {
                exibirTabela();
              }
              var mensagemSucessos = "";
              // Obtém o nome do arquivo atual
              var currentPage = window.location.pathname.split("/").pop();
              if (!enviaOrgaoOrigem) {
                mensagemSucessos =
                  '<br><p class="font-weight-light" >A Orientação ID ' +
                  idOrientacao +
                  "</span> foi enviada para análise da <span>" +
                  lotacaoUsuarioSigla +
                  "</span> (perfil CI-MASTER ACOMPANHAMENTO) com sucesso!</p>";
              } else {
                if (currentPage != "pc_ConsultarPorOrientacao.cfm") {
                  mensagemSucessos =
                    '<br><p class="font-weight-light" >A Orientação ID ' +
                    idOrientacao +
                    "</span> foi enviada para análise da <span>" +
                    orgaoOrigemSigla +
                    '</span> com sucesso!<br><br><span style="font-size:0.8em;"><strong>Atenção:</strong> Como a gerência e perfil que analisará esta orientação não é a sua gerência de lotação e perfil, você não poderá visualizar esta orientação em "Acompanhamento", apenas em "Consulta por Orientação", portanto, orientamos anotar o ID da orientação, informado acima, e realizar uma consulta para verificar se essa rotina realmente foi executada com sucesso.</span></p>';
                } else {
                  mensagemSucessos =
                    '<br><p class="font-weight-light" >A Orientação ID ' +
                    idOrientacao +
                    "</span> foi enviada para análise da <span>" +
                    orgaoOrigemSigla +
                    "</span> com sucesso!</p>";
                }
              }
              $("#modalOverlay")
                .delay(1000)
                .hide(0, function () {
                  Swal.fire({
                    title: mensagemSucessos,
                    html: logoSNCIsweetalert2(""),
                    icon: "success",
                  });
                  $("#modalOverlay").modal("hide");
                });
            }) //fim done
            .fail(function (xhr, ajaxOptions, thrownError) {
              $("#modalOverlay")
                .delay(1000)
                .hide(0, function () {
                  $("#modalOverlay").modal("hide");
                });
              $("#modal-danger").modal("show");
              $("#modal-danger")
                .find(".modal-title")
                .text(
                  "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:"
                );
              $("#modal-danger").find(".modal-body").text(thrownError);
            }); //fim fail
        }, 500);
      } else {
        // Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
        $("#modalOverlay").modal("hide");
        Swal.fire({
          title: "Operação Cancelada",
          html: logoSNCIsweetalert2(""),
          icon: "info",
        });
      }
    });
  }

  $("#modalOverlay")
    .delay(1000)
    .hide(0, function () {
      $("#modalOverlay").modal("hide");
    });
}

/**
 * A função `openPdfModal` cria dinamicamente e exibe um modal com um PDF incorporado
 * e opções para abrir o PDF em uma nova aba do navegador ou fechar o modal.
 * @param pc_anexo_id - O parâmetro `pc_anexo_id` na função `openPdfModal` representa
 * um identificador para o modal de PDF que está sendo aberto. Ele é usado para identificar
 * de forma exclusiva o elemento modal e seu conteúdo dentro do documento HTML. Esse identificador
 * é utilizado para criar e gerenciar dinamicamente várias instâncias do PDF.
 * @param caminho - O parâmetro `caminho` na função `openPdfModal` representa o caminho para o
 * arquivo PDF que você deseja exibir no modal. Esse caminho é usado para carregar dinamicamente
 * o arquivo PDF em um iframe dentro do modal. Ele deve ser um caminho válido para o arquivo PDF.
 */

function openPdfModal(pc_anexo_id, caminho) {
  // Verificar se o modal já existe, se sim, removê-lo antes de criar outro
  if ($("#pdfModal" + pc_anexo_id).length) {
    $("#pdfModal" + pc_anexo_id).remove();
  }

  // Criar o HTML do modal dinamicamente
  var modalHtml = `
        <div class="modal fade" id="pdfModal${pc_anexo_id}" tabindex="-1" role="dialog" aria-labelledby="pdfModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl" role="document">
                <div class="modal-content" style="max-height: 90vh;background:#323639;border:0; display: flex; flex-direction: column;">
                    <div class="modal-body" style="padding:0;background:none;position:relative;top:4px;flex-grow: 1; overflow-y: auto;">
                        <!-- PDF embutido dinamicamente -->
                        <iframe id="pdfEmbed${pc_anexo_id}" src="pc_Anexos.cfm?arquivo=${caminho}#zoom=page-width"  
                                width="100%" style="flex-grow: 1; min-height: 70vh; border: none;" loading="eager"></iframe>
                    </div>
                    <div class="modal-footer p-0 card-header_backgroundColor"
                        style="display:flex; justify-content: space-between; align-items: center; flex-shrink: 0;">
                        <!-- Link para abrir PDF em nova aba -->
                        <a id="pdfLink${pc_anexo_id}" href="pc_Anexos.cfm?arquivo=${caminho}" target="_blank" class="btn btn-danger" style="margin: 0 auto;">
                            <i class="fas fa-file-pdf" style="margin-right:5px;"></i>Abrir PDF em Nova Aba do Navegador
                        </a>
                        <!-- Botão de fechar -->
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
                    </div>
                </div>
            </div>
        </div>
    `;

  // Inserir o HTML do modal no corpo do documento
  $("body").append(modalHtml);

  // Exibir o modal
  $("#pdfModal" + pc_anexo_id).modal("show");
}

$("#btEnviarDistribuicao").on("click", function (event) {
  event.preventDefault();
  event.stopPropagation();

  if ($("#pcOrgaoRespDistribuicao").val().length == 0) {
    Swal.fire({
      title: "Informe, pelo menos, uma área para distribuição.",
      html: logoSNCIsweetalert2(""),
      icon: "error",
    });
    return false;
  }

  if ($("#pcOrientacaoResposta").val().length == 0) {
    Swal.fire({
      title: "Informe uma orientação para a resposta da(s) área(s).",
      html: logoSNCIsweetalert2(""),
      icon: "error",
    });
    return false;
  }
  swalWithBootstrapButtons
    .fire({
      //sweetalert2
      html: logoSNCIsweetalert2(
        "Deseja distribuir essa Medida/Orientação para Regularização às áreas selecionadas?"
      ),
      showCancelButton: true,
      confirmButtonText: "Sim!",
      cancelButtonText: "Cancelar!",
    })
    .then((result) => {
      if (result.isConfirmed) {
        $("#modalOverlay").modal("show");
        setTimeout(function () {
          //inicio ajax
          $.ajax({
            type: "post",
            url: "cfc/pc_cfcAcompanhamentos.cfc",
            data: {
              method: "distribuirOrientacoes",
              pc_aval_orientacao_id: pc_aval_orientacao_id,
              pcAreasDistribuir: $("#pcOrgaoRespDistribuicao").val().join(","),
              pcOrientacaoResposta: $("#pcOrientacaoResposta").val(),
            },
            async: false,
          }) //fim ajax
            .done(function (result) {
              $("#modalOverlay")
                .delay(1000)
                .hide(0, function () {
                  toastr.success("Distribuição realizada com sucesso!");
                  ocultaInformacoes();
                  exibirTabela();
                  $("#modalOverlay").modal("hide");
                  //location.reload();
                });
            }) //fim done
            .fail(function (xhr, ajaxOptions, thrownError) {
              $("#modalOverlay")
                .delay(1000)
                .hide(0, function () {
                  $("#modalOverlay").modal("hide");
                });
              $("#modal-danger").modal("show");
              $("#modal-danger")
                .find(".modal-title")
                .text(
                  "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:"
                );
              $("#modal-danger").find(".modal-body").text(thrownError);
            }); //fim fail
        }, 1000);
      } else if (result.dismiss === Swal.DismissReason.cancel) {
        Swal.fire({
          title: "Operação Cancelada",
          html: logoSNCIsweetalert2(""),
          icon: "info",
        });
      }
    }); //fim sweetalert2
});

/**
 * A função `initFavoriteIcon` adiciona um ícone de favorito (estrela) ao cabeçalho de um card
 * e gerencia o estado de favorito no localStorage.
 * @param cardId - O ID do elemento card ao qual o ícone de favorito será adicionado
 * @param componentPath - O caminho relativo do componente para ser armazenado no localStorage
 * @param componentTitle - O título do componente a ser exibido nas mensagens e armazenado com o favorito
 * @returns O objeto jQuery do ícone criado
 */
function initFavoriteIcon(cardId, componentPath, componentTitle) {
  // Chave para armazenar favoritos no localStorage
  const FAVORITES_KEY = "snci_dashboard_favoritos";

  // Obter os favoritos atuais ou inicializar um array vazio
  function getFavorites() {
    const favoritesJson = localStorage.getItem(FAVORITES_KEY);
    return favoritesJson ? JSON.parse(favoritesJson) : [];
  }

  // Salvar favoritos no localStorage
  function saveFavorites(favorites) {
    localStorage.setItem(FAVORITES_KEY, JSON.stringify(favorites));
  }

  // Verificar se o componente está nos favoritos
  function isFavorite(path) {
    const favorites = getFavorites();
    return favorites.some((fav) => fav.path === path);
  }

  // Adicionar aos favoritos
  function addToFavorites(path, title, id) {
    const favorites = getFavorites();
    if (!isFavorite(path)) {
      favorites.push({
        path: path,
        title: title,
        id: id,
        layout: {x: 0, y: 0, w: 12, h: 2},
        timestamp: new Date().getTime(),
      });
      saveFavorites(favorites);
    }
  }

  // Remover dos favoritos
  function removeFromFavorite(path) {
    const favorites = getFavorites();
    const updatedFavorites = favorites.filter((fav) => fav.path !== path);
    saveFavorites(updatedFavorites);
  }

  // Obter o elemento card e seu cabeçalho
  const $card = $("#" + cardId);
  if ($card.length === 0) return null;

  const $cardHeader = $card.find(".card-header");
  if ($cardHeader.length === 0) return null;

  // Verificar se já existe um ícone de favorito
  let $starIcon = $cardHeader.find(".favorite-star");
  if ($starIcon.length > 0) return $starIcon;

  // Criar o ícone de estrela
  $starIcon = $("<i>", {
    class: "fas fa-star favorite-star",
    css: {
      position: "absolute",
      right: "15px",
      top: "50%",
      transform: "translateY(-50%)",
      cursor: "pointer",
      fontSize: "18px",
      color: isFavorite(componentPath) ? "#ffc107" : "#6c757d",
      transition: "color 0.3s ease",
    },
    "data-toggle": "tooltip",
    "data-placement": "top",
    title: "Marcar como favorito",
  });

  // Certificar que o cabeçalho tem posição relativa para posicionar o ícone
  $cardHeader.css("position", "relative");

  // Adicionar o ícone ao cabeçalho
  $cardHeader.append($starIcon);

  // Inicializar tooltip
  $starIcon.tooltip();

  // Adicionar evento de clique
  $starIcon.on("click", function (e) {
    e.preventDefault();
    const isFav = isFavorite(componentPath);

    if (isFav) {
      // Remover dos favoritos
      removeFromFavorite(componentPath);
      $starIcon.css("color", "#6c757d");
      $starIcon
        .attr("title", "Marcar como favorito")
        .tooltip("dispose")
        .tooltip();
      toastr.info(`"${componentTitle}" removido dos seus favoritos!`);
    } else {
      // Adicionar aos favoritos
      addToFavorites(componentPath, componentTitle, cardId);
      $starIcon.css("color", "#ffc107");
      $starIcon
        .attr("title", "Remover dos favoritos")
        .tooltip("dispose")
        .tooltip();
      toastr.success(`"${componentTitle}" adicionado aos seus favoritos!`);
    }
  });

  // Adicionar efeito hover
  $starIcon.hover(
    function () {
      $(this).css("transform", "translateY(-50%) scale(1.2)");
    },
    function () {
      $(this).css("transform", "translateY(-50%) scale(1)");
    }
  );

  return $starIcon;
}
