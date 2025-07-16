function createLLMTriggers() {
  // Delete existing triggers for fetchMappedCapabilities to avoid duplicates
  const triggers = ScriptApp.getProjectTriggers();
  for (const trigger of triggers) {
    if (trigger.getHandlerFunction() === 'fetchMappedCapabilities') {
      ScriptApp.deleteTrigger(trigger);
    }
  }

  // Create trigger for 8 AM daily
  ScriptApp.newTrigger('fetchMappedCapabilities')
    .timeBased()
    .atHour(8)
    .everyDays(1)
    .create();

  // Create trigger for 1 PM daily
  ScriptApp.newTrigger('fetchMappedCapabilities')
    .timeBased()
    .atHour(13)
    .everyDays(1)
    .create();
}