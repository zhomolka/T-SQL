SELECT TOP 100 DisplayName,GatewayId FROM iCC..Gateway WHERE Deleted=0 
 and (InDevice LIKE '%EWSHost%' AND InDevice NOT LIKE '%ClientId%' or
 OutDevice LIKE '%EWSHost%' AND OutDevice NOT LIKE '%ClientId%')
