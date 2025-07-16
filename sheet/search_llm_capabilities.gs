/**
 * LLM Capabilities Search Tool
 * 
 * This script allows users to fetch and display LLM capabilities from Flow API
 * in a structured spreadsheet format.
 */

// Global properties
const TENANT = PropertiesService.getScriptProperties().getProperty("FLOW_TENANT");
const CLIENT_ID = PropertiesService.getScriptProperties().getProperty("FLOW_CLIENT_ID");
const CLIENT_SECRET = PropertiesService.getScriptProperties().getProperty("FLOW_CLIENT_SECRET");

// Configuration constants
const CONFIG = {
  SHEET_NAME: "LLM-Capabilities",
  API: {
    TOKEN_URL: 'https://flow.ciandt.com/auth-engine-api/v1/api-key/token',
    CAPABILITIES_URL: 'https://flow.ciandt.com/ai-orchestration-api/v2/tenant/'
  },
  COLORS: {
    TITLE_BG: "#000000",
    TITLE_TEXT: "#FFFFFF",
    HEADER_BG: "#D3D3D3",
    ROW_ALTERNATE: "#f2f2f2",
    ENABLE: "#008000",
    DISABLE: "#dc3545",
    LEGEND_BG: "#f2f2f2"
  },
  SIZES: {
    TITLE_HEIGHT: 30,
    HEADER_HEIGHT: 35,
    ROW_HEIGHT: 25,
    COLUMN_WIDTHS: {
      PROVIDER: 160,
      MODEL: 200,
      CAPABILITY: 120
    }
  }
};

// =============================================================================
// UI Functions
// =============================================================================

/**
 * Creates custom menu when spreadsheet is opened
 */
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('Executar Script')
      .addItem('Search LLM Capabilities', 'fetchMappedCapabilities')
      .addItem('Configurar Credenciais', 'configureCredentials')
      .addToUi();
}

/**
 * Displays UI for configuring API credentials
 */
function configureCredentials() {
  const ui = SpreadsheetApp.getUi();
  
  // Request tenant
  const tenantResponse = _promptForCredential(ui, 'Digite o TENANT:');
  if (!tenantResponse) return;
  
  // Request client ID
  const clientIdResponse = _promptForCredential(ui, 'Digite o CLIENT_ID:');
  if (!clientIdResponse) return;
  
  // Request client secret
  const clientSecretResponse = _promptForCredential(ui, 'Digite o CLIENT_SECRET:');
  if (!clientSecretResponse) return;
  
  // Save credentials to script properties
  _saveCredentials(tenantResponse, clientIdResponse, clientSecretResponse);
  
  ui.alert('Configuração', 'Credenciais salvas com sucesso!', ui.ButtonSet.OK);
}

/**
 * Main function to fetch and display LLM capabilities
 */
function fetchMappedCapabilities() {
  try {
    // Prepare the sheet
    const sheet = _prepareSheet();
    
    // Get data from API
    const data = _fetchCapabilitiesData();
    
    // Process and display data
    _displayCapabilitiesData(sheet, data);
    
  } catch (error) {
    SpreadsheetApp.getUi().alert("Erro: " + error.message);
  }
}

// =============================================================================
// API Functions
// =============================================================================

/**
 * Gets authentication token from Flow API
 * @return {string} Authentication token
 */
function getAuthToken() {
  // Verify credentials are configured
  const credentials = _getCredentials();
  
  // Prepare request payload
  const payload = {
    "clientId": credentials.clientId,
    "clientSecret": credentials.clientSecret,
    "appToAccess": "llm-api"
  };
  
  // Configure request
  const options = {
    'method': 'post',
    'contentType': 'application/json',
    'headers': {
      'accept': '*/*',
      'FlowTenant': credentials.tenant,
      'FlowAgent': 'chat-with-docs'
    },
    'payload': JSON.stringify(payload)
  };
  
  try {
    // Make request to token API
    const response = UrlFetchApp.fetch(CONFIG.API.TOKEN_URL, options);
    const data = JSON.parse(response.getContentText());
    
    if (!data.access_token) {
      throw new Error("Token de acesso não encontrado na resposta da API");
    }
    
    return data.access_token;
  } catch (error) {
    throw new Error("Erro ao obter token de autenticação: " + error.message);
  }
}

