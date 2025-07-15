/**
 * Capabilities Comparison Tool
 * 
 * Este script compara a planilha LLM-Capabilities (gerada por search_llm_capabilities.gs)
 * com a planilha IDE-Capabilities para identificar discrepâncias no status das capabilities.
 */

// Configuração - constantes renomeadas para evitar conflitos com outros scripts
const COMPARE_CONFIG = {
  SOURCE_SHEET_NAME: "LLM-Capabilities",
  TARGET_SHEET_NAME: "IDE-Capabilities",
  REPORT_SHEET_NAME: "Comparison-Report",
  STATUS: {
    ENABLE: "Enable",
    DISABLE: "Disable"
  },
  COLORS: {
    TITLE_BG: "#000000",
    TITLE_TEXT: "#FFFFFF",
    HEADER_BG: "#D3D3D3",
    ERROR_BG: "#FFCCCB",
    SUCCESS_BG: "#90EE90",
    ENABLE_BG: "#90EE90",
    DISABLE_BG: "#FFCCCB",
    LIGHT_ERROR: "#FFE6E6",
    ALTERNATE_ROW: "#F8F8F8"
  },
  REPORT: {
    COLUMNS: 8,
    COLUMN_WIDTHS: [150, 120, 200, 150, 150, 150, 250, 250]
  }
};

/**
 * Cria menu personalizado quando a planilha é aberta
 */
function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Comparar Planilhas')
    .addItem('Comparar Status de Capabilities', 'compareCapabilities')
    .addToUi();
}

/**
 * Função principal para comparar capabilities entre planilhas
 */
function compareCapabilities() {
  try {
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    
    // Obter planilhas fonte e alvo
    const sourceSheet = spreadsheet.getSheetByName(COMPARE_CONFIG.SOURCE_SHEET_NAME);
    const targetSheet = spreadsheet.getSheetByName(COMPARE_CONFIG.TARGET_SHEET_NAME);
    
    // Validar existência das planilhas
    if (!sourceSheet) {
      throw new Error(`Planilha "${COMPARE_CONFIG.SOURCE_SHEET_NAME}" não encontrada. Execute o script search_llm_capabilities.gs primeiro.`);
    }
    
    if (!targetSheet) {
      throw new Error(`Planilha "${COMPARE_CONFIG.TARGET_SHEET_NAME}" não encontrada.`);
    }
    
    // Criar ou limpar planilha de relatório
    const reportSheet = _prepareReportSheet(spreadsheet);
    
    // Obter dados de ambas as planilhas incluindo formatação
    const sourceData = _getSheetDataWithFormatting(sourceSheet);
    const targetData = _getSheetDataWithFormatting(targetSheet);
    
    // Comparar dados e gerar relatório
    const discrepancies = _compareData(sourceData, targetData);
    
    // Exibir relatório
    _displayReport(reportSheet, discrepancies, sourceData.headers);
    
    // Mostrar mensagem de conclusão
    const message = discrepancies.length > 0 
      ? `Comparação concluída. Foram encontradas ${discrepancies.length} divergências de status.` 
      : "Comparação concluída. Nenhuma divergência de status encontrada!";
    
    SpreadsheetApp.getUi().alert("Resultado da Comparação", message, SpreadsheetApp.getUi().ButtonSet.OK);
    
  } catch (error) {
    SpreadsheetApp.getUi().alert("Erro: " + error.message);
  }
}

// =============================================================================
// Funções Auxiliares Privadas
// =============================================================================

/**
 * Prepara a planilha de relatório
 * @param {Object} spreadsheet - Objeto da planilha
 * @return {Object} Objeto da planilha de relatório
 * @private
 */
function _prepareReportSheet(spreadsheet) {
  let reportSheet = spreadsheet.getSheetByName(COMPARE_CONFIG.REPORT_SHEET_NAME);
  
  if (reportSheet) {
    reportSheet.clear();
  } else {
    reportSheet = spreadsheet.insertSheet(COMPARE_CONFIG.REPORT_SHEET_NAME);
  }
  
  return reportSheet;
}

/**
 * Obtém dados de uma planilha incluindo cabeçalhos, linhas e cores de fundo
 * @param {Object} sheet - Objeto da planilha
 * @return {Object} Objeto contendo título, cabeçalhos, linhas e cores de fundo
 * @private
 */
