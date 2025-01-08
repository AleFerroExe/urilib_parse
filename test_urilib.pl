% test_uri(+Input, +StrutturaAttesa)
% Esegue il parsing di Input, confronta il risultato con StrutturaAttesa e stampa il risultato.
test_uri(Input, StrutturaAttesa) :-
    urilib_parse(Input, Risultato),
    ( Risultato = StrutturaAttesa ->
        format("Test passed for ~w~n", [Input])
    ; 
        format("Test FAILED for ~w.~nExpected: ~w~nGot: ~w~n", [Input, StrutturaAttesa, Risultato])
    ).

run_tests :-

% Test: HTTP URI with default port and no path/query/fragment
test('http_simple_scheme', [true(URI == uri('http', [], 'www.example.com', 80, [], [], []))]) :-
    urilib_parse('http://www.example.com', URI).

% Test: HTTPS URI with default port and no path/query/fragment
test('https_simple_scheme', [true(URI == uri('https', [], 'secure.example.com', 443, [], [], []))]) :-
    urilib_parse('https://secure.example.com', URI).

% Test: Mailto scheme with userinfo and host
test('mailto_user_host', [true(URI == uri('mailto', 'john.doe', 'example.com', [], [], [], []))]) :-
    urilib_parse('mailto:john.doe@example.com', URI).

% Test: News scheme with only host
test('news_simple', [true(URI == uri('news', [], 'comp.lang.prolog', [], [], [], []))]) :-
    urilib_parse('news:comp.lang.prolog', URI).

% Test: Tel scheme with only userinfo
test('tel_number', [true(URI == uri('tel', '1234567890', [], [], [], [], []))]) :-
    urilib_parse('tel:1234567890', URI).

% Test: Fax scheme with only userinfo
test('fax_number', [true(URI == uri('fax', '0987654321', [], [], [], [], []))]) :-
    urilib_parse('fax:0987654321', URI).

% Test: ZOS scheme with valid dataset
test('zos_simple', [true(URI == uri('zos', [], [], [], 'MY.DATA.SET', [], []))]) :-
    urilib_parse('zos:MY.DATA.SET', URI).

% Test: ZOS with dataset and member
test('zos_dataset_member', [true(URI == uri('zos', [], [], [], 'MY.DATA.SET(MEMBER)', [], []))]) :-
    urilib_parse('zos:MY.DATA.SET(MEMBER)', URI).

% Test: HTTP with root path
test('http_with_root_path', [true(URI == uri('http', [], 'example.it', 80, '/', [], []))]) :-
    urilib_parse('http://example.it/', URI).

% Test: HTTP with IP address as host
test('http_with_ip_address', [true(URI == uri('http', [], '192.168.0.1', 80, [], [], []))]) :-
    urilib_parse('http://192.168.0.1', URI).

% Test: HTTPS with IP address and port
test('https_with_ip_and_port', [true(URI == uri('https', [], '192.168.0.1', 8080, [], [], []))]) :-
    urilib_parse('https://192.168.0.1:8080', URI).

% Test: Invalid IP address in URI
test('invalid_ip_address', [throws(error(invalid_uri))]) :-
    urilib_parse('http://999.999.999.999', _).

% Test: FTP URI with path and query
test('ftp_with_path_and_query', [true(URI == uri('ftp', [], 'ftp.example.com', 21, 'path/to/file', 'type=ascii', []))]) :-
    urilib_parse('ftp://ftp.example.com/path/to/file?type=ascii', URI).

:- end_tests(urilib_tests).