// =============================================================================
// Private Helper Functions
// =============================================================================

/**
 * Prompts user for a credential value
 * @param {Object} ui - SpreadsheetApp UI object
 * @param {string} promptText - Text to display in prompt
 * @return {string|null} User input or null if canceled
 * @private
 */
function _promptForCredential(ui, promptText) {
  const response = ui.prompt(
    'Configuração de Credenciais',
    promptText,
    ui.ButtonSet.OK_CANCEL);
  
  if (response.getSelectedButton() == ui.Button.CANCEL) {
    return null;
  }
  
  return response.getResponseText();
}

/**
 * Saves credentials to script properties
 * @param {string} tenant - Tenant value
 * @param {string} clientId - Client ID value
 * @param {string} clientSecret - Client Secret value
 * @private
 */
function _saveCredentials(tenant, clientId, clientSecret) {
  const scriptProperties = PropertiesService.getScriptProperties();
  scriptProperties.setProperty("FLOW_TENANT", tenant);
  scriptProperties.setProperty("FLOW_CLIENT_ID", clientId);
  scriptProperties.setProperty("FLOW_CLIENT_SECRET", clientSecret);
}

/**
 * Gets credentials from script properties
 * @return {Object} Credentials object
 * @private
 */
function _getCredentials() {
  const tenant = PropertiesService.getScriptProperties().getProperty("FLOW_TENANT");
  const clientId = PropertiesService.getScriptProperties().getProperty("FLOW_CLIENT_ID");
  const clientSecret = PropertiesService.getScriptProperties().getProperty("FLOW_CLIENT_SECRET");
  
  if (!tenant || !clientId || !clientSecret) {
    throw new Error("Credenciais não configuradas. Por favor, use a opção 'Configurar Credenciais' no menu.");
  }
  
  return { tenant, clientId, clientSecret };
}

/**
 * Prepares the sheet for data display
 * @return {Object} Sheet object
 * @private
 */
function _prepareSheet() {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = spreadsheet.getSheetByName(CONFIG.SHEET_NAME) || spreadsheet.insertSheet(CONFIG.SHEET_NAME);
  
  // Clear sheet if it already exists
  if (sheet.getLastRow() > 0) {
    sheet.clear();
  }
  
  return sheet;
}

/**
 * Fetches capabilities data from API
 * @return {Object} API response data
 * @private
 */
function _fetchCapabilitiesData() {
  // Get authentication token
  const token = getAuthToken();
  
  // Get tenant
  const tenant = PropertiesService.getScriptProperties().getProperty("FLOW_TENANT");
  
  // API URL
  const url = `${CONFIG.API.CAPABILITIES_URL}${tenant}/capabilities`;
  
  // Configure request
  const options = {
    'method': 'get',
    'headers': {
      'Authorization': 'Bearer ' + token,
      'accept': '*/*'
    }
  };
  
  // Make request to API
  const response = UrlFetchApp.fetch(url, options);
  return JSON.parse(response.getContentText());
}

/**
 * Displays capabilities data in the sheet
 * @param {Object} sheet - Sheet object
 * @param {Object} data - API response data
 * @private
 */
function _displayCapabilitiesData(sheet, data) {
  // Get all capabilities from API response
  const allCapabilities = data.allCapabilities || [];
  
  // Create headers
  const headers = _createHeaders(allCapabilities);
  
  // Calculate total columns
  const totalColumns = 2 + allCapabilities.length;
  
  // Add title row
  _addTitleRow(sheet, totalColumns);

  // Add headers row
  sheet.appendRow(headers);
  _formatHeaderRow(sheet, headers.length);
  
  // Add data rows
  _addDataRows(sheet, data, allCapabilities);
  
  // Format sheet
  _formatSheet(sheet, headers.length, allCapabilities.length);
  
  // Add legend
  _addLegend(sheet, sheet.getLastRow() + 3);
}

/**
 * Creates headers array from capabilities
 * @param {Array} capabilities - List of capabilities
 * @return {Array} Headers array
 * @private
 */