function _getSheetDataWithFormatting(sheet) {
  const lastRow = sheet.getLastRow();
  const lastColumn = sheet.getLastColumn();
  
  // Obter título da linha 1
  const title = sheet.getRange(1, 1, 1, lastColumn).getValues()[0][0];
  
  // Obter cabeçalhos da linha 2
  const headers = sheet.getRange(2, 1, 1, lastColumn).getValues()[0];
  
  // Obter linhas de dados (a partir da linha 3)
  const dataRange = sheet.getRange(3, 1, lastRow - 2, lastColumn);
  
  return {
    title: title,
    headers: headers,
    rows: dataRange.getValues(),
    backgrounds: dataRange.getBackgrounds()
  };
}

/**
 * Compara dados entre planilhas fonte e alvo
 * @param {Object} sourceData - Dados da planilha fonte
 * @param {Object} targetData - Dados da planilha alvo
 * @return {Array} Array de discrepâncias
 * @private
 */
function _compareData(sourceData, targetData) {
  const discrepancies = [];
  
  // Verificar se os cabeçalhos correspondem
  if (!_arraysEqual(sourceData.headers, targetData.headers)) {
    discrepancies.push({
      type: "header",
      message: "Os cabeçalhos das planilhas não correspondem",
      sourceHeaders: sourceData.headers,
      targetHeaders: targetData.headers
    });
    return discrepancies; // Interromper comparação se os cabeçalhos não corresponderem
  }
  
  // Criar mapas de pesquisa para comparação mais rápida
  const sourceMap = _createLookupMap(sourceData.rows, sourceData.backgrounds);
  const targetMap = _createLookupMap(targetData.rows, targetData.backgrounds);
  
  // Comparar fonte com alvo
  _findDiscrepancies(sourceData, targetData, sourceMap, targetMap, discrepancies);
  
  return discrepancies;
}

/**
 * Cria um mapa de pesquisa para acesso mais rápido aos dados
 * @param {Array} rows - Linhas de dados
 * @param {Array} backgrounds - Cores de fundo das células
 * @return {Object} Mapa de pesquisa
 * @private
 */
function _createLookupMap(rows, backgrounds) {
  return rows.reduce((map, row, rowIndex) => {
    const provider = row[0];
    const model = row[1];
    const key = `${provider}|${model}`;
    
    map[key] = {
      rowIndex: rowIndex,
      data: row,
      backgrounds: backgrounds ? backgrounds[rowIndex] : null
    };
    
    return map;
  }, {});
}

/**
 * Encontra discrepâncias entre os dados fonte e alvo
 * @param {Object} sourceData - Dados da planilha fonte
 * @param {Object} targetData - Dados da planilha alvo
 * @param {Object} sourceMap - Mapa de pesquisa da fonte
 * @param {Object} targetMap - Mapa de pesquisa do alvo
 * @param {Array} discrepancies - Array para armazenar discrepâncias
 * @private
 */
function _findDiscrepancies(sourceData, targetData, sourceMap, targetMap, discrepancies) {
  // Verificar modelos na fonte que estão ausentes no alvo ou têm status diferentes
  sourceData.rows.forEach((sourceRow, sourceRowIndex) => {
    const provider = sourceRow[0];
    const model = sourceRow[1];
    const key = `${provider}|${model}`;
    
    if (targetMap[key]) {
      // Modelo existe em ambas as planilhas, comparar status das capabilities
      _compareCapabilityStatus(
        sourceData, 
        sourceRow, 
        sourceRowIndex, 
        targetMap[key], 
        key, 
        discrepancies
      );
    } else {
      // Modelo existe na fonte mas não no alvo
      discrepancies.push({
        type: "missing_model",
        provider: provider,
        model: model,
        location: "target",
        rowIndex: sourceRowIndex + 3
      });
    }
  });
  
  // Verificar modelos no alvo que estão ausentes na fonte
  targetData.rows.forEach((targetRow, targetRowIndex) => {
    const provider = targetRow[0];
    const model = targetRow[1];
    const key = `${provider}|${model}`;
    
    if (!sourceMap[key]) {
      // Modelo existe no alvo mas não na fonte
      discrepancies.push({
        type: "missing_model",
        provider: provider,
        model: model,
        location: "source",
        rowIndex: targetRowIndex + 3
      });
    }
  });
}

