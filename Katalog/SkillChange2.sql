
select * from project order by displayname
select distinct teamname from agent
select distinct groupname from agent

begin tran
update skill
set PbxInEnabled=1, PbxInChannel=1, PbxInKnowledge=50
where AgentId in (select agentid from agent where GroupName like 'OBJ%' or groupname like 'OST%')
and ProjectId='F1FE4242-2653-4FC3-8BE2-A96FABDA79BC'
--rollback
commit

begin tran
update skill
set PbxInEnabled=1, PbxInChannel=1, PbxInKnowledge=60
where AgentId in (select agentid from agent where GroupName like 'RMA%')
and ProjectId='F1FE4242-2653-4FC3-8BE2-A96FABDA79BC'
--rollback
commit


