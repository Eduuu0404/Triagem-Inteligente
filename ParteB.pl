:- dynamic fact/1.       % Declara fact/1 como dinâmico para permitir modificações em tempo de execução
:- op(600, fx, if).      % Prioridade baixa para o operador `if`, que é um operador prefixo
:- op(650, xfx, then).   % Prioridade mais alta para o operador `then`, que é um operador infixo
:- op(500, xfy, or).     % Prioridade mais baixa para o operador `or`, com associação à direita
:- op(400, xfy, and).    % Prioridade baixa para o operador `and`, com associação à direita
:- op(300, xfx, eq).     % Operador personalizado `eq` para igualdade, com prioridade inferior ao `and`
:- op(200, xfx, <=).     % Operador `<=`, com prioridade ainda mais baixa, para associação de provas


% Regras

demo(P, P) :- fact(P).
demo(P, P <= CondProof) :-
    if Cond then P, demo(Cond, CondProof).
demo(P1 and P2, Proof1 and Proof2) :-
    demo(P1, Proof1), demo(P2, Proof2).
demo(P1 or P2, Proof) :-
    demo(P1, Proof);
    demo(P2, Proof).

% base de conhecimento

if (paragem_cardiorrespiratoria eq sim) then vermelha.
if (dor_severa eq sim) then laranja.
if (pequena_hemorragia_incontrolavel eq sim and convulsao eq nao) then amarelo.
if (vomitos eq sim) then verde.
if (dor_muito_ligeira eq sim or arranhoes eq sim) then azul.
if (congestao_nasal eq sim and vomitos_persistentes eq nao) then azul.
if (compromisso_via_aerea eq sim) then vermelha.
if (grande_hemorragia_incontrolavel eq sim) then laranja.
if (dor_abdominal_moderada eq sim) then amarelo.
if (sintomas_resfriado eq sim and grande_hemorragia eq nao) then azul.
if (convulsao eq sim) then vermelha.
if (alteracao_estado_consciencia eq sim) then laranja.
if (dor_moderada eq sim and respiracao_ineficaz eq nao) then amarelo.
if (dor_ligeira eq sim) then verde.
if (pequenos_cortes eq sim) then azul.
if (respiracao_ineficaz eq sim) then vermelha.
if (choque eq sim) then vermelha.
if (queixa_cronica_estavel eq sim and tontura_ligeira eq nao) then azul.
if (desorientacao eq sim) then laranja.
if (grande_hemorragia eq sim) then vermelha.
if (febre_alta eq sim) then amarelo.
if (tontura_ligeira eq sim) then verde.
if (dor_muito_ligeira eq sim and vomitos_persistentes eq nao) then azul.
if (crianca_nao_responde eq sim) then vermelha.
if (vomitos_persistentes eq sim) then amarelo.
if (dor_intensa_localizada eq sim) then laranja.
if (false) then azul. % Caso por defeito para qualquer situação não tratada

% Fatos (dados de exemplo)
% Fatos estáticos removidos para evitar conflitos com a entrada do utilizador

% Interface do utilizador

start :-
    write('Bem vindo ao sistema de triagem!'), nl,
    write('Responda ás questôes que lhe irão ser perguntadas com "sim" ou "não":'), nl,
    ask_questions,
    determine_triagem.

ask_questions :- 
    ask('O paciente está em paragem cardiorrespiratória?', paragem_cardiorrespiratoria),
    ask('O paciente apresenta dor severa?', dor_severa),
    ask('O paciente apresenta pequena hemorragia incontrolável?', pequena_hemorragia_incontrolavel),
    ask('O paciente está em convulsão?', convulsao),
    ask('O paciente está com vómitos?', vomitos),
    ask('O paciente apresenta dor muito ligeira?', dor_muito_ligeira),
    ask('O paciente tem arranhões?', arranhoes),
    ask('O paciente está com congestão nasal?', congestao_nasal),
    ask('O paciente apresenta vómitos persistentes?', vomitos_persistentes),
    ask('Há compromisso da via aérea?', compromisso_via_aerea),
    ask('O paciente apresenta grande hemorragia incontrolável?', grande_hemorragia_incontrolavel),
    ask('O paciente apresenta dor abdominal moderada?', dor_abdominal_moderada),
    ask('O paciente apresenta sintomas de resfriado?', sintomas_resfriado),
    ask('O paciente apresenta grande hemorragia?', grande_hemorragia),
    ask('O paciente apresenta alteração do estado de consciência?', alteracao_estado_consciencia),
    ask('O paciente apresenta dor moderada?', dor_moderada),
    ask('O paciente apresenta respiração ineficaz?', respiracao_ineficaz),
    ask('O paciente apresenta dor ligeira?', dor_ligeira),
    ask('O paciente tem pequenos cortes?', pequenos_cortes),
    ask('O paciente está em choque?', choque),
    ask('O paciente apresenta queixa crônica estável?', queixa_cronica_estavel),
    ask('O paciente apresenta tontura ligeira?', tontura_ligeira),
    ask('O paciente está desorientado?', desorientacao),
    ask('O paciente tem febre alta?', febre_alta),
    ask('A criança não responde a estímulos?', crianca_nao_responde),
    ask('O paciente apresenta dor intensa localizada?', dor_intensa_localizada).

ask(Question, Fact) :-
    format('~w? ', [Question]),
    read(Response),
    retractall(fact(Fact eq _)), % Remove qualquer fato existente para a mesma condição

    assertz(fact(Fact eq Response)).

determine_triagem :-
    (demo(vermelha, _) -> write('Nivel: Vermelha'), nl;
     demo(laranja, _) -> write('Nivel: Laranja'), nl;
     demo(amarela, _) -> write('Nivel: Amarela'), nl;
     demo(verde, _) -> write('Nivel: Verde'), nl;
     demo(azul, _) -> write('Nivel: Azul'), nl;
     write('Sem nível, tente novamente.'), nl).