function _createHeaders(capabilities) {
  const headers = ['Provider', 'Modelo'];
  capabilities.forEach(capability => {
    headers.push(_formatCapabilityName(capability));
  });
  return headers;
}

/**
 * Formats capability name to be more readable
 * @param {string} capability - Raw capability name
 * @return {string} Formatted capability name
 * @private
 */
function _formatCapabilityName(capability) {
  return capability.split('-')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

/**
 * Adds title row to sheet
 * @param {Object} sheet - Sheet object
 * @param {number} totalColumns - Total number of columns
 * @private
 */
function _addTitleRow(sheet, totalColumns) {
  sheet.appendRow(Array(totalColumns).fill(''));
  const titleRow = sheet.getRange(1, 1, 1, totalColumns);
  titleRow.merge();
  titleRow.setValue("RETORNO DA API");
  titleRow.setFontWeight("bold");
  titleRow.setBackground(CONFIG.COLORS.TITLE_BG);
  titleRow.setFontColor(CONFIG.COLORS.TITLE_TEXT);
  titleRow.setHorizontalAlignment("center");
  titleRow.setVerticalAlignment("middle");
  titleRow.setBorder(true, true, true, true, true, true, "black", SpreadsheetApp.BorderStyle.SOLID);
}

/**
 * Formats header row
 * @param {Object} sheet - Sheet object
 * @param {number} headerLength - Number of header columns
 * @private
 */
function _formatHeaderRow(sheet, headerLength) {
  const headerRange = sheet.getRange(2, 1, 1, headerLength);
  headerRange.setFontWeight("bold");
  headerRange.setFontSize(12);
  headerRange.setBackground(CONFIG.COLORS.HEADER_BG);
  headerRange.setFontColor("black");
  headerRange.setHorizontalAlignment("center");
  headerRange.setBorder(true, true, true, true, true, true);
}

/**
 * Adds data rows to sheet
 * @param {Object} sheet - Sheet object
 * @param {Object} data - API response data
 * @param {Array} allCapabilities - List of all capabilities
 * @private
 */
function _addDataRows(sheet, data, allCapabilities) {
  for (const provider in data.supportedModels) {
    const models = data.supportedModels[provider];
    
    models.forEach(model => {
      const capabilities = model.capabilities;
      const modelName = model.name;

      // Start row with provider and model
      const row = [provider, modelName];
      
      // Add status for each capability
      allCapabilities.forEach(capability => {
        const status = capabilities.includes(capability) ? "Enable" : "Disable";
        row.push(status);
      });
      
      sheet.appendRow(row);
    });
  }
}

/**
 * Formats the sheet for better readability
 * @param {Object} sheet - Sheet object
 * @param {number} numColumns - Number of columns
 * @param {number} numCapabilities - Number of capabilities
 * @private
 */
function _formatSheet(sheet, numColumns, numCapabilities) {
  // Set column widths
  _setColumnWidths(sheet, numColumns, numCapabilities);
  
  const lastRow = sheet.getLastRow();
  
  // Apply borders to all filled cells
  const dataRange = sheet.getRange(1, 1, lastRow, numColumns);
  dataRange.setBorder(true, true, true, true, true, true);
  
  // Alternate row colors
  _alternateRowColors(sheet, lastRow, numColumns);

  // Adjust row heights
  _adjustRowHeights(sheet, lastRow);

  // Center content in capability cells
  _centerCapabilityCells(sheet, lastRow, numColumns);
  
  // Add data validation for capability columns
  _addDataValidation(sheet, lastRow, numColumns);

  // Enable text wrapping for header cells
  _enableHeaderTextWrapping(sheet, numColumns);

  // Add conditional formatting
  _addConditionalFormatting(sheet, lastRow, numColumns);
}

/**
 * Sets column widths
 * @param {Object} sheet - Sheet object
 * @param {number} numColumns - Number of columns
 * @param {number} numCapabilities - Number of capabilities
 * @private
 */
function _setColumnWidths(sheet, numColumns, numCapabilities) {
  // Set width for Provider and Model columns
  sheet.setColumnWidth(1, CONFIG.SIZES.COLUMN_WIDTHS.PROVIDER);
  sheet.setColumnWidth(2, CONFIG.SIZES.COLUMN_WIDTHS.MODEL);
  
  // Set width for capability columns
  for (let i = 3; i <= numColumns; i++) {
    sheet.setColumnWidth(i, CONFIG.SIZES.COLUMN_WIDTHS.CAPABILITY);
  }
}

/**
 * Alternates row colors for better readability
 * @param {Object} sheet - Sheet object
 * @param {number} lastRow - Last row number
 * @param {number} numColumns - Number of columns
 * @private
 */
function _alternateRowColors(sheet, lastRow, numColumns) {
  for (let i = 3; i <= lastRow; i++) {
    if (i % 2 === 1) { // Odd rows (3, 5, 7...)
      sheet.getRange(i, 1, 1, numColumns).setBackground(CONFIG.COLORS.ROW_ALTERNATE);
    }
  }
}

/**
 * Adjusts row heights
 * @param {Object} sheet - Sheet object
 * @param {number} lastRow - Last row number
 * @private
 */
function _adjustRowHeights(sheet, lastRow) {
  sheet.setRowHeight(1, CONFIG.SIZES.TITLE_HEIGHT);
  sheet.setRowHeight(2, CONFIG.SIZES.HEADER_HEIGHT);
  
  for (let i = 3; i <= lastRow; i++) {
    sheet.setRowHeight(i, CONFIG.SIZES.ROW_HEIGHT);
  }
}

/**
 * Centers content in capability cells
 * @param {Object} sheet - Sheet object
 * @param {number} lastRow - Last row number
 * @param {number} numColumns - Number of columns
 * @private
 */
function _centerCapabilityCells(sheet, lastRow, numColumns) {
  const capabilitiesRange = sheet.getRange(3, 3, lastRow - 2, numColumns - 2);
  capabilitiesRange.setHorizontalAlignment("center");
  
  // Add vertical spacing between rows
  sheet.getRange(1, 1, lastRow, numColumns).setVerticalAlignment("middle");
}

/**
 * Adds data validation for capability columns
 * @param {Object} sheet - Sheet object
 * @param {number} lastRow - Last row number
 * @param {number} numColumns - Number of columns
 * @private
 */
function _addDataValidation(sheet, lastRow, numColumns) {
  const validationValues = ["Enable", "Disable"];
  const rule = SpreadsheetApp.newDataValidation()
      .requireValueInList(validationValues)
      .setAllowInvalid(false)
      .build();

  // Get capability column indexes
  const capabilityColumns = [];
  for (let i = 3; i <= numColumns; i++) {
    capabilityColumns.push(i);
  }
  
  // Apply data validation to each capability column
  capabilityColumns.forEach(colIndex => {
    const range = sheet.getRange(3, colIndex, lastRow - 2, 1);
    range.setDataValidation(rule);
  });
}

/**
 * Enables text wrapping for header cells
 * @param {Object} sheet - Sheet object
 * @param {number} numColumns - Number of columns
 * @private
 */
function _enableHeaderTextWrapping(sheet, numColumns) {
  for (let i = 3; i <= numColumns; i++) {
    const headerCell = sheet.getRange(2, i);
    headerCell.setWrap(true);
    headerCell.setVerticalAlignment("middle");
  }
}

/**
 * Adds conditional formatting for capability cells
 * @param {Object} sheet - Sheet object
 * @param {number} lastRow - Last row number
 * @param {number} numColumns - Number of columns
 * @private
 */
function _addConditionalFormatting(sheet, lastRow, numColumns) {
  // Clear existing rules
  sheet.clearConditionalFormatRules();
  
  // Define ranges for conditional formatting
  const formatRanges = [];
  for (let i = 3; i <= numColumns; i++) {
    formatRanges.push(sheet.getRange(3, i, lastRow - 2, 1));
  }
  
  // Create conditional formatting rules
  const rules = [];
  
  // Rule for "Enable"
  rules.push(SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo("Enable")
      .setBackground(CONFIG.COLORS.ENABLE)
      .setRanges(formatRanges)
      .build());
  
  // Rule for "Disable"
  rules.push(SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo("Disable")
      .setBackground(CONFIG.COLORS.DISABLE)
      .setRanges(formatRanges)
      .build());
  
  // Apply rules
  sheet.setConditionalFormatRules(rules);
}

/**
 * Adds legend to the sheet
 * @param {Object} sheet - Sheet object
 * @param {number} startRow - Starting row for legend
 * @private
 */
function _addLegend(sheet, startRow) {
  // Define legend items
  const legendItems = [
    { status: "Enable", color: CONFIG.COLORS.ENABLE, description: "Funcionalidade suportada pelo modelo" },
    { status: "Disable", color: CONFIG.COLORS.DISABLE, description: "Funcionalidade não suportada pelo modelo" }
  ];
  
  // Add legend title
  _addLegendTitle(sheet, startRow);
  
  // Add legend headers
  _addLegendHeaders(sheet, startRow);
  
  // Add legend items
  _addLegendItems(sheet, startRow, legendItems);
  
  // Add legend note
  _addLegendNote(sheet, startRow, legendItems.length);
}

/**
 * Adds legend title
 * @param {Object} sheet - Sheet object
 * @param {number} startRow - Starting row for legend
 * @private
 */
function _addLegendTitle(sheet, startRow) {
  const legendTitleCell = sheet.getRange(startRow, 1, 1, 4);
  legendTitleCell.merge();
  legendTitleCell.setValue("LEGENDA");
  legendTitleCell.setFontWeight("bold");
  legendTitleCell.setHorizontalAlignment("center");
  legendTitleCell.setBackground(CONFIG.COLORS.LEGEND_BG);
  legendTitleCell.setBorder(true, true, true, true, true, true);
}

/**
 * Adds legend headers
 * @param {Object} sheet - Sheet object
 * @param {number} startRow - Starting row for legend
 * @private
 */
function _addLegendHeaders(sheet, startRow) {
  const headerRow = startRow + 1;
  sheet.getRange(headerRow, 1).setValue("Status");
  sheet.getRange(headerRow, 2).setValue("Cor");
  sheet.getRange(headerRow, 3, 1, 2).merge().setValue("Descrição");
  
  // Format headers
  const headerRange = sheet.getRange(headerRow, 1, 1, 4);
  headerRange.setFontWeight("bold");
  headerRange.setBackground(CONFIG.COLORS.HEADER_BG);
  headerRange.setHorizontalAlignment("center");
  headerRange.setBorder(true, true, true, true, true, true);
}

/**
 * Adds legend items
 * @param {Object} sheet - Sheet object
 * @param {number} startRow - Starting row for legend
 * @param {Array} legendItems - Legend items
 * @private
 */
function _addLegendItems(sheet, startRow, legendItems) {
  const headerRow = startRow + 1;
  
  legendItems.forEach((item, index) => {
    const row = headerRow + index + 1;
    
    // Status
    const statusCell = sheet.getRange(row, 1);
    statusCell.setValue(item.status);
    statusCell.setHorizontalAlignment("center");
    statusCell.setBorder(true, true, true, true, true, true);
    
    // Color
    const colorCell = sheet.getRange(row, 2);
    colorCell.setBackground(item.color);
    colorCell.setBorder(true, true, true, true, true, true);
    
    // Description
    const descCell = sheet.getRange(row, 3, 1, 2);
    descCell.merge();
    descCell.setValue(item.description);
    descCell.setBorder(true, true, true, true, true, true);
  });
}

/**
 * Adds legend note
 * @param {Object} sheet - Sheet object
 * @param {number} startRow - Starting row for legend
 * @param {number} itemCount - Number of legend items
 * @private
 */
function _addLegendNote(sheet, startRow, itemCount) {
  const noteRow = startRow + itemCount + 2;
  const noteCell = sheet.getRange(noteRow, 1, 1, 4);
  noteCell.merge();
  noteCell.setValue("Nota: Esta legenda serve como referência para interpretar os status nas células da tabela acima.");
  noteCell.setFontStyle("italic");
  noteCell.setHorizontalAlignment("center");
}