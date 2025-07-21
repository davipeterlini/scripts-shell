function createLLMTriggers() {
  // Delete existing triggers for fetchMappedCapabilities to avoid duplicates
  const triggers = ScriptApp.getProjectTriggers();
  for (const trigger of triggers) {
    if (trigger.getHandlerFunction() === 'fetchMappedCapabilities') {
      ScriptApp.deleteTrigger(trigger);
    }
  }

  // Create trigger for 7 AM daily
  ScriptApp.newTrigger('fetchMappedCapabilities')
    .timeBased()
    .atHour(7)
    .everyDays(1)
    .create();

  // Create trigger for 12 PM daily
  ScriptApp.newTrigger('fetchMappedCapabilities')
    .timeBased()
    .atHour(12)
    .everyDays(1)
    .create();
}