// Variáveis de configuração - podem ser definidas nas propriedades do script
const TENANT = PropertiesService.getScriptProperties().getProperty("FLOW_TENANT");
const CLIENT_ID = PropertiesService.getScriptProperties().getProperty("FLOW_CLIENT_ID");
const CLIENT_SECRET = PropertiesService.getScriptProperties().getProperty("FLOW_CLIENT_SECRET");

function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('Executar Script')
      .addItem('Search Mapped Capabilities', 'fetchMappedCapabilities')
      .addItem('Configurar Credenciais', 'configureCredentials')
      .addToUi();
}

function configureCredentials() {
  const ui = SpreadsheetApp.getUi();
  
  // Solicita o tenant
  const tenantResponse = ui.prompt(
    'Configuração de Credenciais',
    'Digite o TENANT:',
    ui.ButtonSet.OK_CANCEL);
  
  if (tenantResponse.getSelectedButton() == ui.Button.CANCEL) {
    return;
  }
  
  // Solicita o client ID
  const clientIdResponse = ui.prompt(
    'Configuração de Credenciais',
    'Digite o CLIENT_ID:',
    ui.ButtonSet.OK_CANCEL);
  
  if (clientIdResponse.getSelectedButton() == ui.Button.CANCEL) {
    return;
  }
  
  // Solicita o client secret
  const clientSecretResponse = ui.prompt(
    'Configuração de Credenciais',
    'Digite o CLIENT_SECRET:',
    ui.ButtonSet.OK_CANCEL);
  
  if (clientSecretResponse.getSelectedButton() == ui.Button.CANCEL) {
    return;
  }
  
  // Salva as credenciais nas propriedades do script
  const scriptProperties = PropertiesService.getScriptProperties();
  scriptProperties.setProperty("FLOW_TENANT", tenantResponse.getResponseText());
  scriptProperties.setProperty("FLOW_CLIENT_ID", clientIdResponse.getResponseText());
  scriptProperties.setProperty("FLOW_CLIENT_SECRET", clientSecretResponse.getResponseText());
  
  ui.alert('Configuração', 'Credenciais salvas com sucesso!', ui.ButtonSet.OK);
}

function getAuthToken() {
  // Verifica se as credenciais estão configuradas
  const tenant = PropertiesService.getScriptProperties().getProperty("FLOW_TENANT");
  const clientId = PropertiesService.getScriptProperties().getProperty("FLOW_CLIENT_ID");
  const clientSecret = PropertiesService.getScriptProperties().getProperty("FLOW_CLIENT_SECRET");
  
  if (!tenant || !clientId || !clientSecret) {
    throw new Error("Credenciais não configuradas. Por favor, use a opção 'Configurar Credenciais' no menu.");
  }
  
  // URL da API de geração de token
  const tokenUrl = 'https://flow.ciandt.com/auth-engine-api/v1/api-key/token';
  
  // Payload para a requisição
  const payload = {
    "clientId": clientId,
    "clientSecret": clientSecret,
    "appToAccess": "llm-api"
  };
  
  // Configuração da requisição
  const options = {
    'method': 'post',
    'contentType': 'application/json',
    'headers': {
      'accept': '*/*',
      'FlowTenant': tenant,
      'FlowAgent': 'chat-with-docs'
    },
    'payload': JSON.stringify(payload)
  };
  
  try {
    // Fazendo a requisição para a API de token
    const response = UrlFetchApp.fetch(tokenUrl, options);
    const data = JSON.parse(response.getContentText());
    
    // Retorna o token de acesso
    return data.accessToken;
  } catch (error) {
    throw new Error("Erro ao obter token de autenticação: " + error.message);
  }
}

