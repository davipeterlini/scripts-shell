function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('Executar Script')
      .addItem('Search Dynamic Capabilities', 'fetchDynamicCapabilities')
      .addToUi();
}

function fetchDynamicCapabilities() {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = spreadsheet.getSheetByName("Dynamic-Capabilities") || spreadsheet.insertSheet("Dynamic-Capabilities");
  
  // Limpa a aba se já existir
  if (sheet.getLastRow() > 0) {
    sheet.clear();
  }
  
  // Solicita ao usuário o token de autenticação
  const userToken = Browser.inputBox("Por favor, insira seu token de autenticação:");

  // Valida se o token não está vazio
  if (!userToken) {
    Browser.msgBox("O token de autenticação não pode estar vazio. A execução do script foi cancelada.");
    return;
  }

  const url = 'https://flow.ciandt.com/ai-orchestration-api/v2/tenant/flowteam/capabilities';

  // Configuração da requisição
  const options = {
    'method': 'get',
    'headers': {
      'Authorization': 'Bearer ' + userToken,
      'accept': '*/*'
    }
  };
  
  try {
    // Fazendo a requisição para a API
    const response = UrlFetchApp.fetch(url, options);
    const data = JSON.parse(response.getContentText());
    
    // Obtém todas as capabilities disponíveis
    const allCapabilities = data.allCapabilities || [];
    
    // Cria os cabeçalhos fixos
    const fixedHeaders = ['Provider', 'Modelo'];
    
    // Combina os cabeçalhos fixos com as capabilities para formar o cabeçalho completo
    const headers = [...fixedHeaders, ...allCapabilities];
    
    // Adiciona a linha preta com o título "RETORNO DA API"
    sheet.appendRow(Array(headers.length).fill(''));
    const titleRow = sheet.getRange(1, 1, 1, headers.length);
    titleRow.merge();
    titleRow.setValue("RETORNO DA API");
    titleRow.setFontWeight("bold");
    titleRow.setBackground("#000000");
    titleRow.setFontColor("#FFFFFF");
    titleRow.setHorizontalAlignment("center");
    titleRow.setVerticalAlignment("middle");
    titleRow.setBorder(true, true, true, true, true, true, "black", SpreadsheetApp.BorderStyle.SOLID);
    
    // Adiciona os cabeçalhos
    sheet.appendRow(headers);

    // Define estilo para a linha dos cabeçalhos
    const headerRange = sheet.getRange(2, 1, 1, headers.length);
    headerRange.setFontWeight("bold");
    headerRange.setFontSize(12);
    headerRange.setBackground("#D3D3D3"); // Cor de fundo cinza
    headerRange.setFontColor("black"); // Cor da fonte preta
    headerRange.setHorizontalAlignment("center");
    headerRange.setBorder(true, true, true, true, true, true); // Adiciona bordas
    
    // Iterando sobre os providers e modelos
    for (const provider in data.supportedModels) {
      const models = data.supportedModels[provider];
      
      models.forEach(model => {
        const modelCapabilities = model.capabilities || [];
        const modelName = model.name;

        // Cria uma linha com o provider e o modelo
        const row = [provider, modelName];
        
        // Para cada capability disponível, verifica se o modelo suporta
        allCapabilities.forEach(capability => {
          const hasCapability = modelCapabilities.includes(capability);
          row.push(hasCapability ? "Enable" : "Disable");
        });
        
        sheet.appendRow(row);
      });
    }

    // Formatação da planilha
    formatSheet(sheet, headers.length, fixedHeaders.length);
    
  } catch (error) {
    // Exibe uma mensagem de erro se a requisição falhar
    Browser.msgBox("Erro ao acessar a API: " + error.message);
  }
}

