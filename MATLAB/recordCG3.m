function out = recordCG3(varargin)
% function recordGloveData(port, 'p1', v1, 'p2', v2, ...)
% Allows to record data from a CyberGlove III using Matlab. Data is 
% displayed onscreen, returned as structure and optionally saved to a file.
% Closing the window displaying the data stops the streaming process.
% WARNING: This function only saves 2^20 (1'048'576 samples). This is more
% than 3h of data at 90Hz. Attempting to collect more data incurs to risk
% of data loss and timing issues.
% 
% Optional inputs:
% <port>    String indicating the COM port number of the CyberGlove (e.g.
%           'COM1').
%
% Parameters: (insert as parameter name/value pairs (e.g.: 'acc', 0.9))
%
% <Fs>      Sampling rate for the CyberGlove in Hz. Possible values are 30,
%           60 or 90.
%           Default is 90 Hz.
%
% <opts>    A structure with the following fields:
%               - 'usb': 1 or 0, indicates whether to stream over USB or
%                   not respectively.
%                   Default is 1 (USB streaming is ON).
%               - 'wifi': 1 or 0, indicates whether to stream over WiFi or
%                   not respectively.
%                   Default is 0 (WiFi streaming is OFF).
%               - 'sd': 1 or 0, indicates whether to save data to the SD
%                   file or not respectively.
%                   Default is 0 (SD card saving is OFF).
%               - 'streamMode': '8bit' or '12bit', indicates the resolution
%                   of the data stream obtained from the glove.
%                   file or not respectively.
%                   WARNING: This option could not be tested reliably. No
%                   guarantee that it actually works.
%                   Default is 0 (SD card saving is OFF).
%
% <SDFile>  String indicating the name of the file to which the data
%           should be saved on the glove. Only valid if the 'sd' option
%           was set to 1.
%           Default is 'default.txt'.
%
% <saveFile>    String indicating the name of the file to which the data
%               recorded should be saved. If the file does not exist, it is
%               created. If the file exsists, it will be overwritten.
%               Default is 'CG3Data.mat'.
%
% Written by Andreas Thomik, July 2013

%% Parse inputs and set defaults
p = inputParser;

p.addOptional('port', [], @(x)ischar(x) || (isscalar(x) && isdouble(x)));
p.addParamValue('opts', [], @(x)isstruct(x));
p.addParamValue('Fs', 90, @(x)any(x == [30, 60, 90]));
p.addParamValue('SDFile', [], @(x)ischar(x) || isempty(x));
p.addParamValue('saveFile', 'CG3Data.mat', @(x)ischar(x) || isempty(x));

p.parse(varargin{:})

args = p.Results;

glovePort = args.port;
Fs = args.Fs;
opts = args.opts;
SDFile = args.SDFile;
saveFile = args.saveFile;

clearvars p args
%% Define a few commands
queryStatus = [63, 71];
startStream8Bit = 'S';
startStream12Bit = '1S';
stopStream = [3];

PAUSE_USB = 0.1;
PAUSE_WIFI = 0.5;

global GLOVE_CLOSE GLOVE_OPEN GLOVE_REC;
global data;
global serialTime;
global matlabTime;
global sampCnt;

GLOVE_CLOSE = 0;
GLOVE_OPEN = 1;
GLOVE_REC = 2;
sampCnt = 1;


%% Check options structure and set defaults
opts = parseOpts(opts);

if opts.sd
    if isempty(SDFile)
        warning('The active file for the SD card was set to its default value.')
        disp('The active file is now called ''default.txt''')
        SDFile ='default.txt';
    end
end

if opts.wifi
    PAUSE_TIME = PAUSE_WIFI;
else
    PAUSE_TIME = PAUSE_USB;
end
%% Set default values, display warnings
global state nBytes;

% Ask for port ID if it has not been passed as argument to the function
if isempty(glovePort)
    glovePort = input('Glove COM port?\n', 's');
end
glove = serial(glovePort);  % Create glove object

% Display a warning if someone tries to use the glove timestamp
if strcmp(opts.streamMode, '12bit') && Fs == 90
    warning(['Requesting the timestamp from the glove directly '...
        'limits the sampling frequency to 60Hz.'])
    cnt = input('Continue recording? Y\\[N]\n', 's');
    if any(strcmp(cnt, {'Y', 'y'}))
        disp('Setting sampling rate to 60Hz...')
        Fs = 60;
    else 
        return;
    end
end

% Set glove status depending on glove status
if strcmp(glove.Status, 'closed')
    state = GLOVE_CLOSE;
