function createCompareCapabilitiesCLITriggers() {
  // Delete existing triggers for compareCapabilitiesCLI to avoid duplicates
  const triggers = ScriptApp.getProjectTriggers();
  for (const trigger of triggers) {
    if (trigger.getHandlerFunction() === 'CLIcompareCapabilities') {
      ScriptApp.deleteTrigger(trigger);
    }
  }

  // Create trigger for 8:00 AM daily
  ScriptApp.newTrigger('CLIcompareCapabilities')
    .timeBased()
    .atHour(8)
    .everyDays(1)
    .create();

  // Create trigger for 13:00 PM daily (1:00 PM)
  ScriptApp.newTrigger('CLIcompareCapabilities')
    .timeBased()
    .atHour(13)
    .everyDays(1)
    .create();
}