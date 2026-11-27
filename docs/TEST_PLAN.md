# Reproduzir a validação

Execute `bash tests/run.sh` a partir de uma cópia de trabalho com Godot 4.7.2. O script usa diretório temporário para os dados do jogador. O teste das regras verifica os alvos do mapa, o alcance, estágios de cultivo, bloqueio de retirada simultânea, receitas, rotina escolar, depósito, feira, misturas, salvamento e recuperação de arquivo inválido.

A suíte de rede abre um processo anfitrião e convidados ENet reais em loopback. Repete a disputa pela colheita em sessões de dois e quatro participantes. Verifica a carga após a desconexão, a recusa da senha incorreta, a reentrada com a senha correta e o estado após nova conexão.

Em sessão gráfica, execute `godot --script res://tests/visual.gd -- --test`. O roteiro exercita as ações do cenário, posicionando o personagem nos pontos de teste e adiantando o relógio para capturar colheita, refeição, interior e caderno. Para verificar o controle manual, inicie a cena normalmente.
