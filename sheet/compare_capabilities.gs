/**
 * Compares capabilities across columns for each model and provider.
 * Returns success if all values in the same row are identical across specified columns.
 * Otherwise, returns error messages for divergent models.
 */
function compareCapabilities() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getActiveSheet();
  const data = sheet.getDataRange().getValues();
  
  // Find header row and identify column indexes
  const headerRow = data[0];
  const providerColIndex = headerRow.indexOf("Provider");
  const modelColIndex = headerRow.indexOf("Modelo");
  
  // If essential columns are not found, return error
  if (providerColIndex === -1 || modelColIndex === -1) {
    return "Error: Required columns 'Provider' and 'Modelo' not found.";
  }
  
  // Skip header row
  const contentRows = data.slice(1);
  const divergentModels = [];
  
  // For each row, compare values across all columns (except Provider and Modelo)
  contentRows.forEach((row, rowIndex) => {
    const provider = row[providerColIndex];
    const model = row[modelColIndex];
    
    // Get values for comparison (skip Provider and Modelo columns)
    const valuesToCompare = [];
    for (let colIndex = 0; colIndex < row.length; colIndex++) {
      if (colIndex !== providerColIndex && colIndex !== modelColIndex) {
        valuesToCompare.push(row[colIndex]);
      }
    }
    
    // Check if all values are the same
    const firstValue = valuesToCompare[0];
    const allSame = valuesToCompare.every(value => value === firstValue);
    
    if (!allSame) {
      divergentModels.push({
        provider: provider,
        model: model,
        rowIndex: rowIndex + 2 // +2 because we're 0-indexed and skipped header
      });
    }
  });
  
  // Return results
  if (divergentModels.length === 0) {
    return "Success: All models have consistent capabilities across columns.";
  } else {
    let errorMessage = "Error: The following models have inconsistent capabilities:\n";
    divergentModels.forEach(item => {
      errorMessage += `- ${item.provider} ${item.model} (Row ${item.rowIndex})\n`;
    });
    return errorMessage;
  }
}

/**
 * Creates a menu item to run the comparison.
 */
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('Capabilities')
    .addItem('Compare Capabilities', 'showComparisonResults')
    .addToUi();
}

/**
 * Shows the comparison results in a dialog.
 */
function showComparisonResults() {
  const ui = SpreadsheetApp.getUi();
  const result = compareCapabilities();
  ui.alert('Comparison Results', result, ui.ButtonSet.OK);
}