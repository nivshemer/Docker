UPDATE public.service_configurations 
SET "Configuration" = jsonb_set("Configuration", '{ClosedRegistrationRetryTimeOut}', '60', true)
WHERE "ServiceName" = 'Device Service';