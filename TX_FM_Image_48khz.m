
clear;
clc;
pkg load image
pkg load signal

[filename, pathname, filterindex] = uigetfile('*.*','Pick a Image file','c:\AM_Image');

pathname = [pathname filename];
data = imread(pathname);
data = imresize(data,[360,640]);
data = rgb2gray(data);  % 0 to 255
data = double(data);
[hpixels,wpixels] = size(data);
data = data / max(data(:));  % 0 to 1
data = data - 0.5;  % -0.5 to 0.5
data = data / max(data(:)); % -1 to 1
data = 0.9 * data;

figure(45)
plot(data(:))




fs = 48e3;
iqdata = zeros(hpixels,wpixels);
t = [1:wpixels]/fs;
f0 = 300;




% set stuff for fm mod
fd = 0.35 * fs;
fd = (fd) / fs;




for k = 1:hpixels
    iqk = cumsum(data(k,:));
    iqk = exp(1i*2*pi*fd*iqk) ;

    iqdata(k,:) = iqk;
end


iqdata = iqdata  /  max(abs(iqdata(:)));



clear data





%create sync chirp file


rg = 1/fs;
pw = 64*rg;   %
bw = 0.8*fs;  % bandwidth of chirp ,
t = [rg:rg:pw];
t = t - pw/2;
slope = bw / (pw);
sync = exp(1i*pi*slope*t.^2);
chirpstack = repmat(sync,hpixels,1);
data = [chirpstack iqdata];
data = reshape(data.',1,[]);
data = data / max( abs(data));


pw = 1024*rg;   %  preamble time ,  500 range gates
bw = 0.5*fs;    %  bandwidth of chirp ,
t = [rg:rg:pw];
t = t - pw/2;
slope = bw / (pw);
preamble = exp(1i*pi*slope*t.^2);
data = [preamble data];


 [filename, pathname] = uiputfile('*.wav','Save I/Q WAVE File','FM_Image_IQ_48khz.wav');

  pathname = [pathname filename];
%pathname = 'C:\temp\FMImage_IQ_48KHZ.wav';

delay = 5;
dN = round(delay * fs);
dN = zeros(1,dN);
data = [dN data dN];
hlpf = fir1(128,0.9);
data = filter(hlpf,1,data);


##NS = length(data);
##t = [1:NS]/fs;
##data = data .* exp(1i*2*pi*50*t);
##data = 10^(-20/20)*data + 10^(-40/20)*[randn(1,NS) + 1i*randn(1,NS) ];




%data = data / max(abs(data));
dx = data;
data = [real(data)'  imag(data)'];
audiowrite(pathname,data,fs);














