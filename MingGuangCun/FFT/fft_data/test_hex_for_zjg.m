clear
fileID = fopen('E:\fft\simulations\fft_data\idft_before.hex', 'r');
fft_out_fpga=textread('E:\fft\simulations\test_zjg.txt','%d');
% 读取十六进制数据
hexData = fread(fileID, inf, 'int16');
test_data = hexData(1:1024)
% 关闭文件
fclose(fileID);
for i=1:512
    test_data_complex (i) = test_data(2*i-1) + test_data(2*i)*1j;
    fft_out_fpga_complex(i) = fft_out_fpga(2*i-1) + fft_out_fpga(2*i)*1j;
end

ifft_test_data = ifft(test_data_complex);

% measure error between fpga and oai

for i=1:512
    scale_1(i) = abs(ifft_test_data(i))/abs(fft_out_fpga_complex(i));
end
% plot([1:512],abs(ifft_test_data));
plot(scale_1)


