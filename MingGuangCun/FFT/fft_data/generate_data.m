fid=fopen(['E:\fft\simulations\fft_data\test_fft_101_bin.txt'],'w');
N=4096;
error_data = textread('E:\fft\simulations\fft_data\test_fft_101.txt');
for i=1:N
    error_data_complex(i) = error_data(2*i) +error_data(2*i-1)*1j;
end
ifft_result = ifft(error_data_complex);
for i=1:N
        i_re=error_data(2*i);
        i_im=error_data(2*i-1);
        i_re_b=dec2bin(i_re,16);
        i_im_b=dec2bin(i_im,16);

        disp(i_re_b);
        disp(i_im_b);
% %     bb(i)=[i_im_b,i_re_b,'\r\n'];%why this could not work ?
% %     fprintf(fid,[i_re_b,i_im_b,'\r\n']);
        fprintf(fid,[i_re_b,i_im_b,'\r\n']);
end