// Web Worker para processamento paralelo de PDFs
// Este worker recebe lotes de documentos para processar e retorna os resultados

// Importar PDF.js para o worker
importScripts("../../../plugins/pdf.js/pdf.min.js");

// Configurar o worker do PDF.js
pdfjsLib.GlobalWorkerOptions.workerSrc =
  "../../../plugins/pdf.js/pdf.worker.min.js";

// Variáveis de controle
let searchCanceled = false;
let currentSearchTerms = "";
let currentSearchOptions = {};
let currentBatchSize = 3;
let processedCount = 0;
let documentsWithMatches = 0;
let totalDocuments = 0;
let documentsRead = 0;

// Iniciar o processamento quando receber uma mensagem
self.onmessage = function (event) {
  const message = event.data;

  switch (message.action) {
    case "start-search":
      startSearch(
        message.documents,
        message.searchTerms,
        message.searchOptions,
        message.batchSize
      );
      break;
    case "cancel-search":
      searchCanceled = true;
      self.postMessage({ action: "canceled" });
      break;
    case "process-batch":
      processBatch(message.batch);
      break;
  }
};

// Iniciar a busca
function startSearch(documents, searchTerms, searchOptions, batchSize) {
  // Reiniciar variáveis
  searchCanceled = false;
  currentSearchTerms = searchTerms;
  currentSearchOptions = searchOptions;
  currentBatchSize = batchSize || 3;
  processedCount = 0;
  documentsWithMatches = 0;
  totalDocuments = documents.length;
  documentsRead = 0;

  // Ordenar documentos (menores primeiro) para processamento mais eficiente
  const sortedDocuments = [...documents].sort((a, b) => a.size - b.size);

  // Informar que o processamento começou
  self.postMessage({
    action: "progress",
    progress: {
      processed: 0,
      total: totalDocuments,
      read: 0,
      found: 0,
    },
  });

  // Processar documentos em lotes
  processDocumentsInBatches(sortedDocuments);
}

// Processar documentos em lotes
function processDocumentsInBatches(documents) {
  if (searchCanceled) {
    return finishSearch();
  }

  if (documents.length === 0) {
    return finishSearch();
  }

  // Obter o próximo lote
  const batch = documents.splice(0, currentBatchSize);

  // Processar o lote
  const batchPromises = batch.map(processDocument);

  Promise.all(batchPromises)
    .then(() => {
      // Enviar estatísticas do lote atual
      self.postMessage({
        action: "batch-complete",
        stats: {
          processed: processedCount,
          total: totalDocuments,
          read: documentsRead,
          found: documentsWithMatches,
        },
      });

      // Continuar com o próximo lote após um pequeno delay
      setTimeout(() => processDocumentsInBatches(documents), 10);
    })
    .catch((error) => {
      console.error("Erro ao processar lote:", error);
      // Continuar com o próximo lote mesmo com erro
      setTimeout(() => processDocumentsInBatches(documents), 10);
    });
}

// Processar um único documento
async function processDocument(doc) {
  if (searchCanceled) {
    return;
  }

  // Incrementar contador
  processedCount++;

  // Enviar atualização de progresso
  if (processedCount % 2 === 0 || processedCount === 1) {
    self.postMessage({
      action: "progress",
      progress: {
        processed: processedCount,
        total: totalDocuments,
        read: documentsRead,
        found: documentsWithMatches,
      },
    });
  }

  try {
    // Aplicar filtros primeiro (ano e título)
    if (!passesFilters(doc)) {
      return { passed: false }; // Não processa este documento
    }

    // Incrementar contador de documentos lidos
    documentsRead++;

    // Criar URL para carregar o documento
    const fileUrl = `../../../cfc/pc_cfcBuscaPDF_cliente.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
      doc.filePath
    )}&nome=${encodeURIComponent(doc.fileName)}`;

    // Carregar o PDF usando PDF.js
    const pdfDoc = await pdfjsLib.getDocument({ url: fileUrl }).promise;
    const numPages = pdfDoc.numPages;
    const textPromises = [];

    // Extrair texto de todas as páginas
    for (let i = 1; i <= numPages; i++) {
      const page = await pdfDoc.getPage(i);
      const content = await page.getTextContent({ normalizeWhitespace: true });
      textPromises.push(processTextContent(content));
    }

    // Combinar texto de todas as páginas
    const pageTexts = await Promise.all(textPromises);
    const text = pageTexts.join("\n");

    // Buscar termos no texto
    const searchResult = searchTextForTerms(
      text,
      currentSearchTerms,
      currentSearchOptions
    );

    if (searchResult.found) {
      // Incrementar contador
      documentsWithMatches++;

      // Criar objeto de resultado (sem armazenar o texto completo para economizar memória)
      const resultObj = {
        fileName: doc.fileName,
        filePath: doc.filePath,
        fileUrl: fileUrl,
        directory: doc.directory || "Diretório FAQ",
        displayPath: doc.displayPath || "",
        size: doc.size,
        pageCount: numPages,
        dateLastModified: doc.dateLastModified,
        snippets: searchResult.snippets,
        found: true,
        passedFilters: true,
      };

      // Enviar resultado para o script principal
      self.postMessage({
        action: "result",
        result: resultObj,
      });
    }

    return { passed: true };
  } catch (error) {
    console.error(`Erro ao processar PDF ${doc.fileName}:`, error);
    return { passed: false, error: error.message };
  }
}

