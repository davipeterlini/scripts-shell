function createCompareCapabilitiesIDETriggers() {
  // Delete existing triggers for compareCapabilitiesIDE to avoid duplicates
  const triggers = ScriptApp.getProjectTriggers();
  for (const trigger of triggers) {
    if (trigger.getHandlerFunction() === 'compareCapabilitiesIDE') {
      ScriptApp.deleteTrigger(trigger);
    }
  }

  // Create trigger for 7:30 AM daily
  ScriptApp.newTrigger('compareCapabilitiesIDE')
    .timeBased()
    .atHour(7)
    .nearMinute(30)
    .everyDays(1)
    .create();

  // Create trigger for 12:30 PM daily
  ScriptApp.newTrigger('compareCapabilitiesIDE')
    .timeBased()
    .atHour(12)
    .nearMinute(30)
    .everyDays(1)
    .create();
}