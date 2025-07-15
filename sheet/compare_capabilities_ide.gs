/**
 * Capabilities Comparison Tool - Versão Otimizada
 * 
 * Este script compara as planilhas LLM-Capabilities e IDE-Capabilities
 * campo a campo para identificar divergências de status.
 */

// Configuração
const CONFIG = {
  SOURCE_SHEET: "LLM-Capabilities",
  TARGET_SHEET: "IDE-Capabilities",
  REPORT_SHEET: "Comparison-Report",
  COLORS: {
    ENABLE: "#90EE90",  // Verde
    DISABLE: "#FFCCCB", // Vermelho
    HEADER: "#D3D3D3",  // Cinza
    TITLE: "#000000"    // Preto
  }
};

/**
 * Cria menu personalizado quando a planilha é aberta
 */
function onOpen() {
  SpreadsheetApp.getActiveSpreadsheet()
    .addMenu('Comparar Planilhas', [
      {name: 'Comparar Status de Capabilities', functionName: 'compareCapabilities'}
    ]);
}

/**
 * Função principal para comparar capabilities entre planilhas
 */
function compareCapabilities() {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    
    // Obter planilhas
    const sourceSheet = ss.getSheetByName(CONFIG.SOURCE_SHEET);
    const targetSheet = ss.getSheetByName(CONFIG.TARGET_SHEET);
    
    // Validar existência das planilhas
    if (!sourceSheet) throw new Error(`Planilha "${CONFIG.SOURCE_SHEET}" não encontrada.`);
    if (!targetSheet) throw new Error(`Planilha "${CONFIG.TARGET_SHEET}" não encontrada.`);
    
    // Preparar planilha de relatório
    const reportSheet = prepareReportSheet(ss);
    
    // Iniciar relatório
    reportSheet.getRange("A1:H1").merge()
      .setValue("RELATÓRIO DE COMPARAÇÃO DE STATUS DE CAPABILITIES")
      .setBackground(CONFIG.COLORS.TITLE)
      .setFontColor("white")
      .setFontWeight("bold")
      .setHorizontalAlignment("center");
    
    // Obter dados das planilhas (apenas uma vez para melhorar performance)
    const sourceData = getSheetData(sourceSheet);
    const targetData = getSheetData(targetSheet);
    
    // Verificar se os cabeçalhos são iguais
    if (!arraysEqual(sourceData.headers, targetData.headers)) {
      reportSheet.getRange("A2:H2").merge()
        .setValue("ERRO: Os cabeçalhos das planilhas não correspondem. Verifique se as colunas são idênticas.")
        .setBackground("#FF0000")
        .setFontColor("white")
        .setFontWeight("bold");
      return;
    }
    
    // Comparar dados e gerar relatório
    const discrepancies = compareSheetData(sourceData, targetData);
    
    // Exibir resultados
    if (discrepancies.length === 0) {
      reportSheet.getRange("A2:H2").merge()
        .setValue("Nenhuma divergência encontrada. Os status são idênticos em ambas as planilhas.")
        .setBackground(CONFIG.COLORS.ENABLE)
        .setFontWeight("bold");
    } else {
      // Adicionar cabeçalhos do relatório
      const headers = [
        'Tipo', 'Provider', 'Modelo', 'Capability', 
        'Status em ' + CONFIG.SOURCE_SHEET, 
        'Status em ' + CONFIG.TARGET_SHEET, 
        'Localização', 'Ação Recomendada'
      ];
      
      reportSheet.getRange(2, 1, 1, headers.length).setValues([headers])
        .setBackground(CONFIG.COLORS.HEADER)
        .setFontWeight("bold")
        .setHorizontalAlignment("center");
      
      // Adicionar dados de discrepâncias
      const reportData = discrepancies.map(d => [
        "Status Divergente",
        d.provider,
        d.model,
        d.capability,
        d.sourceValue,
        d.targetValue,
        `${CONFIG.SOURCE_SHEET} (${d.sourceCell}) vs ${CONFIG.TARGET_SHEET} (${d.targetCell})`,
        `Alinhar o status de ${d.capability} para o modelo ${d.model}`
      ]);
      
      if (reportData.length > 0) {
        reportSheet.getRange(3, 1, reportData.length, headers.length).setValues(reportData);
        
        // Colorir células de status
        for (let i = 0; i < reportData.length; i++) {
          const row = i + 3;
          
          // Colorir status da fonte
          if (discrepancies[i].sourceValue === "Enable") {
            reportSheet.getRange(row, 5).setBackground(CONFIG.COLORS.ENABLE);
          } else {
            reportSheet.getRange(row, 5).setBackground(CONFIG.COLORS.DISABLE);
          }
          
          // Colorir status do alvo
          if (discrepancies[i].targetValue === "Enable") {
            reportSheet.getRange(row, 6).setBackground(CONFIG.COLORS.ENABLE);
          } else {
            reportSheet.getRange(row, 6).setBackground(CONFIG.COLORS.DISABLE);
          }
        }
      }
      
      // Formatar relatório
      formatReport(reportSheet, reportData.length);
      
      // Adicionar resumo
      reportSheet.insertRowBefore(2);
      reportSheet.getRange("A2:H2").merge()
        .setValue(`Encontradas ${discrepancies.length} divergências de status entre as planilhas.`)
        .setBackground("#FFD700")
        .setFontWeight("bold");
    }
    
    // Mostrar mensagem de conclusão
    SpreadsheetApp.getUi().alert(
      "Comparação Concluída", 
      `A comparação foi concluída com ${discrepancies.length} divergências encontradas.`, 
      SpreadsheetApp.getUi().ButtonSet.OK
    );
    
  } catch (error) {
    SpreadsheetApp.getUi().alert("Erro: " + error.message);
  }
}