elseif strcmp(glove.Status, 'open')
    state = GLOVE_OPEN;
end

% If the timestamp is requested from the glove, this means that the data is
% now sent on a 12bit/sensor format, which makes the total byte count 61.
if strcmp(opts.streamMode, '12bit')
    nBytes = 61;
else
    nBytes = 24;
end

% Initialise the data structure to record 1048576 samples (> 3h of data at
% 90Hz)
data = zeros(2^20, nBytes);
serialTime = zeros(2^20, 7);
matlabTime = zeros(2^20, 7);

% Inform about limitation in data collection
disp(['WARNING: This function only saves 2^20 (1''048''576 samples). '...
    'This is more than 3h of data at 90Hz.'])
disp('Attempting to collect more data incurs to risk of data loss and timing issues.')

% Set a few parameters for glove communication
glove.BaudRate = 115200;
glove.InputBufferSize = 2^18;     % Set to a large value
glove.BytesAvailableFcnMode = 'byte';
% glove.BytesAvailableFcnMode = 'terminator';
glove.BytesAvailableFcnCount = nBytes;
glove.BytesAvailableFcn = {@getGloveSample};
glove.RecordName = saveFile;
glove.RecordDetail = 'verbose';

%% Set the streaming parameters
% They are given in the format '1 E FM SD USB WIFI 1 1 1' where FM is the
% frame-rate multiplier, SD, USB and WIFI indicate the streaming modalities
% to use and 1 1 1 are the sampling-rate dividers (which are fixed here)
streamOpts = ones(1,9);

% The command starts with '1E' here in ASCII values
streamOpts(1) = 49;
streamOpts(2) = 69;

% The third byte is the frame-rate multiplier
switch Fs
    case 30
        streamOpts(3) = double('1');
    case 60
        streamOpts(3) = double('2');
    case 90
        streamOpts(3) = double('3');
    otherwise
        error('Sampling rate not recognised.')
end

streamOpts(4) = double(num2str(opts.sd));
streamOpts(5) = double(num2str(opts.usb));
streamOpts(6) = double(num2str(opts.wifi));
streamOpts(7:end) = double('1');

%% Attempt to open glove

disp('Attempting to open glove...')
if state == GLOVE_CLOSE
    fopen(glove);
    % Ensure that the glove is closed no matter what
    finishup = onCleanup(@()cleanFun(glove));
    pause(2)
    % Clear buffer
    if glove.BytesAvailable
        fread(glove, glove.BytesAvailable);
    end
elseif state == GLOVE_OPEN
    % This should never happen.
    disp('Glove is already open.')
end

disp('Checking glove status...')
fwrite(glove, queryStatus);
pause(PAUSE_TIME)
s = fread(glove, 4);

if s(3) == 3
    disp('Glove OK!');
else
    disp('Error connecting to glove, closing...')
    fclose(glove);
    return
end

