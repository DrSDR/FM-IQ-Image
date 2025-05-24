% read the  iq wave file
% [filename, pathname, filterindex] = uigetfile('*.*','Pick a FSK IQ wave file','c:\FSK4Level\');
clear;
close all;

fs = 48e3;

debugflag = 0;

[filename, pathname, filterindex] = uigetfile('*.*','Pick a Image IQ wave file','c:\FM_Image');

pathname = [pathname filename];
[message,fswave] = audioread(pathname);
[audiosamples,nch] = size(message);
if nch == 2
    message = message(:,1) + 1i*message(:,2);
    message = message.';
%     message = message / max(message);
else
    message = message';
%     message = message / max(message);
end



if fswave ~= fs

    x = gcd(fswave,fs);
    a = fs/x;
    b = fswave/x;
    message = resample(message,a,b);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% enter in expected image dim details
%image pixels height and width
h = 360;
w = 640;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%create sync chirp file


rg = 1/fs;
pw = 64*rg;   %
bw = 0.8*fs;  % bandwidth of chirp ,
t = [rg:rg:pw];
t = t - pw/2;
slope = bw / (pw);
sync = exp(1i*pi*slope*t.^2);
sN = length(sync);



pw = 1024*rg;   % preamble time ,  500 range gates
bw = 0.5*fs;  % bandwidth of chirp ,
t = [rg:rg:pw];
t = t - pw/2;
slope = bw / (pw);
preamble = exp(1i*pi*slope*t.^2);


h1 = conj(sync(end:-1:1));
h1N = length(h1);
h2 = conj(preamble(end:-1:1));
h2N = length(h2);


%find preamble
h2detect = filter(h2,1,(message));
[Imax, indx] = max(abs(h2detect));
index = indx + 1;

% a = indx - (h2N - 1);
% b = indx;
%
% tonesig = message(a:b);
%
%
%
% % compute freq of tonesig
% td1 = [0 tonesig(1:end-1)]; % delay by one sample
% td1 = conj(td1);
% z = tonesig .* td1;
% z = angle(z);
% Tswave = 1/fs;
% z = (1/(2*pi)) * (z / Tswave);
% z = z(56:end-56);  % remove edges for freq mean
% % figure(12222)
% % plot(z)
% foffset = mean(z);
% foffset = -1 * foffset;
%













data = message(index:end);
Ndata = length(data);
% t = [1:Ndata]/fs;
% data = data .* exp(1i*2*pi*foffset*t);

pic = zeros(h,w);
pictime = zeros(h,w);

x1 = 1;
x2 = w + sN;

for k = 1:h

    if x1 >= Ndata || x2 >= Ndata
        break
    end

    iqk = data(x1:x2);
    syncdet = filter(h1,1,iqk);

##    figure(1234)
##    plot(abs(syncdet))


    [imax,index] = max(abs(syncdet));

    a = index + 1;



    iqpic = iqk(a:end);

    if length(iqpic) >= w
        iqpic = iqpic(1:w);
    else
        iqpic = [iqpic zeros(1,w - length(iqpic))];
    end




    pictime(k,:) = 20*log10(abs(iqpic(1:w)));
    iqpic = conj(filter([0,1],1,iqpic)) .* iqpic ;
%     iqpic = iqpic - mean(iqpic);
    iqpic = angle(iqpic);
     %iqpic = iqpic - mean(iqpic);
    pic(k,:) = iqpic(1:w);
    x1 = x1 + index + w;
    x2 = x1 + w + sN;

    if debugflag
        figure(56)
        set(56,'Position',[200,1,1280,900]);
        whitebg(56,'k');
        subplot(2,1,1)
        plot(real(iqk) , 'y');
        hold on
        plot(imag(iqk) , 'm');
        title('IQ Data');
        hold off

        subplot(2,1,2)
        plot(iqpic , 'g')
        title('FM Demod Trace');
        pause(0.1);
    end



end



w = round(w);
h = round(h);
figure(22)
colormap('jet')
set(22,'Position',[50,600,w,h]);
imagesc(pictime);


figure(23)
colormap('bone')
set(23, 'Position',[50,50,w,h]);
imagesc(-1*pic)




figure(24)
colormap('bone')
set(24, 'Position',[600,50,w,h]);
imagesc(pic)










