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
    % 1. URI Completo con tutti i componenti
    test_uri('http://user:pass@www.example.com:8080/path/to/resource?query=param#fragment',
             uri('http', 'user:pass', 'www.example.com', '8080', 'path/to/resource', 'query=param', 'fragment')),

    % 2. URI HTTPS senza userinfo, porta, query e frammento
    test_uri('https://www.secure.com/path/to/resource',
             uri('https', '', 'www.secure.com', '', 'path/to/resource', '', '')),

    % 3. URI FTP con userinfo senza porta e con path semplice
    test_uri('ftp://anonymous@ftp.server.com/resources/file.txt',
             uri('ftp', 'anonymous', 'ftp.server.com', '', 'resources/file.txt', '', '')),

    % 4. URI con schema personalizzato e componenti speciali
    test_uri('custom+scheme://host-name.com:1234/pa-th_./?q=1#frag',
             uri('custom+scheme', '', 'host-name.com', '1234', 'pa-th_./', 'q=1', 'frag')),

    % 5. URI con host IPv6 senza porta
    test_uri('http://[2001:db8::1]/path',
             uri('http', '', '[2001:db8::1]', '', 'path', '', '')),

    % 6. URI con host IPv6 e porta
    test_uri('http://[2001:db8::1]:8080/path',
             uri('http', '', '[2001:db8::1]', '8080', 'path', '', '')),

    % 7. URI senza authority: mailto
    test_uri('mailto:user@example.com',
             uri('mailto', '', '', '', 'user@example.com', '', '')),

    % 8. URI senza authority: urn
    test_uri('urn:isbn:0451450523',
             uri('urn', '', '', '', 'isbn:0451450523', '', '')),

    % 9. URI file con triple slash
    test_uri('file:///C:/path/to/file.txt',
             uri('file', '', '', '', 'C:/path/to/file.txt', '', '')),

    % 10. URI con schema e nessun altro componente
    test_uri('https:', 
             uri('https', '', '', '', '', '', '')),

    % 11. URI con porta non numerica (non standard)
    test_uri('http://host.com:nonnumeric/path',
             uri('http', '', 'host.com', 'nonnumeric', 'path', '', '')),

    % 12. URI con host e porta strani (malformato)
    test_uri('http://host.com:80:extra/path',
             uri('http', '', 'host.com', '80:extra', 'path', '', '')),

    format("Tutti i test sono stati eseguiti.~n").