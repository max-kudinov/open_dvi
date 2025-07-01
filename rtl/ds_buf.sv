`default_nettype none

module ds_buf (
    input  logic in,
    output logic out,
    output logic out_n
);

    always_comb begin
        out   =   in;
        out_n = ~ in;
    end

endmodule
