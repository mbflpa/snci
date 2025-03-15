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

    // NOVO: incluir o ano do processo, se informado
    searchOptions.processYear = $("#searchYear").val().trim();

    $("#resultsCard").show();
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
      $.ajax({
        url: "cfc/pc_cfcBuscaPDF.cfc",
        type: "POST", // Alterado para POST que geralmente funciona melhor com ColdFusion
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
              console.error(
                "Erro ao converter resposta string para objeto:",
                e
              );
              // Verificar se não é um erro de HTML
              if (
                typeof response === "string" &&
                (response.includes("<html") || response.includes("<!DOCTYPE"))
              ) {
                console.error("Recebeu HTML em vez de JSON");
              }
              // Se falhar, usar o método do servidor
              this.searchInServerSide(searchTerms);
              return;
            }
          }

          // ColdFusion retorna propriedades em MAIÚSCULAS, verificar ambas as versões
          const success = parsedResponse.success || parsedResponse.SUCCESS;
          const documents =
            parsedResponse.documents || parsedResponse.DOCUMENTS;

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
                  dateLastModified:
                    doc.dateLastModified || doc.DATELASTMODIFIED,
                };
              });

              this.processDocumentsWithPdfJs(
                normalizedDocuments,
                searchTerms,
                startTime
              );
            } else {
              console.warn("Nenhum documento PDF encontrado no diretório");
              this.searchInServerSide(searchTerms);
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
          this.searchInServerSide(searchTerms);
        },
      });
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

    $("#processingStatus").text(`Buscando em ${totalDocuments} documentos...`);

    // Função para processar um documento por vez
    const processNextDocument = (index) => {
      if (index >= documents.length) {
        // Finaliza quando todos os documentos forem processados
        const searchTime = ((performance.now() - startTime) / 1000).toFixed(2);
        this.displaySearchResults(searchTerms, searchTime);
        return;
      }

      const doc = documents[index];
      processedCount++;

      // NOVO: Se o ano do processo foi informado, verificar se o título do arquivo contém o ano.
      if (searchOptions.processYear) {
        // Captura os últimos 4 dígitos do segmento _PCxxxxxxxxYYYY_
        const m = doc.fileName.match(/_PC\d+(\d{4})_/);
        if (!m || m[1] !== searchOptions.processYear) {
          processNextDocument(index + 1); // Pula este arquivo
          return;
        }
      }

      // Atualizar barra de progresso
      const progress = Math.round((processedCount / totalDocuments) * 100);
      $("#processingProgress").css("width", `${progress}%`);
      $("#processingStatus").text(
        `Processando documento ${processedCount} de ${totalDocuments}: ${doc.fileName}`
      );

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
            let relevanceScore = 0;
            let snippets = [];

            // Aplicar estratégia de busca baseada no modo selecionado
            if (searchOptions && searchOptions.mode === "exact") {
              // Modo de frase exata

              // Normalizar texto para busca exata (remover espaços duplos, normalizar quebras de linha)
              const normalizedText = text
                .replace(/\s+/g, " ")
                .toLowerCase()
                .trim();

              // Normalizar a frase exata da mesma forma
              const exactPhrase = terms.join(" ").toLowerCase().trim();

              // Primeiro, tenta encontrar a frase exata
              if (normalizedText.includes(exactPhrase)) {
                found = true;
                relevanceScore = 10; // Alta pontuação para correspondência exata

                // Encontrar onde a frase aparece no texto original para criar snippet
                let snippetIndex = -1;

                // Buscar mais flexivelmente no texto original para localizar a posição
                const phraseWords = exactPhrase.split(/\s+/);
                const phrasePattern = phraseWords
                  .map((word) => this.escapeRegExp(word))
                  .join("[\\s\\n\\r]*");
                const flexRegex = new RegExp(
                  phrasePattern,
                  searchOptions.caseSensitive ? "g" : "gi"
                );

                const match = flexRegex.exec(text);
                if (match) {
                  snippetIndex = match.index;
                }

                if (snippetIndex >= 0) {
                  // Criar snippet com contexto ao redor da frase encontrada
                  const start = Math.max(0, snippetIndex - 80);
                  const end = Math.min(
                    text.length,
                    snippetIndex + exactPhrase.length + 120
                  );
                  let snippet = text.substring(start, end);

                  // Adicionar reticências se necessário
                  if (start > 0) snippet = "..." + snippet;
                  if (end < text.length) snippet += "...";

                  // Destacar termos agrupados na frase
                  phraseWords.forEach((word) => {
                    if (word.length >= 3) {
                      const wordRegex = new RegExp(
                        `(${this.escapeRegExp(word)})`,
                        "gi"
                      );
                      snippet = snippet.replace(wordRegex, "<mark>$1</mark>");
                    }
                  });

                  snippets.push(snippet);
                }
              } else {
                // Busca mais flexível para frase exata com tolerância a espaçamento
                const phraseWords = exactPhrase.split(/\s+/);

                // Verificar se todas as palavras da frase aparecem na mesma ordem e próximas
                if (phraseWords.length > 1) {
                  const phrasePattern = phraseWords
                    .map((word) => this.escapeRegExp(word))
                    .join("[\\s\\n\\r]{1,20}");
                  const flexRegex = new RegExp(
                    phrasePattern,
                    searchOptions.caseSensitive ? "g" : "gi"
                  );

                  const matches = text.match(flexRegex);

                  if (matches && matches.length > 0) {
                    found = true;
                    relevanceScore = 8; // Pontuação boa, mas menor que a correspondência perfeita

                    // Criar snippet com o primeiro match
                    const matchIndex = text.search(flexRegex);
                    if (matchIndex !== -1) {
                      const start = Math.max(0, matchIndex - 80);
                      const matchLength = matches[0].length;
                      const end = Math.min(
                        text.length,
                        matchIndex + matchLength + 120
                      );

                      let snippet = text.substring(start, end);

                      // Adicionar reticências se necessário
                      if (start > 0) snippet = "..." + snippet;
                      if (end < text.length) snippet += "...";

                      // Destacar termos na frase
                      phraseWords.forEach((word) => {
                        if (word.length >= 3) {
                          const wordRegex = new RegExp(
                            `(${this.escapeRegExp(word)})`,
                            "gi"
                          );
                          snippet = snippet.replace(
                            wordRegex,
                            "<mark>$1</mark>"
                          );
                        }
                      });

                      snippets.push(snippet);
                    }
                  }
                }
              }
            } else if (searchOptions && searchOptions.mode === "proximity") {
              // Modo de palavras próximas
              // Verificar se todos os termos ocorrem dentro de uma janela de proximidade
              const validTerms = terms.filter((t) => t.length >= 3);
              if (validTerms.length > 1) {
                // Primeiro verificamos se todos os termos existem no texto
                const allTermsPresent = validTerms.every((term) => {
                  const flags = searchOptions.caseSensitive ? "g" : "gi";
                  return new RegExp(this.escapeRegExp(term), flags).test(text);
                });

                if (allTermsPresent) {
                  // Dividir o texto em janelas para análise de proximidade
                  const words = text.split(/\s+/);
                  const distance = searchOptions.proximityDistance || 20;

                  // Verificar janelas de palavras
                  for (let i = 0; i < words.length; i++) {
                    const windowEnd = Math.min(i + distance, words.length);
                    const windowText = words.slice(i, windowEnd).join(" ");

                    // Verificar se todos os termos estão nesta janela
                    const allTermsInWindow = validTerms.every((term) => {
                      const flags = searchOptions.caseSensitive ? "g" : "gi";
                      return new RegExp(this.escapeRegExp(term), flags).test(
                        windowText
                      );
                    });

                    if (allTermsInWindow) {
                      found = true;
                      relevanceScore += 3; // Alta pontuação para termos próximos

                      // Criar snippet com esta janela
                      let snippet = windowText;
                      if (i > 0) snippet = "..." + snippet;
                      if (windowEnd < words.length) snippet += "...";

                      // Destacar todos os termos na janela
                      validTerms.forEach((term) => {
                        const flags = searchOptions.caseSensitive ? "g" : "gi";
                        const regex = new RegExp(
                          `(${this.escapeRegExp(term)})`,
                          flags
                        );
                        snippet = snippet.replace(regex, "<mark>$1</mark>");
                      });

                      snippets.push(snippet);
                      break; // Uma janela encontrada é suficiente para esta implementação básica
                    }
                  }
                }
              }
            } else {
              // Modo padrão (OR) - busca por qualquer termo
              terms.forEach((term) => {
                if (term.length >= 3) {
                  const flags = searchOptions.caseSensitive ? "g" : "gi";
                  const regex = new RegExp(this.escapeRegExp(term), flags);
                  const matches = text.match(regex);

                  if (matches && matches.length > 0) {
                    found = true;
                    relevanceScore += matches.length;

                    // Criar snippet com contexto
                    const firstIndex = searchOptions.caseSensitive
                      ? text.indexOf(term)
                      : text.toLowerCase().indexOf(term.toLowerCase());

                    if (firstIndex !== -1) {
                      const start = Math.max(0, firstIndex - 50);
                      const end = Math.min(
                        text.length,
                        firstIndex + term.length + 100
                      );
                      let snippet = text.substring(start, end);

                      // Adicionar reticências se necessário
                      if (start > 0) snippet = "..." + snippet;
                      if (end < text.length) snippet += "...";

                      // Destacar termo
                      snippet = this.highlightSearchTerm(snippet, term);
                      snippets.push(snippet);
                    }
                  }
                }
              });
            }

            // Se encontrou algum termo, adiciona aos resultados
            if (found) {
              // NOVO: se o usuário informou ano de processo, filtrar pelo ano extraído do nome do arquivo
              if (searchOptions.processYear) {
                // Tenta capturar os últimos 4 dígitos do segmento _PCxxxxxxxxYYYY_ no nome do arquivo
                const m = doc.fileName.match(/_PC\d+(\d{4})_/);
                if (!m || m[1] !== searchOptions.processYear) {
                  processNextDocument(index + 1);
                  return;
                }
              }
              this.currentSearchResults.push({
                fileName: doc.fileName,
                filePath: doc.filePath,
                fileUrl: fileUrl,
                directory: doc.directory || "Diretório FAQ",
                size: doc.size,
                dateLastModified: doc.dateLastModified,
                relevanceScore: relevanceScore,
                snippets: snippets,
                extractedText: text, // Armazenamos o texto extraído para usar depois
              });
            }

            // Processar o próximo documento
            processNextDocument(index + 1);
          })
          .catch((error) => {
            console.error(
              `Erro ao processar o documento ${doc.fileName}:`,
              error
            );
            // Continua processando os outros documentos mesmo se um falhar
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
                const contextSize = 150;
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

                    // Adicionar reticências se necessário
                    if (start > 0) snippet = "..." + snippet;
                    if (end < result.text.length) snippet += "...";

                    // Destacar termo
                    snippet = this.highlightSearchTerm(snippet, term);
                    snippets.push(snippet);
                    count++;

                    // Evitar loop infinito
                    if (lastIndex === regex.lastIndex) break;
                    lastIndex = regex.lastIndex;
                  }
                });
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

            this.displaySearchResults(searchTerms, response.searchTime);
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
  displaySearchResults: function (searchTerms, searchTime) {
    $("#searchLoading").hide();

    // Se não há resultados
    if (this.currentSearchResults.length === 0) {
      $("#noResultsAlert").show();
      $("#searchStats").text(
        `0 resultados encontrados em ${searchTime} segundos`
      );
      return;
    }

    // Construir HTML dos resultados
    const termsList = searchTerms.split(" ").filter((term) => term.length >= 3);
    let resultsHtml = "";

    this.currentSearchResults.forEach((result, index) => {
      const relevancePercent = Math.min(
        100,
        Math.round((result.relevanceScore / 10) * 100)
      );
      const badgeClass = this.getRelevanceBadgeClass(relevancePercent);

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
      const highlightedText = termsList.reduce((text, term) => {
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
            <span class="badge badge-${badgeClass}">${relevancePercent}% relevante</span>
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
              <div class="card-body extracted-text-content p-3" style="max-height: 300px; overflow-y: auto;">
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

    // Exibir resultados e estatísticas
    $("#searchResults").html(resultsHtml);
    $("#searchStats").text(
      `${this.currentSearchResults.length} resultado${
        this.currentSearchResults.length !== 1 ? "s" : ""
      } encontrado${
        this.currentSearchResults.length !== 1 ? "s" : ""
      } em ${searchTime} segundos`
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

  // Retorna a classe CSS para o badge de relevância
  getRelevanceBadgeClass: function (relevancePercent) {
    if (relevancePercent >= 80) return "success";
    if (relevancePercent >= 50) return "primary";
    if (relevancePercent >= 30) return "info";
    return "secondary";
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
    // Implementação básica para navegação entre ocorrências destacadas
    // Em uma implementação real, isso percorreria as ocorrências no PDF
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
    // Não precisamos configurar o worker aqui novamente, já foi feito no HTML
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

  // Inicializar o gerenciador
  PdfSearchManager.init();
});