/**
 * Compara o status das capabilities entre um modelo na fonte e no alvo
 * @param {Object} sourceData - Dados da planilha fonte
 * @param {Array} sourceRow - Linha de dados da fonte
 * @param {Number} sourceRowIndex - Índice da linha na fonte
 * @param {Object} targetEntry - Entrada do modelo no mapa do alvo
 * @param {String} key - Chave do modelo (provider|model)
 * @param {Array} discrepancies - Array para armazenar discrepâncias
 * @private
 */
function _compareCapabilityStatus(sourceData, sourceRow, sourceRowIndex, targetEntry, key, discrepancies) {
  const [provider, model] = key.split('|');
  const targetRow = targetEntry.data;
  const sourceBackgrounds = sourceData.backgrounds[sourceRowIndex];
  const targetBackgrounds = targetEntry.backgrounds;
  
  // Comparar cada capability (começando da coluna 2, após provider e model)
  for (let colIndex = 2; colIndex < sourceRow.length; colIndex++) {
    const sourceStatus = sourceRow[colIndex];
    const targetStatus = targetRow[colIndex];
    
    // Comparar valores de status (Enable/Disable)
    if (sourceStatus !== targetStatus) {
      discrepancies.push({
        type: "status",
        provider: provider,
        model: model,
        capability: sourceData.headers[colIndex],
        sourceStatus: sourceStatus,
        targetStatus: targetStatus,
        sourceRowIndex: sourceRowIndex + 3, // +3 porque os dados começam na linha 3
        targetRowIndex: targetEntry.rowIndex + 3,
        columnIndex: colIndex + 1, // +1 porque arrays são indexados em 0
        sourceBackground: sourceBackgrounds[colIndex],
        targetBackground: targetBackgrounds[colIndex]
      });
    }
  }
}

/**
 * Exibe o relatório de comparação
 * @param {Object} reportSheet - Objeto da planilha de relatório
 * @param {Array} discrepancies - Array de discrepâncias
 * @param {Array} headers - Cabeçalhos da planilha fonte
 * @private
 */
function _displayReport(reportSheet, discrepancies, headers) {
  // Adicionar título
  _addReportTitle(reportSheet);
  
  if (discrepancies.length === 0) {
    // Nenhuma discrepância encontrada
    _addNoDiscrepanciesMessage(reportSheet);
    return;
  }
  
  // Adicionar resumo
  _addSummary(reportSheet, discrepancies);
  
  // Adicionar cabeçalhos do relatório
  _addReportHeaders(reportSheet);
  
  // Adicionar discrepâncias
  _addDiscrepancies(reportSheet, discrepancies);
  
  // Formatar relatório
  _formatReport(reportSheet);
}

/**
 * Adiciona título ao relatório
 * @param {Object} sheet - Objeto da planilha de relatório
 * @private
 */
function _addReportTitle(sheet) {
  sheet.appendRow(['']);
  const titleRange = sheet.getRange(1, 1, 1, COMPARE_CONFIG.REPORT.COLUMNS);
  titleRange.merge()
    .setValue("RELATÓRIO DE COMPARAÇÃO DE STATUS DE CAPABILITIES")
    .setFontWeight("bold")
    .setBackground(COMPARE_CONFIG.COLORS.TITLE_BG)
    .setFontColor(COMPARE_CONFIG.COLORS.TITLE_TEXT)
    .setHorizontalAlignment("center")
    .setVerticalAlignment("middle");
  
  sheet.setRowHeight(1, 30);
}

/**
 * Adiciona resumo das discrepâncias
 * @param {Object} sheet - Objeto da planilha de relatório
 * @param {Array} discrepancies - Array de discrepâncias
 * @private
 */
