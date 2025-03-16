// Variáveis globais para controle da busca
let searchCanceled = false;
let documentProcessing = false;

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

    // NOVO: incluir o ano e o texto do título, se informado
    searchOptions.processYear = $("#searchYear").val().trim();
    searchOptions.titleSearch = $("#searchTitle").val().trim();

    $("#resultsCard").show();

    // Rolar automaticamente para o card de resultados após iniciar a busca
    $("html, body").animate(
      {
        scrollTop: $("#resultsCard").offset().top - 200,
      },
      "slow"
    );

    $("#searchLoading").show();
    $("#searchResults").empty();
    $("#noResultsAlert").hide();
    $("#errorAlert").hide();
    $("#pdfViewerContainer").hide();
    $("#searchStats").text("");

    this.updateUrlWithSearchTerms(searchTerms);
    this.saveRecentSearch(searchTerms);

    // Verificar se o PDF.js está disponível
    if (typeof pdfjsLib !== "undefined") {
      try {
        // Tentar busca no cliente primeiro
        this.searchInClientSide(searchTerms, searchOptions);
      } catch (error) {
        console.error("Erro ao tentar busca no cliente:", error);
        // Se falhar, tenta o método do servidor como fallback
        this.searchInServerSide(searchTerms, searchOptions);
      }
    } else {
      // Se o PDF.js não estiver disponível, usa sempre o servidor
      this.searchInServerSide(searchTerms, searchOptions);
    }
  },

  // Processa os documentos PDF usando PDF.js
  processDocumentsWithPdfJs: function (
    documents,
    searchTerms,
    startTime,
    searchOptions
  ) {
    const terms = searchTerms.split(" ");
    let processedCount = 0;
    const totalDocuments = documents.length;
    this.currentSearchResults = [];
    let filesRead = 0; // Contador de arquivos que passaram nos filtros

    // Reset do cancelamento de busca
    searchCanceled = false;
    documentProcessing = true;

    // Mostrar o container de resultados em tempo real
    $("#realTimeResults").show();
    $("#realTimeResultsList").empty();

    $("#processingStatus").text(`Buscando em ${totalDocuments} documentos...`);

    // Função para processar um documento por vez
    const processNextDocument = (index) => {
      // Verificar se a busca foi cancelada
      if (searchCanceled) {
        const searchTime = ((performance.now() - startTime) / 1000).toFixed(2);
        $("#processingStatus").text(
          `Busca cancelada após processar ${processedCount} documentos.`
        );

        // Remover o estado de carregamento do botão cancelar
        $("#cancelSearch")
          .prop("disabled", false)
          .html('<i class="fas fa-times mr-1"></i> Cancelar busca');

        this.displaySearchResults(
          searchTerms,
          searchTime,
          filesRead,
          searchOptions
        );
        documentProcessing = false;
        return;
      }

      if (index >= documents.length) {
        // Finaliza quando todos os documentos forem processados
        const searchTime = ((performance.now() - startTime) / 1000).toFixed(2);

        // Remover o estado de carregamento do botão cancelar
        $("#cancelSearch")
          .prop("disabled", false)
          .html('<i class="fas fa-times mr-1"></i> Cancelar busca');

        this.displaySearchResults(
          searchTerms,
          searchTime,
          filesRead,
          searchOptions
        );
        documentProcessing = false;
        // Rolar automaticamente para o card de resultados
        $("html, body").animate(
          {
            scrollTop: $("#resultsCard").offset().top - 200,
          },
          "slow"
        );
        return;
      }

      const doc = documents[index];
      processedCount++;

      // Atualizar UI
      const progress = Math.round((processedCount / totalDocuments) * 100);
      $("#processingProgress").css("width", `${progress}%`);
      $("#processingStatus").text(
        `Processando: ${processedCount} de ${totalDocuments} (${filesRead} lido(s) até agora)`
      );

      // Não é mais necessário chamar a função de atualização do carrossel
      // O SVG tem animação contínua que funciona sozinha

      // Pequeno efeito visual de "escaneamento" do documento
      $(".document-item").css(
        "transform",
        `translateY(${index % 2 === 0 ? -5 : 5}px)`
      );
      setTimeout(() => {
        $(".document-item").css("transform", "translateY(0)");
      }, 300);

      // Filtrar por ano do processo, se informado
      if (searchOptions && searchOptions.processYear) {
        const yearMatch = doc.fileName.match(/_PC\d+(\d{4})_/);
        if (!yearMatch || yearMatch[1] !== searchOptions.processYear) {
          processNextDocument(index + 1); // Pula este arquivo
          return;
        }
      }

      // Filtrar por texto no título, se informado (busca exata no título, ignorando case)
      if (
        searchOptions &&
        searchOptions.titleSearch &&
        searchOptions.titleSearch.trim() !== ""
      ) {
        if (
          doc.fileName
            .toLowerCase()
            .indexOf(searchOptions.titleSearch.toLowerCase()) === -1
        ) {
          processNextDocument(index + 1);
          return;
        }
      }

      // Se passou em ambos os filtros, conta este arquivo
      filesRead++;

      // Criar URL para carregar o documento
      const fileUrl = `cfc/pc_cfcBuscaPDF.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
        doc.filePath
      )}&nome=${encodeURIComponent(doc.fileName)}`;

      try {
        // Carregar PDF e extrair texto usando API regular do PDF.js (não módulo)
        pdfjsLib
          .getDocument({
            url: fileUrl,
          })
          .promise.then((pdf) => {
            let textPromises = [];

            // Extrair texto de todas as páginas
            for (let i = 1; i <= pdf.numPages; i++) {
              textPromises.push(
                pdf
                  .getPage(i)
                  .then((page) => page.getTextContent())
                  .then((content) =>
                    content.items.map((item) => item.str).join(" ")
                  )
              );
            }

            return Promise.all(textPromises);
          })
          .then((pageTexts) => {
            const text = pageTexts.join("\n");

            // Buscar termos no texto
            let found = false;
            let snippets = [];

            // Verificar o modo de busca e adaptar a lógica
            if (searchOptions.mode === "exact") {
              // Modo de frase exata: busca pela frase completa
              const phrase = searchTerms.trim();
              if (phrase.length >= 3) {
                // Criar regex para buscar frase exata, case insensitive
                const regex = new RegExp(this.escapeRegExp(phrase), "gi");
                const matches = text.match(regex);

                if (matches && matches.length > 0) {
                  found = true;

                  // Criar snippet com contexto para a frase completa
                  const firstIndex = text
                    .toLowerCase()
                    .indexOf(phrase.toLowerCase());
                  if (firstIndex !== -1) {
                    const start = Math.max(0, firstIndex - 200);
                    const end = Math.min(
                      text.length,
                      firstIndex + phrase.length + 200
                    );
                    let snippet = text.substring(start, end);

                    if (start > 0) snippet = "..." + snippet;
                    if (end < text.length) snippet += "...";

                    snippet = this.highlightSearchPhrase(snippet, phrase);
                    snippets.push(snippet);
                  }
                }
              }
            } else {
              // Modo "OU" (padrão): busca por termos individuais
              terms.forEach((term) => {
                if (term.length >= 3) {
                  const regex = new RegExp(this.escapeRegExp(term), "gi");
                  const matches = text.match(regex);

                  if (matches && matches.length > 0) {
                    found = true;

                    // Criar snippet com contexto
                    const firstIndex = text
                      .toLowerCase()
                      .indexOf(term.toLowerCase());
                    if (firstIndex !== -1) {
                      const start = Math.max(0, firstIndex - 200);
                      const end = Math.min(
                        text.length,
                        firstIndex + term.length + 200
                      );
                      let snippet = text.substring(start, end);

                      if (start > 0) snippet = "..." + snippet;
                      if (end < text.length) snippet += "...";

                      snippet = this.highlightSearchTerm(snippet, term);
                      snippets.push(snippet);
                    }
                  }
                }
              });
            }

            if (found) {
              // Criar objeto de resultado simplificado (sem cálculo de relevância)
              const resultObj = {
                fileName: doc.fileName,
                filePath: doc.filePath,
                fileUrl: fileUrl,
                directory: doc.directory || "Diretório FAQ",
                size: doc.size,
                dateLastModified: doc.dateLastModified,
                snippets: snippets,
                extractedText: text,
              };

              // Adicionar ao array de resultados
              this.currentSearchResults.push(resultObj);

              // Mostrar resultado em tempo real
              this.addRealTimeResult(resultObj);
            }

            // Processar o próximo documento
            processNextDocument(index + 1);
          })
          .catch((error) => {
            console.error(
              `Erro ao processar o documento ${doc.fileName}:`,
              error
            );
            processNextDocument(index + 1);
          });
      } catch (error) {
        console.error(`Erro ao carregar o documento ${doc.fileName}:`, error);
        processNextDocument(index + 1);
      }
    };

    // Iniciar o processamento com o primeiro documento
    processNextDocument(0);
  },

  // Método para atualizar a animação - removendo o código anterior e deixando o SVG funcionar
  // Não é necessário atualizar o SVG manualmente pois a animação é controlada por SMIL
  updateCarouselAnimation: function () {
    // A animação do SVG é automática, não precisamos fazer nada aqui
    // As animações SMIL no SVG cuidam de tudo
  },

  // Novo método para adicionar resultados em tempo real
  addRealTimeResult: function (result) {
    const resultItem = `
      <div class="realtime-result-item">
        <h6 class="mb-1">
          <a href="${result.fileUrl}" target="_blank" class="result-link">
            <i class="far fa-file-pdf mr-1"></i> ${result.fileName}
          </a>
        </h6>
        <div class="small text-muted">
          ${this.formatSnippets(result.snippets.slice(0, 1))}
        </div>
      </div>
    `;

    // Adicionar ao início da lista para mostrar os mais recentes primeiro
    $("#realTimeResultsList").prepend(resultItem);

    // Se este for o primeiro resultado encontrado, fazer scroll para a seção de resultados em tempo real
    if (this.currentSearchResults.length === 1) {
      $("html, body").animate(
        {
          scrollTop: $("#realTimeResults").offset().top - 150,
        },
        "slow"
      );
    }
  },

  // Busca usando o método do servidor
  searchInServerSide: function (searchTerms, searchOptions) {
    $.ajax({
      url: "cfc/pc_cfcBuscaPDF.cfc",
      type: "POST",
      dataType: "json",
      data: {
        method: "searchInPDFs",
        searchTerms: searchTerms,
        searchOptions: JSON.stringify(searchOptions),
      },
      success: (response) => {
        $("#searchLoading").hide();

        // Melhorar o tratamento de respostas não-JSON
        if (typeof response === "string") {
          try {
            // Tentar converter string para JSON
            response = JSON.parse(response);
          } catch (e) {
            // Se falhar, verificar se é resposta HTML de erro
            if (response.includes("<html>") || response.includes("<!DOCTYPE")) {
              console.error(
                "Recebeu HTML em vez de JSON:",
                response.substring(0, 200)
              );
              $("#errorMessage").text(
                "O servidor retornou uma página HTML em vez de JSON. Verifique os logs do servidor."
              );
              $("#errorAlert").show();
              return;
            }
          }
        }

        // Verificar se a resposta é string (possível WDDX) e tentar extrair JSON
        if (typeof response === "string" && response.includes("wddxPacket")) {
          try {
            // Extrair o JSON dentro do WDDX
            const jsonMatch = response.match(/<string>(\{.*?\})<\/string>/s);
            if (jsonMatch && jsonMatch[1]) {
              response = JSON.parse(jsonMatch[1]);
            }
          } catch (e) {
            console.error("Erro ao processar resposta WDDX:", e);
          }
        }

        if (response && response.success) {
          if (response.totalFound > 0) {
            // Adaptar os resultados do servidor para o formato esperado
            this.currentSearchResults = response.results.map((result) => {
              const fileUrl = `cfc/pc_cfcBuscaPDF.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
                result.filePath
              )}&nome=${encodeURIComponent(result.fileName)}`;

              // Gerar snippets com termos destacados
              const terms = searchTerms.split(" ").filter((t) => t.length >= 3);
              let snippets = [];

              // Usar texto extraído se disponível
              if (result.text) {
                const contextSize = 200;

                // Verificar o modo de busca
                if (searchOptions.mode === "exact") {
                  // Modo de frase exata
                  const phrase = searchTerms.trim();
                  if (phrase.length >= 3) {
                    const regex = new RegExp(this.escapeRegExp(phrase), "gi");
                    let match;

                    // Encontrar até 3 ocorrências da frase
                    let count = 0;
                    let lastIndex = 0;

                    while (
                      count < 3 &&
                      (match = regex.exec(result.text)) !== null
                    ) {
                      const start = Math.max(0, match.index - contextSize);
                      const end = Math.min(
                        result.text.length,
                        match.index + phrase.length + contextSize
                      );
                      let snippet = result.text.substring(start, end);

                      if (start > 0) snippet = "..." + snippet;
                      if (end < result.text.length) snippet += "...";

                      snippet = this.highlightSearchPhrase(snippet, phrase);
                      snippets.push(snippet);
                      count++;

                      if (lastIndex === regex.lastIndex) break;
                      lastIndex = regex.lastIndex;
                    }
                  }
                } else {
                  // Modo "OU" (padrão): processa termos individuais
                  terms.forEach((term) => {
                    const regex = new RegExp(this.escapeRegExp(term), "gi");
                    let match;

                    // Encontrar até 3 ocorrências do termo
                    let count = 0;
                    const lowerText = result.text.toLowerCase();
                    let lastIndex = 0;

                    while (
                      count < 3 &&
                      (match = regex.exec(result.text)) !== null
                    ) {
                      const start = Math.max(0, match.index - contextSize);
                      const end = Math.min(
                        result.text.length,
                        match.index + term.length + contextSize
                      );
                      let snippet = result.text.substring(start, end);

                      if (start > 0) snippet = "..." + snippet;
                      if (end < result.text.length) snippet += "...";

                      snippet = this.highlightSearchTerm(snippet, term);
                      snippets.push(snippet);
                      count++;

                      if (lastIndex === regex.lastIndex) break;
                      lastIndex = regex.lastIndex;
                    }
                  });
                }
              }

              return {
                fileName: result.fileName,
                filePath: result.filePath,
                fileUrl: fileUrl,
                directory: result.displayPath,
                size: result.fileSize,
                dateLastModified: result.fileDate,
                relevanceScore: result.relevanceScore || 10,
                snippets:
                  snippets.length > 0
                    ? snippets
                    : ["<em>Texto não disponível para visualização</em>"],
              };
            });

            this.displaySearchResults(
              searchTerms,
              response.searchTime,
              null,
              searchOptions
            );
          } else {
            $("#noResultsAlert").show();
            $("#searchStats").text(
              `0 resultados encontrados em ${response.searchTime} segundos`
            );
          }
        } else {
          $("#errorMessage").text(
            response.message || "Erro desconhecido na busca"
          );
          $("#errorAlert").show();
        }
      },
      error: (xhr, status, error) => {
        $("#searchLoading").hide();

        // Exibir informações mais detalhadas sobre o erro
        console.error("Detalhes do erro:", xhr.responseText);
        let errorMessage = "Erro ao realizar a busca. ";

        if (xhr.status === 0) {
          errorMessage += "Problemas de conexão de rede.";
        } else if (xhr.status === 404) {
          errorMessage += "Serviço de busca não encontrado.";
        } else if (xhr.status === 500) {
          errorMessage += "Erro interno no servidor.";
        } else {
          errorMessage += `Código: ${xhr.status}, Mensagem: ${
            error || "Desconhecido"
          }`;
        }

        $("#errorMessage").text(errorMessage);
        $("#errorAlert").show();
      },
    });
  },

  // Busca no lado do cliente usando PDF.js
  searchInClientSide: function (searchTerms, searchOptions) {
    // Definir a variável startTime no escopo correto
    const startTime = performance.now();

    // Buscar lista de documentos PDF primeiro
    $.ajax({
      url: "cfc/pc_cfcBuscaPDF.cfc",
      type: "POST",
      data: {
        method: "listPdfDocuments",
      },
      dataType: "json",
      success: (response) => {
        console.log("Resposta recebida do servidor:", response);

        // Primeiro, garantir que temos uma resposta em formato de objeto
        let parsedResponse = response;

        if (typeof parsedResponse === "string") {
          try {
            parsedResponse = JSON.parse(parsedResponse);
            console.log("Convertido string em objeto JSON:", parsedResponse);
          } catch (e) {
            console.error("Erro ao converter resposta string para objeto:", e);
            // Verificar se não é um erro de HTML
            if (
              typeof response === "string" &&
              (response.includes("<html") || response.includes("<!DOCTYPE"))
            ) {
              console.error("Recebeu HTML em vez de JSON");
            }
            // Se falhar, usar o método do servidor
            this.searchInServerSide(searchTerms, searchOptions);
            return;
          }
        }

        // ColdFusion retorna propriedades em MAIÚSCULAS, verificar ambas as versões
        const success = parsedResponse.success || parsedResponse.SUCCESS;
        const documents = parsedResponse.documents || parsedResponse.DOCUMENTS;

        // Verificar se temos um objeto válido com a estrutura esperada
        if (
          parsedResponse &&
          typeof parsedResponse === "object" &&
          success === true &&
          Array.isArray(documents)
        ) {
          console.log(`Processando ${documents.length} documentos`);

          // Verificar se a lista de documentos não está vazia
          if (documents.length > 0) {
            // Padronizar as chaves para minúsculas para processamento consistente
            const normalizedDocuments = documents.map((doc) => {
              return {
                fileName: doc.fileName || doc.FILENAME,
                filePath: doc.filePath || doc.FILEPATH,
                directory: doc.directory || doc.DIRECTORY,
                displayPath: doc.displayPath || doc.DISPLAYPATH,
                size: doc.size || doc.SIZE,
                dateLastModified: doc.dateLastModified || doc.DATELASTMODIFIED,
              };
            });

            // Passar searchOptions para o método processDocumentsWithPdfJs
            this.processDocumentsWithPdfJs(
              normalizedDocuments,
              searchTerms,
              startTime,
              searchOptions
            );
          } else {
            console.warn("Nenhum documento PDF encontrado no diretório");
            this.searchInServerSide(searchTerms, searchOptions);
          }
        } else {
          console.warn(
            "Estrutura de resposta inválida, usando busca no servidor:",
            parsedResponse
          );
          this.searchInServerSide(searchTerms, searchOptions);
        }
      },
      error: (xhr, status, error) => {
        console.error(`Erro ao buscar documentos: ${status} - ${error}`);
        console.log("Texto da resposta:", xhr.responseText);
        this.searchInServerSide(searchTerms, searchOptions);
      },
    });
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

  // Adicionar nova função para destacar frase exata
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

  // Função auxiliar para escapar caracteres especiais em expressões regulares
  escapeRegExp: function (string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  },

  // Formata os snippets para exibição
  formatSnippets: function (snippets) {
    if (!snippets || snippets.length === 0) {
      return '<p class="text-muted">Sem prévia disponível</p>';
    }

    return snippets
      .map((snippet) => `<div class="snippet">${snippet}</div>`)
      .join("");
  },

  // Exibir resultados de busca
  displaySearchResults: function (
    searchTerms,
    searchTime,
    filesRead,
    searchOptions
  ) {
    $("#searchLoading").hide();
    $("#realTimeResults").hide();

    // Se não há resultados
    if (this.currentSearchResults.length === 0) {
      $("#noResultsAlert").show();
      $("#searchStats").text(
        `0 resultados encontrados em ${searchTime} segundos. Arquivos lidos: ${
          filesRead || "N/A"
        }`
      );
      return;
    }

    // Construir HTML dos resultados - sem mostrar relevância
    const termsList = searchTerms.split(" ").filter((term) => term.length >= 3);
    let resultsHtml = "";

    this.currentSearchResults.forEach((result, index) => {
      // URL direta para visualizar o PDF
      const pdfUrl = `cfc/pc_cfcBuscaPDF.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
        result.filePath
      )}`;

      // Truncar texto para preview (primeiros 5000 caracteres)
      const truncatedText = result.extractedText
        ? result.extractedText.length > 5000
          ? result.extractedText.substring(0, 5000) + "..."
          : result.extractedText
        : "Texto não disponível";

      // Destacar termos de busca no texto completo
      const highlightedText =
        searchOptions && searchOptions.mode === "exact"
          ? this.highlightSearchPhrase(truncatedText, searchTerms)
          : termsList.reduce((text, term) => {
              if (term.length >= 3) {
                const regex = new RegExp(`(${this.escapeRegExp(term)})`, "gi");
                return text.replace(regex, "<mark>$1</mark>");
              }
              return text;
            }, truncatedText);

      resultsHtml += `
        <div class="search-result" data-file-path="${
          result.filePath
        }" data-file-url="${pdfUrl}" data-result-id="${index}">
          <div class="d-flex justify-content-between align-items-start">
            <h5>
              <a href="${pdfUrl}" target="_blank" class="view-pdf-link">
                <i class="far fa-file-pdf mr-2"></i>${result.fileName}
              </a>
            </h5>
          </div>
          <p class="mb-1 text-muted small">
            <i class="fas fa-folder-open mr-1"></i> ${
              result.directory || "Diretório FAQ"
            }
          </p>
          <div class="search-snippets">
            ${this.formatSnippets(result.snippets)}
          </div>
          
          <!-- Botão para mostrar/ocultar texto extraído -->
          <div class="mt-3">
            <button class="btn btn-sm btn-outline-info toggle-extracted-text" data-result-id="${index}">
              <i class="fas fa-file-alt mr-1"></i> Ver texto extraído
            </button>
          </div>
          
          <!-- Container para o texto extraído (inicialmente oculto) -->
          <div class="extracted-text-container mt-2" id="extractedText-${index}" style="display: none;">
            <div class="card">
              <div class="card-header py-2 bg-light">
                <div class="d-flex justify-content-between align-items-center">
                  <span><i class="fas fa-file-alt mr-1"></i> Conteúdo do documento</span>
                  <button class="btn btn-sm btn-link text-muted p-0 copy-text" data-result-id="${index}">
                    <i class="far fa-copy"></i> Copiar
                  </button>
                </div>
              </div>
              <div class="card-body extracted-text-content " style="max-height: 300px; overflow-y: auto;">
                ${highlightedText}
              </div>
            </div>
          </div>
          
          <div class="d-flex justify-content-between mt-2">
            <div>
              <span class="badge badge-light mr-1">
                <i class="far fa-calendar-alt mr-1"></i> ${this.formatDate(
                  result.dateLastModified || new Date()
                )}
              </span>
              <span class="badge badge-light">
                <i class="fas fa-file-alt mr-1"></i> ${this.formatFileSize(
                  result.size || 0
                )}
              </span>
            </div>
          </div>
        </div>
      `;
    });

    // Exibir resultados e estatísticas (sem menção a relevância)
    $("#searchResults").html(resultsHtml);
    $("#searchStats").text(
      `${this.currentSearchResults.length} resultado${
        this.currentSearchResults.length !== 1 ? "s" : ""
      } encontrado${
        this.currentSearchResults.length !== 1 ? "s" : ""
      } em ${searchTime} segundos. Arquivos lidos: ${filesRead}`
    );

    // Adicionar handlers para os botões de exibir texto extraído
    this.setupExtractedTextHandlers();
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
      const textContent =
        PdfSearchManager.currentSearchResults[resultId].extractedText;

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
      filteredSearches.unshift(searchTerms);

      // Manter apenas as 5 pesquisas mais recentes
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
      toastr.success("Histórico de buscas removido com sucesso!");
    } catch (e) {
      console.error("Erro ao limpar buscas recentes:", e);
      toastr.error("Erro ao limpar histórico de buscas.");
    }
  },

  // Iniciar busca com termo específico
  searchWithTerm: function (term) {
    $("#searchTerms").val(term);
    this.performSearch(term);

    // Não precisamos adicionar o scroll aqui pois já está no performSearch
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

  // Navegar pelos destaques
  navigateHighlights: function (direction) {
    console.log("Navegação entre destaques: direção =", direction);
  },
};

// Inicializar o gerenciador de busca
$(document).ready(function () {
  // Verificar se o PDF.js foi carregado corretamente
  if (typeof pdfjsLib === "undefined") {
    console.error(
      "PDF.js não foi carregado corretamente. Verifique se o script foi importado."
    );
  } else {
    console.log("PDF.js inicializado e pronto para uso.");
  }

  // Configurar manipulador de formulário
  $("#searchFaqForm").on("submit", function (e) {
    e.preventDefault();
    PdfSearchManager.performSearch();
  });

  // Configurar troca de tipo de busca para habilitar/desabilitar opções
  $('input[name="searchType"]').on("change", function () {
    $("#fuzzyThreshold").prop("disabled", $(this).val() !== "fuzzy");
  });

  // Configurar botão de cancelamento
  $("#cancelSearch").on("click", function () {
    if (documentProcessing) {
      searchCanceled = true;
      $(this)
        .prop("disabled", true)
        .html('<i class="fas fa-spinner fa-spin mr-1"></i> Cancelando...');
    }
  });

  // Inicializar o gerenciador
  PdfSearchManager.init();
});
