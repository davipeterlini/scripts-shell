function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('Executar Script')
      .addItem('Search Capabilities - Monitor', 'fetchCapabilities')
      .addToUi();
}

function fetchCapabilities() {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = spreadsheet.getSheetByName("Tenant-Models") || spreadsheet.insertSheet("Tenant-Models");
  
  // Limpa a aba se já existir
  if (sheet.getLastRow() > 0) {
    sheet.clear();
  }
  
  // Definindo os cabeçalhos da tabela
  const headers = ['Provider', 'Modelo', 'Streaming', 'System Instruction', 
                   'Chat Conversation', 'Image Recognition', 
                   'Text Embedding', '', 'Chat with Stream', 
                   'Chat S/ Stream', 'Agent Stream', 
                   'Agent S/ Stream', '', 'Coder With Stream', 'Coder S/ Stream']; // Adicionada coluna vazia entre Agent S/ Stream e Coder With Stream

  // Adiciona a linha preta com os títulos segmentados
  sheet.appendRow(Array(headers.length).fill(''));
  const titleRow = sheet.getRange(1, 1, 1, headers.length);
  titleRow.setBackground("#000000");
  titleRow.setFontColor("#FFFFFF");
  titleRow.setBorder(true, true, true, true, true, true, "black", SpreadsheetApp.BorderStyle.SOLID);
  titleRow.setHorizontalAlignment("center");
  titleRow.setVerticalAlignment("middle");
  
  // Configura os segmentos de título conforme solicitado
  // Merge das colunas A-G (1-7) com o texto "RETORNO DA API"
  const apiTitleRange = sheet.getRange(1, 1, 1, 7);
  apiTitleRange.merge();
  apiTitleRange.setValue("RETORNO DA API");
  apiTitleRange.setFontWeight("bold");
  
  // A coluna H (8) fica como separador
  
  // Merge das colunas I-L (9-12) com o texto "CODER IDE"
  const ideTitleRange = sheet.getRange(1, 9, 1, 4);
  ideTitleRange.merge();
  ideTitleRange.setValue("CODER IDE");
  ideTitleRange.setFontWeight("bold");
  
  // A coluna M (13) fica como separador
  
  // Merge das colunas N-O (14-15) com o texto "CODER CLI"
  const cliTitleRange = sheet.getRange(1, 14, 1, 2);
  cliTitleRange.merge();
  cliTitleRange.setValue("CODER CLI");
  cliTitleRange.setFontWeight("bold");
  
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
    
    // Iterando sobre os providers e modelos
    for (const provider in data.supportedModels) {
      const models = data.supportedModels[provider];
      
      models.forEach(model => {
        const capabilities = model.capabilities;
        const modelName = model.name;

        const row = [
          provider,
          modelName,
          capabilities.includes('streaming') ? "Not Tested" : "Not Supported", // Coluna Streaming
          capabilities.includes('system-instruction') ? "Not Tested" : "Not Supported", // Coluna System Instruction
          capabilities.includes('chat-conversation') ? "Not Tested" : "Not Supported", // Coluna Chat Conversation
          capabilities.includes('image-recognition') ? "Not Tested" : "Not Supported", // Coluna Image Recognition
          capabilities.includes('text-embedding') ? "Not Tested" : "Not Supported", // Coluna Text Embedding
          '', // Primeira coluna vazia
          'Not Tested', // Coluna Chat with Stream
          'Not Tested', // Coluna Chat S/ Stream
          'Not Tested', // Coluna Agent Stream
          'Not Tested', // Coluna Agent S/ Stream
          '', // Segunda coluna vazia
          'Not Tested', // Coluna Coder With Stream
          'Not Tested'  // Coluna Coder S/ Stream
        ];
        
        sheet.appendRow(row);
      });
    }

    // Formatação da planilha
    formatSheet(sheet, headers.length);
    
  } catch (error) {
    // Exibe uma mensagem de erro se a requisição falhar
    Browser.msgBox("Erro ao acessar a API: " + error.message);
  }
}