function _addSummary(sheet, discrepancies) {
  // Contar discrepâncias por tipo
  const counts = discrepancies.reduce((acc, d) => {
    acc[d.type] = (acc[d.type] || 0) + 1;
    return acc;
  }, {});
  
  // Adicionar linha de resumo
  sheet.appendRow(['']);
  const summaryRange = sheet.getRange(2, 1, 1, COMPARE_CONFIG.REPORT.COLUMNS);
  summaryRange.merge();
  
  let summaryText = `RESUMO: Encontradas ${discrepancies.length} divergências no total.`;
  if (counts.status) summaryText += ` ${counts.status} divergências de status.`;
  if (counts.missing_model) summaryText += ` ${counts.missing_model} modelos ausentes.`;
  if (counts.header) summaryText += " Problema nos cabeçalhos das planilhas.";
  
  summaryRange.setValue(summaryText)
    .setFontWeight("bold")
    .setBackground("#FFD700") // Amarelo para destaque
    .setHorizontalAlignment("center")
    .setVerticalAlignment("middle");
  
  sheet.setRowHeight(2, 30);
}

/**
 * Adiciona mensagem quando nenhuma discrepância é encontrada
 * @param {Object} sheet - Objeto da planilha de relatório
 * @private
 */
function _addNoDiscrepanciesMessage(sheet) {
  sheet.appendRow(['']);
  const messageRange = sheet.getRange(2, 1, 1, COMPARE_CONFIG.REPORT.COLUMNS);
  messageRange.merge()
    .setValue("Nenhuma divergência de status encontrada. Os status das capabilities são idênticos em ambas as planilhas.")
    .setFontWeight("bold")
    .setBackground(COMPARE_CONFIG.COLORS.SUCCESS_BG)
    .setHorizontalAlignment("center")
    .setVerticalAlignment("middle");
  
  sheet.setRowHeight(2, 30);
}

/**
 * Adiciona cabeçalhos do relatório
 * @param {Object} sheet - Objeto da planilha de relatório
 * @private
 */
function _addReportHeaders(sheet) {
  const headers = [
    'Tipo de Divergência',
    'Provider',
    'Modelo',
    'Capability',
    'Status em LLM-Capabilities',
    'Status em IDE-Capabilities',
    'Localização',
    'Ação Recomendada'
  ];
  
  sheet.appendRow(['']);
  sheet.appendRow(headers);
  
  sheet.getRange(4, 1, 1, headers.length)
    .setFontWeight("bold")
    .setBackground(COMPARE_CONFIG.COLORS.HEADER_BG)
    .setHorizontalAlignment("center")
    .setVerticalAlignment("middle");
}

/**
 * Adiciona discrepâncias ao relatório
 * @param {Object} sheet - Objeto da planilha de relatório
 * @param {Array} discrepancies - Array de discrepâncias
 * @private
 */
function _addDiscrepancies(sheet, discrepancies) {
  discrepancies.forEach(discrepancy => {
    let row = [];
    
    if (discrepancy.type === "header") {
      row = [
        "Cabeçalhos Diferentes",
        "-",
        "-",
        "-",
        "-",
        "-",
        "-",
        "Verificar e alinhar os cabeçalhos das planilhas"
      ];
    } else if (discrepancy.type === "missing_model") {
      const location = discrepancy.location === "source" 
        ? `Modelo existe apenas em ${COMPARE_CONFIG.TARGET_SHEET_NAME} (linha ${discrepancy.rowIndex})` 
        : `Modelo existe apenas em ${COMPARE_CONFIG.SOURCE_SHEET_NAME} (linha ${discrepancy.rowIndex})`;
      
      const action = discrepancy.location === "source"
        ? `Adicionar modelo ao ${COMPARE_CONFIG.SOURCE_SHEET_NAME}`
        : `Adicionar modelo ao ${COMPARE_CONFIG.TARGET_SHEET_NAME}`;
      
      row = [
        "Modelo Ausente",
        discrepancy.provider,
        discrepancy.model,
        "-",
        "-",
        "-",
        location,
        action
      ];
    } else if (discrepancy.type === "status") {
      const location = `${COMPARE_CONFIG.SOURCE_SHEET_NAME} (${_columnToLetter(discrepancy.columnIndex)}${discrepancy.sourceRowIndex}) vs ${COMPARE_CONFIG.TARGET_SHEET_NAME} (${_columnToLetter(discrepancy.columnIndex)}${discrepancy.targetRowIndex})`;
      
      const action = `Alinhar o status de ${discrepancy.capability} para o modelo ${discrepancy.model}`;
      
      row = [
        "Status Divergente",
        discrepancy.provider,
        discrepancy.model,
        discrepancy.capability,
        discrepancy.sourceStatus,
        discrepancy.targetStatus,
        location,
        action
      ];
    }
    
    sheet.appendRow(row);
    
    // Colorir células de status para discrepâncias de status
    if (discrepancy.type === "status") {
      const currentRow = sheet.getLastRow();
      
      // Colorir célula do status na planilha fonte
      const sourceStatusCell = sheet.getRange(currentRow, 5);
      if (discrepancy.sourceStatus === COMPARE_CONFIG.STATUS.ENABLE) {
        sourceStatusCell.setBackground(COMPARE_CONFIG.COLORS.ENABLE_BG);
      } else if (discrepancy.sourceStatus === COMPARE_CONFIG.STATUS.DISABLE) {
        sourceStatusCell.setBackground(COMPARE_CONFIG.COLORS.DISABLE_BG);
      }
      
      // Colorir célula do status na planilha alvo
      const targetStatusCell = sheet.getRange(currentRow, 6);
      if (discrepancy.targetStatus === COMPARE_CONFIG.STATUS.ENABLE) {
        targetStatusCell.setBackground(COMPARE_CONFIG.COLORS.ENABLE_BG);
      } else if (discrepancy.targetStatus === COMPARE_CONFIG.STATUS.DISABLE) {
        targetStatusCell.setBackground(COMPARE_CONFIG.COLORS.DISABLE_BG);
      }
    }
  });
}

