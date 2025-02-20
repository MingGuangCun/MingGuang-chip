% generate fft_8 stimulate data and result
% include 25 set of data
fft_in=textread('E:\fft\simulations\fft_data\fft_oai_in1.txt','%d');
fft_out=textread('E:\fft\simulations\result.txt','%d');
fid_data=fopen(['fft_8_data.txt'],'w');
fid_result=fopen(['fft_8_result.txt'],'w');
fft_fpga_in = fft_in;
N=1024;
set_num = N/8;
for i=1:N
    fft_fpga_in_complex(i)=fft_fpga_in(2*i)+fft_fpga_in(2*i-1)*1j;
    fft_fpga_out_complex(i)=fft_out(2*i)+fft_out(2*i-1)*1j;
%     i_re_b=num2str(dec2bin(fft_fpga_in(2*i),16));
%     i_im_b=num2str(dec2bin(fft_fpga_in(2*i-1),16));
%     fprintf(fid_data,[i_im_b,'\n',i_re_b,'\n']);
end
for i=1:set_num
    fft_result_cmp = fft(fft_fpga_in_complex(8*i-7:8*i));
    fft_result     = fft_fpga_out_complex(8*i-7:8*i);
    error = abs(fft_result_cmp -fft_result);
    error_mean(i) = mean(error);
    SNR(i) = 10*log10(var(fft_result_cmp)/(mean(error)^2))
end

plot(SNR)
title('mean(SNR) = 48.90')
xlabel('sample')
ylabel('SNR/dB')
mean(SNR)
