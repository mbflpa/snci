// Variáveis globais para controle da busca
let searchCanceled = false;
let documentProcessing = false;
let searchStartTime = 0;
let totalProcessed = 0;
let totalDocuments = 0;

// Gerenciador de busca em PDFs
const PdfSearchManager = {
  currentSearchResults: [],
  currentPdfQueue: [],
  documentBatch: [],

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
    documentProcessing = false;
    totalProcessed = 0;
    totalDocuments = 0;
    
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
            $("#processingStatus").text(`Processando documentos (0 de ${totalDocuments})`);
            
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
  processDocumentsBatch: function() {
    if (searchCanceled) {
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
    const promises = batch.map(doc => this.processDocument(doc));
    
    // Quando o lote terminar, processar o próximo
    Promise.all(promises).then(() => {
      // Atualizar progresso
      const progress = Math.min(100, Math.round((totalProcessed / totalDocuments) * 100));
      $("#processingProgress").css("width", `${progress}%`);
      $("#processingStatus").text(`Processando documentos (${totalProcessed} de ${totalDocuments})`);
      
      // Continuar com o próximo lote
      setTimeout(() => this.processDocumentsBatch(), 10);
    });
  },

  // Processar um único documento
  processDocument: function(doc) {
    return new Promise((resolve) => {
      // Verificar se a busca foi cancelada
      if (searchCanceled) {
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
        if (this.searchOptions && this.searchOptions.titleSearch && 
            this.searchOptions.titleSearch.trim() !== "") {
          if (doc.fileName.toLowerCase().indexOf(
             this.searchOptions.titleSearch.toLowerCase()) === -1) {
            resolve(); // Pular este documento
            return;
          }
        }
        
        // Criar URL para carregar o documento
        const fileUrl = `cfc/pc_cfcBuscaPDF_cliente.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
          doc.filePath
        )}&nome=${encodeURIComponent(doc.fileName)}`;
        
        // Carregar o PDF usando PDF.js
        pdfjsLib.getDocument({url: fileUrl}).promise.then(pdfDoc => {
          const numPages = pdfDoc.numPages;
          const textPromises = [];
          
          // Extrair texto de todas as páginas
          for (let i = 1; i <= numPages; i++) {
            textPromises.push(
              pdfDoc.getPage(i)
                .then(page => page.getTextContent({normalizeWhitespace: true}))
                .then(content => this.processTextContent(content))
            );
          }
          
          // Combinar o texto de todas as páginas
          return Promise.all(textPromises).then(pageTexts => {
            return {
              text: pageTexts.join("\n"),
              pageCount: numPages
            };
          });
        }).then(result => {
          // Buscar termos no texto obtido
          const searchResult = this.searchTextForTerms(result.text, this.searchTerms, this.searchOptions);
          
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
              extractedText: result.text
            };
            
            // Adicionar ao array de resultados
            this.currentSearchResults.push(resultObj);
            
            // IMPORTANTE: Exibir o resultado imediatamente
            this.displayResultCard(resultObj);
          }
          
          resolve();
        }).catch(error => {
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
  searchTextForTerms: function(text, searchTerms, options) {
    const result = {
      found: false,
      snippets: []
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
      const words = searchTerms.split(" ").filter(term => term.length >= 3);
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
      const terms = searchTerms.split(" ").filter(term => term.length >= 3);
      
      terms.forEach(term => {
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

  // NOVO MÉTODO: Exibir card de resultado em tempo real
  displayResultCard: function(result) {
    // Esconder indicador de carregamento após encontrar primeiro resultado
    if (this.currentSearchResults.length === 1) {
      $("#searchLoading").hide();
    }
    
    // Criar HTML do card
    const cardHtml = this.createResultHTML(result);
    
    // Adicionar ao início da lista de resultados com efeito de animação
    const $card = $(cardHtml).addClass("live-result");
    $("#searchResults").prepend($card);
    
    // Remover classe de animação após um tempo
    setTimeout(() => {
      $card.removeClass("live-result");
    }, 1000);
    
    // Adicionar handlers para o texto extraído
    this.setupExtractedTextHandlers();
  },

  // Criar HTML para um resultado
  createResultHTML: function(result) {
    // URL direta para visualizar o PDF
    const pdfUrl = result.fileUrl;
    
    // Formatar o nome do arquivo se for muito longo
    const shortFileName = result.fileName.length > 50 
      ? result.fileName.substring(0, 47) + "..." 
      : result.fileName;
    
    // Formatar data e tamanho
    const formattedDate = this.formatDate(result.dateLastModified);
    const formattedSize = this.formatFileSize(result.size);
    
    return `
      <div class="search-result" data-file-path="${result.filePath}" data-file-url="${pdfUrl}" data-result-id="${this.currentSearchResults.length - 1}">
        <div class="d-flex justify-content-between align-items-start">
          <h5>
            <a href="${pdfUrl}" target="_blank" class="view-pdf-link">
              <i class="far fa-file-pdf mr-2"></i>${shortFileName}
            </a>
          </h5>
        </div>
        <p class="mb-1 text-muted small">
          <i class="fas fa-folder-open mr-1"></i> ${result.directory || "Diretório FAQ"}
        </p>
        <div class="search-snippets">
          ${this.formatSnippets(result.snippets)}
        </div>
        
        <!-- Botão para mostrar/ocultar texto extraído -->
        <div class="mt-3">
          <button class="btn btn-sm btn-outline-info toggle-extracted-text" data-result-id="${this.currentSearchResults.length - 1}">
            <i class="fas fa-file-alt mr-1"></i> Ver texto extraído
          </button>
        </div>
        
        <!-- Container para o texto extraído (inicialmente oculto) -->
        <div class="extracted-text-container mt-2" id="extractedText-${this.currentSearchResults.length - 1}" style="display: none;">
          <div class="card">
            <div class="card-header py-2 bg-light">
              <div class="d-flex justify-content-between align-items-center">
                <span><i class="fas fa-file-alt mr-1"></i> Conteúdo do documento</span>
                <button class="btn btn-sm btn-link text-muted p-0 copy-text" data-result-id="${this.currentSearchResults.length - 1}">
                  <i class="far fa-copy"></i> Copiar
                </button>
              </div>
            </div>
            <div class="card-body extracted-text-content" style="max-height: 300px; overflow-y: auto;">
              ${this.highlightSearchTerms(result.extractedText)}
            </div>
          </div>
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
              <i class="fas fa-file-pdf mr-1"></i> ${result.pageCount || "?"} página${result.pageCount !== 1 ? "s" : ""}
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
  highlightSearchTerms: function(text) {
    if (!text || text.length > 10000) {
      // Limitar texto se for muito longo
      text = text.substring(0, 10000) + "...";
    }
    
    if (this.searchOptions.mode === "exact") {
      return this.highlightSearchPhrase(text, this.searchTerms);
    } else {
      const terms = this.searchTerms.split(" ").filter(term => term.length >= 3);
      let highlightedText = text;
      
      terms.forEach(term => {
        highlightedText = this.highlightSearchTerm(highlightedText, term);
      });
      
      return highlightedText;
    }
  },

  // Finalizar a busca
  finishSearch: function() {
    $("#searchLoading").hide();
    
    const searchTime = ((performance.now() - searchStartTime) / 1000).toFixed(2);
    
    if (this.currentSearchResults.length === 0) {
      $("#noResultsAlert").show();
      $("#searchStats").text(`0 resultados encontrados em ${searchTime} segundos. Documentos processados: ${totalProcessed} de ${totalDocuments}`);
    } else {
      $("#searchStats").text(
        `${this.currentSearchResults.length} resultado${
          this.currentSearchResults.length !== 1 ? "s" : ""
        } encontrado${
          this.currentSearchResults.length !== 1 ? "s" : ""
        } em ${searchTime} segundos. Documentos processados: ${totalProcessed} de ${totalDocuments}`
      );
    }
    
    // Resetar variáveis de controle
    searchCanceled = false;
    documentProcessing = false;
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
    searchOptionsdisabled", true)
  ) {pinner fa-spin mr-1"></i> Cancelando...');
    $("#searchLoading").hide();
    $("#realTimeResults").hide();/ Mostrar feedback na interface
("#processingStatus").text("Cancelando busca...");
    // Se não há resultados  });
    if (this.currentSearchResults.length === 0) {
      $("#noResultsAlert").show();dfSearchManager.init();
      $("#searchStats").text(});




























































































































































































































































































































































































});  PdfSearchManager.init();  });    }        .html('<i class="fas fa-spinner fa-spin mr-1"></i> Cancelando...');        .prop("disabled", true)      $(this)      searchCanceled = true;    if (documentProcessing) {  $("#cancelSearch").on("click", function () {  });    $("#fuzzyThreshold").prop("disabled", $(this).val() !== "fuzzy");  $('input[name="searchType"]').on("change", function () {  });    PdfSearchManager.performSearch();    e.preventDefault();  $("#searchFaqForm").on("submit", function (e) {  }    console.log("PDF.js inicializado e pronto para uso.");  } else {    );      "PDF.js não foi carregado corretamente. Verifique se o script foi importado."    console.error(  if (typeof pdfjsLib === "undefined") {$(document).ready(function () {// Inicializar o gerenciador de busca}  return highlightedText;  });    }      highlightedText = highlightedText.replace(regex, "<mark>$1</mark>");      );        "gi"        `(${PdfSearchManager.escapeRegExp(term)})`,      const regex = new RegExp(    if (term.length >= 3) {  terms.forEach((term) => {  let highlightedText = text;  if (!text || !terms || !terms.length) return text;function highlightAllSearchTerms(text, terms) {// Função aprimorada para destacar todas as palavras pesquisadas}  return false;  }    }      }        return true;      if (allFound) {      }        }          break;          allFound = false;        if (!found) {        }          }            break;            found = true;          if (textWords[k].toLowerCase().includes(words[j].toLowerCase())) {        ) {          k++          k < Math.min(i + proximity + 1, textWords.length);          let k = i + 1;        for (        // Verificar nas próximas 'proximity' palavras        let found = false;      for (let j = 1; j < words.length; j++) {      let allFound = true;      // Verificar se todas as outras palavras estão dentro da proximidade especificada    if (textWords[i].toLowerCase().includes(words[0].toLowerCase())) {    // Verificar se a primeira palavra está presente  for (let i = 0; i < textWords.length; i++) {  const textWords = text.trim().split(/\s+/);  // Dividir o texto em palavras  }    );      text.toLowerCase().includes(word.toLowerCase())    return words.every((word) =>  if (proximity === -1) {  // Se proximidade for -1, significa "Em qualquer parte"function checkProximity(text, words, proximity) {// Função para verificar proximidade entre palavras};  },    console.log("Navegação entre destaques: direção =", direction);  navigateHighlights: function (direction) {  // Navegar pelos destaques  },    // Não precisamos adicionar o scroll aqui pois já está no performSearch    this.performSearch(term);    $("#searchTerms").val(term);  searchWithTerm: function (term) {  // Iniciar busca com termo específico  },    window.history.pushState({ path: newUrl }, "", newUrl);      encodeURIComponent(searchTerms);      "?q=" +      window.location.pathname +      window.location.host +      "//" +      window.location.protocol +    const newUrl =  updateUrlWithSearchTerms: function (searchTerms) {  // Atualizar a URL com os termos de busca para permitir compartilhamento  },    }      toastr.error("Erro ao limpar histórico de buscas.");      console.error("Erro ao limpar buscas recentes:", e);    } catch (e) {      toastr.success("Histórico de buscas removido com sucesso!");      $("#recentSearchesContainer").empty();      localStorage.removeItem("recentFaqSearches");    try {  clearRecentSearches: function () {  // Limpar as buscas recentes  },    }      console.error("Erro ao carregar buscas recentes:", e);    } catch (e) {      container.html(html);      </div>`;        </button>          <i class="fas fa-times"></i> Limpar                onclick="PdfSearchManager.clearRecentSearches()">        <button class="btn btn-link btn-sm text-muted px-0 ml-2"       html += `      });        `;             )}')">${term}</a>               "\\'"               /'/g,             onclick="PdfSearchManager.searchWithTerm('${term.replace(          <a href="javascript:void(0)" class="badge badge-light mr-1"         html += `      recentSearches.forEach((term) => {        '<div class="mt-2"><small class="text-muted">Buscas recentes: </small>';      let html =      if (recentSearches.length === 0) return;      container.empty();      const container = $("#recentSearchesContainer");      // Limpar e atualizar container      );        localStorage.getItem("recentFaqSearches") || "[]"      const recentSearches = JSON.parse(    try {  loadRecentSearches: function () {  // Carregar e exibir buscas recentes  },    }      console.error("Erro ao salvar busca recente:", e);    } catch (e) {      this.loadRecentSearches();      // Atualizar UI      );        JSON.stringify(filteredSearches)        "recentFaqSearches",      localStorage.setItem(      }        filteredSearches.length = 5;      if (filteredSearches.length > 5) {      filteredSearches.unshift(searchTerms);      // Manter apenas as 5 pesquisas mais recentes      );        (term) => term.toLowerCase() !== searchTerms.toLowerCase()      const filteredSearches = recentSearches.filter(      );        localStorage.getItem("recentFaqSearches") || "[]"      const recentSearches = JSON.parse(    try {  saveRecentSearch: function (searchTerms) {  // Salvar buscas recentes no localStorage  },    }      return "Data desconhecida";    } catch (e) {      return date.toLocaleDateString("pt-BR");      const date = new Date(dateStr);    try {  formatDate: function (dateStr) {  // Formatar data  },    }      return (bytes / 1073741824).toFixed(1) + " GB";    } else {      return (bytes / 1048576).toFixed(1) + " MB";    } else if (bytes < 1073741824) {      return (bytes / 1024).toFixed(1) + " KB";    } else if (bytes < 1048576) {      return bytes + " bytes";    if (bytes < 1024) {  formatFileSize: function (bytes) {  // Formatar tamanho do arquivo  },    });      }, 2000);        $(this).html('<i class="far fa-copy"></i> Copiar');      setTimeout(() => {      $(this).html('<i class="fas fa-check"></i> Copiado!');      // Feedback ao usuário      document.body.removeChild(tempElement);      document.execCommand("copy");      tempElement.select();      document.body.appendChild(tempElement);      tempElement.value = textContent;      const tempElement = document.createElement("textarea");      // Criar elemento temporário para copiar        PdfSearchManager.currentSearchResults[resultId].extractedText;      const textContent =      const resultId = $(this).data("result-id");    $(".copy-text").on("click", function () {    // Copiar texto para área de transferência    });      }        $(this).html('<i class="fas fa-file-alt mr-1"></i> Ocultar texto');        textContainer.slideDown(200);        // Abrir este texto        );          '<i class="fas fa-file-alt mr-1"></i> Ver texto extraído'        $(".toggle-extracted-text").html(        $(".extracted-text-container").slideUp(200);        // Fechar outros textos abertos      } else {        $(this).html('<i class="fas fa-file-alt mr-1"></i> Ver texto extraído');        textContainer.slideUp(200);      if (textContainer.is(":visible")) {      const textContainer = $(`#extractedText-${resultId}`);      const resultId = $(this).data("result-id");    $(".toggle-extracted-text").on("click", function () {    // Toggle para mostrar/ocultar texto extraído  setupExtractedTextHandlers: function () {  // Configurar manipuladores para o texto extraído  },    this.setupExtractedTextHandlers();    // Adicionar handlers para os botões de exibir texto extraído    );      } em ${searchTime} segundos. Arquivos lidos: ${filesRead || "N/A"}`        this.currentSearchResults.length !== 1 ? "s" : ""      } encontrado${        this.currentSearchResults.length !== 1 ? "s" : ""      `${this.currentSearchResults.length} resultado${    $("#searchStats").text(    $("#searchResults").html(resultsHtml);    // Exibir resultados e estatísticas    });      `;        </div>          </div>            </div>              </span>                } página${result.pageCount !== 1 ? "s" : ""}                  result.pageCount || "?"                <i class="fas fa-file-pdf mr-1"></i> ${              <span class="badge badge-light">              </span>                )}                  result.size || 0                <i class="fas fa-file-alt mr-1"></i> ${this.formatFileSize(              <span class="badge badge-light mr-1">              </span>                )}                  result.dateLastModified || new Date()                <i class="far fa-calendar-alt mr-1"></i> ${this.formatDate(              <span class="badge badge-light mr-1">            <div>          <div class="d-flex justify-content-between mt-2">                    </div>            </div>              </div>                ${highlightedText}              <div class="card-body extracted-text-content " style="max-height: 300px; overflow-y: auto;">              </div>                </div>                  </button>                    <i class="far fa-copy"></i> Copiar                  <button class="btn btn-sm btn-link text-muted p-0 copy-text" data-result-id="${index}">                  <span><i class="fas fa-file-alt mr-1"></i> Conteúdo do documento</span>                <div class="d-flex justify-content-between align-items-center">              <div class="card-header py-2 bg-light">            <div class="card">          <div class="extracted-text-container mt-2" id="extractedText-${index}" style="display: none;">          <!-- Container para o texto extraído (inicialmente oculto) -->                    </div>            </button>              <i class="fas fa-file-alt mr-1"></i> Ver texto extraído            <button class="btn btn-sm btn-outline-info toggle-extracted-text" data-result-id="${index}">          <div class="mt-3">          <!-- Botão para mostrar/ocultar texto extraído -->                    </div>            ${this.formatSnippets(result.snippets)}          <div class="search-snippets">          </p>            }              result.directory || "Diretório FAQ"            <i class="fas fa-folder-open mr-1"></i> ${          <p class="mb-1 text-muted small">          </div>            </h5>              </a>                <i class="far fa-file-pdf mr-2"></i>${result.fileName}              <a href="${pdfUrl}" target="_blank" class="view-pdf-link">            <h5>          <div class="d-flex justify-content-between align-items-start">        }" data-file-url="${pdfUrl}" data-result-id="${index}">          result.filePath        <div class="search-result" data-file-path="${      resultsHtml += `            }, truncatedText);              return text;              }                return text.replace(regex, "<mark>$1</mark>");                const regex = new RegExp(`(${this.escapeRegExp(term)})`, "gi");              if (term.length >= 3) {          : termsList.reduce((text, term) => {          ? this.highlightSearchPhrase(truncatedText, searchTerms)        searchOptions && searchOptions.mode === "exact"      const highlightedText =      // Destacar termos de busca no texto completo        : "Texto não disponível";          : result.extractedText          ? result.extractedText.substring(0, 5000) + "..."        ? result.extractedText.length > 5000      const truncatedText = result.extractedText      // Truncar texto para preview (primeiros 5000 caracteres)      )}`;        result.filePath      const pdfUrl = `cfc/pc_cfcBuscaPDF.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(      // URL direta para visualizar o PDF    this.currentSearchResults.forEach((result, index) => {    let resultsHtml = "";    const termsList = searchTerms.split(" ").filter((term) => term.length >= 3);    // Construir HTML dos resultados - sem mostrar relevância    }      return;      );        }`          filesRead || "N/A"        `0 resultados encontrados em ${searchTime} segundos. Arquivos lidos: ${