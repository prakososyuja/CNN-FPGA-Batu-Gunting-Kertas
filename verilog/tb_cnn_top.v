`timescale 1ns / 1ps

module tb_cnn_top;

    reg clk;
    reg rst_n;
    reg start;
    wire done;
    wire [1:0] pred_class;
    wire signed [63:0] score0, score1, score2;

    // Memori sementara untuk menampung 30 gambar sekaligus (30 x 1024 = 30720 piksel)
    reg [7:0] all_test_images [0:30719];

    integer img_idx, px_idx;

    // Instansiasi modul CNN utama
    cnn_top #(
        .SH1(9)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .done(done),
        .pred_class(pred_class),
        .score0(score0),
        .score1(score1),
        .score2(score2)
    );

    // Clock 100 MHz (periode 10 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // 1. Muat bobot, bias, dan seluruh gambar uji dari file .hex
        // Pastikan nama file sesuai dengan yang ada di folder proyek_cnn_fpga

        $readmemh("w_conv.hex",      dut.w_conv_mem);
        $readmemh("b_conv.hex",      dut.b_conv_mem);
        $readmemh("w_fc.hex",        dut.w_fc_mem);
        $readmemh("b_fc.hex",        dut.b_fc_mem);
        $readmemh("test_images.hex", all_test_images);

        // 2. Reset awal
        rst_n = 0;
        start = 0;
        #20;
        rst_n = 1;
        #10;

        $display("==================================================");
        $display("No | Prediksi_Verilog | Score_0 | Score_1 | Score_2");
        $display("==================================================");

        // 3. Loop pengujian untuk 30 gambar
        for (img_idx = 0; img_idx < 30; img_idx = img_idx + 1) begin
            // Salin 1 gambar (1024 piksel) ke memori internal dut
            for (px_idx = 0; px_idx < 1024; px_idx = px_idx + 1) begin
                dut.img_mem[px_idx] = all_test_images[(img_idx * 1024) + px_idx];
            end

            // Mulai inferensi
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;

            // Tunggu sampai selesai
            wait(done == 1'b1);
            @(posedge clk);

            $display("%2d |        %1d         | %7d | %7d | %7d", 
                     img_idx, pred_class, score0, score1, score2);
            
            #20;
        end

        $display("==================================================");
        $display("Simulasi selesai untuk 30 gambar!");
        $stop;
    end

endmodule