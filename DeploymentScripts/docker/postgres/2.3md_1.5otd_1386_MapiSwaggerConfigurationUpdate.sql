UPDATE public.service_configurations 
SET "Configuration" = jsonb_set("Configuration", '{Swagger}', '{
	"UserName": "swaggeradmin",
	"Password": "nanolocksec"
	}', true)
WHERE "ServiceName" = 'Management API';