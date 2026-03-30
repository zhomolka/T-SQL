BEGIN TRANSACTION

UPDATE Workplace SET DisplayName = 'Lisecová Kristýna' WHERE Number='20257' AND Deleted=0 
UPDATE Workplace SET DisplayName = 'Vyletová Jana' WHERE Number='20258' AND Deleted=0
UPDATE Workplace SET DisplayName = 'Slavíková Barbora' WHERE Number='20262' AND Deleted=0 
UPDATE Workplace SET DisplayName = 'Zboøil Jan' WHERE Number='20251' AND Deleted=0 
UPDATE Workplace SET DisplayName = 'Kepková Monika' WHERE Number='20264' AND Deleted=0 
UPDATE Workplace SET DisplayName = 'Volné pracovištì' WHERE Number='20265' AND Deleted=0
UPDATE Workplace SET DisplayName = 'Volné pracovištì' WHERE Number='20242' AND Deleted=0 
COMMIT TRANSACTION
--ROLLBACK TRANSACTION
