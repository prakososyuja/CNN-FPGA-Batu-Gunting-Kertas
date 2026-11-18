`timescale 1ns / 1ps

module cnn_top #(
    parameter SH1 = 9
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    output reg        done,
    output reg  [1:0] pred_class,
    output reg signed [63:0] score0,
    output reg signed [63:0] score1,
    output reg signed [63:0] score2
);

    // Memori internal
    reg [7:0]         img_mem    [0:1023]; // 32x32 gambar input (unsigned 0..255)
    reg signed [7:0]  w_conv_mem [0:35];   // 4 filter x 3x3
    reg signed [31:0] b_conv_mem [0:3];    // 4 bias conv
    reg signed [7:0]  w_fc_mem   [0:2699]; // 3 kelas x 900 fitur
    reg signed [31:0] b_fc_mem   [0:2];    // 3 bias fc

    // Buffer hasil MaxPool (15x15x4 = 900 elemen, rentang 0..127)
    reg [7:0] pool_mem [0:899];

    // State Machine
    localparam S_IDLE = 3'd0,
               S_CONV = 3'd1,
               S_FC   = 3'd2,
               S_ARG  = 3'd3,
               S_DONE = 3'd4;

    reg [2:0] state;

    // Variabel loop & akumulator
    integer f, pi, pj, di, dj, m, n, idx_pool, idx_img, idx_w;
    reg signed [63:0] acc;
    reg signed [63:0] max_val;
    reg signed [63:0] shifted_val;
    reg signed [63:0] scores [0:2];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            done       <= 1'b0;
            pred_class <= 2'd0;
            score0     <= 64'd0;
            score1     <= 64'd0;
            score2     <= 64'd0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= S_CONV;
                    end
                end

                // Tahap 1: Conv2D (3x3) + Bias + ReLU + MaxPool (2x2) + Shift & Clamp
                S_CONV: begin
                    for (pi = 0; pi < 15; pi = pi + 1) begin
                        for (pj = 0; pj < 15; pj = pj + 1) begin
                            for (f = 0; f < 4; f = f + 1) begin
                                max_val = 64'd0; // ReLU otomatis karena minimal 0

                                // Evaluasi 2x2 area untuk MaxPooling
                                for (m = 0; m < 2; m = m + 1) begin
                                    for (n = 0; n < 2; n = n + 1) begin
                                        acc = b_conv_mem[f];
                                        for (di = 0; di < 3; di = di + 1) begin
                                            for (dj = 0; dj < 3; dj = dj + 1) begin
                                                idx_img = ((pi*2 + m + di) * 32) + (pj*2 + n + dj);
                                                idx_w   = (f * 9) + (di * 3) + dj;
                                                acc     = acc + ($signed({1'b0, img_mem[idx_img]}) * w_conv_mem[idx_w]);
                                            end
                                        end
                                        if (acc > max_val) begin
                                            max_val = acc;
                                        end
                                    end
                                end

                                // Shift kanan SH1 dan clamp maksimal 127
                                shifted_val = max_val >>> SH1;
                                if (shifted_val > 64'd127)
                                    shifted_val = 64'd127;

                                // Urutan flatten di Keras: (15, 15, 4) -> (pi*15 + pj)*4 + f
                                idx_pool = ((pi * 15) + pj) * 4 + f;
                                pool_mem[idx_pool] = shifted_val[7:0];
                            end
                        end
                    end
                    state <= S_FC;
                end

                // Tahap 2: Fully Connected Layer (900 -> 3)
                S_FC: begin
                    for (f = 0; f < 3; f = f + 1) begin
                        acc = b_fc_mem[f];
                        for (idx_pool = 0; idx_pool < 900; idx_pool = idx_pool + 1) begin
                            idx_w = (f * 900) + idx_pool;
                            acc   = acc + ($signed({1'b0, pool_mem[idx_pool]}) * w_fc_mem[idx_w]);
                        end
                        scores[f] = acc;
                    end
                    score0 <= scores[0];
                    score1 <= scores[1];
                    score2 <= scores[2];
                    state  <= S_ARG;
                end

                // Tahap 3: Argmax (pilih skor tertinggi)
                S_ARG: begin
                    if (scores[0] >= scores[1] && scores[0] >= scores[2])
                        pred_class <= 2'd0;
                    else if (scores[1] >= scores[0] && scores[1] >= scores[2])
                        pred_class <= 2'd1;
                    else
                        pred_class <= 2'd2;
                    state <= S_DONE;
                end

                S_DONE: begin
                    done <= 1'b1;
                    if (!start) begin
                        state <= S_IDLE;
                    end
                end
            endcase
        end
    end

endmodule