/**
 * Formata o relatório para melhor legibilidade
 * @param {Object} sheet - Objeto da planilha de relatório
 * @private
 */
function _formatReport(sheet) {
  const lastRow = sheet.getLastRow();
  
  // Definir larguras das colunas
  COMPARE_CONFIG.REPORT.COLUMN_WIDTHS.forEach((width, index) => {
    sheet.setColumnWidth(index + 1, width);
  });
  
  // Aplicar bordas
  sheet.getRange(4, 1, lastRow - 3, COMPARE_CONFIG.REPORT.COLUMNS)
    .setBorder(true, true, true, true, true, true);
  
  // Definir cor de fundo clara para linhas de dados
  if (lastRow > 4) {
    sheet.getRange(5, 1, lastRow - 4, COMPARE_CONFIG.REPORT.COLUMNS)
      .setBackground(COMPARE_CONFIG.COLORS.LIGHT_ERROR);
  }
  
  // Alinhar todas as células ao centro
  sheet.getRange(1, 1, lastRow, COMPARE_CONFIG.REPORT.COLUMNS)
    .setHorizontalAlignment("center")
    .setVerticalAlignment("middle");
  
  // Alinhar texto à esquerda na coluna de ação
  if (lastRow > 4) {
    sheet.getRange(5, 8, lastRow - 4, 1)
      .setHorizontalAlignment("left");
  }
  
  // Habilitar quebra de texto
  sheet.getRange(4, 1, lastRow - 3, COMPARE_CONFIG.REPORT.COLUMNS)
    .setWrap(true);
  
  // Adicionar cores alternadas para melhor legibilidade
  for (let i = 5; i <= lastRow; i += 2) {
    if (i <= lastRow) {
      // Pular coloração das células de status (colunas 5 e 6)
      sheet.getRange(i, 1, 1, 4).setBackground(COMPARE_CONFIG.COLORS.ALTERNATE_ROW);
      sheet.getRange(i, 7, 1, 2).setBackground(COMPARE_CONFIG.COLORS.ALTERNATE_ROW);
    }
  }
}

/**
 * Converte índice de coluna para letra (ex: 1 -> A, 2 -> B)
 * @param {number} column - Índice da coluna
 * @return {string} Letra da coluna
 * @private
 */
function _columnToLetter(column) {
  let temp, letter = '';
  while (column > 0) {
    temp = (column - 1) % 26;
    letter = String.fromCharCode(temp + 65) + letter;
    column = (column - temp - 1) / 26;
  }
  return letter;
}

/**
 * Verifica se dois arrays são iguais
 * @param {Array} arr1 - Primeiro array
 * @param {Array} arr2 - Segundo array
 * @return {boolean} Verdadeiro se os arrays forem iguais
 * @private
 */
function _arraysEqual(arr1, arr2) {
  if (arr1.length !== arr2.length) return false;
  
  for (let i = 0; i < arr1.length; i++) {
    if (arr1[i] !== arr2[i]) return false;
  }
  
  return true;
}