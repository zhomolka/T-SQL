
--PRIDANI SEATINGS PRO KAZDEHO OPERATORA, KAZDY WORKPLACE
	-- znove workplaces 801051 - 801079

declare @NewSeatings as table (AgentId uniqueidentifier)
insert into @NewSeatings
	select 
		AgentId
	from icc..Agent where Deleted=0

while (select count(1) from @NewSeatings) >=1
begin
	declare @NewSeating as uniqueidentifier = (select top 1 AgentId from @NewSeatings)
	begin
				
        -- pridani seatingu ke vsem agentum od rady 801051 - 801079
        --801051
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'F1642E8C-13A4-48AB-815A-84F5D42D4DE2',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801052
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'7BED680A-7A6B-485D-B010-9160EB5C5487',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
		--801053
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'0B24CA61-2AD1-4C03-918E-079D33AB0FA2',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801054
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'02A89A45-D4C3-4B22-BB54-C53849243FC0',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801055
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'F39079C4-C9F8-4A68-A499-D6A97D4D72FD',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801056
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'87FF2F5B-CB10-4B4A-9D94-748B14EB6F1F',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801057
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'F3391DD6-218C-4961-9B52-333A564CB752',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801058
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'222A8D2B-4E93-4D87-AF68-A29BF0059E48',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801059
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'9B852AE4-6247-4F49-82ED-F5033050EAD9',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801060
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'CE1482D7-8289-4D89-BF09-C18D5A05DF12',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801061
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'68F0A983-FAB7-4526-A977-C33EBD857EB0',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801062
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'C95181C3-98F7-46EF-B9F8-F2D0B41C5D09',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801063
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'1DB43A6F-CBC1-4468-A171-5AD4A4D5B746',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801064
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'E10F3275-5D86-46C3-8138-42FD768A2D6A',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801065
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'F20EEE73-EA67-4FA7-950D-B34F6613987A',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801066
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'E8218184-28B0-4290-B7C6-79702A313458',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801067
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'1D355E10-2D72-4BEA-B6EF-08A80C752E7D',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801068
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'00255E52-0463-4E5C-94BA-9F305017CFBD',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801069
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'92012B37-F989-4C41-91CB-BF92ECF10892',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801070
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'EC7A9033-D29B-4536-9AFC-06F1C4C7AAF2',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801071
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'59B50188-802E-4A8D-B9B5-7F8490E73C03',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801072
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'12FE8029-4A27-48A4-8508-43B9EA7F604F',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801073
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'8E66C276-3B7A-4CDC-B727-779A5B534103',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801074
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'A382D32B-4F6D-4E6C-9550-F700887E8629',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801075
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'E509D5B1-8C9C-418F-9319-5DCD9D0E65E7',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801076
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'FC86AB29-3AC0-4ED1-B0CC-C9A295A88E3B',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801077
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'E989B5D4-0E5B-484E-A194-A6059D2C67DC',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801078
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'C89760B2-EB95-4729-8C77-BCACA454498B',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
        --801079
        INSERT INTO [dbo].[Seating]
           ([SeatingId],[AgentId],[WorkplaceId],[KnowledgeOffset],[LoginClientModels],[UseClientModels],[Preference])
         VALUES
           (newid (),@NewSeating,'D92131B2-2E73-4F55-8931-ADF58D6ACFA2',0,'ProCaller;WebCaller;WebClient','ProCaller;WebCaller;WebClient',1)
        
	end
	delete from @NewSeatings where AgentId = @NewSeating
end
-----------

Vše všem:

delete from Seating
INSERT INTO Seating SELECT newid() SeatingId, 
AgentId, 
Workplace.WorkplaceId as WorkplaceId, 
0 as KnowlegeOffset, 
'ProCaller;WebCaller;WebClient' as LoginClientModels, 
'ProCaller;WebCaller;WebClient' as UseClientModels,
'1' as PreferenceAge
from Agent cross join Workplace where 
Agent.Deleted = 0 and Workplace.Deleted = 0
Order by AgentId, Workplace.WorkplaceId 

