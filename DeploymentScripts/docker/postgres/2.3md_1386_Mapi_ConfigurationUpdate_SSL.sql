/*
Change PublicLocation value to support https instead of http
old value: "http://nl-md.nanolocksecurity.nl:8073/..."
new value: "https://nl-ota.nanolocksecurity.nl/..."
*/
UPDATE public.service_configurations
SET "Configuration" = jsonb_set(
    "Configuration", 
    '{Updates, PublicLocation}', 
    to_jsonb(regexp_replace("Configuration"->'Updates'->>'PublicLocation', '^(http://)([^/:]+)\.nanolocksecurity\.nl(:\d+)?(/.*)?$', 'https://\2-ota.nanolocksecurity.nl/'))
    , true)
WHERE "ServiceName" = 'Management API'
AND "Configuration"->'Updates'->>'PublicLocation' LIKE 'http://%';


/*
Convert old updates "FirmwareLocation" from http to https
old value: "http://nl.nanolocksecurity.nl:8073/..."
new value: "https://nl-ota.nanolocksecurity.nl/..."
*/
UPDATE public.update_configurations
SET "FirmwareLocation" = regexp_replace(
  "FirmwareLocation",
  '^(https?://)([^/:]+)\.nanolocksecurity\.nl(:\d+)?(.*)$',
  'https://\2-ota.nanolocksecurity.nl\4'
)
WHERE "FirmwareLocation" ~ '^http://.*$' /*AND "UpdateName" = 'test';*/