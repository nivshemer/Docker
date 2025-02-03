/*
Change PublicLocation value to support https instead of http
old value: "http://nl-md.Nivshemersecurity.nl:8073/..."
new value: "https://nl-ota.Nivshemersecurity.nl/..."
*/
UPDATE public.service_configurations
SET "Configuration" = jsonb_set(
    "Configuration", 
    '{Updates, PublicLocation}', 
    to_jsonb(regexp_replace("Configuration"->'Updates'->>'PublicLocation', '^(http://)([^/:]+)\.Nivshemersecurity\.nl(:\d+)?(/.*)?$', 'https://\2-ota.Nivshemersecurity.nl/'))
    , true)
WHERE "ServiceName" = 'Management API'
AND "Configuration"->'Updates'->>'PublicLocation' LIKE 'http://%';


/*
Convert old updates "FirmwareLocation" from http to https
old value: "http://nl.Nivshemersecurity.nl:8073/..."
new value: "https://nl-ota.Nivshemersecurity.nl/..."
*/
UPDATE public.update_configurations
SET "FirmwareLocation" = regexp_replace(
  "FirmwareLocation",
  '^(https?://)([^/:]+)\.Nivshemersecurity\.nl(:\d+)?(.*)$',
  'https://\2-ota.Nivshemersecurity.nl\4'
)
WHERE "FirmwareLocation" ~ '^http://.*$' /*AND "UpdateName" = 'test';*/