%% Set streaming parameters 
if opts.sd
    fwrite(glove, [double('1A') double(SDFile) 1])
    pause(PAUSE_TIME)
    [tmp, cnt] = fread(glove);
    if cnt ~= 1 && tmp ~= 0
        warning('The SD file name was sent but the response did not match the expected value. The response obtained was:')
        disp(char(tmp'))
        return
    end
    tmp = clock;
    tmp = [tmp round(1000*rem(tmp(end), 1))];
    tmp(end-1) = round(tmp(end-1));
    tmp = num2str(tmp);
    str = 'Data recorded on ';
    fwrite(glove, [double([str tmp]) 1])
    [tmp, cnt] = fread(glove);
    if cnt ~= 1 && tmp ~= 0
        warning('The SD file name was sent but the response did not match the expected value. The response obtained was:')
        disp(char(tmp'))
        return
    end
    disp('Active file set on SD card.')
end

fwrite(glove, streamOpts);
pause(PAUSE_TIME)
[tmp, cnt] = fread(glove, glove.BytesAvailable);

if cnt ~= 2 && ~strcmp(tmp, '1E')
    warning('The streaming parameters were sent but the response did not match the expected value. The response obtained was:')
    disp(char(tmp'))
    return
else
    disp('Streaming parameters set!')
end

%% Record data
switch opts.streamMode
    case '8bit'
        disp('Start streaming 8 bit values.')
        fwrite(glove, double(startStream8Bit));
        fwrite(glove, double(startStream8Bit));
        glove.Terminator = 0;
        state = GLOVE_REC;
    case '12bit'
        disp('Start streaming 12 bit values with timestamp')
        fwrite(glove, double(startStream12Bit));
        fwrite(glove, double(startStream12Bit));
        glove.Terminator = 0;
        state = GLOVE_REC;
end

h = figure;
while ishandle(h)
    plot(1, 1);
    drawnow
%     if ~isempty(glove.UserData)
%         plot(glove.UserData)
%         drawnow
%     end
end

% Save data structure
out.data = data(1:sampCnt-1,:);
out.serialTime = serialTime(1:sampCnt-1,:);
out.matlabTime = matlabTime(1:sampCnt-1,:);

if ~isempty(saveFile)
    disp(['Trying to save data to ' saveFile '. This may take a while...'])
    save(saveFile, 'out', '-v7.3');
    disp('Data saved successfully!')
end

end

function getGloveSample(glove, event)
global GLOVE_REC state nBytes data matlabTime serialTime sampCnt;

tStmpProc = clock;  % Time at which the data was processed
tStmpProc = [tStmpProc, round(1e3*rem(tStmpProc(end),1))];
tStmpProc(end-1) = round(tStmpProc(end-1));
matlabTime(sampCnt,:) = tStmpProc;

if state ~= GLOVE_REC
    return 
end

% Remove offset which comes from god knows where
if sampCnt == 1
    fread(glove, 1);
end

% [tmp, numPts] = fgets(glove);
% if numPts ~= 24 || (tmp(1) ~= 83 && tmp(24) ~= 0)
%     disp('Dropped 1 data frame')
%     return
% end

% data(sampCnt,:) = tmp';%fread(glove, nBytes)';
data(sampCnt,:) = fread(glove, nBytes)';

% if data(sampCnt, 1) ~= 83 && data(sampCnt, 24) ~= 0
%     disp('Dropped 1 data frame')
%     return
% end

% if sampCnt < 3
%     if data(1) ~= 83 % 83 = double('S')
%         error('Something is wrong with the recording...')
%     elseif data(sampCnt, 2) ~= double('S')
%         error('Something is wrong with the recording...')
%     end
% end

tStmpRec = event.Data.AbsTime;  % Time at which the data was received
tStmpRec = [tStmpRec, 1e3*rem(tStmpRec(end),1)];
tStmpRec(end-1) = round(tStmpRec(end-1));
serialTime(sampCnt,:) = tStmpRec;

% if ~rem(sampCnt,50)
%     glove.UserData = data(sampCnt-49:sampCnt,:);
% end

% Increment data counter
sampCnt = sampCnt + 1;
return

end

function cleanFun(glove)

global GLOVE_REC state;

if state == GLOVE_REC
    disp('Stop steaming...')
    fwrite(glove, 3);
    tmp = [];
    while tmp ~= glove.BytesAvailable
        tmp = glove.BytesAvailable;
        pause(PAUSE_TIME)
    end
    % Clear buffer
    if glove.BytesAvailable
        fread(glove, glove.BytesAvailable);
    end
end

record(glove, 'off');

disp('Closing glove...')    
if strcmp(glove.Status, 'open')
    fclose(glove);
end
delete(glove)

end

function opts = parseOpts(opts)
% Parses the options structure and sets default values

if isempty(opts)
    opts.wifi = 0;
    opts.usb = 1;
    opts.sd = 0;
    opts.streamMode = '8bit';
end

% Check the wifi setting
if ~isfield(opts, 'wifi')
    opts.wifi = 0;
else
    if isempty(opts.wifi)
        opts.wifi = 0;
    elseif ~any(opts.wifi == [0 1])
        error('The value for the ''wifi'' option must be either 0 or 1.')
    end
end

% Check the USB setting
if ~isfield(opts, 'usb')
    opts.usb = 1;
else
    if isempty(opts.usb)
        opts.usb = 1;
    elseif ~any(opts.usb == [0 1])
        error('The value for the ''usb'' option must be either 0 or 1.')
    end
end

% Check the SD setting
if ~isfield(opts, 'sd')
    opts.sd = 0;
else
    if isempty(opts.sd)
        opts.sd = 0;
    elseif ~any(opts.sd == [0 1])
        error('The value for the ''sd'' option must be either 0 or 1.')
    end
end

% Check the streaming mode
if ~isfield(opts, 'streamMode')
    opts.streamMode = '8bit';
else
    if isempty(opts.streamMode)
        opts.sd = '8bit';
    elseif ~any(strcmp(opts.streamMode, {'8bit', '12bit'}))
        error('The value for the ''streamMode'' option must be either ''8bit'' or ''12bit''.')
    end
end

end