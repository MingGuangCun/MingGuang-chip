clear
for i=0:99
    filename_in = sprintf('E:\\fft\\simulations\\SNR_test\\SNR_data_OAI\\random_data_in%d.txt', i);
    filename_out = sprintf('E:\\fft\\simulations\\SNR_test\\SNR_data_OAI\\random_result_out%d.txt', i);
    data_fpga_fft512 = textread(filename_in);
    result_fpga_fft512 = textread(filename_out);
    for k=1:512
        data_fpga_complex(k) = data_fpga_fft512(2*k) + data_fpga_fft512(2*k-1)*1j;
    end
    for k=1:512
        result_fpga_complex(k) = result_fpga_fft512(2*k) + result_fpga_fft512(2*k-1)*1j;
    end
    ifft_result_cmp = ifft(data_fpga_complex)*sqrt(512);
    error = ifft_result_cmp - result_fpga_complex;
    var_fft = var(ifft_result_cmp);
    mean_error = abs(mean(error)^2);
    SNR(i+1) = 10*log10(var_fft/mean_error);
end
plot(SNR)
title('mean(SNR) = 56.47')
xlabel('sample')
ylabel('SNR/dB')
mean(SNR)
