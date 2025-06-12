%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BASE DE CONHECIMENTO (REGRAS DE PRODUÇÃO) %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- dynamic triagem/5.  % Estrutura: DataHora, Sintomas, Nivel, Timestamp, Recomendacao

% Regras de urgência com recomendações associadas
nivel_urgencia(vermelho, [compromisso_via_aerea, respiracao_ineficaz, choque, crianca_nao_responde, convulsao_atual],
    'Emergência máxima! Atendimento imediato. Preparar equipa de reanimação.').

nivel_urgencia(laranja, [grande_hemorragia_incontrolavel, alteracao_estado_consciencia, dor_severa],
    'Emergência alta. Atendimento em 10 minutos. Monitorizar constantemente.').

nivel_urgencia(amarelo, [pequena_hemorragia_incontrolavel, vomitos_persistentes, dor_moderada],
    'Urgência moderada. Atendimento em 1 hora. Avaliar periodicamente.').

nivel_urgencia(verde, [vomitos, dor_ligeira],
    'Urgência baixa. Atendimento em 2 horas. Orientar paciente.').

nivel_urgencia(azul, [pequenos_cortes, dor_muito_ligeira, sintomas_resfriado, queixa_cronica_estavel],
    'Caso não urgente. Atendimento em 240 minutos. Encaminhar para consulta de cuidados primários ou medicação leve.').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SISTEMA DE INFERÊNCIA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determina o nível de urgência com base numa lista de sintomas

determinar_urgencia([], desconhecido, 'Nenhum Sintoma Reconhecido. Consulte um médico para avaliação.').  
determinar_urgencia(Sintomas, Nivel, Recomendacao) :-  
    encontrar_niveis(Sintomas, ListaNiveis),
    mais_urgente(ListaNiveis, Nivel),  
    nivel_urgencia(Nivel, _, Recomendacao).  

% Obtém os níveis de urgência de uma lista de sintomas  
encontrar_niveis([], []).  
encontrar_niveis([Sintoma|Resto], [Nivel|Niveis]) :-  
    nivel_urgencia(Nivel, Sintomas, _),  
    member(Sintoma, Sintomas), !,  
    encontrar_niveis(Resto, Niveis).  
encontrar_niveis([_|Resto], Niveis) :-  
    encontrar_niveis(Resto, Niveis).  

% Define a hierarquia de urgência  
mais_urgente(ListaNiveis, NivelMaisAlto) :-  
    ordem_urgencia(Ordem),  
    member(NivelMaisAlto, Ordem),  
    member(NivelMaisAlto, ListaNiveis), !.  

ordem_urgencia([vermelho, laranja, amarelo, verde, azul, desconhecido]).  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SISTEMA DE TRIAGEM INTERATIVO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

processo_triagem :-  
    write('==== SISTEMA DE TRIAGEM HOSPITALAR ===='), nl,  
    write('Lista completa de Sintomas Disponíveis:'), nl,
    listar_sintomas_disponiveis,
    write('Quais os Sintomas que sente? Insira uma Lista entre parênteses retos, separados por vírgulas (ex: [dor_severa, vomitos_persistentes]): '),  
    read(Sintomas),  
    (determinar_urgencia(Sintomas, Nivel, Recomendacao) ->  
        registar_triagem(Sintomas, Nivel, Recomendacao),  
        mostrar_resultado(Nivel, Recomendacao)  
    ;  
        write('Sintomas não reconhecidos. Tente Novamente.'), nl,  
        processo_triagem  
    ).  

% Lista todos os sintomas disponíveis agrupados por nível de urgência
listar_sintomas_disponiveis :-
    nivel_urgencia(Nivel, Sintomas, _),
    write('Nível '), write(Nivel), write(': '), nl,
    listar_itens(Sintomas),
    nl, fail.
listar_sintomas_disponiveis.

listar_itens([]).
listar_itens([H|T]) :-
    write('- '), write(H), nl,
    listar_itens(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BASE DE DADOS (REGISTOS DE TRIAGEM) %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Registar triagem na base de dados
registar_triagem(Sintomas, Nivel, Recomendacao) :-
    get_time(Timestamp),
    format_time(atom(DataHora), '%Y-%m-%d %H:%M:%S', Timestamp),
    assertz(triagem(DataHora, Sintomas, Nivel, Timestamp, Recomendacao)).

% Listar triagens registadas
listar_triagens :- 
    write('==== HISTÓRICO DE TRIAGENS ===='), nl, nl,
    forall(triagem(DataHora, Sintomas, Nivel, _, Recomendacao),
           (write('Data e Hora: '), write(DataHora), nl,
            write('Sintomas: '), write(Sintomas), nl,
            write('Nível: '), write(Nivel), nl,
            write('Recomendação: '), write(Recomendacao), nl,
            nl)).

% Limpar base de dados
limpar_triagens :-
    retractall(triagem(_, _, _, _, _)),
    write('Todos os Registos de Triagem foram Removidos.'), nl.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INTERFACE DE UTILIZADOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mostrar_resultado(Nivel, Recomendacao) :-
    nl, write('==== RESULTADO DA TRIAGEM ===='), nl, nl,
    write('Nível de Urgência: '), write(Nivel), nl,
    write('Recomendação: '), write(Recomendacao), nl, nl,
    write('Por favor, informe a Equipa Médica.'), nl.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MENU PRINCIPAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iniciar :-
    nl, write('==== SISTEMA DE TRIAGEM MÉDICA ===='), nl, nl,
    write('1. Iniciar Nova Triagem'), nl,
    write('2. Ver Histórico de Triagens'), nl,
    write('3. Limpar Histórico'), nl,
    write('4. Sair'), nl, nl,
    write('Escolha uma opção: '),
    read(Opcao),
    executar_opcao(Opcao).

executar_opcao(1) :- processo_triagem, iniciar.
executar_opcao(2) :- listar_triagens, iniciar.
executar_opcao(3) :- limpar_triagens, iniciar.
executar_opcao(4) :- write('Sistema encerrado.'), nl.
executar_opcao(_) :- write('Opção inválida!'), nl, iniciar.

:- iniciar.
