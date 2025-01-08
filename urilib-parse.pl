uri(_, _, _, _, _, _, _).

% --- Suddivide una lista in due parti in base a un taglio ---
split_list([], _, [], []).
split_list(Lista, Taglio, [], Lista) :-
    \+ member(Taglio, Lista), !.
split_list([Taglio|Coda], Taglio, [], Coda) :- !.
split_list([Testa|Coda], Taglio, [Testa|Pre], Post) :-
    split_list(Coda, Taglio, Pre, Post).

% --- Converte stringa o atomo in lista di codici ---
stringa_a_lista(StringaOAtomo, ListaCodici) :-
    (  string(StringaOAtomo)
    -> string_codes(StringaOAtomo, ListaCodici)
    ;  atom(StringaOAtomo)
    -> atom_codes(StringaOAtomo, ListaCodici)
    ;  throw(error(non_stringa_o_atomo, StringaOAtomo))
    ).

% --- Converte lista di codici in lista di atomi singoli ---
lista_codici_a_lista_atomi([], []).
lista_codici_a_lista_atomi([Codice|Codici], [Atomo|Atomi]) :-
    char_code(Carattere, Codice),
    atom_chars(Atomo, [Carattere]),
    lista_codici_a_lista_atomi(Codici, Atomi).

% --- Converte lista di caratteri in atomo/stringa ---
lista_a_percorso([], '') :- !.
lista_a_percorso(Lista, Atomo) :- atom_chars(Atomo, Lista).

% --- Parsifica l'authority in userinfo, host e port ---
parsa_authority(ListaAuthority, InformazioniUtente, Host, Porta) :-
    ( member('@', ListaAuthority) ->
        split_list(ListaAuthority, '@', ListaUserInfo, ListaHostPort),
        lista_a_percorso(ListaUserInfo, InformazioniUtente)
    ;
        InformazioniUtente = '',
        ListaHostPort = ListaAuthority
    ),
    parsa_host_port(ListaHostPort, Host, Porta).

% --- Parsifica host e port da una lista, con gestione IPv6 ---
parsa_host_port(ListaHostPort, Host, Porta) :-
    ( ListaHostPort = ['[' | _] ->
         split_with_ipv6(ListaHostPort, Host, Porta)
    ; member(':', ListaHostPort) ->
         split_list(ListaHostPort, ':', ListaHost, ListaPorta),
         lista_a_percorso(ListaHost, Host),
         lista_a_percorso(ListaPorta, Porta)
    ; 
         lista_a_percorso(ListaHostPort, Host),
         Porta = ''
    ).

split_with_ipv6(ListaHostPort, Host, Porta) :-
    append(HostPart, DopoBracket, ListaHostPort),
    last(HostPart, ']'),
    lista_a_percorso(HostPart, Host),
    ( DopoBracket = [':'|PortaList] -> 
          lista_a_percorso(PortaList, Porta)
    ; 
          Porta = ''
    ).

% --- Parsifica path, query e fragment ---
parsa_path_query_fragment(Resto, Percorso, Query, Frammento) :-
    % Gestione del frammento, se presente
    ( member('#', Resto) ->
        split_list(Resto, '#', PartePrimaDelFragmento, ListaFragmento),
        lista_a_percorso(ListaFragmento, Frammento)
    ;
        PartePrimaDelFragmento = Resto,
        Frammento = ''
    ),
    % Gestione della query, se presente
    ( member('?', PartePrimaDelFragmento) ->
        split_list(PartePrimaDelFragmento, '?', PartePrimaDellaQuery, ListaQuery),
        lista_a_percorso(ListaQuery, Query)
    ;
        PartePrimaDellaQuery = PartePrimaDelFragmento,
        Query = ''
    ),
    % Il resto è il percorso
    lista_a_percorso(PartePrimaDellaQuery, Percorso).

% --- Sistema di printing ---
pl(Var, Testo) :- 
    term_to_atom(Testo, TestoOut),
    ( is_list(Var) -> list_to_path(Var, VarT) ; VarT = Var ),
    ( var(VarT) -> VarOut = '' ; atomics_to_string([VarT], VarOut) ),
    write(TestoOut),
    write(': '),
    write(VarOut),
    nl.

% --- Stampa i componenti di un URI ---
stampa_componenti_uri(URI) :-
    URI = uri(Schema, InformazioniUtente, Host, Porta, Percorso, Query, Frammento),
    pl(Schema, 'Schema'),
    pl(InformazioniUtente, 'InformazioniUtente'),
    pl(Host, 'Host'),
    pl(Porta, 'Porta'),
    pl(Percorso, 'Percorso'),
    pl(Query, 'Query'),
    pl(Frammento, 'Frammento').

% --- Predicato principale per il parsing di un URI ---
urilib_parse(URIStringa, URI) :-
    stringa_a_lista(URIStringa, ListaCodiciURI),
    lista_codici_a_lista_atomi(ListaCodiciURI, ListaURI),

    % Parsing dello schema
    split_list(ListaURI, ':', ListaSchema, RestoDopoSchema),
    lista_a_percorso(ListaSchema, Schema),

    (   RestoDopoSchema = ['/', '/' | RestoSenzaSlash]
    ->  % Caso in cui l'URI contiene '//' dopo lo schema
        split_list(RestoSenzaSlash, '/', ListaAuthority, RestoPathQueryFragment),
        parsa_authority(ListaAuthority, InformazioniUtente, Host, Porta),
        parsa_path_query_fragment(RestoPathQueryFragment, Percorso, Query, Frammento)
    ;   % Caso in cui non c'è authority
        InformazioniUtente = '',
        Host = '',
        Porta = '',
        parsa_path_query_fragment(RestoDopoSchema, Percorso, Query, Frammento)
    ),

    % Costruisce la struttura URI con i componenti ottenuti
    URI = uri(Schema, InformazioniUtente, Host, Porta, Percorso, Query, Frammento),

    % Stampa i componenti dell'URI
    stampa_componenti_uri(URI),
    !.

%%--------------------------------------------------------------------------------------------------------------------------------------

%%esempio di stringa completa :  https://www.w3.org:134/path/path2?query=faghjeifeya#fragment
