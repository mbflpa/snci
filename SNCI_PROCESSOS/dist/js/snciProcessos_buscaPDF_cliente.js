// Variáveis globais para controle da busca
let searchCanceled = false;
let documentProcessing = false;
let searchStartTime = 0;
let totalProcessed = 0;
let totalDocuments = 0;
let totalFilesRead = 0; // Nova variável para contar arquivos que passaram pelos filtros

// Variável global para estatísticas de busca
let searchStats = {
  startTime: 0,
  endTime: 0,
  totalTime: 0,
  documentsProcessed: 0,
  documentsWithMatches: 0,
  averageTimePerDocument: 0,
  peakMemoryUsage: 0,
  averageMemoryUsage: 0,
  memoryMeasurements: [],
  timestamp: null,
};

// Gerenciador de busca em PDFs
const PdfSearchManager = {
  currentSearchResults: [],
  currentPdfQueue: [],
  documentBatch: [],

  // Inicializar o gerenciador
  init: function () {
    this.loadRecentSearches();
    this.initMemoryMonitoring();

    // Verificar se há termos de busca na URL
    const urlParams = new URLSearchParams(window.location.search);
    const searchTerms = urlParams.get("q");
    if (searchTerms) {
      $("#searchTerms").val(searchTerms);
      this.performSearch(searchTerms);
    }
  },

  // Inicializar monitoramento de memória
  initMemoryMonitoring: function () {
    if (window.performance && window.performance.memory) {
      // Monitorar uso de memória a cada 2 segundos
      setInterval(() => {
        const memUsed = Math.round(
          window.performance.memory.usedJSHeapSize / (1024 * 1024)
        );
        const memTotal = Math.round(
          window.performance.memory.totalJSHeapSize / (1024 * 1024)
        );
        const memPercent = Math.round((memUsed / memTotal) * 100);

        // Atualizar estatísticas
        searchStats.memoryMeasurements.push(memUsed);

        // Atualizar pico de memória se necessário
        if (memUsed > searchStats.peakMemoryUsage) {
          searchStats.peakMemoryUsage = memUsed;
        }

        // Atualizar UI
        let memClass = "memory-optimal";
        if (memPercent > 70) memClass = "memory-warning";
        if (memPercent > 85) memClass = "memory-danger";

        $("#memoryUsage")
          .text(`Memória: ${memUsed}MB (${memPercent}%)`)
          .removeClass("memory-optimal memory-warning memory-danger")
          .addClass(memClass);
      }, 2000);
    }
  },

  // Realizar a busca
  performSearch: function (searchTerms) {
    // Resetar estatísticas no início de cada busca
    searchStats = {
      startTime: Date.now(),
      endTime: 0,
      totalTime: 0,
      documentsProcessed: 0,
      documentsWithMatches: 0,
      averageTimePerDocument: 0,
      peakMemoryUsage: 0,
      averageMemoryUsage: 0,
      memoryMeasurements: [],
      timestamp: new Date().toISOString(),
    };

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

    // Ajustado: Rolar automaticamente para o card de resultados após iniciar a busca
    // com offset de -80px
    $("html, body").animate(
      {
        scrollTop: $("#resultsCard").offset().top - 80,
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
            const pageCount = pdf.numPages; // Armazenar o número de páginas

            // Extrair texto de todas as páginas com melhor processamento de espaços
            for (let i = 1; i <= pdf.numPages; i++) {
              textPromises.push(
                pdf
                  .getPage(i)
                  .then((page) =>
                    page.getTextContent({ normalizeWhitespace: true })
                  )
                  .then((content) => {
                    // Algoritmo melhorado para processamento do texto considerando posições
                    return this.processTextContent(content);
                  })
              );
            }

            return Promise.all(textPromises).then((pageTexts) => ({
              pageTexts,
              pageCount, // Incluir o número de páginas no retorno
            }));
          })
          .then((result) => {
            const text = result.pageTexts.join("\n");
            const pageCount = result.pageCount;

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
            } else if (searchOptions.mode === "proximity") {
              const words = searchTerms
                .split(" ")
                .filter((term) => term.length >= 3);
              const proximity = parseInt(searchOptions.proximityDistance);

              // Verificar proximidade entre as palavras no texto
              found = checkProximity(text, words, proximity);

              if (found) {
                // Criar snippet com o texto destacado
                const start = Math.max(0, text.indexOf(words[0]) - 200);
                const end = Math.min(text.length, text.indexOf(words[0]) + 400);
                let snippet = text.substring(start, end);
                if (start > 0) snippet = "..." + snippet;
                if (end < text.length) snippet += "...";
                snippet = highlightAllSearchTerms(snippet, words);
                snippets.push(snippet);
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
                pageCount: pageCount, // Incluir o número de páginas
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

  // Processar conteúdo de texto do PDF considerando posições
  processTextContent: function (textContent) {
    // Ordenar itens por posição vertical (y) e depois horizontal (x)
    const items = textContent.items.slice();
    const textItems = [];

    // Extrair informações relevantes dos itens
    items.forEach((item) => {
      textItems.push({
        str: item.str,
        x: item.transform[4], // Posição X
        y: item.transform[5], // Posição Y
        width: item.width,
        height: item.height,
      });
    });

    // Ordenar itens primeiro por Y (linhas) e depois por X (posição na linha)
    textItems.sort((a, b) => {
      // Tolerância para considerar itens na mesma linha (geralmente 3-5 unidades)
      const yTolerance = 5;

      // Se estão aproximadamente na mesma linha
      if (Math.abs(a.y - b.y) < yTolerance) {
        return a.x - b.x; // Ordena da esquerda para direita
      }

      return b.y - a.y; // Ordena de cima para baixo (coordenadas Y são invertidas em PDF)
    });

    // Construir o texto final considerando a proximidade dos itens
    let lastY = null;
    let text = "";

    textItems.forEach((item, index) => {
      // Adicionar quebra de linha se for uma nova linha
      if (lastY !== null && Math.abs(item.y - lastY) > 5) {
        text += "\n";
      } else if (index > 0) {
        // Verificar se é preciso adicionar espaço entre palavras na mesma linha
        const lastItem = textItems[index - 1];
        const expectedSpaceWidth = lastItem.width / lastItem.str.length; // Estimativa da largura de um espaço

        // Se a distância entre este item e o anterior for maior que um espaço típico
        if (item.x - (lastItem.x + lastItem.width) > expectedSpaceWidth * 0.5) {
          text += " ";
        }
      }

      text += item.str;
      lastY = item.y;
    });

    // Normalizar espaços múltiplos e espaços no início/fim das linhas
    return text
      .split("\n")
      .map((line) => line.trim())
      .join("\n")
      .replace(/\s+/g, " ") // Substitui sequências de espaços por um único espaço
      .trim();
  },

  // Método para atualizar a animação - removendo o código anterior e deixando o SVG funcionar
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
    searchStartTime = startTime;
    this.searchTerms = searchTerms;
    this.searchOptions = searchOptions;

    // Resetar resultados
    this.currentSearchResults = [];
    searchCanceled = false;
    documentProcessing = true; // Importante: marcar como true para o botão cancelar funcionar
    totalProcessed = 0;
    totalDocuments = 0;
    totalFilesRead = 0; // Resetar contador de arquivos lidos

    // Limpar área de resultados
    $("#searchResults").empty();

    // Buscar lista de documentos PDF primeiro
    $.ajax({
      url: "cfc/pc_cfcBuscaPDF_cliente.cfc",
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

            // Atualizar contadores
            totalDocuments = normalizedDocuments.length;

            // Atualizar status de processamento
            $("#processingStatus").text(
              `Processando documentos (0 de ${totalDocuments})`
            );

            // Iniciar processamento de documentos em lotes
            this.currentPdfQueue = [...normalizedDocuments];
            this.processDocumentsBatch();
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

  // Processar documentos em lotes para melhor performance
  processDocumentsBatch: function () {
    if (searchCanceled) {
      console.log("Busca cancelada pelo usuário");
      this.finishSearch();
      return;
    }

    // Verifica se ainda há documentos para processar
    if (this.currentPdfQueue.length === 0) {
      this.finishSearch();
      return;
    }

    // Tamanho do lote - ajustar conforme necessário para performance
    const batchSize = 3;

    // Obter o próximo lote de documentos
    const batch = this.currentPdfQueue.splice(0, batchSize);

    // Processar documentos em paralelo
    const promises = batch.map((doc) => this.processDocument(doc));

    // Quando o lote terminar, processar o próximo
    Promise.all(promises).then(() => {
      // Limpar memória após cada lote processado
      if (window.gc) {
        try {
          window.gc(); // Força coleta de lixo em navegadores que suportam
        } catch (e) {
          console.log("Coleta de lixo não disponível");
        }
      }

      // Atualizar progresso
      const progress = Math.min(
        100,
        Math.round((totalProcessed / totalDocuments) * 100)
      );
      $("#processingProgress").css("width", `${progress}%`);

      // Atualizar status com informação de arquivos lidos vs processados
      // Agora usando a variável totalFilesRead ao invés de this.currentSearchResults.length
      $("#processingStatus").text(
        `Processando: ${totalProcessed} de ${totalDocuments} (${totalFilesRead} arquivo(s) lido(s), ${this.currentSearchResults.length} com termos encontrados)`
      );

      // Continuar com o próximo lote
      setTimeout(() => this.processDocumentsBatch(), 10);
    });
  },

  // Processar um único documento
  processDocument: function (doc) {
    return new Promise((resolve) => {
      // Verificar se a busca foi cancelada
      if (searchCanceled) {
        console.log("Processamento cancelado para: " + doc.fileName);
        resolve();
        return;
      }

      // Incrementar contador
      totalProcessed++;

      try {
        // Aplicar filtros primeiramente (ano e título)

        // Filtrar por ano do processo, se informado
        if (this.searchOptions && this.searchOptions.processYear) {
          const yearMatch = doc.fileName.match(/_PC\d+(\d{4})_/);
          if (!yearMatch || yearMatch[1] !== this.searchOptions.processYear) {
            resolve(); // Pular este documento
            return;
          }
        }

        // Filtrar por texto no título, se informado
        if (
          this.searchOptions &&
          this.searchOptions.titleSearch &&
          this.searchOptions.titleSearch.trim() !== ""
        ) {
          if (
            doc.fileName
              .toLowerCase()
              .indexOf(this.searchOptions.titleSearch.toLowerCase()) === -1
          ) {
            resolve(); // Pular este documento
            return;
          }
        }

        // Se passou em ambos os filtros, incrementar contador de arquivos lidos
        totalFilesRead++;

        // Criar URL para carregar o documento
        const fileUrl = `cfc/pc_cfcBuscaPDF_cliente.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
          doc.filePath
        )}&nome=${encodeURIComponent(doc.fileName)}`;

        // Carregar o PDF usando PDF.js
        pdfjsLib
          .getDocument({ url: fileUrl })
          .promise.then((pdfDoc) => {
            const numPages = pdfDoc.numPages;
            const textPromises = [];

            // Extrair texto de todas as páginas
            for (let i = 1; i <= numPages; i++) {
              textPromises.push(
                pdfDoc
                  .getPage(i)
                  .then((page) =>
                    page.getTextContent({ normalizeWhitespace: true })
                  )
                  .then((content) => this.processTextContent(content))
              );
            }

            // Combinar o texto de todas as páginas
            return Promise.all(textPromises).then((pageTexts) => {
              return {
                text: pageTexts.join("\n"),
                pageCount: numPages,
              };
            });
          })
          .then((result) => {
            // Buscar termos no texto obtido
            const searchResult = this.searchTextForTerms(
              result.text,
              this.searchTerms,
              this.searchOptions
            );

            if (searchResult.found) {
              // Criar objeto de resultado
              const resultObj = {
                fileName: doc.fileName,
                filePath: doc.filePath,
                fileUrl: fileUrl,
                directory: doc.directory || "Diretório FAQ",
                displayPath: doc.displayPath || "",
                size: doc.size,
                pageCount: result.pageCount,
                dateLastModified: doc.dateLastModified,
                snippets: searchResult.snippets,
                extractedText: result.text,
              };

              // Adicionar ao array de resultados
              this.currentSearchResults.push(resultObj);

              // IMPORTANTE: Exibir o resultado imediatamente
              this.displayResultCard(resultObj);
            }

            // Limpar a referência ao texto para ajudar o coletor de lixo
            result.text = null;

            resolve();
          })
          .catch((error) => {
            console.error(`Erro ao processar PDF ${doc.fileName}:`, error);
            resolve();
          });
      } catch (error) {
        console.error(`Erro ao processar documento ${doc.fileName}:`, error);
        resolve();
      }
    });
  },

  // Buscar termos no texto
  searchTextForTerms: function (text, searchTerms, options) {
    const result = {
      found: false,
      snippets: [],
    };

    if (!text || !searchTerms) return result;

    // Verificar modo de busca e executar a lógica correspondente
    if (options.mode === "exact") {
      // Modo de frase exata
      const phrase = searchTerms.trim();
      if (phrase.length >= 3) {
        const regex = new RegExp(this.escapeRegExp(phrase), "gi");
        const matches = text.match(regex);

        if (matches && matches.length > 0) {
          result.found = true;

          // Criar snippet com contexto
          const firstIndex = text.toLowerCase().indexOf(phrase.toLowerCase());
          if (firstIndex !== -1) {
            const start = Math.max(0, firstIndex - 200);
            const end = Math.min(text.length, firstIndex + phrase.length + 200);
            let snippet = text.substring(start, end);

            if (start > 0) snippet = "..." + snippet;
            if (end < text.length) snippet += "...";

            snippet = this.highlightSearchPhrase(snippet, phrase);
            result.snippets.push(snippet);
          }
        }
      }
    } else if (options.mode === "proximity") {
      // Modo de proximidade
      const words = searchTerms.split(" ").filter((term) => term.length >= 3);
      const proximity = parseInt(options.proximityDistance || "20");

      // Verificar proximidade
      result.found = checkProximity(text, words, proximity);

      if (result.found) {
        // Criar snippet com contexto
        const firstWord = words[0];
        const firstIndex = text.toLowerCase().indexOf(firstWord.toLowerCase());

        if (firstIndex !== -1) {
          const start = Math.max(0, firstIndex - 200);
          const end = Math.min(text.length, firstIndex + 400);
          let snippet = text.substring(start, end);

          if (start > 0) snippet = "..." + snippet;
          if (end < text.length) snippet += "...";

          snippet = highlightAllSearchTerms(snippet, words);
          result.snippets.push(snippet);
        }
      }
    } else {
      // Modo OR (padrão)
      const terms = searchTerms.split(" ").filter((term) => term.length >= 3);

      terms.forEach((term) => {
        const regex = new RegExp(this.escapeRegExp(term), "gi");
        const matches = text.match(regex);

        if (matches && matches.length > 0) {
          result.found = true;

          // Adicionar snippet se ainda não temos muitos
          if (result.snippets.length < 3) {
            const firstIndex = text.toLowerCase().indexOf(term.toLowerCase());

            if (firstIndex !== -1) {
              const start = Math.max(0, firstIndex - 200);
              const end = Math.min(text.length, firstIndex + term.length + 200);
              let snippet = text.substring(start, end);

              if (start > 0) snippet = "..." + snippet;
              if (end < text.length) snippet += "...";

              snippet = this.highlightSearchTerm(snippet, term);
              result.snippets.push(snippet);
            }
          }
        }
      });
    }

    return result;
  },

  // NOVO MÉTODO: Exibir card de resultado em tempo real - MODIFICADO para remover texto extraído
  displayResultCard: function (result) {
    // Criar HTML do card - sem opção de texto extraído
    const cardHtml = this.createResultHTML(result);

    // Adicionar ao início da lista de resultados com efeito de animação
    const $card = $(cardHtml).addClass("live-result");
    $("#searchResults").prepend($card);

    // Remover classe de animação após um tempo
    setTimeout(() => {
      $card.removeClass("live-result");
    }, 1000);

    // Garantir que a área de resultados esteja visível
    $("#searchResults").show();

    // Se este for o primeiro resultado, fazer scroll para ele
    if (this.currentSearchResults.length === 1) {
      setTimeout(() => {
        $("html, body").animate(
          {
            scrollTop: $card.offset().top - 80,
          },
          "slow"
        );
      }, 300);
    }

    // Forçar coleta de lixo se disponível após cada card exibido
    this.triggerGarbageCollection();
  },

  // Criar HTML para um resultado - MODIFICADO para remover texto extraído
  createResultHTML: function (result) {
    // URL direta para visualizar o PDF
    const pdfUrl = result.fileUrl;

    // Formatar o nome do arquivo se for muito longo
    const shortFileName =
      result.fileName.length > 50
        ? result.fileName.substring(0, 47) + "..."
        : result.fileName;

    // Formatar data e tamanho
    const formattedDate = this.formatDate(result.dateLastModified);
    const formattedSize = this.formatFileSize(result.size);

    return `
      <div class="search-result" data-file-path="${
        result.filePath
      }" data-file-url="${pdfUrl}" data-result-id="${
      this.currentSearchResults.length - 1
    }">
        <div class="d-flex justify-content-between align-items-start">
          <h5>
            <a href="${pdfUrl}" target="_blank" class="view-pdf-link">
              <i class="far fa-file-pdf mr-2"></i>${shortFileName}
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
        
        <div class="d-flex justify-content-between mt-2">
          <div>
            <span class="badge badge-light mr-1">
              <i class="far fa-calendar-alt mr-1"></i> ${formattedDate}
            </span>
            <span class="badge badge-light mr-1">
              <i class="fas fa-file-alt mr-1"></i> ${formattedSize}
            </span>
            <span class="badge badge-light">
              <i class="fas fa-file-pdf mr-1"></i> ${
                result.pageCount || "?"
              } página${result.pageCount !== 1 ? "s" : ""}
            </span>
          </div>
          <div>
            <a href="${pdfUrl}" target="_blank" class="btn btn-sm btn-outline-primary">
              <i class="far fa-eye mr-1"></i> Visualizar
            </a>
          </div>
        </div>
      </div>
    `;
  },

  // Destacar termos de busca em um texto longo
  highlightSearchTerms: function (text) {
    if (!text || text.length > 10000) {
      // Limitar texto se for muito longo
      text = text.substring(0, 10000) + "...";
    }

    if (this.searchOptions.mode === "exact") {
      return this.highlightSearchPhrase(text, this.searchTerms);
    } else {
      const terms = this.searchTerms
        .split(" ")
        .filter((term) => term.length >= 3);
      let highlightedText = text;

      terms.forEach((term) => {
        highlightedText = this.highlightSearchTerm(highlightedText, term);
      });

      return highlightedText;
    }
  },

  // Finalizar a busca
  finishSearch: function () {
    // Agora escondemos a animação apenas quando a busca termina
    $("#searchLoading").hide();

    const searchTime = ((performance.now() - searchStartTime) / 1000).toFixed(
      2
    );
    const filesRead = totalFilesRead;
    const filesWithMatches = this.currentSearchResults.length;

    if (filesWithMatches === 0) {
      $("#noResultsAlert").show();
      $("#searchStats").text(
        `0 resultados encontrados em ${searchTime} segundos. Processados: ${totalProcessed} de ${totalDocuments} documentos. Lidos: ${filesRead} (${
          Math.round((filesRead / totalProcessed) * 100) || 0
        }%). Uso de memória: ${searchStats.peakMemoryUsage}MB (pico)`
      );
    } else {
      $("#searchStats").text(
        `${filesWithMatches} resultado${
          filesWithMatches !== 1 ? "s" : ""
        } encontrado${
          filesWithMatches !== 1 ? "s" : ""
        } em ${searchTime} segundos. Processados: ${totalProcessed} de ${totalDocuments} documentos. Lidos: ${filesRead} (${Math.round(
          (filesRead / totalProcessed) * 100
        )}%). Uso de memória: ${searchStats.peakMemoryUsage}MB (pico)`
      );
    }

    // Resetar variáveis de controle
    searchCanceled = false;
    documentProcessing = false;

    // Forçar a coleta de lixo no final da busca
    this.triggerGarbageCollection();

    // Habilitar o botão de cancelar para a próxima busca
    $("#cancelSearch")
      .prop("disabled", false)
      .html('<i class="fas fa-times mr-1"></i> Cancelar busca');

    // Salvar estatísticas
    this.saveSearchStats();
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

  // Função aprimorada para destacar todas as palavras pesquisadas
  highlightAllSearchTerms: function (text, terms) {
    if (!text || !terms || !terms.length) return text;

    let highlightedText = text;
    terms.forEach((term) => {
      if (term.length >= 3) {
        const regex = new RegExp(`(${escapeRegExp(term)})`, "gi");
        highlightedText = highlightedText.replace(regex, "<mark>$1</mark>");
      }
    });
    return highlightedText;
  },

  // Função auxiliar para escapar caracteres especiais em expressões regulares
  escapeRegExp: function (string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  },

  // Função para contar palavras em um texto
  countWords: function (text) {
    return text.trim().split(/\s+/).length;
  },

  // Função para verificar proximidade entre palavras
  checkProximity: function (text, words, proximity) {
    // Se proximidade for -1, significa "Em qualquer parte"
    if (proximity === -1) {
      return words.every((word) =>
        text.toLowerCase().includes(word.toLowerCase())
      );
    }

    // Dividir o texto em palavras
    const textWords = text.trim().split(/\s+/);

    for (let i = 0; i < textWords.length; i++) {
      // Verificar se a primeira palavra está presente
      if (textWords[i].toLowerCase().includes(words[0].toLowerCase())) {
        // Verificar se todas as outras palavras estão dentro da proximidade especificada
        let allFound = true;
        for (let j = 1; j < words.length; j++) {
          let found = false;
          // Verificar nas próximas 'proximity' palavras
          for (
            let k = i + 1;
            k < Math.min(i + proximity + 1, textWords.length);
            k++
          ) {
            if (textWords[k].toLowerCase().includes(words[j].toLowerCase())) {
              found = true;
              break;
            }
          }
          if (!found) {
            allFound = false;
            break;
          }
        }
        if (allFound) {
          return true;
        }
      }
    }
    return false;
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

      // Mostrar estatísticas detalhadas, incluindo porcentagem de arquivos lidos
      // Usar totalFilesRead para a contagem correta
      const actualFilesRead = filesRead || totalFilesRead;
      const percentRead =
        totalProcessed > 0
          ? Math.round((actualFilesRead / totalProcessed) * 100)
          : 0;

      $("#searchStats").text(
        `0 resultados encontrados em ${searchTime} segundos. Processados: ${totalProcessed} de ${totalDocuments} documentos. Lidos: ${actualFilesRead} (${percentRead}%)`
      );
      return;
    }

    // Construir HTML dos resultados - sem mostrar relevância
    const termsList = searchTerms.split(" ").filter((term) => term.length >= 3);
    let resultsHtml = "";

    // Exibir estatísticas sobre arquivos processados e lidos
    const actualFilesRead = filesRead || totalFilesRead;
    const resultsCount = this.currentSearchResults.length;
    const percentRead = Math.round((actualFilesRead / totalProcessed) * 100);

    // Adicionar resumo no topo da lista de resultados
    resultsHtml += `
      <div class="alert alert-info mb-3">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <i class="fas fa-info-circle mr-2"></i>
            <strong>Resultados da busca:</strong> ${resultsCount} termo(s) encontrado(s) em ${actualFilesRead} arquivos lidos (${percentRead}% dos processados)
          </div>
          <div>
            <span class="badge badge-primary">${
              searchOptions.processYear
                ? "Ano: " + searchOptions.processYear
                : ""
            }</span>
            <span class="badge badge-primary">${
              searchOptions.titleSearch
                ? "Título: " + searchOptions.titleSearch
                : ""
            }</span>
          </div>
        </div>
      </div>
    `;

    this.currentSearchResults.forEach((result, index) => {
      // URL direta para visualizar o PDF
      const pdfUrl = `cfc/pc_cfcBuscaPDF.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
        result.filePath
      )}&nome=${encodeURIComponent(result.fileName)}`;

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
              <div class="card-body extracted-text-content" style="max-height: 300px; overflow-y: auto;">
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
              <span class="badge badge-light mr-1">
                <i class="fas fa-file-alt mr-1"></i> ${this.formatFileSize(
                  result.size || 0
                )}
              </span>
              <span class="badge badge-light">
                <i class="fas fa-file-pdf mr-1"></i> ${
                  result.pageCount || "?"
                } página${result.pageCount !== 1 ? "s" : ""}
              </span>
            </div>
            <div>
              <a href="${pdfUrl}" target="_blank" class="btn btn-sm btn-outline-primary">
                <i class="far fa-eye mr-1"></i> Visualizar
              </a>
            </div>
          </div>
        </div>
      `;
    });

    // Exibir resultados e estatísticas
    $("#searchResults").html(resultsHtml);
    $("#searchStats").text(
      `${this.currentSearchResults.length} resultado${
        this.currentSearchResults.length !== 1 ? "s" : ""
      } encontrado${
        this.currentSearchResults.length !== 1 ? "s" : ""
      } em ${searchTime} segundos. Processados: ${totalProcessed} de ${totalDocuments} documentos. Lidos: ${actualFilesRead} (${percentRead}%)`
    );

    // Adicionar handlers para os botões de exibir texto extraído
    this.setupExtractedTextHandlers();
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

  // Navegar pelos destaques
  navigateHighlights: function (direction) {
    console.log("Navegação entre destaques: direção =", direction);
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

  // Carregar e exibir buscas recentes
  loadRecentSearches: function () {
    try {
      const recentSearches = JSON.parse(
        localStorage.getItem("recentFaqSearches") || "[]"
      );
      const container = $("#recentSearchesContainer");
      // Limpar e atualizar container
      container.empty();
      if (recentSearches.length === 0) return;
      let html =
        '<div class="mt-2"><small class="text-muted">Buscas recentes: </small>';
      recentSearches.forEach((term) => {
        html += `
          <a href="javascript:void(0)" class="badge badge-light mr-1" onclick="PdfSearchManager.searchWithTerm('${term.replace(
            /'/g,
            "\\'"
          )}')">${term}</a>
        `;
      });
      html += `
        <button class="btn btn-link btn-sm text-muted px-0 ml-2" onclick="PdfSearchManager.clearRecentSearches()">
          <i class="fas fa-times"></i> Limpar
        </button>
      </div>`;
      container.html(html);
    } catch (e) {
      console.error("Erro ao carregar buscas recentes:", e);
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

  // Formatar data
  formatDate: function (dateStr) {
    try {
      const date = new Date(dateStr);
      return date.toLocaleDateString("pt-BR");
    } catch (e) {
      return "Data desconhecida";
    }
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

  // NOVO MÉTODO: Força a coleta de lixo quando disponível
  triggerGarbageCollection: function () {
    try {
      // Tentar forçar a coleta de lixo
      if (window.gc) window.gc();

      // Atualizar o indicador de uso de memória
      if (window.performance && window.performance.memory) {
        const memUsed = Math.round(
          window.performance.memory.usedJSHeapSize / (1024 * 1024)
        );
        const memTotal = Math.round(
          window.performance.memory.totalJSHeapSize / (1024 * 1024)
        );
        const memPercent = Math.round((memUsed / memTotal) * 100);

        // Atualizar pico de memória se necessário
        if (memUsed > searchStats.peakMemoryUsage) {
          searchStats.peakMemoryUsage = memUsed;
        }

        let memClass = "memory-optimal";
        if (memPercent > 70) memClass = "memory-warning";
        if (memPercent > 85) memClass = "memory-danger";

        $("#memoryUsage")
          .text(`Memória: ${memUsed}MB (${memPercent}%)`)
          .removeClass("memory-optimal memory-warning memory-danger")
          .addClass(memClass);
      }
    } catch (e) {
      console.log("Não foi possível forçar a coleta de lixo");
    }
  },

  // NOVO MÉTODO: Salvar estatísticas no localStorage
  saveSearchStats: function () {
    try {
      // Recuperar estatísticas anteriores
      const existingStatsString = localStorage.getItem("pdfSearchStats_client");
      let allStats = [];

      if (existingStatsString) {
        try {
          allStats = JSON.parse(existingStatsString);
          if (!Array.isArray(allStats)) {
            allStats = [];
          }
        } catch (e) {
          console.error("Erro ao analisar estatísticas existentes:", e);
          allStats = [];
        }
      }

      // Calcular média de uso de memória
      let avgMemory = 0;
      if (
        searchStats.memoryMeasurements &&
        searchStats.memoryMeasurements.length > 0
      ) {
        avgMemory =
          searchStats.memoryMeasurements.reduce((sum, val) => sum + val, 0) /
          searchStats.memoryMeasurements.length;
      }

      // Adicionar as novas estatísticas
      allStats.push({
        timestamp: new Date().toISOString(),
        searchTerms: this.searchTerms,
        searchOptions: {
          mode: this.searchOptions.mode,
          processYear: this.searchOptions.processYear,
          titleSearch: this.searchOptions.titleSearch,
        },
        stats: {
          totalTime: ((performance.now() - searchStartTime) / 1000).toFixed(2),
          documentsProcessed: totalProcessed,
          documentsWithMatches: this.currentSearchResults.length,
          documentsRead: totalFilesRead,
          averageTimePerDocument:
            totalProcessed > 0
              ? (
                  (performance.now() - searchStartTime) /
                  1000 /
                  totalProcessed
                ).toFixed(3)
              : 0,
          peakMemoryUsage: searchStats.peakMemoryUsage,
          averageMemoryUsage: avgMemory.toFixed(1),
          percentageWithMatches: (
            (this.currentSearchResults.length / Math.max(1, totalFilesRead)) *
            100
          ).toFixed(1),
        },
      });

      // Manter apenas as últimas 20 estatísticas
      if (allStats.length > 20) {
        allStats = allStats.slice(-20);
      }

      // Salvar no localStorage
      localStorage.setItem("pdfSearchStats_client", JSON.stringify(allStats));

      console.log("Estatísticas de busca salvas:", searchStats);
    } catch (e) {
      console.error("Erro ao salvar estatísticas:", e);
    }
  },
};

$(document).ready(function () {
  if (typeof pdfjsLib === "undefined") {
    console.error(
      "PDF.js não foi carregado corretamente. Verifique se o script foi importado."
    );
  } else {
    console.log("PDF.js inicializado e pronto para uso.");
  }

  $("#searchFaqForm").on("submit", function (e) {
    e.preventDefault();
    PdfSearchManager.performSearch();
  });

  $('input[name="searchType"]').on("change", function () {
    $("#fuzzyThreshold").prop("disabled", $(this).val() !== "fuzzy");
  });

  // Reestruturado para garantir que o clique do botão funcione corretamente
  $("#cancelSearch")
    .off("click")
    .on("click", function () {
      console.log(
        "Botão cancelar clicado, documentProcessing =",
        documentProcessing
      );
      if (!documentProcessing) return;
      searchCanceled = true;
      console.log("Busca cancelada, documentProcessing =", documentProcessing);
      $(this)
        .prop("disabled", true)
        .html('<i class="fas fa-spinner fa-spin mr-1"></i> Cancelando...');
      $("#processingStatus").text("Cancelando busca...");
    });

  PdfSearchManager.init();
});
