clc;clear;
%打开数据文件，32bit为一个数，包括实部和虚部（各16bit）
fid1 = fopen('E:\fft\simulations\fft_data\idft_before.hex','r');
%每次读取16bit
Rx_temp1 = fread(fid1,inf,'int16');
Rx_temp_real1 = Rx_temp1(1:2:length(Rx_temp1));
Rx_temp_imag1 = Rx_temp1(2:2:length(Rx_temp1));
%转换为复数序列
data1 = Rx_temp_real1 + Rx_temp_imag1*1i;
data1_1 = data1(1:512);

% 
% fid2 = fopen('idft_after.hex','r');
% %每次读取16bit
% Rx_temp2 = fread(fid2,inf,'int16');
% Rx_temp_real2 = Rx_temp2(1:2:length(Rx_temp2));
% Rx_temp_imag2 = Rx_temp2(2:2:length(Rx_temp2));
% %转换为复数序列
% data2 = Rx_temp_real2 + Rx_temp_imag2*1i;
% 
% fid3 = fopen('add_cp.hex','r');
% %每次读取16bit
% Rx_temp3 = fread(fid3,inf,'int16');
% Rx_temp_real3 = Rx_temp3(1:2:length(Rx_temp3));
% Rx_temp_imag3 = Rx_temp3(2:2:length(Rx_temp3));
% %转换为复数序列
% data3 = Rx_temp_real3 + Rx_temp_imag3*1i;




% data2_1 = data2(1:512);

data1_ifft = ifft(data1_1);

figure(1);
plot(abs(data1_ifft));
title("MATLAB IFFT结果");

% figure(2);
% plot(abs(data2_1));
% title("C IFFT结果");



fclose("all");