/**
 * Prepara a planilha de relatório
 */
function prepareReportSheet(spreadsheet) {
  let reportSheet = spreadsheet.getSheetByName(CONFIG.REPORT_SHEET);
  
  if (reportSheet) {
    reportSheet.clear();
  } else {
    reportSheet = spreadsheet.insertSheet(CONFIG.REPORT_SHEET);
  }
  
  return reportSheet;
}

/**
 * Obtém dados de uma planilha de forma eficiente
 */
function getSheetData(sheet) {
  // Obter título (primeira linha)
  const title = sheet.getRange(1, 1).getValue();
  
  // Obter cabeçalhos (segunda linha)
  const lastColumn = sheet.getLastColumn();
  const headers = sheet.getRange(2, 1, 1, lastColumn).getValues()[0];
  
  // Criar mapa de índices de colunas para acesso rápido
  const columnMap = {};
  headers.forEach((header, index) => {
    columnMap[header] = index;
  });
  
  // Obter dados (a partir da terceira linha)
  const lastRow = sheet.getLastRow();
  const dataRange = sheet.getRange(3, 1, lastRow - 2, lastColumn);
  const values = dataRange.getValues();
  
  // Criar mapa de modelos para acesso rápido
  const modelMap = {};
  values.forEach((row, rowIndex) => {
    const provider = row[0];
    const model = row[1];
    const key = `${provider}|${model}`;
    
    modelMap[key] = {
      rowIndex: rowIndex,
      row: row
    };
  });
  
  return {
    title: title,
    headers: headers,
    columnMap: columnMap,
    values: values,
    modelMap: modelMap,
    startRow: 3, // Dados começam na linha 3
    sheet: sheet
  };
}

/**
 * Compara dados entre as planilhas e identifica divergências
 */
function compareSheetData(sourceData, targetData) {
  const discrepancies = [];
  
  // Para cada modelo na planilha fonte
  Object.keys(sourceData.modelMap).forEach(modelKey => {
    const sourceModel = sourceData.modelMap[modelKey];
    const targetModel = targetData.modelMap[modelKey];
    
    // Verificar se o modelo existe na planilha alvo
    if (targetModel) {
      // Comparar cada capability (começando da coluna 2 - após Provider e Model)
      for (let colIndex = 2; colIndex < sourceData.headers.length; colIndex++) {
        const capability = sourceData.headers[colIndex];
        const sourceValue = sourceModel.row[colIndex];
        const targetValue = targetModel.row[colIndex];
        
        // Comparar valores
        if (sourceValue !== targetValue) {
          discrepancies.push({
            provider: sourceModel.row[0],
            model: sourceModel.row[1],
            capability: capability,
            sourceValue: sourceValue,
            targetValue: targetValue,
            sourceCell: columnToLetter(colIndex + 1) + (sourceModel.rowIndex + sourceData.startRow),
            targetCell: columnToLetter(colIndex + 1) + (targetModel.rowIndex + targetData.startRow)
          });
        }
      }
    }
  });
  
  return discrepancies;
}

/**
 * Formata o relatório para melhor legibilidade
 */
function formatReport(sheet, rowCount) {
  // Definir larguras das colunas
  sheet.setColumnWidth(1, 100);  // Tipo
  sheet.setColumnWidth(2, 100);  // Provider
  sheet.setColumnWidth(3, 180);  // Modelo
  sheet.setColumnWidth(4, 150);  // Capability
  sheet.setColumnWidth(5, 150);  // Status Fonte
  sheet.setColumnWidth(6, 150);  // Status Alvo
  sheet.setColumnWidth(7, 200);  // Localização
  sheet.setColumnWidth(8, 250);  // Ação
  
  // Aplicar bordas
  if (rowCount > 0) {
    sheet.getRange(2, 1, rowCount + 1, 8).setBorder(true, true, true, true, true, true);
  }
  
  // Centralizar texto
  sheet.getRange(1, 1, rowCount + 3, 7).setHorizontalAlignment("center");
  
  // Alinhar ações à esquerda
  if (rowCount > 0) {
    sheet.getRange(3, 8, rowCount, 1).setHorizontalAlignment("left");
  }
  
  // Ativar quebra de texto
  sheet.getRange(1, 1, rowCount + 3, 8).setWrap(true);
  
  // Alternar cores das linhas
  for (let i = 0; i < rowCount; i++) {
    if (i % 2 === 1) {
      sheet.getRange(i + 3, 1, 1, 8).setBackground("#F8F8F8");
    }
  }
}

/**
 * Converte índice de coluna para letra (ex: 1 -> A, 2 -> B)
 */
function columnToLetter(column) {
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
 */
function arraysEqual(arr1, arr2) {
  if (arr1.length !== arr2.length) return false;
  for (let i = 0; i < arr1.length; i++) {
    if (arr1[i] !== arr2[i]) return false;
  }
  return true;
}