
#[generate_trait]
pub impl Base64Encoder of Base64EncoderTrait {

    #[inline(always)]
    fn encode_json(data: ByteArray, encode_data: bool) -> ByteArray {
        (Self::encode_mime_type(data, "data:application/json", encode_data))
    }

    #[inline(always)]
    fn encode_svg(data: ByteArray, encode_data: bool) -> ByteArray {
        (Self::encode_mime_type(data, "data:image/svg+xml", encode_data))
    }

    #[inline(always)]
    fn encode_mime_type(data: ByteArray, mime_type: ByteArray, encode_data: bool) -> ByteArray {
        if (encode_data) {
            (format!("{};base64,{}", mime_type, Self::encode_bytes(data)))
        } else {
            (format!("{},{}", mime_type, data))
        }
    }

    fn encode_bytes(mut bytes: ByteArray) -> ByteArray {
        let base64_chars: Span<u8> = array!['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'].span();
        let mut result: ByteArray = "";
        if bytes.len() == 0 {
            return result;
        }
        let mut p: u8 = 0;
        let c = bytes.len() % 3;
        if c == 1 {
            p = 2;
            bytes.append_byte(0_u8);
            bytes.append_byte(0_u8);
        } else if c == 2 {
            p = 1;
            bytes.append_byte(0_u8);
        }
        let mut i = 0;
        let bytes_len = bytes.len();
        let last_iteration = bytes_len - 3;
        loop {
            if i == bytes_len {
                break;
            }
            let n: u32 = (bytes.at(i).unwrap()).into()
                * 65536 | (bytes.at(i + 1).unwrap()).into()
                * 256 | (bytes.at(i + 2).unwrap()).into();
            let e1 = (n / 262144) & 63;
            let e2 = (n / 4096) & 63;
            let e3 = (n / 64) & 63;
            let e4 = n & 63;
            if i == last_iteration {
                if p == 2 {
                    result.append_byte(*base64_chars[e1]);
                    result.append_byte(*base64_chars[e2]);
                    result.append_byte('=');
                    result.append_byte('=');
                } else if p == 1 {
                    result.append_byte(*base64_chars[e1]);
                    result.append_byte(*base64_chars[e2]);
                    result.append_byte(*base64_chars[e3]);
                    result.append_byte('=');
                } else {
                    result.append_byte(*base64_chars[e1]);
                    result.append_byte(*base64_chars[e2]);
                    result.append_byte(*base64_chars[e3]);
                    result.append_byte(*base64_chars[e4]);
                }
            } else {
                result.append_byte(*base64_chars[e1]);
                result.append_byte(*base64_chars[e2]);
                result.append_byte(*base64_chars[e3]);
                result.append_byte(*base64_chars[e4]);
            }
            i += 3;
        };
        result
    }
}


//----------------------------------------
// Unit  tests
//
#[cfg(test)]
mod unit {
    use super::{Base64EncoderTrait};

    fn DECODED() -> ByteArray {
        ("<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" width=\"600\" height=\"600\" viewBox=\"-1 -1 6 6\"><style>text{fill:#fff;font-size:1px;font-family:'Courier New',monospace;}.BG{fill:#000;}</style><g><rect class=\"BG\" x=\"-1\" y=\"-1\" width=\"6\" height=\"6\" /><text x=\"0\" y=\"1\">Karat</text><text x=\"0\" y=\"2\">#1</text></g></svg>")
    }
    fn ENCODED() -> ByteArray {
        ("PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIHdpZHRoPSI2MDAiIGhlaWdodD0iNjAwIiB2aWV3Qm94PSItMSAtMSA2IDYiPjxzdHlsZT50ZXh0e2ZpbGw6I2ZmZjtmb250LXNpemU6MXB4O2ZvbnQtZmFtaWx5OidDb3VyaWVyIE5ldycsbW9ub3NwYWNlO30uQkd7ZmlsbDojMDAwO308L3N0eWxlPjxnPjxyZWN0IGNsYXNzPSJCRyIgeD0iLTEiIHk9Ii0xIiB3aWR0aD0iNiIgaGVpZ2h0PSI2IiAvPjx0ZXh0IHg9IjAiIHk9IjEiPkthcmF0PC90ZXh0Pjx0ZXh0IHg9IjAiIHk9IjIiPiMxPC90ZXh0PjwvZz48L3N2Zz4=")
    }
    fn ENCODED_MIME() -> ByteArray {
        ("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIHdpZHRoPSI2MDAiIGhlaWdodD0iNjAwIiB2aWV3Qm94PSItMSAtMSA2IDYiPjxzdHlsZT50ZXh0e2ZpbGw6I2ZmZjtmb250LXNpemU6MXB4O2ZvbnQtZmFtaWx5OidDb3VyaWVyIE5ldycsbW9ub3NwYWNlO30uQkd7ZmlsbDojMDAwO308L3N0eWxlPjxnPjxyZWN0IGNsYXNzPSJCRyIgeD0iLTEiIHk9Ii0xIiB3aWR0aD0iNiIgaGVpZ2h0PSI2IiAvPjx0ZXh0IHg9IjAiIHk9IjEiPkthcmF0PC90ZXh0Pjx0ZXh0IHg9IjAiIHk9IjIiPiMxPC90ZXh0PjwvZz48L3N2Zz4=")
    }

    #[test]
    fn test_encode_bytes() {
        let _encoded = Base64EncoderTrait::encode_bytes(DECODED());
        assert_eq!(_encoded, ENCODED(), "bad encode_bytes()");
    }

    #[test]
    fn test_encode_mime() {
        let _svg = Base64EncoderTrait::encode_svg(DECODED(), true);
        assert_eq!(_svg, ENCODED_MIME(), "bad encoding");
    }
}
