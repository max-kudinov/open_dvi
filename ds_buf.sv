module ds_buf (
    input  in,
    output out,
    output n_out
);

    assign out   = in;
    assign n_out = ~in;

endmodule
