module ds_buf (
    input  logic clk_i,
    input  logic in,
    output logic out,
    output logic out_n
);

    always_ff @(posedge clk_i) begin
        out   <=   in;
        out_n <= ~ in;
    end

endmodule
