SELECT     TOP (200) FileRecordId, OriginalName, Name, [Content], FtpTime, Time, Length, Device, Number0, Number1, Number2, Direction, LocalNumber, DateDownload, 
                      NoDelete, Trunk, Number1Filter, AgentName, StationName
FROM         FileRecord
WHERE     (AgentName = 'spcr\mambrozo')