// Verificar se o documento passa nos filtros
function passesFilters(doc) {
  // Filtrar por ano do processo, se informado
  if (currentSearchOptions && currentSearchOptions.processYear) {
    const yearMatch = doc.fileName.match(/_PC\d+(\d{4})_/);
    if (!yearMatch || yearMatch[1] !== currentSearchOptions.processYear) {
      return false;
    }
  }

  // Filtrar por texto no título, se informado
  if (
    currentSearchOptions &&
    currentSearchOptions.titleSearch &&
    currentSearchOptions.titleSearch.trim() !== ""
  ) {
    if (
      doc.fileName
        .toLowerCase()
        .indexOf(currentSearchOptions.titleSearch.toLowerCase()) === -1
    ) {
      return false;
    }
  }

  return true;
}

// Processar conteúdo de texto do PDF considerando posições
function processTextContent(textContent) {
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
    // Tolerância para considerar itens na mesma linha
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

      if (item.x - (lastItem.x + lastItem.width) > expectedSpaceWidth * 0.5) {
        text += " ";
      }
    }

    text += item.str;
    lastY = item.y;
  });

  // Normalizar espaços
  return text
    .split("\n")
    .map((line) => line.trim())
    .join("\n")
    .replace(/\s+/g, " ")
    .trim();
}

// Buscar termos no texto
function searchTextForTerms(text, searchTerms, options) {
  const result = {
    found: false,
    snippets: [],
  };

  if (!text || !searchTerms) return result;

  // Verificar modo de busca e executar lógica correspondente
  if (options.mode === "exact") {
    // Modo de frase exata
    const phrase = searchTerms.trim();
    if (phrase.length >= 3) {
      const regex = new RegExp(escapeRegExp(phrase), "gi");
      const matches = text.match(regex);

      if (matches && matches.length > 0) {
        result.found = true;

        // Criar snippet com contexto
        const firstIndex = text.toLowerCase().indexOf(phrase.toLowerCase());
        if (firstIndex !== -1) {
          const start = Math.max(0, firstIndex - 150);
          const end = Math.min(text.length, firstIndex + phrase.length + 150);
          let snippet = text.substring(start, end);

          if (start > 0) snippet = "..." + snippet;
          if (end < text.length) snippet += "...";

          snippet = highlightSearchPhrase(snippet, phrase);
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
        const start = Math.max(0, firstIndex - 150);
        const end = Math.min(text.length, firstIndex + 300);
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
      const regex = new RegExp(escapeRegExp(term), "gi");
      const matches = text.match(regex);

      if (matches && matches.length > 0) {
        result.found = true;

        // Adicionar snippet se ainda não temos muitos
        if (result.snippets.length < 2) {
          // Reduzido para 2 para economizar memória
          const firstIndex = text.toLowerCase().indexOf(term.toLowerCase());

          if (firstIndex !== -1) {
            const start = Math.max(0, firstIndex - 150);
            const end = Math.min(text.length, firstIndex + term.length + 150);
            let snippet = text.substring(start, end);

            if (start > 0) snippet = "..." + snippet;
            if (end < text.length) snippet += "...";

            snippet = highlightSearchTerm(snippet, term);
            result.snippets.push(snippet);
          }
        }
      }
    });
  }

  return result;
}

// Finalizar a busca
function finishSearch() {
  self.postMessage({
    action: "search-complete",
    stats: {
      processed: processedCount,
      total: totalDocuments,
      read: documentsRead,
      found: documentsWithMatches,
    },
  });
}

// Destacar termo em um texto
function highlightSearchTerm(text, term) {
  if (!text || !term) return text;
  try {
    // Escapa caracteres especiais para uso em regex
    const escapedTerm = escapeRegExp(term);
    const regex = new RegExp(`(${escapedTerm})`, "gi");
    return text.replace(regex, "<mark>$1</mark>");
  } catch (e) {
    console.error("Erro ao destacar termos:", e);
    return text;
  }
}

// Destacar frase exata
function highlightSearchPhrase(text, phrase) {
  if (!text || !phrase) return text;
  try {
    // Escapa caracteres especiais para uso em regex
    const escapedPhrase = escapeRegExp(phrase);
    const regex = new RegExp(`(${escapedPhrase})`, "gi");
    return text.replace(regex, "<mark>$1</mark>");
  } catch (e) {
    console.error("Erro ao destacar frase:", e);
    return text;
  }
}

// Destacar todas as palavras
function highlightAllSearchTerms(text, terms) {
  if (!text || !terms || !terms.length) return text;

  let highlightedText = text;
  terms.forEach((term) => {
    if (term.length >= 3) {
      const regex = new RegExp(`(${escapeRegExp(term)})`, "gi");
      highlightedText = highlightedText.replace(regex, "<mark>$1</mark>");
    }
  });
  return highlightedText;
}

// Escapar caracteres especiais em expressões regulares
function escapeRegExp(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

// Verificar proximidade entre palavras
function checkProximity(text, words, proximity) {
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
}
