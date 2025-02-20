clear
N = 512;
fft_in=textread('E:\fft\simulations\fft_data\test_1_error_data_ifft.txt','%d');
ifft_oai_out=textread('E:\fft\simulations\fft_data\ifft_oai_out.txt','%d');
cnt = 0;
% 输入数据
for i=1:N
    fft_in_complex(i)=fft_in(2*i-1)+fft_in(2*i)*1j;
end
% oai端输出的ifft结果
for i=1:N
    ifft_out_complex(i)=ifft_oai_out(2*i-1)+ifft_oai_out(2*i)*1j;
end

ifft_out_cmp_complex = ifft(fft_in_complex);
% fft_out_cmp_complex = fft(fft_in_complex);
% scale = real(ifft_out_complex(1))/real(ifft_out_cmp_complex(1))
% 
% for i=1:10
%     cmp = "cmp=";
%     x86_out = "x86=";
%     error(i)=ifft_out_complex(i)-ifft_out_cmp_complex(i)*scale;
%     display(error(i))
%     cmp = cmp + ifft_out_cmp_complex(i)*scale;
%     x86_out = x86_out + ifft_out_complex(i);
%     disp(cmp)
%     disp(x86_out)
%     
% end

% scatterplot(fft_out_complex);

