// Variáveis globais para controle da busca
let searchCanceled = false;
let searchInProgress = false;
let searchStartTime = 0;
let pollInterval = null;

// Gerenciador de busca em PDFs
const PdfSearchManager = {
  currentSearchResults: [],

  // Inicializar o gerenciador
  init: function () {
    this.loadRecentSearches();

    // Verificar se há termos de busca na URL
    const urlParams = new URLSearchParams(window.location.search);
    const searchTerms = urlParams.get("q");
    if (searchTerms) {
      $("#searchTerms").val(searchTerms);
      this.performSearch(searchTerms);
    }

    // Configurar o handler para o botão de cancelamento
    $("#cancelSearch").on("click", function () {
      if (searchInProgress) {
        searchCanceled = true;
        $(this)
          .prop("disabled", true)
          .html('<i class="fas fa-spinner fa-spin mr-1"></i> Cancelando...');

        // Cancelar polling e qualquer requisição pendente
        if (pollInterval) {
          clearInterval(pollInterval);
          pollInterval = null;
        }

        $("#searchLoading").hide();
        $("#realTimeResults").hide();
        $("#searchStats").text("Busca cancelada pelo usuário");

        setTimeout(function () {
          $("#cancelSearch")
            .prop("disabled", false)
            .html('<i class="fas fa-times mr-1"></i> Cancelar busca');

          searchInProgress = false;
        }, 1000);
      }
    });
  },

  // Realizar a busca
  performSearch: function (searchTerms) {
    if (!searchTerms) {
      searchTerms = $("#searchTerms").val().trim();
    }

    // Validação dos termos
    if (!searchTerms || searchTerms.length < 3) {
      if (typeof toastr !== "undefined") {
        toastr.warning("Digite pelo menos 3 caracteres para realizar a busca.");
      } else {
        alert("Digite pelo menos 3 caracteres para realizar a busca.");
      }
      return;
    }

    // Obter as opções de busca selecionadas
    const searchOptions = {
      mode: $('input[name="searchMode"]:checked').val() || "or", // or, exact, proximity
      type: $('input[name="searchType"]:checked').val() || "exact", // exact, fuzzy
      fuzzyThreshold: parseFloat($("#fuzzyThreshold").val() || "0.2"),
      caseSensitive: $("#searchCaseSensitive").is(":checked"),
      proximityDistance: parseInt($("#proximityDistance").val() || "20"),
      showHighlights: $("#showHighlights").is(":checked"),
    };

    // Incluir o ano e o texto do título, se informado
    searchOptions.processYear = $("#searchYear").val().trim();
    searchOptions.titleSearch = $("#searchTitle").val().trim();

    $("#resultsCard").show();
    $("#searchLoading").show();
    $("#searchResults").empty();
    $("#noResultsAlert").hide();
    $("#errorAlert").hide();
    $("#searchStats").text("");
    $("#realTimeResults").show();
    $("#realTimeResultsList").empty();

    this.updateUrlWithSearchTerms(searchTerms);
    this.saveRecentSearch(searchTerms);

    // Definir variáveis de controle
    searchCanceled = false;
    searchInProgress = true;
    searchStartTime = performance.now();

    // Inicializar animação
    this.startSearchAnimation();

    console.log("Iniciando busca no servidor com termos:", searchTerms);
    console.log("Opções de busca:", searchOptions);

    // Variável para armazenar o ID da busca retornado pelo servidor
    let searchID = null;

    // Fazer a requisição para o servidor - usar o caminho correto do CFC
    $.ajax({
      url: "cfc/pc_cfcBuscaPDF_novo.cfc",
      type: "POST",
      data: {
        method: "searchInPDFs",
        searchTerms: searchTerms,
        searchOptions: JSON.stringify(searchOptions),
      },
      dataType: "json",
      success: (response) => {
        console.log("Resposta recebida:", response);

        // Armazenar o ID da busca para usar no polling
        if (response && response.searchID) {
          searchID = response.searchID;
        }

        // Não encerrar o searchInProgress aqui para permitir o polling
        if (!response.isPartialResult) {
          searchInProgress = false;
          $("#searchLoading").hide();
          this.handleSearchResponse(response, searchTerms, searchOptions);
        } else {
          // Se for resultado parcial, continuar o polling com o ID da busca
          this.startRealTimePolling(searchID || searchTerms);
        }
      },
      error: (xhr, status, error) => {
        console.error("Erro na requisição AJAX:", status, error);
        console.error("Resposta completa:", xhr.responseText);
        searchInProgress = false;
        $("#searchLoading").hide();

        // Exibir informações mais detalhadas sobre o erro
        let errorMessage = "Erro ao realizar a busca. ";

        if (xhr.status === 0) {
          errorMessage += "Problemas de conexão de rede.";
        } else if (xhr.status === 404) {
          errorMessage += "Serviço de busca não encontrado.";
        } else if (xhr.status === 500) {
          // Tentar extrair a mensagem de erro do ColdFusion
          if (
            xhr.responseText &&
            xhr.responseText.includes("Element FILESREAD is undefined")
          ) {
            errorMessage +=
              "Erro no servidor: Variável não definida. Tente novamente.";
          } else {
            errorMessage += "Erro interno no servidor. Verifique os logs.";
          }
        } else {
          errorMessage += `Código: ${xhr.status}, Mensagem: ${
            error || "Desconhecido"
          }`;
        }

        $("#errorMessage").text(errorMessage);
        $("#errorAlert").show();

        // Limpar o polling se estiver em andamento
        if (pollInterval) {
          clearInterval(pollInterval);
          pollInterval = null;
        }
      },
    });

    // Iniciar polling para feedback em tempo real, usando o termo como fallback
    this.startRealTimePolling(searchID || searchTerms);
  },

  // Processar resposta da busca
  handleSearchResponse: function (response, searchTerms, searchOptions) {
    const searchTime = ((performance.now() - searchStartTime) / 1000).toFixed(
      2
    );

    // Garantir que temos uma resposta em formato de objeto
    let parsedResponse = response;

    if (typeof parsedResponse === "string") {
      try {
        parsedResponse = JSON.parse(parsedResponse);
      } catch (e) {
        console.error("Erro ao converter resposta para objeto:", e);
        console.log("Resposta recebida:", response);

        // Se temos resultados parciais já coletados durante polling, mostrá-los
        if (this.currentSearchResults && this.currentSearchResults.length > 0) {
          $("#searchLoading").hide();
          // Atualizar apenas estatísticas
          $("#searchStats").text(
            `${this.currentSearchResults.length} resultado${
              this.currentSearchResults.length !== 1 ? "s" : ""
            } encontrado${
              this.currentSearchResults.length !== 1 ? "s" : ""
            } em ${searchTime} segundos.`
          );
          return;
        }

        $("#errorMessage").text(
          "Erro ao processar resposta do servidor. Verifique o console para mais detalhes."
        );
        $("#errorAlert").show();
        return;
      }
    }

    try {
      // ColdFusion pode retornar propriedades em maiúsculas
      const success = parsedResponse.success || parsedResponse.SUCCESS;

      // Se já temos resultados do polling em tempo real, usá-los em vez dos resultados da resposta
      if (this.currentSearchResults && this.currentSearchResults.length > 0) {
        if (success) {
          // Podemos usar totalFound e filesRead da resposta final
          const filesRead =
            parsedResponse.filesRead || parsedResponse.FILESREAD || 0;
          const totalFound = this.currentSearchResults.length;

          // Apenas atualizar estatísticas, não recriar os cards
          $("#searchStats").text(
            `${this.currentSearchResults.length} resultado${
              this.currentSearchResults.length !== 1 ? "s" : ""
            } encontrado${
              this.currentSearchResults.length !== 1 ? "s" : ""
            } em ${searchTime} segundos. Arquivos lidos: ${filesRead}`
          );
        } else {
          $("#errorMessage").text(
            parsedResponse.message || "Erro desconhecido na busca"
          );
          $("#errorAlert").show();
        }
        return;
      }

      // Se não temos resultados do polling, proceder normalmente
      const results = parsedResponse.results || parsedResponse.RESULTS || [];
      const totalFound =
        parsedResponse.totalFound || parsedResponse.TOTALFOUND || 0;
      const filesRead =
        parsedResponse.filesRead || parsedResponse.FILESREAD || 0;

      if (success) {
        this.currentSearchResults = results;

        if (totalFound > 0) {
          // Apenas atualizar estatísticas, não recriar os cards
          $("#searchStats").text(
            `${this.currentSearchResults.length} resultado${
              this.currentSearchResults.length !== 1 ? "s" : ""
            } encontrado${
              this.currentSearchResults.length !== 1 ? "s" : ""
            } em ${searchTime} segundos. Arquivos lidos: ${filesRead}`
          );
        } else {
          $("#noResultsAlert").show();
          $("#searchStats").text(
            `0 resultados encontrados em ${searchTime} segundos. Arquivos lidos: ${filesRead}`
          );
        }
      } else {
        $("#errorMessage").text(
          parsedResponse.message || "Erro desconhecido na busca"
        );
        $("#errorAlert").show();
      }
    } catch (error) {
      console.error("Erro ao processar resposta:", error);
      $("#errorMessage").text(
        "Erro ao processar resposta do servidor: " + error.message
      );
      $("#errorAlert").show();
    }
  },

  // Iniciar polling para feedback em tempo real
  startRealTimePolling: function (searchID) {
    if (pollInterval) {
      clearInterval(pollInterval);
    }

    let lastProgress = 0;
    this.currentSearchResults = []; // Reiniciar os resultados para a nova busca

    // Consultar o status da busca a cada 1 segundo
    pollInterval = setInterval(() => {
      if (searchCanceled || !searchInProgress) {
        clearInterval(pollInterval);
        pollInterval = null;

        // Se cancelado, manter os resultados que já foram encontrados
        if (this.currentSearchResults.length > 0) {
          const searchTime = (
            (performance.now() - searchStartTime) /
            1000
          ).toFixed(2);
          $("#searchLoading").hide();

          // Apenas atualizar estatísticas, não recriar os cards
          $("#searchStats").text(
            `${this.currentSearchResults.length} resultado${
              this.currentSearchResults.length !== 1 ? "s" : ""
            } encontrado${
              this.currentSearchResults.length !== 1 ? "s" : ""
            } em ${searchTime} segundos. ${
              searchCanceled ? "Busca cancelada pelo usuário." : ""
            }`
          );
        }
        return;
      }

      $.ajax({
        url: "cfc/pc_cfcBuscaPDF_novo.cfc",
        type: "POST",
        data: {
          method: "getProcessingStatus",
          jobID: searchID,
        },
        dataType: "json",
        success: (response) => {
          console.log("Resposta do status:", response);

          if (response && (response.success || response.SUCCESS)) {
            const status =
              response.status || response.STATUS || "Processando...";
            const progress =
              response.progress || response.PROGRESS || lastProgress + 5;
            const resultsFound =
              response.resultsFound || response.RESULTSFOUND || 0;

            // Armazenar o último progresso
            lastProgress = progress > 100 ? 100 : progress;

            // Atualizar a barra de progresso e o status
            $("#processingProgress").css("width", `${lastProgress}%`);
            $("#processingStatus").text(status);

            // Se já temos resultados, mostrar em tempo real
            if (
              resultsFound > 0 &&
              (response.recentResults || response.RECENTRESULTS)
            ) {
              const recentResults =
                response.recentResults || response.RECENTRESULTS || [];
              console.log("Novos resultados:", recentResults.length);

              if (recentResults.length > 0) {
                $("#realTimeResults").show();

                // Adicionar os novos resultados à lista completa
                recentResults.forEach((result) => {
                  console.log(
                    "Processando resultado:",
                    result.fileName || result.FILENAME
                  );

                  // Garantir que o resultado não seja duplicado
                  if (!this.isResultAlreadyAdded(result)) {
                    // Adicionar ao array atual
                    this.currentSearchResults.push(result);

                    // Adicionar visualmente na interface usando o mesmo formato dos resultados finais
                    this.addRealTimeResult(result);
                  }
                });

                // Atualizar contador de resultados
                $("#processingStatus").text(
                  `Processando... (${this.currentSearchResults.length} resultados encontrados)`
                );
              }
            }

            // Se já terminou, finalizar a busca
            if (lastProgress >= 100 || response.isComplete) {
              clearInterval(pollInterval);
              pollInterval = null;
              searchInProgress = false;
              $("#searchLoading").hide();

              // Apenas atualizar estatísticas, não recriar os cards
              const searchTime = (
                (performance.now() - searchStartTime) /
                1000
              ).toFixed(2);
              const filesRead =
                response.filesRead ||
                response.FILESREAD ||
                this.currentSearchResults.length;

              $("#searchStats").text(
                `${this.currentSearchResults.length} resultado${
                  this.currentSearchResults.length !== 1 ? "s" : ""
                } encontrado${
                  this.currentSearchResults.length !== 1 ? "s" : ""
                } em ${searchTime} segundos. Arquivos lidos: ${filesRead}`
              );
            }
          }

          // Tratamento de erros
          if (response && response.error) {
            console.error("Erro reportado pelo servidor:", response.error);
            if (response.fatalError) {
              clearInterval(pollInterval);
              pollInterval = null;
              searchInProgress = false;
              $("#searchLoading").hide();
            }
          }
        },
        error: (xhr, status, error) => {
          console.log("Erro temporário ao verificar status:", error);
        },
      });
    }, 1000);
  },

  // Verificar se um resultado já foi adicionado para evitar duplicações
  isResultAlreadyAdded: function (newResult) {
    // Vamos usar apenas o filePath como identificador único, que é mais confiável
    const newFilePath = newResult.filePath || newResult.FILEPATH || "";

    if (!newFilePath) return false; // Se não tem caminho, não podemos comparar

    return this.currentSearchResults.some((existingResult) => {
      const existingFilePath =
        existingResult.filePath || existingResult.FILEPATH || "";
      return existingFilePath === newFilePath;
    });
  },

  // Iniciar animação de busca
  startSearchAnimation: function () {
    // Exibir o container de animação
    $("#searchLoading").show();

    // Iniciar as animações do SVG
    setTimeout(function () {
      try {
        console.log("Iniciando animações SVG");

        // Obtém as animações do SVG que precisam ser iniciadas manualmente
        var docAnimation = document.getElementById("docAnimation");
        var opacityAnimation = document.getElementById("opacityAnimation");
        var scanLineAnimation = document.getElementById("scanLineAnimation");
        var scanLineOpacity = document.getElementById("scanLineOpacity");
        var animatedDoc = document.getElementById("animated-document");

        // Torna o grupo do documento visível
        if (animatedDoc) {
          animatedDoc.setAttribute("opacity", "1");
        }

        // Inicia as animações
        if (docAnimation) docAnimation.beginElement();
        if (opacityAnimation) opacityAnimation.beginElement();
        if (scanLineAnimation) scanLineAnimation.beginElement();
        if (scanLineOpacity) scanLineOpacity.beginElement();
      } catch (error) {
        console.error("Erro ao iniciar animações:", error);
      }
    }, 1000);
  },

  // Adicionar novo resultado em tempo real
  addRealTimeResult: function (result) {
    // Verificar se este resultado já foi adicionado à lista (usando o filePath como identificador único)
    const filePathSelector = CSS.escape(result.filePath);
    if (
      $("#realTimeResultsList").find(`[data-file-path="${filePathSelector}"]`)
        .length > 0
    ) {
      return; // Não adicionar duplicados
    }

    // Extrair informações úteis para exibição
    const fileName = result.fileName || result.FILENAME || "Documento sem nome";
    const filePath = result.filePath || result.FILEPATH || "";
    const displayPath = result.displayPath || result.DISPLAYPATH || "";
    const fileSize = result.fileSize || result.FILESIZE || 0;
    const pageCount = result.pageCount || result.PAGECOUNT || "?";

    // Formatar data, se disponível
    let formattedDate = "Data desconhecida";
    if (result.fileDate || result.FILEDATE) {
      try {
        formattedDate = this.formatDate(result.fileDate || result.FILEDATE);
      } catch (e) {
        /* usar valor padrão */
      }
    }

    // Garantir que temos snippets válidos
    const snippets =
      result.snippets && result.snippets.length > 0
        ? result.snippets
        : result.SNIPPETS && result.SNIPPETS.length > 0
        ? result.SNIPPETS
        : ["Texto não disponível para visualização"];

    // Construir URL do PDF
    const pdfUrl = `cfc/pc_cfcBuscaPDF_novo.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
      filePath
    )}&nome=${encodeURIComponent(fileName)}`;

    // Criar item de resultado usando o mesmo formato dos resultados finais
    const resultHtml = `
    <div class="search-result" data-file-path="${filePath}" data-file-url="${pdfUrl}" data-result-id="${
      this.currentSearchResults.length - 1
    }">
        <div class="d-flex justify-content-between align-items-start">
            <h5>
                <a href="${pdfUrl}" target="_blank" class="view-pdf-link">
                    <i class="far fa-file-pdf mr-2"></i>${fileName}
                </a>
            </h5>
        </div>
        <p class="mb-1 text-muted small">
            <i class="fas fa-folder-open mr-1"></i> ${displayPath}
        </p>
        <div class="search-snippets">
            ${this.formatSnippets(snippets)}
        </div>
        
        <!-- Botão para mostrar/ocultar texto extraído -->
        <div class="mt-3">
            <button class="btn btn-sm btn-outline-info toggle-extracted-text" data-result-id="${
              this.currentSearchResults.length - 1
            }">
                <i class="fas fa-file-alt mr-1"></i> Ver texto extraído
            </button>
        </div>
        
        <!-- Container para o texto extraído (inicialmente oculto) -->
        <div class="extracted-text-container mt-2" id="extractedText-${
          this.currentSearchResults.length - 1
        }" style="display: none;">
            <div class="card">
                <div class="card-header py-2 bg-light">
                    <div class="d-flex justify-content-between align-items-center">
                        <span><i class="fas fa-file-alt mr-1"></i> Conteúdo do documento</span>
                        <button class="btn btn-sm btn-link text-muted p-0 copy-text" data-result-id="${
                          this.currentSearchResults.length - 1
                        }">
                            <i class="far fa-copy"></i> Copiar
                        </button>
                    </div>
                </div>
                <div class="card-body extracted-text-content" style="max-height: 300px; overflow-y: auto;">
                    ${result.text || result.TEXT || "Texto não disponível"}
                </div>
            </div>
        </div>
        
        <div class="d-flex justify-content-between mt-2">
            <div>
                <span class="badge badge-light mr-1">
                    <i class="far fa-calendar-alt mr-1"></i> ${formattedDate}
                </span>
                <span class="badge badge-light mr-1">
                    <i class="fas fa-file-alt mr-1"></i> ${this.formatFileSize(
                      fileSize
                    )}
                </span>
                <span class="badge badge-light">
                    <i class="fas fa-file-pdf mr-1"></i> ${pageCount} página${
      pageCount !== 1 ? "s" : ""
    }
                </span>
            </div>
        </div>
    </div>
  `;

    // Adicionar ao início da lista
    $("#realTimeResultsList").prepend(resultHtml);

    // Configurar handlers para o texto extraído
    this.setupExtractedTextHandlers();

    // Se este for o primeiro resultado encontrado, fazer scroll para a seção
    if ($("#realTimeResultsList").children().length === 1) {
      $("html, body").animate(
        {
          scrollTop: $("#realTimeResults").offset().top - 150,
        },
        "slow"
      );
    }
  },

  // Destacar termo em um texto
  highlightSearchTerm: function (text, term) {
    if (!text || !term) return text;
    try {
      // Escapa caracteres especiais para uso em regex
      const escapedTerm = this.escapeRegExp(term);
      const regex = new RegExp(`(${escapedTerm})`, "gi");
      return text.replace(regex, "<mark>$1</mark>");
    } catch (e) {
      console.error("Erro ao destacar termos:", e);
      return text;
    }
  },

  // Destacar frase exata
  highlightSearchPhrase: function (text, phrase) {
    if (!text || !phrase) return text;
    try {
      // Escapa caracteres especiais para uso em regex
      const escapedPhrase = this.escapeRegExp(phrase);
      const regex = new RegExp(`(${escapedPhrase})`, "gi");
      return text.replace(regex, "<mark>$1</mark>");
    } catch (e) {
      console.error("Erro ao destacar frase:", e);
      return text;
    }
  },

  // Destacar todas as palavras pesquisadas
  highlightAllSearchTerms: function (text, terms) {
    if (!text || !terms || !terms.length) return text;

    let highlightedText = text;
    terms.forEach((term) => {
      if (term.length >= 3) {
        try {
          const regex = new RegExp(`(${this.escapeRegExp(term)})`, "gi");
          highlightedText = highlightedText.replace(regex, "<mark>$1</mark>");
        } catch (e) {
          console.error(`Erro ao destacar termo ${term}:`, e);
        }
      }
    });
    return highlightedText;
  },

  // Função auxiliar para escapar caracteres especiais em expressões regulares
  escapeRegExp: function (string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  },

  // Formatar snippets para exibição
  formatSnippets: function (snippets) {
    if (!snippets || snippets.length === 0) {
      return '<p class="text-muted">Sem prévia disponível</p>';
    }

    return snippets
      .map((snippet) => `<div class="snippet">${snippet}</div>`)
      .join("");
  },

  // Exibir resultados da busca
  displaySearchResults: function (
    searchTerms,
    searchTime,
    filesRead,
    searchOptions
  ) {
    this.handleSearchResponse(
      {
        success: true,
        filesRead: filesRead,
        totalFound: this.currentSearchResults.length,
      },
      searchTerms,
      searchOptions
    );
  },

  // Configurar manipuladores para o texto extraído
  setupExtractedTextHandlers: function () {
    // Toggle para mostrar/ocultar texto extraído
    $(".toggle-extracted-text").on("click", function () {
      const resultId = $(this).data("result-id");
      const textContainer = $(`#extractedText-${resultId}`);

      if (textContainer.is(":visible")) {
        textContainer.slideUp(200);
        $(this).html('<i class="fas fa-file-alt mr-1"></i> Ver texto extraído');
      } else {
        // Fechar outros textos abertos
        $(".extracted-text-container").slideUp(200);
        $(".toggle-extracted-text").html(
          '<i class="fas fa-file-alt mr-1"></i> Ver texto extraído'
        );

        // Abrir este texto
        textContainer.slideDown(200);
        $(this).html('<i class="fas fa-file-alt mr-1"></i> Ocultar texto');
      }
    });

    // Copiar texto para área de transferência
    $(".copy-text").on("click", function () {
      const resultId = $(this).data("result-id");
      // Tratar caso em que a propriedade text pode estar em maiúsculas
      const result = PdfSearchManager.currentSearchResults[resultId];
      const textContent = result.text || result.TEXT || "";

      // Criar elemento temporário para copiar
      const tempElement = document.createElement("textarea");
      tempElement.value = textContent;
      document.body.appendChild(tempElement);
      tempElement.select();
      document.execCommand("copy");
      document.body.removeChild(tempElement);

      // Feedback ao usuário
      $(this).html('<i class="fas fa-check"></i> Copiado!');
      setTimeout(() => {
        $(this).html('<i class="far fa-copy"></i> Copiar');
      }, 2000);
    });
  },

  // Formatar tamanho do arquivo
  formatFileSize: function (bytes) {
    if (bytes < 1024) {
      return bytes + " bytes";
    } else if (bytes < 1048576) {
      return (bytes / 1024).toFixed(1) + " KB";
    } else if (bytes < 1073741824) {
      return (bytes / 1048576).toFixed(1) + " MB";
    } else {
      return (bytes / 1073741824).toFixed(1) + " GB";
    }
  },

  // Formatar data
  formatDate: function (dateStr) {
    try {
      const date = new Date(dateStr);
      return date.toLocaleDateString("pt-BR");
    } catch (e) {
      return "Data desconhecida";
    }
  },

  // Salvar buscas recentes no localStorage
  saveRecentSearch: function (searchTerms) {
    try {
      const recentSearches = JSON.parse(
        localStorage.getItem("recentFaqSearches") || "[]"
      );
      const filteredSearches = recentSearches.filter(
        (term) => term.toLowerCase() !== searchTerms.toLowerCase()
      );

      // Manter apenas as 5 pesquisas mais recentes
      filteredSearches.unshift(searchTerms);
      if (filteredSearches.length > 5) {
        filteredSearches.length = 5;
      }

      localStorage.setItem(
        "recentFaqSearches",
        JSON.stringify(filteredSearches)
      );

      // Atualizar UI
      this.loadRecentSearches();
    } catch (e) {
      console.error("Erro ao salvar busca recente:", e);
    }
  },

  // Carregar e exibir buscas recentes
  loadRecentSearches: function () {
    try {
      const recentSearches = JSON.parse(
        localStorage.getItem("recentFaqSearches") || "[]"
      );

      // Limpar e atualizar container
      const container = $("#recentSearchesContainer");
      container.empty();

      if (recentSearches.length === 0) return;

      let html =
        '<div class="mt-2"><small class="text-muted">Buscas recentes: </small>';

      recentSearches.forEach((term) => {
        html += `
          <a href="javascript:void(0)" class="badge badge-light mr-1" 
             onclick="PdfSearchManager.searchWithTerm('${term.replace(
               /'/g,
               "\\'"
             )}')">${term}</a>
        `;
      });

      html += `
        <button class="btn btn-link btn-sm text-muted px-0 ml-2" 
                onclick="PdfSearchManager.clearRecentSearches()">
          <i class="fas fa-times"></i> Limpar
        </button>
      </div>`;

      container.html(html);
    } catch (e) {
      console.error("Erro ao carregar buscas recentes:", e);
    }
  },

  // Limpar as buscas recentes
  clearRecentSearches: function () {
    try {
      localStorage.removeItem("recentFaqSearches");
      $("#recentSearchesContainer").empty();
      if (typeof toastr !== "undefined") {
        toastr.success("Histórico de buscas removido com sucesso!");
      } else {
        alert("Histórico de buscas removido com sucesso!");
      }
    } catch (e) {
      console.error("Erro ao limpar buscas recentes:", e);
      if (typeof toastr !== "undefined") {
        toastr.error("Erro ao limpar histórico de buscas.");
      } else {
        alert("Erro ao limpar histórico de buscas.");
      }
    }
  },

  // Atualizar a URL com os termos de busca para permitir compartilhamento
  updateUrlWithSearchTerms: function (searchTerms) {
    const newUrl =
      window.location.protocol +
      "//" +
      window.location.host +
      window.location.pathname +
      "?q=" +
      encodeURIComponent(searchTerms);
    window.history.pushState({ path: newUrl }, "", newUrl);
  },

  // Iniciar busca com termo específico
  searchWithTerm: function (term) {
    $("#searchTerms").val(term);
    this.performSearch(term);
  },
};

// Inicializar o gerenciador de busca
$(document).ready(function () {
  $("#searchFaqForm").on("submit", function (e) {
    e.preventDefault();
    PdfSearchManager.performSearch();
  });

  $('input[name="searchType"]').on("change", function () {
    $("#fuzzyThreshold").prop("disabled", $(this).val() !== "fuzzy");
  });

  $('input[name="searchMode"]').on("change", function () {
    if ($(this).val() === "proximity") {
      $("#proximityOptionsGroup").slideDown(200);
    } else {
      $("#proximityOptionsGroup").slideUp(200);
    }

    // Quando "Frase Exata" for selecionado, desabilitar a opção de busca aproximada
    if ($(this).val() === "exact") {
      $("#searchTypeFuzzy").prop("disabled", true);
      $("#searchTypeExact").prop("checked", true);
      $("#fuzzyThreshold").prop("disabled", true);
    } else {
      $("#searchTypeFuzzy").prop("disabled", false);
    }
  });

  PdfSearchManager.init();
});
