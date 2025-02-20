% test for version 1.0.1 fft
data = textread('E:\fft\simulations\fft_data\test_fft_101.txt');
result_fpga_fft8 = textread('E:\fft\simulations\fft_data\test_fft_101_fpga.txt');

% for i=1:512
%     data_complex(i) = data(2*i) + data(2*i-1)*1j;
% end
% data_fft = round(fft(data_complex)/22);
% for i=1:512
%     result_fpga_complex(i) = result_fpga_fft8(2*i) + result_fpga_fft8(2*i-1)*1j;
%     error(i)               = abs(result_fpga_complex(i)-data_fft(i));
% end

for i=0:99
    filename_in = sprintf('E:\\fft\\simulations\\SNR_test\\SNR_data\\random_data_in%d.txt', i);
    filename_in = sprintf('E:\\fft\\simulations\\SNR_test\\SNR_data\\random_result_out%d.txt', i);
    data_fpga_fft512 = textread(filename_in);
    result_fpga_fft512 = textread(filename_out);
    for i=1:512
        data_fpga_complex(i) = data_fpga_fft512(2*i) + data_fpga_fft512(2*i-1)*1j;
    end
    for i=1:512
        result_fpga_complex(i) = result_fpga_fft512(2*i) + result_fpga_fft512(2*i-1)*1j;
    end
    
end

% plot(error);
% SNR = 10*log10(var(data_fft)/(mean(error)^2))

