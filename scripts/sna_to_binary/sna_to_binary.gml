/// @return Buffer that contains binary encoded struct/array nested data
/// 
/// @param struct/array   The data to be encoded. Can contain structs, arrays, strings, and numbers.   N.B. Will not encode ds_list, ds_map etc.
/// 
/// @jujuadams 2020-05-02

function sna_to_binary(_ds)
{
    return (new __sna_to_binary_parser(_ds)).buffer;
}

function __sna_to_binary_parser(_ds) constructor
{
    root = _ds;
    buffer = buffer_create(1024, buffer_grow, 1);
    
    static parse_struct = function(_struct)
    {
        buffer_write(buffer, buffer_u8, 0x01);
        
        var _names = variable_struct_get_names(_struct);
        var _count = array_length(_names);
        var _i = 0;
        repeat(_count)
        {
            var _name = _names[_i];
            value = variable_struct_get(_struct, _name);
            
            if (is_struct(_name) || is_array(_name))
            {
                show_error("Key type \"" + typeof(_name) + "\" not supported\n ", false);
                _name = string(ptr(_name));
            }
            
            buffer_write(buffer, buffer_u8, 0x03);
            buffer_write(buffer, buffer_string, string(_name));
            
            write_value();
            
            ++_i;
        }
        
        buffer_write(buffer, buffer_u8, 0x00);
    }
    
    
    
    static parse_array = function(_array)
    {
    
        var _count = array_length(_array);
        var _i = 0;
        
        buffer_write(buffer, buffer_u8, 0x02);
        
        repeat(_count)
        {
            value = _array[_i];
            write_value();
            ++_i;
        }
        
        buffer_write(buffer, buffer_u8, 0x00);
    }
    
    
    
    static write_value = function()
    {
        if (is_struct(value))
        {
            parse_struct(value);
        }
        else if (is_array(value))
        {
            parse_array(value);
        }
        else if (is_string(value))
        {
            buffer_write(buffer, buffer_u8, 0x03);
            buffer_write(buffer, buffer_string, value);
        }
        else if (is_real(value))
        {
            if (value == 0)
            {
                buffer_write(buffer, buffer_u8, 0x05);
            }
            else if (value == 1)
            {
                buffer_write(buffer, buffer_u8, 0x06);
            }
            else
            {
                buffer_write(buffer, buffer_u8, 0x04);
                buffer_write(buffer, buffer_f64, value);
            }
        }
        else if (is_bool(value))
        {
            buffer_write(buffer, buffer_u8, value? 0x06 : 0x05);
        }
        else if (is_undefined(value))
        {
            buffer_write(buffer, buffer_u8, 0x07);
        }
        else if (is_int32(value))
        {
            buffer_write(buffer, buffer_u8, 0x08);
            buffer_write(buffer, buffer_s32, value);
        }
        else if (is_int64(value))
        {
            buffer_write(buffer, buffer_u8, 0x09);
            buffer_write(buffer, buffer_u64, value);
        }
        else
        {
            show_message("Datatype \"" + typeof(value) + "\" not supported");
        }
    }
    
    
    
    if (is_struct(root))
    {
        parse_struct(root);
    }
    else if (is_array(root))
    {
        parse_array(root);
    }
    else
    {
        show_error("Value not struct or array. Returning empty string\n ", false);
    }
    
    buffer_resize(buffer, buffer_tell(buffer));
}