function fetchMappedCapabilities() {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = spreadsheet.getSheetByName("LLM-Capabilities") || spreadsheet.insertSheet("LLM-Capabilities");
  
  // Limpa a aba se já existir
  if (sheet.getLastRow() > 0) {
    sheet.clear();
  }
  
  try {
    // Obtém o token de autenticação
    const token = getAuthToken();
    
    // Obtém o tenant configurado
    const tenant = PropertiesService.getScriptProperties().getProperty("FLOW_TENANT");
    
    // URL da API de capabilities
    const url = `https://flow.ciandt.com/ai-orchestration-api/v2/tenant/${tenant}/capabilities`;
    
    // Configuração da requisição
    const options = {
      'method': 'get',
      'headers': {
        'Authorization': 'Bearer ' + token,
        'accept': '*/*'
      }
    };
    
    // Fazendo a requisição para a API
    const response = UrlFetchApp.fetch(url, options);
    const data = JSON.parse(response.getContentText());
    
    // Obtém todas as capabilities disponíveis da resposta da API
    const allCapabilities = data.allCapabilities || [];
    
    // Define os cabeçalhos com Provider e Modelo fixos, seguidos pelas capabilities dinâmicas
    const headers = ['Provider', 'Modelo'];
    allCapabilities.forEach(capability => {
      // Converte o nome da capability para um formato mais legível
      const formattedCapability = formatCapabilityName(capability);
      headers.push(formattedCapability);
    });
    
    // Calcula o número total de colunas (2 fixas + número de capabilities)
    const totalColumns = 2 + allCapabilities.length;
    
    // Adiciona a linha preta com o título "RETORNO DA API"
    sheet.appendRow(Array(totalColumns).fill(''));
    const titleRow = sheet.getRange(1, 1, 1, totalColumns);
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
        const capabilities = model.capabilities;
        const modelName = model.name;

        // Inicia a linha com provider e modelo
        const row = [provider, modelName];
        
        // Adiciona o status para cada capability
        allCapabilities.forEach(capability => {
          const status = capabilities.includes(capability) ? "Enable" : "Disable";
          row.push(status);
        });
        
        sheet.appendRow(row);
      });
    }

    // Formatação da planilha
    formatSheet(sheet, headers.length, allCapabilities.length);
    
    // Exibe mensagem de sucesso
    SpreadsheetApp.getUi().alert("Dados carregados com sucesso!");
    
  } catch (error) {
    // Exibe uma mensagem de erro se a requisição falhar
    SpreadsheetApp.getUi().alert("Erro: " + error.message);
  }
}

// Função para formatar o nome da capability para um formato mais legível
function formatCapabilityName(capability) {
  // Substitui hífens por espaços e capitaliza cada palavra
  return capability.split('-')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

function formatSheet(sheet, numColumns, numCapabilities) {
  // Define a largura mínima das colunas
  const minColumnWidths = [160, 200]; // Provider e Modelo
  
  // Adiciona larguras para as colunas de capabilities (120px cada)
  for (let i = 0; i < numCapabilities; i++) {
    minColumnWidths.push(120);
  }

  // Aplica a largura mínima
  for (let i = 0; i < numColumns; i++) {
    sheet.setColumnWidth(i + 1, minColumnWidths[i] || 120);
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

  // Centraliza o conteúdo das células de capabilities (colunas 3 em diante)
  const capabilitiesRange = sheet.getRange(3, 3, lastRow - 2, numColumns - 2);
  capabilitiesRange.setHorizontalAlignment("center");
  
  // Adiciona espaçamento entre as linhas
  sheet.getRange(1, 1, lastRow, numColumns).setVerticalAlignment("middle"); // Centraliza verticalmente

  // Adiciona a validação de dados nas colunas de capabilities (colunas 3 em diante)
  const validationValues = ["Enable", "Disable"];
  const rule = SpreadsheetApp.newDataValidation()
      .requireValueInList(validationValues)
      .setAllowInvalid(false)
      .build();

  // Cria ranges para as colunas de capacidades (excluindo Provider e Modelo)
  const capabilityColumns = [];
  for (let i = 3; i <= numColumns; i++) {
    capabilityColumns.push(i);
  }
  
  // Aplica a validação de dados a cada coluna de capacidade para todas as linhas de dados
  capabilityColumns.forEach(colIndex => {
    const range = sheet.getRange(3, colIndex, lastRow - 2, 1); // Da linha 3 até a última linha
    range.setDataValidation(rule);
  });

  // Habilita quebra de texto para todas as colunas de cabeçalho com nomes longos
  capabilityColumns.forEach(colIndex => {
    const headerCell = sheet.getRange(2, colIndex);
    headerCell.setWrap(true);
    headerCell.setVerticalAlignment("middle");
  });

  // Limpa as regras existentes
  sheet.clearConditionalFormatRules();
  
  // Define o range para formatação condicional (apenas colunas de capacidades)
  const formatRanges = [];
  capabilityColumns.forEach(colIndex => {
    formatRanges.push(sheet.getRange(3, colIndex, lastRow - 2, 1));
  });
  
  // Cria as regras de formatação condicional
  const rules = [];
  
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