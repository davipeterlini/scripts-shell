function createCompareCapabilitiesIDETriggers() {
  // Delete existing triggers for compareCapabilitiesIDE to avoid duplicates
  const triggers = ScriptApp.getProjectTriggers();
  for (const trigger of triggers) {
    if (trigger.getHandlerFunction() === 'compareCapabilitiesIDE') {
      ScriptApp.deleteTrigger(trigger);
    }
  }

  // Create trigger for 9 AM daily
  ScriptApp.newTrigger('compareCapabilitiesIDE')
    .timeBased()
    .atHour(9)
    .everyDays(1)
    .create();

  // Create trigger for 2 PM daily
  ScriptApp.newTrigger('compareCapabilitiesIDE')
    .timeBased()
    .atHour(14)
    .everyDays(1)
    .create();
}
