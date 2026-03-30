 IF EXISTS(SELECT * FROM iCC.dbo.LiteralLookup WHERE LiteralGroup=44 AND LiteralValue=15
   AND Culture='cs-CZ' AND LiteralText='AgentMissed' AND DisplayName='Změškáno')
    BEGIN
     UPDATE iCC.dbo.LiteralLookup
     SET DisplayName='Zmeškáno'
      WHERE LiteralGroup=44 AND LiteralValue=15
       AND Culture='cs-CZ' AND LiteralText='AgentMissed' AND DisplayName='Změškáno'
	   PRINT 'Náprava Změškáno byla provedena'
    END