function formatSheet(sheet, numColumns, fixedColumnsCount) {
  // Define a largura mínima das colunas
  const baseColumnWidth = 120;
  const minColumnWidths = [160, 200]; // Larguras para Provider e Modelo
  
  // Adiciona larguras para as colunas de capabilities
  for (let i = 0; i < numColumns - fixedColumnsCount; i++) {
    minColumnWidths.push(baseColumnWidth);
  }

  // Aplica a largura mínima
  for (let i = 0; i < numColumns; i++) {
    sheet.setColumnWidth(i + 1, minColumnWidths[i] || baseColumnWidth);
  }
  
  const lastRow = sheet.getLastRow();
  
  // Aplica bordas a todas as células preenchidas
  const dataRange = sheet.getRange(1, 1, lastRow, numColumns);
  dataRange.setBorder(true, true, true, true, true, true);
  
  // Alterna a cor das linhas de dados (começando da linha 3)
  for (let i = 3; i <= lastRow; i++) {
    if (i % 2 === 1) { // Linhas ímpares (3, 5, 7...)
      sheet.getRange(i, 1, 1, numColumns).setBackground("#f2f2f2"); // Cor de fundo cinza claro
    }
  }

  // Ajusta a altura das linhas
  sheet.setRowHeight(1, 30); // Altura da linha do título
  sheet.setRowHeight(2, 35); // Altura da linha do cabeçalho aumentada para acomodar quebra de texto
  
  // Ajusta a altura das linhas de dados
  for (let i = 3; i <= lastRow; i++) {
    sheet.setRowHeight(i, 25);
  }

  // Centraliza o conteúdo das células de capabilities
  if (lastRow > 2) {
    const capabilitiesRange = sheet.getRange(3, fixedColumnsCount + 1, lastRow - 2, numColumns - fixedColumnsCount);
    capabilitiesRange.setHorizontalAlignment("center");
  }
  
  // Adiciona espaçamento entre as linhas
  sheet.getRange(1, 1, lastRow, numColumns).setVerticalAlignment("middle"); // Centraliza verticalmente

  // Adiciona a validação de dados nas colunas de capabilities
  const validationValues = ["Enable", "Disable"];
  const rule = SpreadsheetApp.newDataValidation()
      .requireValueInList(validationValues)
      .setAllowInvalid(false)
      .build();

  // Cria ranges para as colunas de capacidades (excluindo Provider e Modelo)
  const capabilityColumns = [];
  for (let i = fixedColumnsCount + 1; i <= numColumns; i++) {
    capabilityColumns.push(i);
  }
  
  // Aplica a validação de dados a cada coluna de capacidade para todas as linhas de dados
  if (lastRow > 2) {
    capabilityColumns.forEach(colIndex => {
      const range = sheet.getRange(3, colIndex, lastRow - 2, 1); // Da linha 3 até a última linha
      range.setDataValidation(rule);
    });
  }

  // Habilita quebra de texto para todas as colunas de cabeçalho
  for (let i = 1; i <= numColumns; i++) {
    const headerCell = sheet.getRange(2, i);
    headerCell.setWrap(true);
    headerCell.setVerticalAlignment("middle");
  }

  // Limpa as regras existentes
  sheet.clearConditionalFormatRules();
  
  // Define o range para formatação condicional (apenas colunas de capacidades)
  const formatRanges = [];
  if (lastRow > 2) {
    capabilityColumns.forEach(colIndex => {
      formatRanges.push(sheet.getRange(3, colIndex, lastRow - 2, 1));
    });
  }
  
  // Cria as regras de formatação condicional
  const rules = [];
  
  if (formatRanges.length > 0) {
    // Regra para "Enable"
    rules.push(SpreadsheetApp.newConditionalFormatRule()
        .whenTextEqualTo("Enable")
        .setBackground("#008000") // Verde
        .setRanges(formatRanges)
        .build());
    
    // Regra para "Disable"
    rules.push(SpreadsheetApp.newConditionalFormatRule()
        .whenTextEqualTo("Disable")
        .setBackground("#dc3545") // Vermelho
        .setRanges(formatRanges)
        .build());
    
    // Aplica todas as regras
    sheet.setConditionalFormatRules(rules);
  }
  
  // Adiciona a legenda abaixo da tabela
  addLegend(sheet, lastRow + 3); // Adiciona a legenda 3 linhas abaixo da tabela
}

function addLegend(sheet, startRow) {
  // Define os itens da legenda com seus respectivos status e cores
  const legendItems = [
    { status: "Enable", color: "#008000", description: "Funcionalidade suportada pelo modelo" },
    { status: "Disable", color: "#dc3545", description: "Funcionalidade não suportada pelo modelo" }
  ];
  
  // Adiciona o título da legenda
  const legendTitleCell = sheet.getRange(startRow, 1, 1, 4);
  legendTitleCell.merge();
  legendTitleCell.setValue("LEGENDA");
  legendTitleCell.setFontWeight("bold");
  legendTitleCell.setHorizontalAlignment("center");
  legendTitleCell.setBackground("#f2f2f2");
  legendTitleCell.setBorder(true, true, true, true, true, true);
  
  // Adiciona os cabeçalhos da legenda
  const headerRow = startRow + 1;
  sheet.getRange(headerRow, 1).setValue("Status");
  sheet.getRange(headerRow, 2).setValue("Cor");
  sheet.getRange(headerRow, 3, 1, 2).merge().setValue("Descrição");
  
  // Formata os cabeçalhos
  const headerRange = sheet.getRange(headerRow, 1, 1, 4);
  headerRange.setFontWeight("bold");
  headerRange.setBackground("#D3D3D3");
  headerRange.setHorizontalAlignment("center");
  headerRange.setBorder(true, true, true, true, true, true);
  
  // Adiciona os itens da legenda
  legendItems.forEach((item, index) => {
    const row = headerRow + index + 1;
    
    // Status
    const statusCell = sheet.getRange(row, 1);
    statusCell.setValue(item.status);
    statusCell.setHorizontalAlignment("center");
    statusCell.setBorder(true, true, true, true, true, true);
    
    // Cor
    const colorCell = sheet.getRange(row, 2);
    colorCell.setBackground(item.color);
    colorCell.setBorder(true, true, true, true, true, true);
    
    // Descrição
    const descCell = sheet.getRange(row, 3, 1, 2);
    descCell.merge();
    descCell.setValue(item.description);
    descCell.setBorder(true, true, true, true, true, true);
  });
  
  // Adiciona uma nota sobre a legenda
  const noteRow = headerRow + legendItems.length + 2;
  const noteCell = sheet.getRange(noteRow, 1, 1, 4);
  noteCell.merge();
  noteCell.setValue("Nota: Esta legenda serve como referência para interpretar os status nas células da tabela acima.");
  noteCell.setFontStyle("italic");
  noteCell.setHorizontalAlignment("center");
}