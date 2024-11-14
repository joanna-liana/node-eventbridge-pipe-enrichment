exports.handler = async (event) => {
  console.log("Original event:", JSON.stringify(event, null, 2));

  // Add enrichment data
  const enrichedEvent = {
    ...event,
    enrichedData: {
      addedBy: "Enrichment Lambda",
      timestamp: new Date().toISOString(),
    }
  };

  console.log("Enriched event:", JSON.stringify(enrichedEvent, null, 2));

  return enrichedEvent;
};
