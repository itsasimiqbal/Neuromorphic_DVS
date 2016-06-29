% Receives events continuosly from jaer AEViewer which sends them
% using AEUnicastOutput on default port 8991 on localhost.
% Requires InstrumentControlToolbox.
% In AEViewer, use menu item File/Remote/Enable AEUnicastOutput and 
% select jAER Defaults for the settings, but set the buffer size to 8192
% bytes which is the maximum buffer supported by matlab's udp.

% TODO not yet really working, should use async reading with callback
port=7941; % default port in jAER for AEUnicast connections
bufsize=8192; %81
eventsize=8;
count = 0;
r1 = zeros(2000,2000);
r2 = zeros(2000,2000);
try
    fprintf('opening datagram input to localhost:%d\n',port);
    u=udp('localhost','localport',port,'timeout',1,'inputbuffersize',bufsize,'DatagramTerminateMode','on');
    fopen(u);
    lastSeqNum=0;
    while 1,
%         raw=fread(u);
        if(u.BytesAvailable==0),
            pause(.1);
            continue;
        end % 
        raw=fread(u,u.BytesAvailable/4,'int32');
        if ~isempty(raw),
            seqNum=raw(1); % current broken size we cannot easily convert to int from array of bytes,and we cannot know size to read if reading synchronously so we can't use fread's conversion capability. lame.
            if(seqNum~=lastSeqNum+1), fprintf('dropped %d packets\n',(seqNum-lastSeqNum)); end
            lastSeqNum=seqNum;
    %         fprintf('%d bytes\n',length(b));
            if length(raw)>2,
                allAddr=raw(2:2:end); % addr are each 4 bytes (uint32) separated by 4 byte timestamps
                allTs=raw(3:2:end); % ts are 4 bytes (uint32) skipping 2 bytes after each
            end
            %fprintf('%d events\n',length(allAddr));
            %fprintf('%d events\n',length(raw));
            fprintf('%d \nAddress\n', allAddr);
            fprintf('%d Time Stamps\n', allTs(1));
            count = count + 1;
            fprintf('%d total frames\n', count);
            [a1,m1] = size(allAddr);
            [a2,m2] = size(allTs);
            r1(1:a1,count) = allAddr(:,1); % each column contains events against one frame
            r2(1:a2,count) = allTs(:,1); % each column contains time_stamps against one frame
            
            
            %events
        end
        pause(.1);
    end
catch ME
    ME
    fclose(u);
    %save r1
    %save r2
    delete(u);
    clear u
end
