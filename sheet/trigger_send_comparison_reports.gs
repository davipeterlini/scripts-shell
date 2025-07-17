/**
 * Email recipients for comparison reports
 */
const REPORT_RECIPIENTS = [
  'davi.peterlini@ciandt.com',
  'laisbonafe@ciandt.com',
  'arysanchez@ciandt.com'
];

/**
 * Creates triggers to check for comparison reports and send emails
 */
function createSendComparisonReportsTriggers() {
  // Delete existing triggers to avoid duplicates
  const triggers = ScriptApp.getProjectTriggers();
  for (const trigger of triggers) {
    if (trigger.getHandlerFunction() === 'sendComparisonReports') {
      ScriptApp.deleteTrigger(trigger);
    }
  }

  // Create trigger for 10:30 AM daily
  ScriptApp.newTrigger('sendComparisonReports')
    .timeBased()
    .atHour(10)
    .nearMinute(30)
    .everyDays(1)
    .create();

  // Create trigger for 3:30 PM daily
  ScriptApp.newTrigger('sendComparisonReports')
    .timeBased()
    .atHour(15)
    .nearMinute(30)
    .everyDays(1)
    .create();
    
  Logger.log('Triggers created for 10:30 AM and 3:30 PM daily');
}

/**
 * Checks for comparison report sheets and sends emails with divergences
 */
function sendComparisonReports() {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  
  // Check for CLI Report
  const cliReportSheet = _findSheet(spreadsheet, 'Comparison-CLI-Report');
  if (cliReportSheet) {
    const cliDivergences = _extractDivergences(cliReportSheet);
    if (cliDivergences.length > 0) {
      _sendDivergenceEmail(REPORT_RECIPIENTS, 'CLI Comparison Report Divergences', cliDivergences);
      Logger.log('CLI report email sent');
    } else {
      Logger.log('No CLI divergences found');
    }
  } else {
    Logger.log('CLI report sheet not found');
  }
  
  // Check for IDE Report
  const ideReportSheet = _findSheet(spreadsheet, 'Comparison-IDE-Report');
  if (ideReportSheet) {
    const ideDivergences = _extractDivergences(ideReportSheet);
    if (ideDivergences.length > 0) {
      _sendDivergenceEmail(REPORT_RECIPIENTS, 'IDE Comparison Report Divergences', ideDivergences);
      Logger.log('IDE report email sent');
    } else {
      Logger.log('No IDE divergences found');
    }
  } else {
    Logger.log('IDE report sheet not found');
  }
}

/**
 * Finds a sheet by name
 * @param {Spreadsheet} spreadsheet - The spreadsheet to search in
 * @param {string} sheetName - The name of the sheet to find
 * @return {Sheet|null} The found sheet or null if not found
 * @private
 */
function _findSheet(spreadsheet, sheetName) {
  try {
    return spreadsheet.getSheetByName(sheetName);
  } catch (e) {
    Logger.log(`Error finding sheet ${sheetName}: ${e.message}`);
    return null;
  }
}

/**
 * Extracts divergences from a comparison report sheet
 * @param {Sheet} sheet - The sheet containing divergences
 * @return {Array} Array of divergence data
 * @private
 */
function _extractDivergences(sheet) {
  const data = sheet.getDataRange().getValues();
  
  // Skip header row
  if (data.length <= 1) {
    return [];
  }
  
  // Return all rows except the header
  return data.slice(1).filter(row => row.some(cell => cell !== ''));
}

/**
 * Sends an email with divergence information
 * @param {Array} recipients - List of email addresses
 * @param {string} subject - Email subject
 * @param {Array} divergences - Array of divergence data
 * @private
 */
function _sendDivergenceEmail(recipients, subject, divergences) {
  // Create HTML table for the email body
  let tableRows = '';
  
  // Add table headers - assuming first row contains headers
  const headers = ['Capability', 'Expected', 'Actual', 'Status'];
  
  tableRows += '<tr style="background-color: #f2f2f2; font-weight: bold;">';
  headers.forEach(header => {
    tableRows += `<td style="padding: 8px; border: 1px solid #ddd;">${header}</td>`;
  });
  tableRows += '</tr>';
  
  // Add data rows
  divergences.forEach((row, index) => {
    const backgroundColor = index % 2 === 0 ? '#ffffff' : '#f9f9f9';
    tableRows += `<tr style="background-color: ${backgroundColor};">`;
    
    // Add each cell in the row
    row.forEach(cell => {
      // Determine cell color based on status (if it's the status column)
      let cellStyle = 'padding: 8px; border: 1px solid #ddd;';
      if (cell === 'FAIL') {
        cellStyle += ' color: red; font-weight: bold;';
      } else if (cell === 'PASS') {
        cellStyle += ' color: green;';
      }
      
      tableRows += `<td style="${cellStyle}">${cell}</td>`;
    });
    
    tableRows += '</tr>';
  });
  
  // Complete HTML email body
  const htmlBody = `
    <html>
      <body>
        <h2>${subject}</h2>
        <p>The following divergences were found in the comparison report:</p>
        <table style="border-collapse: collapse; width: 100%; border: 1px solid #ddd;">
          ${tableRows}
        </table>
        <p>This is an automated message. Please do not reply.</p>
      </body>
    </html>
  `;
  
  // Send the email
  GmailApp.sendEmail(
    recipients.join(','),
    subject,
    `Divergences found in the comparison report. Please view this email in HTML format.`, // Plain text fallback
    { htmlBody: htmlBody }
  );
}