function formatSheet(sheet, numColumns) {
  // Define a largura mínima das colunas
  const minColumnWidths = [160, 200, 120, 120, 120, 120, 120, 30, 120, 120, 120, 120, 30, 120, 120]; // Adicionada largura para a nova coluna vazia

  // Aplica a largura mínima
  for (let i = 0; i < numColumns; i++) {
    sheet.setColumnWidth(i + 1, minColumnWidths[i]);
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
  sheet.setRowHeight(1, 30); // Altura da linha preta (um pouco maior para o título)
  sheet.setRowHeight(2, 35); // Altura da linha do cabeçalho aumentada para acomodar quebra de texto
  
  // Ajusta a altura das linhas de dados
  for (let i = 3; i <= lastRow; i++) {
    sheet.setRowHeight(i, 25);
  }

  // Centraliza o conteúdo das células de capabilities
  const capabilitiesRange = sheet.getRange(3, 3, lastRow - 2, numColumns - 2);
  capabilitiesRange.setHorizontalAlignment("center");
  
  // Adiciona espaçamento entre as linhas
  sheet.getRange(1, 1, lastRow, numColumns).setVerticalAlignment("middle"); // Centraliza verticalmente

  // Adiciona a validação de dados nas colunas
  const validationValues = ["Tested", "Not Tested", "Problem", "Not Work", "Not Supported"];
  const rule = SpreadsheetApp.newDataValidation()
      .requireValueInList(validationValues)
      .setAllowInvalid(false)
      .build();

  // Cria ranges para todas as colunas de capacidades (exceto as colunas vazias)
  const capabilityColumns = [3, 4, 5, 6, 7, 9, 10, 11, 12, 14, 15]; // Índices das colunas de capacidades (pulando as colunas 8 e 13)
  
  // Aplica a validação de dados a cada coluna de capacidade para todas as linhas de dados
  capabilityColumns.forEach(colIndex => {
    const range = sheet.getRange(3, colIndex, lastRow - 2, 1); // Da linha 3 até a última linha
    range.setDataValidation(rule);
  });

  // Mescla todas as células da primeira coluna vazia (coluna 8), exceto a primeira linha que já está mesclada
  sheet.getRange(2, 8, lastRow - 1, 1).merge();
  
  // Mescla todas as células da segunda coluna vazia (coluna 13), exceto a primeira linha que já está mesclada
  sheet.getRange(2, 13, lastRow - 1, 1).merge();

  // Habilita quebra de texto para todas as colunas de cabeçalho com nomes longos
  // Colunas com nomes longos: System Instruction, Chat Conversation, Image Recognition, Text Embedding,
  // Chat with Stream, Chat S/ Stream, Agent Stream, Agent S/ Stream, Coder With Stream, Coder S/ Stream
  const longHeaderColumns = [4, 5, 6, 7, 9, 10, 11, 12, 14, 15]; // Índices das colunas com nomes longos
  
  longHeaderColumns.forEach(colIndex => {
    const headerCell = sheet.getRange(2, colIndex);
    headerCell.setWrap(true);
    headerCell.setVerticalAlignment("middle");
  });

  // Limpa as regras existentes
  sheet.clearConditionalFormatRules();
  
  // Define o range para formatação condicional (todas as colunas de capacidades, exceto as vazias)
  const formatRanges = [];
  capabilityColumns.forEach(colIndex => {
    formatRanges.push(sheet.getRange(3, colIndex, lastRow - 2, 1));
  });
  
  // Cria as regras de formatação condicional
  const rules = [];
  
  // Regra para "Tested"
  rules.push(SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo("Tested")
      .setBackground("#008000") // Verde
      .setRanges(formatRanges)
      .build());
  
  // Regra para "Not Supported"
  rules.push(SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo("Not Supported")
      .setBackground("#FFA500") // Laranja
      .setRanges(formatRanges)
      .build());
  
  // Regra para "Not Tested"
  rules.push(SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo("Not Tested")
      .setBackground("#d9d9d9") // Cinza
      .setRanges(formatRanges)
      .build());
  
  // Regra para "Problem"
  rules.push(SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo("Problem")
      .setBackground("#ffcc00") // Amarelo
      .setRanges(formatRanges)
      .build());
  
  // Regra para "Not Work"
  rules.push(SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo("Not Work")
      .setBackground("#dc3545") // Vermelho
      .setRanges(formatRanges)
      .build());
  
  // Aplica todas as regras
  sheet.setConditionalFormatRules(rules);
  
  // Adiciona a legenda abaixo da tabela
  addLegend(sheet, lastRow + 3); // Adiciona a legenda 3 linhas abaixo da tabela
}

function addLegend(sheet, startRow) {
  // Define os itens da legenda com seus respectivos status e cores
  const legendItems = [
    { status: "Tested", color: "#008000", description: "Funcionalidade testada e funcionando corretamente" },
    { status: "Not Tested", color: "#d9d9d9", description: "Funcionalidade ainda não testada" },
    { status: "Problem", color: "#ffcc00", description: "Funcionalidade testada, mas apresentou problemas" },
    { status: "Not Work", color: "#dc3545", description: "Funcionalidade testada, mas não funcionou" },
    { status: "Not Supported", color: "#FFA500", description: "Funcionalidade não suportada pelo modelo" }
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