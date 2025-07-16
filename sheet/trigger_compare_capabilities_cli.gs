function createCompareCapabilitiesCLITriggers() {
  // Delete existing triggers for compareCapabilitiesCLI to avoid duplicates
  const triggers = ScriptApp.getProjectTriggers();
  for (const trigger of triggers) {
    if (trigger.getHandlerFunction() === 'CLIcompareCapabilities') {
      ScriptApp.deleteTrigger(trigger);
    }
  }

  // Create trigger for 10 AM daily
  ScriptApp.newTrigger('CLIcompareCapabilities')
    .timeBased()
    .atHour(10)
    .everyDays(1)
    .create();

  // Create trigger for 3 PM daily
  ScriptApp.newTrigger('CLIcompareCapabilities')
    .timeBased()
    .atHour(15)
    .everyDays(1)
    .create();
}
