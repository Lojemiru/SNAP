struct = {
    a : true,
    b : false,
    c : undefined,
    d : 1/9,
    array : [
        5,
        6,
        7,
        {
            struct : "struct!",
            nested : {
                nested : "nested!",
                array : [
                    "more",
                    "MORE",
                    "M O R E"
                ]
            }
        }
    ],
    test : "text!",
    test2 : "\"Hello world!\"",
    url : "https://www.jujuadams.com/"
};

show_debug_message(sna_to_json(struct, true));
show_debug_message(sna_to_json(struct, false));
show_debug_message(sna_to_json(json_to_sna(sna_to_json(struct))));

show_debug_message(sna_to_json(binary_to_sna(sna_to_binary(struct))));